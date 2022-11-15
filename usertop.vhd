library ieee;
use ieee.std_logic_1164.all;

entity usertop is
    -- generic (N: integer := 8);
    port (
        A, B: in std_logic_vector(7 downto 0); -- Números que vão ser multiplicados
        RESET, INICIAR: in std_logic; -- Entradas de controle
        PRONTO: out std_logic; -- Saída de controle
        RESULTADO: out std_logic -- Saída de dados
    );
end usertop;

architecture rtl of usertop is

    component datapath is
        port(
            CLK: in std_logic;
            A, B: in std_logic_vector(7 downto 0); -- Números que vão ser multiplicados (Entradas de dados)
            SIG1, SIG2, SIG3: in std_logic; -- Sinais de controle (mP, cP, mA, cA, cB, cmult) onde
                                            -- (mP = mA = cB) é SIG1; (cP = cA) é SIG2; (cmult) é SIG3
            RESULTADO: out std_logic_vector(7 downto 0); -- Saída de dados
            Az, Bz: out std_logic -- Sinais de status
        );
    end component;
    
    component control is
        port(
            CLK: in std_logic;
            RESET, INICIAR: in std_logic; -- Entradas de controle
            Azero, Bzero: in std_logic; -- Sinais de status (recebidos do Datapath)
            SIG1, SIG2, SIG3: out std_logic; -- Sinais de controle (enviados para o Datapath)
            PRONTO: out std_logic -- Saída de controle
        );
    end component;

type STATES is (S0, S1, S2, S3, S4) -- Todos os estados da FSM
signal EAtual, PEstado: STATES;

begin

process(CLK, RESET) -- Sensitivity list
begin
    if (RESET = '1') then
        PEstado <= S0;
    elsif (CLK'event and CLK = '1') then
        PEstado <= EAtual;
    end if;
end process;

process(EAtual, INICIAR) -- Sensitivy list lógica PEstado
    begin
        case EAtual is
            when S0 =>
                PRONTO <= '1';
                if (INICIAR = '1') then
                    EAtual <= S1;
                end if;
            when S1 =>
                PRONTO <= '0';
                SIG1 <= '1';
                SIG2 <= '1';
                SIG3 <= '0';
                EAtual <= S2;
            when S2 =>
                if (Azero = '0' and Bzero = '0') then
                    EAtual <= S3;
                else
                    EAtual <= S4;
                end if;
            when S3 =>
                SIG1 <= '0';
                SIG2 <= '1';
                Eatual <= S2;
            when S4 =>
                SIG3 <= '1';
                EAtual <= S0;
        end case;
    end process;
end rtl;
