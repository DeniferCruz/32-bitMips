library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ula is 
    port(
        A,B           in  :   std_logic_vector(3 downto 0); 
        O             in  :   std_logic_vector(3 downto 0);
        selection     in  :   std_logic_vector(3 downto 0) 
    );
end ula;

architecture hardware of ula is 
beginprocess(A,B,selection)
begin
    case selection is 

    when "0001" => O <= A  +  B;
    when "0001" => O <= A  OR B;
