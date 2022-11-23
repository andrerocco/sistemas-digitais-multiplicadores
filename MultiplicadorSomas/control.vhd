library ieee;
use ieee.std_logic_1164.all;

entity control is
    port (
        CLK: in std_logic;
        RESET, INICIAR: in std_logic; -- Entradas de controle
        Azero, Bzero: in std_logic; -- Sinais de status (recebidos do Datapath)
        SIG1, SIG2, SIG3: out std_logic; -- Sinais de controle (enviados para o Datapath)
        PRONTO: out std_logic -- Saída de controle
    );
end control;

architecture rtl of control is
    type STATES is (S0, S1, S2, S3, S4);
    signal EstadoAtual, ProximoEstado: STATES := S0; -- O sistema começa no estado S0
begin

    process(CLK, RESET)
    begin
    
        if reset = '1' then
            EstadoAtual <= S0;
        elsif (clk'event and clk = '1') then
            EstadoAtual <= ProximoEstado;
        end if;
    
    end process;

    process(EstadoAtual, INICIAR, Azero, Bzero)
    begin
    
        case EstadoAtual is
        
            when S0 =>
                if INICIAR = '1' then
                    ProximoEstado <= S1; -- Vai para o estado S1
                else
                    ProximoEstado <= S0; -- Fica no estado S0
                end if;
                
                PRONTO <= '1';
                SIG1 <= '0'; -- (mP = mA = cB)
                SIG2 <= '0'; -- (cP = cA)
                SIG3 <= '0'; -- (cmult)
            
            when S1 =>
                ProximoEstado <= S2; -- Vai para o estado S2 sem condições
                
                PRONTO <= '0';
                SIG1 <= '1'; -- (mP = mA = cB)
                SIG2 <= '1'; -- (cP = cA)
                SIG3 <= '0'; -- (cmult)
                
            when S2 =>
                if ( (Azero = '0') and (Bzero = '0') ) then -- Se não tiver acabado a multiplicação
                    ProximoEstado <= S3; -- Vai para S3
                elsif ( (Azero = '1') or (Bzero = '1') ) then -- Se algum dos sinais que dizem se A ou B são zero
                    ProximoEstado <= S4; -- Vai para S4
                end if;
                
                PRONTO <= '0';
                SIG1 <= '0'; -- (mP = mA = cB)
                SIG2 <= '0'; -- (cP = cA)
                SIG3 <= '0'; -- (cmult)
            
            when S3 =>
                ProximoEstado <= S2; -- Vai para o estado S2 sem condições
                
                PRONTO <= '0';
                SIG1 <= '0'; -- (mP = mA = cB)
                SIG2 <= '1'; -- (cP = cA)
                SIG3 <= '0'; -- (cmult)
            
            when S4 =>
                ProximoEstado <= S0; -- Vai para o estado S0 sem condições

                PRONTO <= '0';
                SIG1 <= '0'; -- (mP = mA = cB)
                SIG2 <= '0'; -- (cP = cA)
                SIG3 <= '1'; -- (cmult)

        end case;
        
    end process;

end rtl;