LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY somadoroverflow IS
PORT (a, b : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cin : IN STD_LOGIC;
      s : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cout : OUT STD_LOGIC
      );
END somadoroverflow;

ARCHITECTURE estrutura OF somadoroverflow IS
    SIGNAL sum : STD_LOGIC_VECTOR(4 DOWNTO 0) ;
BEGIN
    sum <= ('0' & a) + b + cin;
    s <= sum(3 DOWNTO 0);
    cout <= sum(4);
    cout <= sum(4) XOR a(3) XOR b(3) XOR sum(3);
END estrutura;