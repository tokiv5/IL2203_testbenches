library IEEE;
use IEEE.std_logic_1164.all;

entity cpu is
    generic(N:integer:=16;M:integer:=3);
    port(
        clk, reset: IN std_logic;
        RW, done: OUT std_logic;
        Din: IN std_logic_vector(N-1 downto 0);
        Dout, Address: OUT std_logic_vector(N-1 downto 0)
    );
end entity cpu;

architecture behave of cpu is

    -- Signals for registers
    signal IR: std_logic_vector(15 downto 0);
    signal ALU_out: std_logic_vector(N-1 downto 0);
    signal ZFL, NFL, OFL, flags, out_clk: std_logic;
    signal SEL: std_logic_vector(2 downto 0);
    signal LE: std_logic_vector(3 downto 0);
    -- Signals for connecting decoder and datapath
    signal offset_tmp: std_logic_vector(15 downto 0);
    signal w_en, RA_en, RB_en, IE, OE, byPassA, byPassB, byPassW, Z_Reg, N_Reg, O_Reg: std_logic;
    signal op: std_logic_vector(2 downto 0);
    signal uPC: std_logic_vector(1 downto 0);

    component datapath
        generic(N:integer:=4;
                M:integer:=3);
        port (
            input_data, offset: IN std_logic_vector(N-1 downto 0);
            --PC: OUT std_logic_vector(N-1 downto 0);
            clk, reset, write, readA, readB, IE, OE, byPassA, byPassB, byPassW:IN std_logic;
            op: IN std_logic_vector(2 downto 0);
            WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic;
            output_data: OUT std_logic_vector(N-1 downto 0);
            out_clk: OUT std_logic
        );
    end component;

    component decoder
        generic(N:integer:=16);
        port(
            ins_OP: IN std_logic_vector(3 downto 0); -- From IR, to tell which instruction is
            Z_reg, N_reg, O_reg, clk, reset: IN std_logic; --From flag mux
            RA_enable, RB_enable, WA_enable, byPassA, byPassB, byPassW, IE, OE, RW: OUT std_logic; -- uInstruction
            op, SEL: OUT std_logic_vector(2 downto 0); -- uInstruction for ALU
            LE: OUT std_logic_vector(3 downto 0); -- Latch signal for IR, flag, Addr and Dout
            uPC: OUT std_logic_vector(1 downto 0)
        );
    end component;

begin
    offset_tmp(8 downto 0) <= IR(8 downto 0);
    offset_tmp(11 downto 9) <= (others => IR(8)) when IR(15 downto 12) = "1010" else
        IR(11 downto 9);
    offset_tmp(15 downto 12) <= (others => IR(8)) when IR(15 downto 12) = "1010" else
        (others => IR(11));

    done <= '1' when (uPC = "11") else '0';
    D0: datapath
    generic map(N => N)
    port map(
        input_data => Din,
        offset => offset_tmp,
        clk => clk,
        reset => '0',
        write => w_en,
        readA => RA_en,
        readB => RB_en,
        IE => IE,
        OE => OE,
        byPassA => byPassA,
        byPassB => byPassB,
        byPassW => byPassW,
        op => op,
        WAddr => IR(11 downto 9),
        RA => IR(8 downto 6),
        RB => IR(5 downto 3),
        Z_flag => ZFL,
        N_flag => NFL,
        O_flag => OFL,
        output_data => ALU_out,
        out_clk => out_clk
    );

    DC0: decoder
    generic map(N => N)
    port map(
        ins_OP => IR(15 downto 12),
        Z_reg => Z_reg,
        N_reg => N_reg,
        O_reg => O_reg,
        clk => clk,
        reset => reset,
        RA_enable => RA_en,
        RB_enable => RB_en,
        WA_enable => w_en,
        byPassA => byPassA,
        byPassB => byPassB,
        byPassW => byPassW,
        IE => IE,
        OE => OE,
        RW => RW,
        op => op,
        SEL => SEL,
        LE => LE,
        uPC => uPC
    );
    -- This line should be deleted after memory is implmented
    -- IR <= Din;
    flags <= Z_Reg when SEL = "100" else
        N_Reg when SEL = "010" else
        O_Reg when SEL = "001" else
        '0';
    IR <= Din when LE(3) = '1';
    -- Z_Reg <= ZFL when LE(2) = '1';
    -- N_Reg <= NFL when LE(2) = '1';
    -- O_Reg <= OFL when LE(2) = '1';
    -- Address <= ALU_out when LE(1) = '1';
    -- Dout <= ALU_out when LE(0) = '1';
    -- process(LE, reset)
    -- begin
    --     --if clk'event and clk = '1' then
    --         -- Latch registers
    --     if reset = '1' then
    --         Address <= (others => '0');
    --         Dout <= (others => '0');
    --         Z_reg <= '0';
    --         N_reg <= '0';
    --         O_reg <= '0';
    --     else
    --         if LE(3) = '1' then IR <= Din; end if;
    --         if LE(2) = '1' then
    --             Z_Reg <= ZFL;
    --             N_Reg <= NFL;
    --             O_Reg <= OFL;
    --         end if;
    --         if LE(1) = '1' then Address <= ALU_out; end if;
    --         if LE(0) = '1' then Dout <= ALU_out; end if;
    --     end if;
    -- end process;

    process(clk, reset)
    begin
        --if clk'event and clk = '1' then
            -- Latch registers
        if reset = '1' then
            Address <= (others => '0');
            Dout <= (others => '0');
            Z_reg <= '0';
            N_reg <= '0';
            O_reg <= '0';
        
        elsif clk'event and clk = '1' then
        --     if LE(3) = '1' then IR <= Din; end if;
            if LE(2) = '1' then
                Z_Reg <= ZFL;
                N_Reg <= NFL;
                O_Reg <= OFL;
            end if;
            if LE(1) = '1' then Address <= ALU_out; end if;
            if LE(0) = '1' then Dout <= ALU_out; end if;
        end if;
    end process;
end behave; -- behave