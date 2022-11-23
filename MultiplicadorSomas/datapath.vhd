library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    generic (N: integer);
    port (
        CLK: in std_logic;
        NUMA, NUMB: in std_logic_vector(N-1 downto 0); -- Números que vão ser multiplicados (Entradas de dados)
        SIG1, SIG2, SIG3: in std_logic; -- Sinais de controle (mP, cP, mA, cA, cB, cmult) onde
                                        -- (mP = mA = cB) é SIG1; (cP = cA) é SIG2; (cmult) é SIG3
        RESULTADO: out std_logic_vector(N-1 downto 0); -- Saída de dados
        Az, Bz: out std_logic -- Sinais de status
    );
end datapath;

architecture rtl of datapath is

    -- COMPONENTES
    component mux2para1 is
		  generic (N: integer);
        port(
            a, b: in std_logic_vector(N-1 downto 0);
            sel: in std_logic;
            y: out std_logic_vector(N-1 downto 0)
        );
    end component;
    
    component somadorsubtrator is
	     generic (N: integer);
        port(
				a, b: in std_logic_vector(N-1 downto 0);
				op: in std_logic;
				s: out std_logic_vector(N-1 downto 0)
        );
    end component;

    component igualazero is
		  generic (N: integer);
        port(
            a: in std_logic_vector(N-1 downto 0);
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

    signal sai_somador, sai_mux1, sai_regP, sai_regB: std_logic_vector(N-1 downto 0);
    signal sai_subtrator, sai_mux2, sai_regA: std_logic_vector(N-1 downto 0);
	 signal zero: std_logic_vector(N-1 downto 0) := (others => '0');
	 signal um: std_logic_vector(N-1 downto 0) := std_logic_vector(to_unsigned(1, N));

begin

    -- MULTIPLICAÇÂO (ESQUERDA DO CIRCUITO)

    MUX1: mux2para1 generic map ( N => N )
						  port map (a => sai_somador, b => zero,
                              sel => SIG1, y => sai_mux1 );
    
    REG_P: registrador generic map ( N => N )
							  port map (clk => clk, carga => SIG2,
                                 d => sai_mux1, q => sai_regP );
    
    REG_MULT: registrador generic map ( N => N )
								  port map (clk => clk, carga => SIG3,
                                    d => sai_regP, q => RESULTADO );

    REG_B: registrador generic map ( N => N )
							  port map (clk => clk, carga => SIG1,
                                 d => NUMB, q => sai_regB );
    
    GERA_Bz: igualazero generic map ( N => N )
								port map (a => sai_regB, igual => Bz );
    
    SOMA: somadorsubtrator generic map ( N => N )
									port map (a => sai_regP, b => sai_regB,
                                     op => '0', s => sai_somador);
    
    -- CONTAGEM DE MULTIPLICAÇÕES (DIREITA DO CIRCUITO)

    MUX2: mux2para1 generic map ( N => N )
						  port map (a => sai_subtrator, b => NUMA,
                              sel => SIG1, y => sai_mux2 );
	
	REG_A: registrador generic map ( N => N )
							 port map (clk => clk, carga => SIG2,
                                d => sai_mux2, q => sai_regA );
	
	GERA_Az: igualazero generic map ( N => N )
							  port map (a => sai_regA, igual => Az );
	
	SUB: somadorsubtrator generic map ( N => N )
								 port map (a => sai_regA, b => um,
                                   op => '1', s => sai_subtrator);

end rtl;