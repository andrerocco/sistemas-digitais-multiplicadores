library ieee;
use ieee.std_logic_1164.all;

entity usertop is
    generic (N: integer := 8);
    port (
        CLK: in std_logic;
        A, B: in std_logic_vector(N-1 downto 0); -- Números que vão ser multiplicados
        RESET, INICIAR: in std_logic; -- Entradas de controle
        PRONTO: out std_logic; -- Saída de controle
        RESULTADO: out std_logic_vector(N-1 downto 0) -- Saída de dados
    );
end usertop;

architecture rtl of usertop is

    component control is
        port(
            CLK: in std_logic;
            RESET, INICIAR: in std_logic; -- Entradas de controle
            Azero, Bzero: in std_logic; -- Sinais de status (recebidos do Datapath)
            SIG1, SIG2, SIG3: out std_logic; -- Sinais de controle (enviados para o Datapath)
            PRONTO: out std_logic -- Saída de controle
        );
    end component;

    component datapath is
		  generic ( N: integer := 8 );
        port(
            CLK: in std_logic;
            NUMA, NUMB: in std_logic_vector(N-1 downto 0); -- Números que vão ser multiplicados (Entradas de dados)
            SIG1, SIG2, SIG3: in std_logic; -- Sinais de controle (mP, cP, mA, cA, cB, cmult) onde
                                            -- (mP = mA = cB) é SIG1; (cP = cA) é SIG2; (cmult) é SIG3
            RESULTADO: out std_logic_vector(N-1 downto 0); -- Saída de dados
            Az, Bz: out std_logic -- Sinais de status
        );
    end component;

    signal controle1, controle2, controle3: std_logic; -- Sinais de controle
    signal status_Az, status_Bz: std_logic; -- Sinais de status

begin
    
    BLOCOCONTROL: control port map (CLK => CLK,
                                    RESET => RESET, INICIAR => INICIAR,
                                    Azero => status_Az, Bzero => status_Bz,
                                    SIG1 => controle1, SIG2 => controle2, SIG3 => controle3,
                                    PRONTO => PRONTO );

    BLOCODATAPATH: datapath port map (CLK => CLK,
                                      NUMA => A, NUMB => B,
                                      SIG1 => controle1, SIG2 => controle2, SIG3 => controle3,
                                      RESULTADO => RESULTADO,
                                      Az => status_Az, Bz => status_Bz );

end rtl;
