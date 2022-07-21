library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity decoder is
    generic(N:integer:=16);
    port(
        ins_OP: IN std_logic_vector(3 downto 0); -- From IR, to tell which instruction is
        Z_reg, N_reg, O_reg, clk, reset: IN std_logic; --From flag mux
        RA_enable, RB_enable, WA_enable, byPassA, byPassB, byPassW, IE, OE, RW: OUT std_logic; -- uInstruction
        op, SEL: OUT std_logic_vector(2 downto 0); -- uInstruction for ALU
        LE: OUT std_logic_vector(3 downto 0); -- Latch signal for IR, flag, Addr and Dout
        uPC: OUT std_logic_vector(1 downto 0)
    );
end entity decoder;

architecture structure of decoder is
    signal pres_state: std_logic_vector(1 downto 0) := "00"; -- uPC

    subtype opCode is std_logic_vector(2 downto 0);
    constant opADD: opCode:= "000";
    constant opSUB: opCode:= "001";
    constant opAND: opCode:= "010";
    constant opOR: opCode:= "011";
    constant opXOR: opCode:= "100";
    constant opNOT: opCode:= "101";
    constant opMOV: opCode:= "110";
    constant opINC: opCode:= "111";

    subtype selFlag is std_logic_vector(2 downto 0);
    constant ZFL: selFlag:= "100";
    constant NFL: selFlag:= "010";
    constant OFL: selFlag:= "001";

    subtype latchEn is std_logic_vector(3 downto 0);
    constant L_IR: latchEn:= "1000";
    constant L_Flag: latchEn:= "0100";
    constant L_Addr: latchEn:= "0010";
    constant L_Dout: latchEn:= "0001";
    constant L_none: latchEn:= "0000";

    type uIns is record
        IE: std_logic;
        bypass: std_logic_vector(2 downto 0); --A B W
        WA_en: std_logic;
        RA_en: std_logic;
        RB_en: std_logic;
        ALU: opCode;
        OE: std_logic; -- useless ?
        RW: std_logic; -- for mem ?
        SEL: selFlag; -- flags select
        LE: std_logic_vector(3 downto 0); -- What is this ?
    end record;

    type uPr is array(0 to 3) of uIns; -- four states FSM

    -- IE, ByPass, WA, RA, RB, op, OE, RW, SEL. LE
    constant uADD: uPr:= (
        ('0', "000", '0', '0', '0', opADD, '1', '1', ZFL, L_IR),
        ('0', "000", '1','1','1', opADD, '1', '1' ,ZFL , L_Flag), -- FO
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );

    constant uSUB: uPr:= (
        ('0', "000", '0', '0', '0', opADD, '1', '1', ZFL, L_IR),
        ('0', "000", '1','1','1', opSUB, '1', '1' ,ZFL , L_Flag), -- FO
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );

    constant uAND: uPr:= (
        ('0', "000", '0', '0', '0', opADD, '1', '1', ZFL, L_IR),
        ('0', "000", '1','1','1', opAND, '1', '1' ,ZFL , L_Flag), -- FO
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );

    constant uOR: uPr:= (
        ('0', "000", '0', '0', '0', opADD, '1', '1', ZFL, L_IR),
        ('0', "000", '1','1','1', opOR, '1', '1' ,ZFL , L_Flag), -- FO
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );
    
    constant uXOR: uPr:= (
        ('0', "000", '0', '0', '0', opADD, '1', '1', ZFL, L_IR),
        ('0', "000", '1','1','1', opXOR, '1', '1' ,ZFL , L_Flag), -- FO
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );

    constant uNOT: uPr:= (
        ('0', "000", '0', '0', '0', opADD, '1', '1', ZFL, L_IR),
        ('0', "000", '1','1','1', opNOT, '1', '1' ,ZFL , L_Flag), -- FO
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );

    constant uMOV: uPr:= (
        ('0', "000", '0', '0', '0', opADD, '1', '1', ZFL, L_IR),
        ('0', "000", '1','1','1', opMOV, '1', '1' ,ZFL , L_Flag), -- FO
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );

    -- constant uINC: uPr:= (
    --     ('0', "00", '0', '0', '0', opINC, '0', '0', ZFL, L_IR),
    --     ('0', "00", '1','1','1', opINC, '0', '0' ,ZFL , L_FLAG), -- FO
    --     ('0', "11", '1','1','0', opINC, '1', '0' ,ZFL, L_Addr), -- EX
    --     ('0', "00", '0','0','0', opMOV,'0', '0', ZFL, L_none) -- WA
    -- );

    constant uNOP: uPr:= (
        ('0', "000", '0', '0', '0', opINC, '1', '1', ZFL, L_IR),
        ('0', "011", '1','1','0', opINC, '1', '1' ,ZFL, L_Addr), -- EX
        ('0', "000", '0','0','0', opMOV, '1', '1' ,ZFL , L_none), -- FO
        ('0', "000", '0','0','0', opMOV,'1', '1', ZFL, L_none) -- WA
    );

    constant uBRZ_F: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "011", '1', '1','0', opINC, '1', '1', ZFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_none),
        ('0', "000", '0', '0','0', opMOV,'1', '1', ZFL, L_none)
    );

    constant uBRZ_T: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "011", '1', '1','0', opADD, '1', '1', ZFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_none),
        ('0', "000", '0', '0','0', opMOV,'1', '1', ZFL, L_none)
    );

    constant uBRN_F: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "011", '1', '1','0', opINC, '1', '1', NFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV, '1', '1', NFL, L_none),
        ('0', "000", '0', '0','0', opMOV,'1', '1', ZFL, L_none)
    );

    constant uBRN_T: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "011", '1', '1','0', opADD, '1', '1', NFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV, '1', '1', NFL, L_none),
        ('0', "000", '0', '0','0', opMOV,'1', '1', ZFL, L_none)
    );

    constant uBRO_F: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "011", '1', '1','0', opINC, '1', '1', OFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV, '1', '1', OFL, L_none),
        ('0', "000", '0', '0','0', opMOV,'1', '1', ZFL, L_none)
    );
    
    constant uBRO_T: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "011", '1', '1','0', opADD, '1', '1', OFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV, '1', '1', OFL, L_none),
        ('0', "000", '0', '0','0', opMOV,'1', '1', ZFL, L_none)
    );

    constant uBRA: uPr:= ( 
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "011", '1', '1', '0', opADD, '1', '1' ,ZFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_none),
        ('0', "000", '0', '0', '0', opMOV,'1', '1', ZFL, L_none)
    );

    constant uST: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "000", '0', '0', '1', opADD, '1', '1', ZFL, L_Dout),
        ('0', "000", '0', '1', '0', opMOV, '1', '1', ZFL, L_Addr),
        ('0', "011", '1', '1', '0', opINC, '1', '0', ZFL, L_Addr)
    );

    constant uLD: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "000", '0', '1', '0', opMOV, '1', '1', ZFL, L_Addr),
        ('0', "011", '1', '1', '0', opINC, '1', '1', ZFL, L_Addr),
        ('1', "000", '1', '0', '0', opMOV, '1', '1', ZFL, L_none)
        
    );

    constant uLDI: uPr:= (
        ('0', "000", '0', '0', '0', opMOV, '1', '1', ZFL, L_IR),
        ('0', "100", '1', '0', '0', opMOV, '1', '1', ZFL, L_Flag),
        ('0', "011", '1', '1', '0', opINC, '1', '1', ZFL, L_Addr),
        ('0', "000", '0', '0', '0', opMOV,'1', '1', ZFL, L_none)
    );
    
    signal pres_uPr: uPr;
begin
    pres_uPr <= uADD when ins_OP = "0000" else
        uSUB when ins_OP = "0001" else
        uAND when ins_OP = "0010" else
        uOR when ins_OP = "0011" else
        uXOR when ins_OP = "0100" else
        uNOT when ins_OP = "0101" else
        uMOV when ins_OP = "0110" else
        uNOP when ins_OP = "0111" else
        uLD when ins_OP = "1000" else
        uST when ins_OP = "1001" else
        uLDI when ins_OP = "1010" else
        uBRZ_F when ins_OP = "1100" and Z_reg = '0' else
        uBRZ_T when ins_OP = "1100" and Z_reg = '1' else
        uBRN_F when ins_OP = "1101" and N_reg = '0' else
        uBRN_T when ins_OP = "1101" and N_reg = '1' else
        uBRO_F when ins_OP = "1110" and O_reg = '0' else
        uBRO_T when ins_OP = "1110" and O_reg = '1' else
        uBRA when ins_OP = "1111" else
        uNOP;
    
    uPC <= pres_state;
    -- IE, ByPass, WA, RA, RB, op, OE, RW, SEL. LE
    process(clk, reset)
    begin
        if reset = '1' then
            pres_state <= "00";
            -- IE <= '0';
            -- byPassA <= '0';
            -- byPassB <= '0';
            -- byPassW <= '0';
            -- WA_enable <= '0';
            -- RA_enable <= '0';
            -- RB_enable <= '0';
            -- op <= "000";
            -- OE <= '0';
            -- RW <= '0';
            -- SEL <= ZFL;
            -- LE <= L_IR;
        elsif clk'event and clk = '1' then
            pres_state <= pres_state + 1;
        end if; 
    end process;

    process(pres_state, pres_uPr)
    begin
        IE <= pres_uPr(conv_integer(pres_state)).IE;
        byPassA <= pres_uPr(conv_integer(pres_state)).bypass(2);
        byPassB <= pres_uPr(conv_integer(pres_state)).bypass(1);
        byPassW <= pres_uPr(conv_integer(pres_state)).bypass(0);
        WA_enable <= pres_uPr(conv_integer(pres_state)).WA_en;
        RA_enable <= pres_uPr(conv_integer(pres_state)).RA_en;
        RB_enable <= pres_uPr(conv_integer(pres_state)).RB_en;
        op <= pres_uPr(conv_integer(pres_state)).ALU;
        OE <= pres_uPr(conv_integer(pres_state)).OE;
        RW <= pres_uPr(conv_integer(pres_state)).RW;
        SEL <= pres_uPr(conv_integer(pres_state)).SEL;
        LE <= pres_uPr(conv_integer(pres_state)).LE;
    end process;
end structure; -- structure