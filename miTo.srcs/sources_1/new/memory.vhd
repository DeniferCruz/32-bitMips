----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Newton Jr
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.ALL;
library mito;
use mito.mito_pkg.all;

entity memory is
	port(		
        clk                 : in  std_logic;
        escrita             : in  std_logic;
        rst_n               : in  std_logic;

		-- Datapath        
        entrada_memoria     : in  std_logic_vector(15 downto 0);
        endereco_memoria    : in  std_logic_vector(6  downto 0);
        saida_memoria       : out std_logic_vector(15 downto 0)
    );
        
end memory;

architecture rtl of memory is

	-- 256 words of 4 bytes (16 bits)
	subtype palavra is std_logic_vector(15 downto 0);
	type memory is array (0 to 63) of palavra;
	signal mem : memory;
	
begin 

process(clk)	
begin
			
	if(rst_n = '1') then
			--  reset memory when rst_n = 1 
			 
			mem(0)    <= "0000000000000000"; 
			mem(1)    <= "0000000000000000";
			mem(2)    <= "0000000000000000";
			mem(3)    <= "0000000000000000";
			mem(4)    <= "0000000000000000";
			mem(5)    <= "0000000000000000"; 
			mem(6)    <= "0000000000000000";
			mem(7)    <= "0000000000000000";
			mem(8)    <= "0000000000000000";
			mem(9)    <= "0000000000000000";
			mem(10)   <= "0000000000000000";
			mem(11)   <= "0000000000000000";
			mem(12)   <= "0000000000000000";
			mem(13)   <= "0000000000000000";
			mem(14)   <= "0000000000000000";
			mem(15)   <= "0000000000000000"; 
			mem(16)   <= "0000000000000000"; 
			mem(17)   <= "0000000000000000"; 
			mem(18)   <= "0000000000000000"; 
			mem(19)   <= "0000000000000000"; 
			mem(20)   <= "0000000000000000";
			mem(21)   <= "0000000000000000"; 
			mem(22)   <= "0000000000000000";
			mem(23)   <= "0000000000000000";
			mem(24)   <= "0000000000000000"; 
			mem(25)   <= "0000000000000000"; 
			mem(26)   <= "0000000000000000"; 
			mem(27)   <= "0000000000000000";      
			mem(28)   <= "0000000000000000"; 
			mem(29)   <= "0000000000000000"; 
			mem(30)   <= "0000000000000000"; 
			mem(31)   <= "0000000000000000"; 
			mem(32)   <= "0000000000000000";  
			mem(33)   <= "0000000000000000"; 
			mem(34)   <= "0000000000000000"; 
			mem(35)   <= "0000000000000000";
			mem(36)   <= "0000000000000000";
			mem(37)   <= "0000000000000000";
			mem(38)   <= "0000000000000000";
			mem(39)   <= "0000000000000000";
			mem(40)   <= "0000000000000000";
			mem(41)   <= "0000000000000000";
			mem(42)   <= "0000000000000000";
			mem(43)   <= "0000000000000000";
			mem(44)   <= "0000000000000000";
			mem(45)   <= "0000000000000000";
			mem(46)   <= "0000000000000000";
			mem(47)   <= "0000000000000000";
			mem(48)   <= "0000000000000000";
			mem(49)   <= "0000000000000000";
			mem(50)   <= "0000000000000000";
			mem(51)   <= "0000000000000000"; 
			mem(52)   <= "0000000000000000";
			mem(53)   <= "0000000000000000";
			mem(54)   <= "0000000000000000";
			mem(55)   <= "0000000000000000";
			mem(56)   <= "0000000000000000";
			mem(57)   <= "0000000000000000";
			mem(58)   <= "0000000000000000";
			mem(59)   <= "0000000000000000";
			mem(60)   <= "0000000000000000";
			mem(61)   <= "0000000000000000";
			mem(62)   <= "0000000000000000";
			mem(63)   <= "0000000000000000";
			
	else
	    -- read from memory
		if((escrita = '0'))then 
				saida_memoria(15 downto 0) <= mem(to_integer(unsigned(endereco_memoria)));
		-- write in memory		
		elsif ((escrita = '1')) then 		
			mem(to_integer(unsigned(endereco_memoria))) <= entrada_memoria(15 downto 0);
		end if;
	end if;		

						
end process;

end rtl;
