----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Newton Jr
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library mito;
use mito.mito_pkg.all;

entity data_path is
  Port (
    -- Clock e reset
    clk                 : in  std_logic;
    rst_n               : in  std_logic;   -- reset

    -- Memória
    saida_memoria       : in  std_logic_vector (15 downto 0);
    entrada_memoria     : out std_logic_vector (15 downto 0);
    adress_pc           : out std_logic_vector (5 downto 0);   -- saída do pc

    -- Controle de seletores
    jmp_sel             : in  std_logic;   -- seletor do jump
    adress_sel          : in  std_logic;   -- seletor do pc
    alu_mem_sel         : in  std_logic;   -- seletor do ula
    mem_write_sel       : in  std_logic;   -- seletor da escrita de memória
    alu_op              : in  std_logic_vector (3 downto 0);    -- seletor da ula

    -- Registradores
    pc_en               : in  std_logic;    -- habilita registrador de pc
    ir_en               : in  std_logic;    -- habilita registrador de instrução
    data_en             : in  std_logic;    -- habilita registrador de dados na memória 
    write_reg_en        : in  std_logic;    -- escrita nos registradores
    alu_a_ind           : in  std_logic;    -- registrador a
    alu_b_ind           : in  std_logic;    -- registrador b
   
    
    -- Infos para o controle
    decoded_inst        : out decoded_instruction_type;
    flag_z              : out std_logic;
    flag_n              : out std_logic
);
end data_path;

architecture rtl of data_path is

    -- sinais que saem de algum lugar
    signal data                 : std_logic_vector (15 downto 0);
    signal alu_or_mem_data      : std_logic_vector (15 downto 0);
    signal instruction          : std_logic_vector (15 downto 0); 
    signal mem_addr             : std_logic_vector (5  downto 0); 
    signal program_counter      : std_logic_vector (5  downto 0); 
    signal out_pc_mux           : std_logic_vector (5  downto 0); 
    signal b_alu                : std_logic_vector (15 downto 0);
    signal dr_to_reg            : std_logic_vector (15 downto 0);
    signal pc_in                : std_logic_vector (5 downto 0);
    signal pc_out               : std_logic_vector (5 downto 0);
    
    -- banco de registradores
     signal reg1                : std_logic_vector (15 downto 0);
     signal reg2                : std_logic_vector (15 downto 0);
     signal reg3                : std_logic_vector (15 downto 0);
     signal reg4                : std_logic_vector (15 downto 0);
    
     signal reg_inst_mem        : std_logic_vector (14 downto 0); 
     signal mem_data_reg        : std_logic_vector (15 downto 0);
     signal reg_a_ula           : std_logic_vector (1 downto 0);   -- entrada do registrador a
     signal reg_b_ula           : std_logic_vector (1 downto 0);   -- entrada do registrador b
     signal reg_ula_out         : std_logic_vector (15 downto 0);
     
         
    -- registrador de destino
    signal reg_dest     : std_logic_vector(1 downto 0);
    
    -- Saída dos registradores a e b 
    signal reg_a_alu_out: std_logic_vector(15 downto 0);  
    signal reg_b_alu_out: std_logic_vector(15 downto 0);
      
   -- ALU signals
    signal a_operand    : STD_LOGIC_VECTOR (15 downto 0);      
    signal b_operand    : STD_LOGIC_VECTOR (15 downto 0);   
    signal ula_out      : STD_LOGIC_VECTOR (15 downto 0);
    
    -- FLAGS
    signal zero         : std_logic;
    signal neg          : std_logic;

    signal saida_mux_pc          : STD_LOGIC_VECTOR (5 downto 0);
    signal saida_mux_register    : STD_LOGIC_VECTOR (15 downto 0);
      
    begin 
    
    -- enter your code here

    -- mux entrda pc (jump e branch quando 1)
   saida_mux_pc <= saida_memoria(5 downto 0) WHEN jmp_sel= '1' ELSE
   program_counter + 1; 
   
    -- mux entre pc e mem (load e store quando 1)
   adress_pc <= saida_memoria (5 downto 0) WHEN jmp_sel= '1' ELSE
    pc_out(5 downto 0);

    -- mux entre saida da ula e mem�ria
    saida_mux_register <= ula_out when alu_mem_sel  = '1' ELSE 
    alu_or_mem_data; 

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

    FLAGS : process (clk)
    begin
          flag_z <= zero;
          flag_n <= neg;
    end process FLAGS;

    reg_bank : process(clk)  
    begin
      if (clk'event and clk='1') then
        if (write_reg_en = '1') then
            case reg_dest is
              when "01" => reg1 <= ula_out;
              when "10" => reg2 <= ula_out;
              when "11" => reg3 <= ula_out;
              when others => reg4 <= ula_out;
            
            end case;
        else
          if(rst_n='1') then
            reg1 <= x"0001";
            reg2 <= x"0010";
            reg3 <= x"0000";
            reg4 <= x"0000";                              
          end if;    
        end if;    
      end if;
    end process reg_bank;

    ULA : process (reg_a_alu_out, reg_b_alu_out, alu_op)
    begin
      case alu_op is 

      when "0001" => ula_out <= reg_a_alu_out +  reg_b_alu_out;
      when "0010" => ula_out <= reg_a_alu_out OR reg_b_alu_out;
      when "0110" => ula_out <= reg_a_alu_out - reg_b_alu_out;
      
      when others => ula_out <= reg_a_alu_out NAND reg_b_alu_out;
      end case;

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
                                                
                when "0110" =>  --SUB
                                
                         decoded_inst <= I_SUB;
                        reg_a_ula <= instruction(11 downto 10);
                         reg_b_ula <= instruction(9 downto 8);
                         reg_dest <= instruction(7 downto 6);
                                                                              
                when "0010" =>  --or
                                                
                         decoded_inst <= I_OR;
                
                when "0100" =>  --LOAD
                                                                         
                         decoded_inst <= I_LOAD;  
                                                
                when "0111" =>  --STORE
                
                        decoded_inst <= I_STORE;
                        reg_b_ula <= instruction(9 downto 8); -- recebe o reg q o dado a ser enviado est� (pq � o q sai pra mem)
                        entrada_memoria <= reg_b_alu_out;
                
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
