----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Marco Ant�nio e Denifer
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library mito;
use mito.mito_pkg.all;

entity data_path is
  Port (
    -- PC e Mem�ria--
    clk                 : in  std_logic; --clk
    rst_n               : in  std_logic;   -- reset

    -- Mem�ria--
    saida_memoria       : in  std_logic_vector (15 downto 0);--saida memoria
    entrada_memoria     : out std_logic_vector (15 downto 0);--n�o foi usado
    adress_pc           : out std_logic_vector (5 downto 0); -- entrada da mem�ria

    -- Controle de seletores
    jmp_sel             : in  std_logic;   -- seletor do jump
    adress_sel          : in  std_logic;   -- n�o foi usado
    alu_mem_sel         : in  std_logic;   -- seletor do mux depois da ula
    mem_write_sel       : in  std_logic;   -- seletor da escrita de mem�ria
    alu_op              : in  std_logic_vector (3 downto 0); -- seletor de opera��o da ula

    -- Registradores
    pc_en               : in  std_logic;    -- habilita registrador de pc
    ir_en               : in  std_logic;    -- habilita registrador de instrução
    data_en             : in  std_logic;    -- seletor do mux depois do PC
    write_reg_en        : in  std_logic;    -- escrita nos registradores
    alu_a_ind           : in std_logic; --n�o foi usado
    alu_b_ind           : in std_logic; --n�o foi usado
    
    -- Infos para o controle
    decoded_inst        : out decoded_instruction_type; --processo
    flag_z              : out std_logic; --flag para brach
    flag_n              : out std_logic --flag para branch
);
end data_path;

architecture rtl of data_path is

    -- sinais que saem de algum lugar
    signal data                 : std_logic_vector (15 downto 0);--n�o foi usado
    signal alu_or_mem_data      : std_logic_vector (15 downto 0);--n�o foi usado
    signal instruction          : std_logic_vector (15 downto 0); -- processo
    signal mem_addr             : std_logic_vector (5  downto 0);--endere�o 
    signal program_counter      : std_logic_vector (5  downto 0);--n�o foi usado 
    signal b_alu                : std_logic_vector (15 downto 0);--n�o foi usado
    signal pc_out               : std_logic_vector (5 downto 0); --sa�da do PC
    
    -- banco de registradores
     signal reg1                : std_logic_vector (15 downto 0); --r1
     signal reg2                : std_logic_vector (15 downto 0);--r2
     signal reg3                : std_logic_vector (15 downto 0); --r3
     signal reg4                : std_logic_vector (15 downto 0); --r4
    
     signal reg_inst_mem        : std_logic_vector (14 downto 0);--n�o foi usado
     signal mem_data_reg        : std_logic_vector (15 downto 0); --n�o foi usado
     signal reg_a_ula           : std_logic_vector (1 downto 0);   -- sai da inntruc reg para register
     signal reg_b_ula           : std_logic_vector (1 downto 0);   -- sai da inntruc reg para register
     signal reg_ula_out         : std_logic_vector (15 downto 0); --n�o foi usado
     
         
    
    signal reg_dest     : std_logic_vector(1 downto 0); --sai da inntruc reg para register
    
    -- Saída dos registradores a e b 
    signal reg_a_alu_out: std_logic_vector(15 downto 0); --saida do registrador a da ula 
    signal reg_b_alu_out: std_logic_vector(15 downto 0); --saida do registrador b da ula
      
   -- ALU signals
    signal a_operand    : STD_LOGIC_VECTOR (15 downto 0); --n�o foi usado     
    signal b_operand    : STD_LOGIC_VECTOR (15 downto 0);  --n�o foi usado 
    signal ula_out      : STD_LOGIC_VECTOR (15 downto 0); --sa�da da ula
    
    -- FLAGS
    signal zero         : std_logic; --flag zero
    signal neg          : std_logic; -- flag neg

    signal saida_mux_pc          : STD_LOGIC_VECTOR (5 downto 0); -- saida do mux para o pc
    signal saida_mux_register    : STD_LOGIC_VECTOR (15 downto 0); -- saida do mux para o register
      
    begin 
    
    -- enter your code here

    -- mux entrda pc (jump e branch quando 1)
   saida_mux_pc <= saida_memoria(5 downto 0) WHEN jmp_sel= '1' ELSE
   pc_out +1; 
   
    -- mux entre pc e mem (load e store quando 1)
    adress_pc <= saida_memoria(5 downto 0) WHEN data_en = '1' ELSE
    pc_out ;

    -- mux entre saida da ula e mem�ria
    saida_mux_register <=  saida_memoria when alu_mem_sel  = '1' ELSE 
    ula_out; 
    
    -- mux entre saida da ula  e mem�ria
    entrada_memoria<=  ula_out when adress_sel  = '1' ELSE 
    reg_b_alu_out; 

    PC : process (clk)
      begin
      if (clk'event and clk ='1') then
          if(rst_n='1') then
            pc_out <= "000000";
           else if (pc_en='1') then
              pc_out <= saida_mux_pc;
            end if;
           end if;    
         end if;
  
    end process PC;

    reg_bank : process(clk)  
    begin
      if (clk'event and clk='1') then
        if (write_reg_en = '1') then
            case reg_dest is
              when "01" => reg1 <= saida_mux_register;
              when "10" => reg2 <= saida_mux_register;
              when "11" => reg3 <= saida_mux_register;
              when others => reg4 <= saida_mux_register;
            
            end case;
        else
          if(rst_n='1') then
            reg1 <= x"0001";--hexadecimal "1"
            reg2 <= x"0011";--hexadecimal "17"
            reg3 <= x"0000";
            reg4 <= x"0000";                              
          end if;    
        end if;    
      end if;
    end process reg_bank;

    ULA : process (reg_a_alu_out, reg_b_alu_out, alu_op, instruction)
    begin
      case alu_op is 

      when "0001" => ula_out <= reg_a_alu_out +  reg_b_alu_out;
      when "0010" => ula_out <= reg_a_alu_out OR reg_b_alu_out;
      when "0110" => ula_out <= reg_a_alu_out - reg_b_alu_out;
      when "1100" => ula_out <= reg_a_alu_out - reg_b_alu_out;
      when "0011" => ula_out <= reg_a_alu_out + instruction(9 downto 8);
      
        
      when others => ula_out <= reg_a_alu_out NAND reg_b_alu_out;
      end case;
      
      if(ula_out=0)then
            flag_z<= '1';
      else
            flag_z<= '0';
      end if;       
        
    end process ULA;
    
    IR : process (clk)
    begin
         if (clk'event and clk='1') then
            if (ir_en = '1') then
                instruction <= saida_memoria;   
            end if;
      end if;
    end process IR;
    
    decode_instruction : process(instruction)
        begin
            reg_a_ula <= "00";
            reg_b_ula <= "00";
            reg_dest <= "00";
            mem_addr <= "000000";
            case instruction (15 downto 12) is                         
                when "0001" =>  --ADD
                        
                        decoded_inst <= I_ADD;
                        reg_a_ula <= instruction(11 downto 10);
                        reg_b_ula <= instruction(9 downto 8);
                        reg_dest <= instruction(7 downto 6); 
                         
                when "0011" =>  --ADDI
                        
                        decoded_inst <= I_ADDI;
                        reg_a_ula <= instruction(11 downto 10);
                        reg_dest <= instruction(7 downto 6);                 
                                                
                when "0110" =>  --SUB
                                
                         decoded_inst <= I_SUB;
                        reg_a_ula <= instruction(11 downto 10);
                         reg_b_ula <= instruction(9 downto 8);
                         reg_dest <= instruction(7 downto 6);
                                                                              
                when "0010" =>  --or
                                                
                         decoded_inst <= I_OR;
                
                when "0100" =>  --LOAD
                                                                         
                         decoded_inst <= I_LOAD;  
                         reg_dest <= instruction(11 downto 10);
                        
                                                
                when "0111" =>  --STORE
                
                        decoded_inst <= I_STORE;
                        reg_b_ula <= instruction(9 downto 8); -- recebe o reg q o dado a ser enviado est� (pq � o q sai pra mem)
                        --entrada_memoria <= reg_b_alu_out;
                        
                when "1111" =>  --ADDSTORE
                
                       decoded_inst <= I_ADDSTORE;
                       reg_a_ula <= instruction (11 downto 10); -- recebe o reg q o dado a ser enviado est� (pq � o q sai pra mem)      
                       --entrada_memoria <= ula_out;
                
                when "1000" => -- JUMP
                
                        decoded_inst <= I_JMP; 
                                                               
                when "1100" => -- BNE      
                        reg_a_ula <= instruction(11 downto 10);
                        reg_b_ula <= instruction(9 downto 8);                        
                        decoded_inst <= I_BNE;                       
                        
                when others => -- nop
                
                        decoded_inst <= I_NOP;
                        
            end case;    
        end process;
        reg_op_a_alu : process(clk)
              begin
              if (clk'event and clk='1') then
                        case reg_a_ula is
                            when "01" => reg_a_alu_out <= reg1;
                            when "10" => reg_a_alu_out <= reg2;
                            when "11" => reg_a_alu_out <= reg3;  
                            when others  => reg_a_alu_out <= reg4;
                        end case;
               if(rst_n='1') then
                        reg_a_alu_out <= x"0000";        
                    end if;    
               end if;
      end process;
        reg_op_b_alu : process(clk)
              begin
              if (clk'event and clk='1') then
                        case reg_b_ula is
                            when "01" => reg_b_alu_out <= reg1;
                            when "10" => reg_b_alu_out <= reg2;
                            when "11" => reg_b_alu_out <= reg3;  
                            when others  => reg_b_alu_out <= reg4;
                        end case;
               if(rst_n='1') then
                        reg_b_alu_out <= x"0000";        
                    end if;    
               end if;
      end process;


end rtl;
