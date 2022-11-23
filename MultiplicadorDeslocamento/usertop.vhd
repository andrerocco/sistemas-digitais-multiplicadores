library ieee;
use ieee.std_logic_1164.all;

entity usertop is
    -- generic (N: integer := 4);
    port (
        CLK: in std_logic;
        A, B: in std_logic_vector(3 downto 0); -- Números que vão ser multiplicados
        RESET, INICIAR: in std_logic; -- Entradas de controle
        PRONTO: out std_logic; -- Saída de controle
        RESULTADO: out std_logic_vector(3 downto 0) -- Saída de dados
    );
end usertop;

architecture rtl of usertop is

    component control is
        port(
            CLK: in std_logic;
            RESET, INICIAR: in std_logic; -- Entradas de controle
            Azero, Bzero, CONTz: in std_logic; -- Sinais de status (recebidos do Datapath)
            UltimoBitA: in std_logic; -- Sinal de status (recebido do Datapath)
            PRONTO: out std_logic; -- Saída de controle
            SIG1, SIG2, ccont, cmult, cPH: out std_logic -- Sinais de controle (enviados para o Datapath)
        );
    end component;

    component datapath is
        port(
            CLK: in std_logic;
            NUMA, NUMB: in std_logic_vector(3 downto 0); -- Números que vão ser multiplicados (Entradas de dados)
            RESULTADO: out std_logic_vector(3 downto 0); -- Saída de dados
            Az, Bz, CONTz: out std_logic; -- Sinais de status
            UltimoBitA: out std_logic; -- Sinal de status
            SIG1, SIG2, ccont, cmult, cPH: in std_logic -- Sinais de controle (enviados do Bloco de Controle)
                                                     -- (mPH = cPL = cB = cA = mCONT = mFF) é SIG1
                                                     -- (srPH = srPL = srA0) é SIG2
        );
    end component;

    signal controle_SIG1, controle_SIG2, controle_ccont, controle_cmult, controle_cPH: std_logic; -- Sinais de controle
    signal status_Az, status_Bz, status_CONTz, status_UltimoBitA: std_logic; -- Sinais de status

begin
    
    BLOCOCONTROL: control port map (
        CLK => CLK,
        RESET => RESET, INICIAR => INICIAR,
        Azero => status_Az, Bzero => status_Bz, CONTz => status_CONTz,
        UltimoBitA => status_UltimoBitA,
        PRONTO => PRONTO,
        SIG1 => controle_SIG1, SIG2 => controle_SIG2, ccont => controle_ccont, cmult => controle_cmult, cPH => controle_cPH
    );

    BLOCODATAPATH: datapath port map (
        CLK => CLK,
        NUMA => A, NUMB => B,
        RESULTADO => RESULTADO,
        Az => status_Az, Bz => status_Bz, CONTz => status_CONTz,
        UltimoBitA => status_UltimoBitA,
        SIG1 => controle_SIG1, SIG2 => controle_SIG2, ccont => controle_ccont, cmult => controle_cmult, cPH => controle_cPH
    );

end rtl;