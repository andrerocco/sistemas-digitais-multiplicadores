library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftregister is
    -- generic( N: natural := 4 );
    port(
        clk: in  std_logic;
        carga: in std_logic_vector(3 downto 0);
        enable_carga: in std_logic;
        enable_shift_right: in  std_logic;
        serial_input: in  std_logic; -- Valor que entra no registrador quando há deslocamento para a direita
        serial_output: out std_logic; -- Valor que saí do registrador quando há deslocamento para a direita
        valor_atual: out std_logic_vector(3 downto 0) -- Recebe o valor que está armazenado dentro do registrador
    );
end shiftregister;

architecture bhv of shiftregister is
    
    signal reg : std_logic_vector(3 downto 0) := (others => '0'); -- Registra o valor atual armazenado
    
begin
    main_process : process(clk) is
    begin
        if rising_edge(clk) then
        
            if (enable_carga = '1') then
                reg <= carga;
            elsif (enable_shift_right = '1') then
                reg <= serial_input & reg(3 downto 1); --Shift para a direita
                serial_output <= reg(0); -- Valor que "saiu" do registrador com o shift
            else
                reg <= reg;
            end if;
        
        end if;
    end process main_process;
    
    valor_atual <= reg;
end bhv;