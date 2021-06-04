----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Marco Antônio e Denifer
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
    
    next_st : process(nextstate,current,rst_n ,clk)
    begin
    
    jmp_sel <='0';
    pc_en <= '0';
    ir_en <= '0';
    write_reg_en <= '0';
    adress_sel <= '0';
    alu_op <="0000";
    write_mem_en <= '0';
    data_en<='0';
    alu_mem_sel<='0';
    

    
        case(current) is
            when registra_inst =>
                nextstate <= decodifica_inst;
                ir_en <= '1';
                
            when decodifica_inst =>            
                nextstate <= pos_decodifica_inst;
               
            
            when pos_decodifica_inst =>
                case decoded_inst is
                        
                    when I_LOAD => 
                        
                        
                        nextstate <= load;
                         data_en <= '1';
                         alu_mem_sel <= '1'; 
                         write_reg_en <= '1'; 
                          
                        
                    when I_STORE =>
     
                        write_mem_en <= '1';
                        data_en <= '1';
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
                        
                        data_en <= '0';
                        jmp_sel<='1';
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
                        write_reg_en <= '0';
                        write_mem_en <= '0';
                        pc_en <= '1';
                      
                           
                end case;
         
           
                when load =>
                    nextstate <= registra_inst;
                    alu_mem_sel  <= '1'; 
                    pc_en <= '1';   
                    
                when store =>
                    nextstate <= registra_inst;
                    pc_en <= '1'; 
                    
                when add =>                
                     pc_en <= '1';
                     alu_mem_sel <= '1';
                     nextstate <= registra_inst;
                     
                when sub =>                   
                     pc_en <= '1';
                     alu_mem_sel <= '1';
                     nextstate <= registra_inst;
                     
                    
                when ore =>
                      pc_en <= '1';
                     alu_mem_sel <= '1';
                     nextstate <= registra_inst;
                     
                 
                 when jmp =>
                    nextstate <= registra_inst;
                     pc_en <= '1';
                     data_en <= '0';
                     jmp_sel<='1';
                     ir_en <= '1';
                  
                    
                 when bne =>
                     nextstate <= registra_inst;
                     if(flag_z='0') then         --verificando se não são iguais   
                                    data_en<='0';
                                    jmp_sel<='1';
                                    nextstate<= registra_inst; 
                                else
                                    nextstate<= final; 
                                end if;     
                      pc_en <= '1';
                      ir_en <= '1'; 
                      
                when final =>
                    nextstate <= registra_inst;
                   pc_en <= '1';  
                 
                when others =>
                    nextstate <= registra_inst;
                
        end case;
    end process next_st;  
end rtl;
