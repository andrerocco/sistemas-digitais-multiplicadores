library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity multiplicador_deslocamento is
generic(
	N : integer := 4;
	CONTADOR : integer := 3
	);
port(
   HEX0, HEX1: out std_logic_vector(6 downto 0); -- Sinaliza o estado

	CLK: in std_logic;
	INICIAR, RESET: in std_logic;
	PRONTO: out std_logic;
	
	NUM_A, NUM_B: in std_logic_vector(N-1 downto 0);
	
	RESULTADO: out std_logic_vector((N*2)-1 downto 0)
	);
end multiplicador_deslocamento;

architecture rtl of multiplicador_deslocamento is
    
    component somador_overflow is 
        generic(N : integer );
        port (
            A, B : std_logic_vector(N-1 downto 0);
	         Cout : out std_logic;
            RESULTADO : out std_logic_vector(N-1 downto 0)
            );
    end component;
    
    
    -- Estados
    type STATES is (S0, S1, S2, S3, S4, S5, S6);
    signal EstadoAtual, ProximoEstado: STATES := S0; -- O sistema começa no estado S0
    
    -- Sinais
    signal reg_mult: std_logic_vector((N*2)-1 downto 0) := (others => '0');
    
    signal A, B: std_logic_vector(N-1 downto 0);
    signal P: std_logic_vector((N*2)-1 downto 0);
    signal reg_cont: std_logic_vector(CONTADOR-1 downto 0);
    signal status_pronto: std_logic;
    
    signal Zero_AB: std_logic_vector(N-1 downto 0) := (others => '0'); -- Zero em binário com a quantidade de bits de A e B
    signal Zero_CONT: std_logic_vector(CONTADOR-1 downto 0) := (others => '0'); -- Zero em binário com a quantidade de bits de reg_cont

    signal overflow, overflow_capturado: std_logic := '0';
    signal reg_soma: std_logic_vector(N-1 downto 0); 

begin
    
    SOMA: somador_overflow 
	 generic map ( N => 4 )
	 port map (
        A => P((N*2)-1 downto N), B => B,
        Cout => overflow,
        RESULTADO => reg_soma
    );
    
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
                reg_cont <= std_logic_vector(to_unsigned(CONTADOR, reg_cont'length));
                
                
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
                        -- Se "pular" o estado S4, o valor que deve ser colocado na entrada do shift de P
                        -- deve ser zero, pois nâo ocorreu a soma. Como nesse sistema a soma ocorre de qualquer forma
                        -- no componente "somador_overflow", se entrar nesse if, deve-se sobrepor qualquer possível overflow
                        -- que estará armazenado no sinal "overflow" (é oveflow do componente).
                        overflow_capturado <= '0';
                    end if;
                end if;
                
                reg_mult <= P;
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1001111");
            
            when S4 =>
                -- Lógica do estado
                ProximoEstado <= S5;
                
                -- Operações
                P((N*2)-1 downto N) <= reg_soma;
                overflow_capturado <= overflow;
                
                reg_mult <= P;
                
                
                HEX0 <= "0010010";
                HEX1 <= not("1100110");
            
            when S5 =>
                -- Lógica do estado
                ProximoEstado <= S3;
                
                -- Operações
                A <= '0' & A(N-1 downto 1); -- Desloca A para direita em 1 bit
                P <= overflow_capturado & P((N*2)-1 downto 1); -- Desloca P para direita em 1 bit
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