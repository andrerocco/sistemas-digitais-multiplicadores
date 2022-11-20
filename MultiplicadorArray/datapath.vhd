library ieee;
use ieee.std_logic_1164.all;

entity datapath is
    -- generic (N: integer := 8);
    port (
        CLK: in std_logic;
        NUMA, NUMB: in std_logic_vector(3 downto 0); -- Números que vão ser multiplicados (Entradas de dados)
        
        RESULTADO: out std_logic_vector(3 downto 0); -- Saída de dados
        Az, Bz, CONTz: out std_logic; -- Sinais de status
        UltimoBitA: out std_logic; -- Sinal de status
        
        SIG1, SIG2, ccont, cmult, cPH: in std_logic -- Sinais de controle (enviados do Bloco de Controle)
                                                     -- (mPH = cPL = cB = cA = mCONT = mFF) é SIG1
                                                     -- (srPH = srPL = srA0) é SIG2
    );
end datapath;

architecture rtl of datapath is

    -- COMPONENTES
    component mux2para1 is -- Esse componente deve usar "generic map" quando for instanciado
        generic (N: integer);
        port(
            a, b: in std_logic_vector(N-1 downto 0); --(N-1 downto 0)
            sel: in std_logic;
            y: out std_logic_vector(N-1 downto 0) --(N-1 downto 0)
        );
    end component;

    component igualazero is
        port(
            a: in std_logic_vector(3 downto 0); --(N-1 downto 0)
            igual: out std_logic
        );
    end component;
    
    component registrador is
        generic (N: integer);
        port(
            clk, carga: in std_logic;
		    d: in std_logic_vector(N-1 downto 0);
		    q: out std_logic_vector(N-1 downto 0)
        );
    end component;

    -- COMPONENTES DIFERENTES DO MULTIPLICADOR POR SOMAS
    
    component somadoroverflow is
        port(
            a, b: in std_logic_vector(3 downto 0); --(N-1 downto 0)
            cin: in std_logic;
		    s: out std_logic_vector(3 downto 0); --(N-1 downto 0)
            cout: out std_logic
        );
    end component;

    component subtrator is
        port(
            a, b: in std_logic_vector(3 downto 0); --(N-1 downto 0)
            s: out std_logic_vector(3 downto 0) --(N-1 downto 0)
        );
    end component;

    component flipflop is
        port(
            clk: in std_logic;
            d: in std_logic;
            q: out std_logic
        );
    end component;

    component shiftregister is
        port(
            clk: in  std_logic;
            carga: in std_logic_vector(3 downto 0);
            enable_carga: in std_logic;
            enable_shift_right: in  std_logic;
            serial_input: in  std_logic; -- Valor que entra no registrador quando há deslocamento para a direita
            serial_output: out std_logic; -- Valor que saí do registrador quando há deslocamento para a direita
            valor_atual: out std_logic_vector(3 downto 0) -- Recebe o valor que está armazenado dentro do registrador
        );
    end component;
    
    component mux2para1_1bit is
        port(
            a, b: in std_logic;
            sel: in std_logic;
            y: out std_logic
        );
    end component;

    --signal sai_soma, sai_mux1, entra_reg_MULT, sai_reg_MULT, sai_mux2, sai_sub, sai_shift, sai_reg_A, sai_reg_B: std_logic_vector(3 downto 0);

    -- Parte 1 do circuito
    signal sai_soma, sai_mux1, sai_shiftPH, sai_shiftPL, sai_regB: std_logic_vector(3 downto 0);
    signal entra_reg_MULT: std_logic_vector(7 downto 0);
    signal sai_cout, sai_muxFF, sai_flipflop, sai_serialPH, sai_serialPL: std_logic;

    -- Parte 2 do circuito
    signal sai_subtrator, sai_mux2, sai_regCONT: std_logic_vector(3 downto 0); -- (2 downto 0)
    
    -- Parte 3 do circuito
    signal sai_shiftA: std_logic_vector(3 downto 0);
    signal sai_serialA: std_logic;

begin

    MUX1: mux2para1 generic map ( N => 4 )
                    port map (
        a => sai_soma, b => "0000",
        sel => SIG1, --SINAL DE SELEÇÃO mPH
        y => sai_mux1
    );
    
    SHIFT_PH: shiftregister port map (
        clk => clk,
        carga => sai_mux1,
        enable_carga => cPH, --SINAL DE SELEÇÃO cPH
        enable_shift_right => SIG2, --SINAL srPH
        serial_input => sai_flipflop,
        serial_output => sai_serialPH,
        valor_atual => sai_shiftPH
    );

    SHIFT_PL: shiftregister port map (
        clk => clk,
        carga => "0000",
        enable_carga => SIG1, --SINAL DE SELEÇÃO cPL
        enable_shift_right => SIG2, --SINAL srPL
        serial_input => sai_serialPH,
        serial_output => sai_serialPL,
        valor_atual => sai_shiftPL
    );

    entra_reg_MULT <= sai_shiftPH & sai_shiftPL; -- Concatenação dos valores de saída do shift register PH e PL
    
    REG_MULT: registrador generic map ( N => 8 )
                          port map (
        clk => CLK, carga => cmult, --SINAL DE SELEÇÃO cmult
        d => entra_reg_MULT,
        q => RESULTADO
    );
    
    SOMA: somadoroverflow port map(
        a => sai_shiftPH, b => sai_regB,
        cin => '0',
        s => sai_soma,
        cout => sai_cout
    );

    MUX_FF: mux2para1_1bit port map (
        a => sai_cout, b => '0',
        sel => SIG1, --SINAL DE SELEÇÃO mFF
        y => sai_muxFF
    );

    REG_FF: flipflop port map (
        clk => CLK,
        d => sai_muxFF,
        q => sai_flipflop
    );

    REG_B : registrador generic map ( N => 4 )
                        port map(
        clk => CLK, carga => SIG1, -- SINAL DE SELEÇÃO cB
        d => NUMB,
        q => sai_regB
    );

    GERA_Bz : igualazero port map(
        a => sai_regB,
        igual => Bz
    );

    -- Segunda parte do bloco operativo

    MUX2: mux2para1 generic map ( N => 4 )
                    port map(
        a => sai_subtrator, b => "1000", -- TEM QUE SER O TAMANHO DE A EM BINÁRIO
        sel => SIG1, -- SINAL DE SELEÇÃO mcont
        y => sai_mux2
    );

    REG_CONT: registrador generic map ( N => 4 )
                          port map(
        clk => CLK, carga => ccont, -- SINAL DE CONTROLE ccont
        d => sai_mux2,
        q => sai_regCONT
    );

    GERA_CONTz: igualazero port map(
        a => sai_regCONT,
        igual => Az
    );

    SUBTRACAO: subtrator port map (
        a => sai_regCONT, b => "0001", -- NUMERO 1 COM O TAMANHO CERTO DE BITS
        s => sai_subtrator
    );

    -- Terceira parte do bloco operativo

    SHIFT_A: shiftregister port map(
        clk => clk,
        carga => NUMA,
        enable_carga => SIG1, -- SINAL DE CONTROLE cA
        enable_shift_right => SIG2, -- SINAL DE CONTROLE srA
        serial_input => '0',
        serial_output => sai_serialA,
        valor_atual => sai_shiftA
    );

    UltimoBitA <= sai_shiftA(0);

    GERA_Az: igualazero port map(
        a => sai_shiftA,
        igual => Az
    );

end rtl;