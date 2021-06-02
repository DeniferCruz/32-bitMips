----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Newton Jr
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library mito;
use mito.mito_pkg.all;

entity control_unit is
    Port ( 

        clk                 : in  std_logic;
        rst_n               : in  std_logic;
        adress_sel          : out std_logic;
        alu_b_ind           : out std_logic;
        pc_en               : out std_logic;
        ir_en               : out std_logic;
        data_en             : out std_logic;
        write_reg_en        : out std_logic;
        jmp_sel             : out std_logic;
        alu_mem_sel         : out std_logic;
        write_mem_en        : out std_logic;
        mem_write_sel       : out std_logic;
        alu_a_ind           : out std_logic;
        flag_z              : in  std_logic;
        flag_n              :  in std_logic;
        decoded_inst        : in  decoded_instruction_type;
        alu_op              : out std_logic_vector(3 downto 0)
       
    );
end control_unit;

architecture rtl of control_unit is
     
type state_type is(busca_inst, registra_inst, decodifica_inst, pos_decodifica_inst, load, store, bne, add, ore , jmp, sub, final, aux);
        
        signal current : state_type;
        signal nextstate : state_type;
begin
   
    main : process(clk)
    begin
        if (clk'event and clk='1') then
            if (rst_n = '1') then
                current <= busca_inst;
            else
                current <= nextstate; 
            end if;
        end if;
        
    end process main;
    
    next_st : process(current,decoded_inst,flag_z,flag_n)
    begin
    
    jmp_sel <='0';
    pc_en <= '0';
    ir_en <= '0';
    write_reg_en <= '0';
    adress_sel <= '0';
    alu_op <="0000";
    write_mem_en <= '0';

    
        case(current) is
            when registra_inst =>
                nextstate <= decodifica_inst;
                ir_en <= '1';
                
            when decodifica_inst =>            
                nextstate <= pos_decodifica_inst;
                pc_en <= '1'; 
            
            when pos_decodifica_inst =>
                case decoded_inst is
                        
                    when I_LOAD => 
                        
                        write_reg_en <= '1';
                        nextstate <= load;  
                        
                    when I_STORE =>
     
                        write_mem_en <= '1';
                        nextstate <= store;    
                        
                    when I_ADD =>
     
                        alu_op <= "0001";
                        write_reg_en <= '1';
                        nextstate <= add; 
                           
                    when I_OR =>
     
                        alu_op <= "0010";
                         write_reg_en <= '1';
                        nextstate <= ore; 
                        
                    when I_JMP =>
     
                        jmp_sel <= '1';
                        pc_en <= '1';
                        nextstate <= jmp;
                        
                   when I_SUB =>
     
                        alu_op <= "0110";
                         write_reg_en <= '1';
                        nextstate <= sub;
                        
                    when I_BNE =>
                        
                        alu_op <= "1100";
                        nextstate <= bne; 
                                       
                    when others =>
                        nextstate <= registra_inst;    
                end case;
         
           
                when load =>
                    nextstate <= busca_inst;  
                    
                when store =>
                    nextstate <= busca_inst;
                    
                when add =>
                    nextstate <= busca_inst;
                    write_reg_en <= '1';
                     pc_en <= '1';
                when sub =>
                    nextstate <= busca_inst;
                    
                when ore =>
                    nextstate <= busca_inst;
                 
                 when jmp =>
                    nextstate <= busca_inst;
                     pc_en <= '1';
                    
                 when bne =>
                    nextstate <= busca_inst;    
                     
                when final =>
                    nextstate <= final;
                 
                when others =>
                    nextstate <= registra_inst;
                
        end case;
    end process next_st;  
end rtl;
