library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic(N:integer:=4);
    port (
        clk,enable:IN std_logic;
        in_data:IN std_logic_vector(N-1 downto 0);
        out_data:OUT std_logic_vector(N-1 downto 0)
    );
end reg;

architecture data_flow of reg is
begin
    process(clk)
    begin
        if clk'event and (clk='1') then
            if enable = '1' then
                out_data <= in_data;
            elsif enable = '0' then
                out_data <= (others=>'0');
            end if;
        end if;
    end process;
end architecture data_flow;
