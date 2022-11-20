library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplicador is
-- generic( N: integer =: 4 );
port(
    CLK: in std_logic;

    NUM_A, NUM_B: in std_logic_vector(3 downto 0);
    INICIAR: in std_logic;
    RESET: in std_logic;
    
    RESULTADO: out std_logic_vector(7 downto 0);
    PRONTO: out std_logic
	);
end multiplicador;

architecture rtl of multiplicador is

    -- Estados
    type STATES is (S0, S1, S2, S3, S4, S5, S6);
    signal EstadoAtual, ProximoEstado: STATES := S0; -- O sistema começa no estado S0
    
    -- Sinais
    signal A, B: std_logic_vector(3 downto 0);
    signal cont: std_logic_vector(3 downto 0);
    signal P: std_logic_vector(7 downto 0);

begin
    
    process(CLK, RESET)
    begin
        if reset = '1' then
            EstadoAtual <= S0;
        elsif (clk'event and clk = '1') then
            EstadoAtual <= ProximoEstado;
        end if;
    end process;
    
    process(EstadoAtual, INICIAR)
    begin
    
        case EstadoAtual is
        
            when S0 =>
                -- Lógica do estado
                if (INICIAR = '1') then
                    ProximoEstado <= S1;
                else
                    ProximoEstado <= S0;
                end if;
                
                -- Operações
                PRONTO <= '1';
            
            when S1 =>
                -- Lógica do estado
                ProximoEstado <= S2;
                
                -- Operações
                PRONTO <= '0';
                
                A <= NUM_A; -- Copia os número A da entrada
                B <= NUM_B; -- Copia os número B da entrada
                P <= (others => '0'); -- 0 em binário
                cont <= "0100"; -- 4 em binário
                
            when S2 =>
                -- Lógica do estado
                if ((A = "0000") or (B = "0000")) then
                    ProximoEstado <= S6;
                else
                    ProximoEstado <= S3;
                end if;
                
            when S3 =>
                -- Lógica do estado
                if (cont = "0000") then
                    ProximoEstado <= S6;
                elsif (not(cont = "0000") and A(0)='1') then
                    ProximoEstado <= S4;
                elsif (not(cont = "0000") and A(0)='0') then
                    ProximoEstado <= S5;
                end if;
                
            when S4 =>
                -- Lógica do estado
                ProximoEstado <= S5;
                
                -- Operações
                
                -- Parte alta de P recebe a soma dela com B
                P(7 downto 4) <= std_logic_vector( unsigned( P(7 downto 4) ) + unsigned(B) );
                
            when S5 =>
                -- Lógica do estado
                ProximoEstado <= S3;
                
                -- Operações
                P <= '0' & P(7 downto 1); -- Desloca P para a direta em 1 bit
                A <= '0' & A(3 downto 1); -- Desloca A para a direta em 1 bit
                cont <= std_logic_vector( unsigned(cont) - 1 ); -- Subtrai 1 de cont
                
            when S6 =>
                -- Lógica do estado
                ProximoEstado <= S0;
                
                -- Operações
                RESULTADO <= P;
        
        end case;
    
    end process;

end rtl;