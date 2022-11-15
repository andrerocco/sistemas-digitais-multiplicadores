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
            
        );
    end component;
    
    component control is
        port(
            
        );
    end component;

begin

    

end rtl;
