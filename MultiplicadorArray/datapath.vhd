library ieee;
use ieee.std_logic_1164.all;

entity datapath is
    -- generic (N: integer := 8);
    port (
        CLK: in std_logic;
        NUMA, NUMB: in std_logic_vector(3 downto 0); -- Números que vão ser multiplicados (Entradas de dados)
        --SIG1, SIG2, SIG3: in std_logic; -- Sinais de controle (mP, cP, mA, cA, cB, cmult) onde
                                        -- (mP = mA = cB) é SIG1; (cP = cA) é SIG2; (cmult) é SIG3
        RESULTADO: out std_logic_vector(3 downto 0); -- Saída de dados
        Az, Bz: out std_logic -- Sinais de status
        UltimoBitA: out std_logic; -- Sinal de status
    );
end datapath;

architecture rtl of datapath is

    -- COMPONENTES
    component mux2para1 is -- Esse componente deve usar "generic map" quando for instanciado
        port(
            a, b: in std_logic_vector(3 downto 0); --(N-1 downto 0)
            sel: in std_logic;
            y: out std_logic_vector(3 downto 0) --(N-1 downto 0)
        );
    end component;

    component igualazero is
        port(
            a: in std_logic_vector(3 downto 0); --(N-1 downto 0)
            igual: out std_logic
        );
    end component;
    
    component registrador is
        port(
            clk, carga: in std_logic;
		    d: in std_logic_vector(3 downto 0); --(N-1 downto 0)
		    q: out std_logic_vector(3 downto 0) --(N-1 downto 0)
        );
    end component;

    -- COMPONENTES DIFERENTES DO MULTIPLICADOR POR SOMAS
    
    component somadoroverflow is
        port(
            a, b: in std_logic_vector(3 downto 0); --(N-1 downto 0)
		    s: out std_logic_vector(3 downto 0) --(N-1 downto 0)
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
            carga: in std_logic_vector(N-1 downto 0);
            enable_carga: in std_logic;
            enable_shift_right: in  std_logic;
            serial_input: in  std_logic; -- Valor que entra no registrador quando há deslocamento para a direita
            serial_output: out std_logic; -- Valor que saí do registrador quando há deslocamento para a direita
            valor_atual: out std_logic_vector(N-1 downto 0) -- Recebe o valor que está armazenado dentro do registrador
        );
    end component;

    signal sai_soma, sai_mux1, entra_reg_MULT, sai_reg_MULT, sai_mux2, sai_sub, sai_shift, sai_reg_A, sai_reg_B: std_logic_vector(3 downto 0);

begin

    MUX1: mux2para1 generic map ( N => 4 )
                    port map (
        a => sai_soma, b => "0000",
        sel => --SINAL DE SELEÇÃO mPH,
        y => sai_mux1
    );
    
    SHIFT_PH: shiftregister port map (
        clk => clk,
        carga => sai_mux1,
        enable_carga => --SINAL DE SELEÇÃO H,
        enable_shift_right => --SINAL srP,
        serial_input => sai_flipflop,
        serial_output => sai_serialPH,
        valor_atual => sai_shiftPH
    );

    SHIFT_PL: shiftregister port map (
        clk => clk,
        carga => "0000",
        enable_carga => --SINAL DE SELEÇÃO cPL,
        enable_shift_right => --SINAL srPL,
        serial_input => sai_serialPH,
        serial_output => sai_serialPL,
        valor_atual => sai_shiftPL
    );

    entra_reg_MULT <= sai_PH & sai_PL
    
    REG_MULT: registrador port map (
        clk => CLK, carga => --SINAL DE SELEÇÃO cmult,
        d => entra_reg_MULT,
        q => RESULTADO
    );
    
    SOMA: somadoroverflow port map(
        a => sai_ph, b => sai_regB,
        cin => '0',
        s => sai_soma,
        cout => sai_cout
    );

    MUX_FF: mux2para1 generic map (N => 1)
                     port map (
        a => sai_cout, b => "0",
        sel => --SINAL DE SELEÇÃO mFF,
        y => sai_muxFF
    );

    REG_FF: flipflop port map (
        clk => CLK,
        d => sai_muxFF,
        q => sai_flipflop
    );

    REG_B : registrador port map(
        clk => CLK, carga => -- SINAL DE SELEÇÃO cB,
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
        a => sai_subtrator, b => -- TEM QUE SER O TAMANHO DE A EM BINÁRIO,
        sel => -- SINAL DE SELEÇÃO mcont,
        y => sai_mux2
    )

    REG_CONT: registrador port map(
        clk => CLK, carga => -- SINAL DE CONTROLE ccont,
        d => sai_mux2,
        q => sai_regCONT
    )

    GERA_CONTz: igualazero port map(
        a => sai_regCONT,
        igual => Az
    );

    SUBTRACAO: subtrator port map (
        a => sai_regCONT, b => -- NUMERO 1 COM O TAMANHO CERTO DE BITS,
        s => sai_subtrator
    );

    -- Terceira parte do bloco operativo

    SHIFT_A: shiftregister port map(
        clk => clk; 
        carga => NUMA,
        enable_carga => /* SINAL DE CONTROLE cA */,
        enable_shift_right => /* srA */,
        serial_input => '0',
        serial_output => sai_serialA,
        valor_atual => sai_shiftA
    );

    UltimoBitA <= sai_shift(0);

    GERA_Az: igualazero port map(
        a => sai_shiftA,
        igual => Az
    );

end rtl;
