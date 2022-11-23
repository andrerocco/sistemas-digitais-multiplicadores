LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY igualazero IS
GENERIC ( N: integer );
PORT (a : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		igual : OUT STD_LOGIC);
END igualazero;

ARCHITECTURE estrutura OF igualazero IS
BEGIN
	igual <= '1' WHEN A = (A-A) ELSE '0'; -- Torna "0000" em um tamanho que se jadapta ao Generic
END estrutura;