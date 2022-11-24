library ieee;
use ieee.std_Logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity somador_overflow is 
generic(N : integer );
port (A, B : std_logic_vector(N-1 downto 0);
	   Cout : out std_logic;
      RESULTADO : out std_logic_vector(N-1 downto 0));
end somador_overflow;
		
architecture myarch of somador_overflow is

    signal extensao_1, extensao_2, soma : std_logic_vector(N downto 0);

BEGIN

	extensao_1 <= '0' & A;
	extensao_2 <= '0' & B;
	soma <= extensao_1 + extensao_2;
	cout <= soma(N);
	resultado <= soma(N-1 downto 0);
	
end myarch;