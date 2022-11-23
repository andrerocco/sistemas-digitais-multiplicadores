library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all; 

entity multiplicador is
port(
    HEX0, HEX1: out std_logic_vector(6 downto 0);


	CLK: in std_logic;
	INICIAR, RESET: in std_logic;
	PRONTO: out std_logic;
	
	NUM_A, NUM_B: in std_logic_vector(3 downto 0);
	
	RESULTADO: out std_logic_vector(7 downto 0)
	);
end multiplicador;

architecture rtl of multiplicador is
    
    -- Estados
    type STATES is (S0, S1, S2, S3, S4, S5, S6);
    signal EstadoAtual, ProximoEstado: STATES := S0; -- O sistema começa no estado S0
    
    -- Sinais
    signal reg_mult: std_logic_vector(7 downto 0) := "11111111";
    
    signal A, B: std_logic_vector(3 downto 0);
    signal P: std_logic_vector(7 downto 0);
    signal reg_cont: std_logic_vector(2 downto 0);
    signal status_pronto: std_logic;
    
    signal Zero_AB: std_logic_vector(3 downto 0) := (others => '0'); -- Zero em binário com a quantidade de bits de A e B
    signal Zero_CONT: std_logic_vector(2 downto 0) := (others => '0'); -- Zero em binário com a quantidade de bits de reg_cont

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
                status_pronto <= '1';
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1111110");
                
            when S1 =>
                -- Lógica do estado
                ProximoEstado <= S2;
                
                -- Operações
                status_pronto <= '0';
                
                A <= NUM_A; -- Copia os número A da entrada
                B <= NUM_B; -- Copia os número B da entrada
                P <= (others => '0'); -- 0 em binário
                reg_cont <= "100";
                
                
                HEX0 <= "0010010";
                HEX1 <= not("0000110");
            
            when S2 =>
                -- Lógica do estado
                if ( (A = Zero_AB) or (B = Zero_AB) ) then
                    ProximoEstado <= S6;
                else
                    ProximoEstado <= S3;
                end if;
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1011011");
                
            when S3 =>
                -- Lógica do estado
                if ( reg_cont = Zero_CONT ) then
                    ProximoEstado <= S6;
                else
                    if ( A(0) = '1' ) then
                        ProximoEstado <= S4;
                    elsif ( A(0) = '0' ) then
                        ProximoEstado <= S5;
                    end if;
                end if;
                
                reg_mult <= P;
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1001111");
            
            when S4 =>
                -- Lógica do estado
                ProximoEstado <= S5;
                
                -- Operações
                P(7 downto 4) <= P(7 downto 4) + B; -- Soma PH (parte alta de P) com B
                
                reg_mult <= P;
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1100110");
            
            when S5 =>
                -- Lógica do estado
                ProximoEstado <= S3;
                
                -- Operações
                A <= '0' & A(3 downto 1); -- Desloca A para direita em 1 bit
                P <= '0' & P(7 downto 1); -- Desloca P para direita em 1 bit
                reg_cont <= reg_cont - 1 ; -- Subtrai 1 do contador
                
                reg_mult <= P;
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1101101");
            
            when S6 =>
                ProximoEstado <= S0;
                
                reg_mult <= P;
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1111101");
        
        end case;
        
    end process;
    
    PRONTO <= status_pronto;
    RESULTADO <= reg_mult;

end rtl;