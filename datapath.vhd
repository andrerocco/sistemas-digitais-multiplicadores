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

begin

end rtl;
