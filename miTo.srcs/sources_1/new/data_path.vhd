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
    flag_n              : out std_logic;

    out_pc_mux_signal   : out std_logic
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
    signal pc_in                : std_logic_vector (8 downto 0);
    signal pc_out               : std_logic_vector (8 downto 0);
    
    -- banco de registradores
     signal reg1                : std_logic_vector (15 downto 0);
     signal reg2                : std_logic_vector (15 downto 0);
     signal reg3                : std_logic_vector (15 downto 0);
     signal reg4                : std_logic_vector (15 downto 0);
    
     signal reg_inst_mem        : std_logic_vector (14 downto 0); 
     signal mem_data_reg        : std_logic_vector (15 downto 0);
     signal reg_a_ula           : std_logic_vector (15 downto 0);   -- entrada do registrador a
     signal reg_b_ula           : std_logic_vector (15 downto 0);   -- entrada do registrador b
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
    signal saida_mux_register    : STD_LOGIC_VECTOR (5 downto 0);
      
    begin
    
    -- enter your code here

    -- mux entrda pc (jump e branch quando 1)
    saida_mux_pc <= saida_memoria(5 downto 0) WHEN jmp_sel = '1' ELSE
                    program_counter + 1;

    -- mux entre pc e mem (load e store quando 1)
    adress_pc <= saida_memoria(5 downto 0) WHEN out_pc_mux_signal = '1' ELSE
                 pc_out;

    -- mux entre saida da ula e banco de regs
    saida_mux_register <= saida_memoria(5 downto 0) WHEN alu_mem_sel = '1' ELSE
              

    PC : process (clk)
      begin
      if (rst_n = '1' AND rising_edge(clk)) then
          pc_out <= "000000";
      elsif (pc_enable = '1' AND rising_edge(clk)) then
          pc_out <= pc_in;
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
              when "0001" => reg1 <= reg_ula_out;
              when "0010" => reg2 <= reg_ula_out;
              when "0011" => reg3 <= reg_ula_out;
              when "0100" => reg4 <= reg_ula_out;
              when others  => reg5<= reg_ula_out;
            end case;
        else
          if(rst_n='1') then
            reg1 <= x"0000";
            reg2 <= x"0000";
            reg3 <= x"0000";
            reg4 <= x"0000";                              
          end if;    
        end if;    
      end if;
    end process FLAGS;

    ULA : process (a_operand, b_operand, alu_op)
    begin
      case alu_op is 

      when "0001" => ula_out <= a_operand +  b_operand;
      when "0010" => ula_out <= a_operand OR b_operand;
      when "1100" => ula_out <= a_operand - b_operand;
      
      when others a_operand +  b_operand;
      end case;

    end process ULA;

end rtl;
