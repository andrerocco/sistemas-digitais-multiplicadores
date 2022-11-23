library ieee;
use ieee.std_logic_1164.all;

entity control is
    port (
        CLK: in std_logic;
        RESET, INICIAR: in std_logic; -- Entradas de controle
        
        Azero, Bzero, CONTz: in std_logic; -- Sinais de status (recebidos do Datapath)
        UltimoBitA: in std_logic; -- Sinal de status (recebido do Datapath)
        
        PRONTO: out std_logic; -- Saída de controle
        SIG1, SIG2, ccont, cmult, cPH: out std_logic -- Sinais de controle (enviados para o Datapath)
    );
end control;

architecture rtl of control is
    type STATES is (S0, S1, S2, S3, S4, S5, S6);
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
        
                SIG1 <= '0';
                SIG2 <= '0';
                ccont <= '0';
                cmult <= '0';
                cPH <= '0';
            
            when S1 =>
                ProximoEstado <= S2; -- Vai para o estado S2 sem condições
                
                PRONTO <= '0';
        
                SIG1 <= '1';
                SIG2 <= '0';
                ccont <= '1';
                cmult <= '0';
                cPH <= '1';
                
            when S2 =>
                if ( (Azero = '1') or (Bzero = '1') ) then
                    ProximoEstado <= S6;
                else
                    ProximoEstado <= S3;
                end if;
                
                PRONTO <= '0';
        
                SIG1 <= '0';
                SIG2 <= '0';
                ccont <= '0';
                cmult <= '0';
                cPH <= '0';
            
            when S3 =>
                if ( CONTz = '1' ) then
                    ProximoEstado <= S6;
                elsif ( (CONTz = '0') and (UltimoBitA = '0') ) then
                    ProximoEstado <= S4;
                elsif ( (CONTz = '0') and (UltimoBitA = '1') ) then
                    ProximoEstado <= S5;
                end if;
                
                PRONTO <= '0';
        
                SIG1 <= '0';
                SIG2 <= '0';
                ccont <= '0';
                cmult <= '0';
                cPH <= '0';
            
            when S4 =>
                ProximoEstado <= S5;
                
                PRONTO <= '0';
        
                SIG1 <= '0';
                SIG2 <= '0';
                ccont <= '0';
                cmult <= '0';
                cPH <= '1';
            
            when S5 =>
                ProximoEstado <= S3;
                
                PRONTO <= '0';
        
                SIG1 <= '0';
                SIG2 <= '1';
                ccont <= '1';
                cmult <= '0';
                cPH <= '0';
                
            when S6 =>
                ProximoEstado <= S0;
                
                PRONTO <= '0';
        
                SIG1 <= '0';
                SIG2 <= '0';
                ccont <= '0';
                cmult <= '1';
                cPH <= '0';

        end case;
        
    end process;

end rtl;