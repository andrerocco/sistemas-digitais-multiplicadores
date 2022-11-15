library ieee;
use ieee.std_logic_1164.all;

entity datapath is
    -- generic (N: integer := 8);
    port (
        CLK: in std_logic;
        A, B: in std_logic_vector(7 downto 0); -- Números que vão ser multiplicados (Entradas de dados)
        SIG1, SIG2, SIG3: in std_logic; -- Sinais de controle (mP, cP, mA, cA, cB, cmult) onde
                                        -- (mP = mA = cB) é SIG1; (cP = cA) é SIG2; (cmult) é SIG3
        RESULTADO: out std_logic_vector(7 downto 0); -- Saída de dados
        Az, Bz: out std_logic -- Sinais de status
    );
end datapath;

architecture rtl of datapath is

    -- COMPONENTES
    component mux2para1 is
        port(
            a, b: in std_logic_vector(3 downto 0); --(N-1 downto 0)
            sel: in std_logic;
            y: out std_logic_vector(3 downto 0) --(N-1 downto 0)
        );
    end component;
    
    component somadorsubtrator is
        port(
            a, b: in std_logic_vector(3 downto 0); --(N-1 downto 0)
		    op: in std_logic;
		    s: out std_logic_vector(3 downto 0) --(N-1 downto 0)
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
		    q: out std_logic_vector(3 downto 0)
        );
    end component;

	signal saimux1, saimux2, saimux3, sairegP, sairegA, sairegB, saisomasub: std_logic_vector(3 downto 0); --(N-1 downto 0)

begin

    --MUX1: mux2para1 port map ( );
	--REG_P: registrador_r port map ( );
	--REG_A: registrador port map ( );
	--REG_B: registrador port map ( );
	--MUX2: mux2para1 port map ( );	
	--MUX3: mux2para1 port map ( );
	--SOMA_SUB: somadorsubtrator port map ( );
	--GERA_Az: igualazero port map ( );
	--GERA_Bz: igualazero port map ( );	
	
	--saida <= sairegP;
	--conteudoA <= sairegA;
	--conteudoB <= sairegB;

end rtl;
