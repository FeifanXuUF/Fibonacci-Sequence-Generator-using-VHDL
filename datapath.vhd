library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        n      : in  std_logic_vector(5 downto 0);
        result : out std_logic_vector(31 downto 0);

        n_en       : in std_logic;
        result_en  : in std_logic;
        result_sel : in std_logic;
        x_en       : in std_logic;
        x_sel      : in std_logic;
        y_en       : in std_logic;
        y_sel      : in std_logic;
        i_en       : in std_logic;
        i_sel      : in std_logic;

        n_eq_0 : out std_logic;
        i_le_n : out std_logic
        );
end datapath;

architecture default_arch of datapath is
    signal n_r : std_logic_vector(n'range);
    signal result_r : std_logic_vector(result'range);
    signal i_mux_out : unsigned(n'range);
    signal x_mux_out : unsigned(result'range);
    signal y_mux_out : unsigned(result'range);
    signal result_mux_out : unsigned(result'range);
    signal i_add_out : unsigned(n'range);
    signal xy_add_out : unsigned(result'range);
    signal i_r : std_logic_vector(n'range);
    signal x_r : std_logic_vector(result'range);
    signal y_r : std_logic_vector(result'range);
begin
    process(clk, rst)
    begin
        if (rst = '1') then
            n_r <= (others => '0');
            i_r <= (others => '0');
            x_r <= (others => '0');
            y_r <= (others => '0');
            result_r <= (others => '0');
        elsif (rising_edge(clk)) then
            if (n_en = '1') then
                n_r <= n;
            end if;

            if (i_en = '1') then
                i_r <= std_logic_vector(i_mux_out);
            end if;

            if (x_en = '1') then
                x_r <= std_logic_vector(x_mux_out);
            end if;

            if (y_en = '1') then
                y_r <= std_logic_vector(y_mux_out);
            end if;

            if (result_en = '1') then
                result_r <= std_logic_vector(result_mux_out);
            end if;            
        end if;
    end process;

    i_mux_out <= "000010" when i_sel = '1' else i_add_out;
    x_mux_out <= (others => '0') when x_sel = '1' else unsigned(y_r);
    y_mux_out <= "00000000000000000000000000000001" when y_sel = '1' else xy_add_out;
    result_mux_out <= (others => '0') when result_sel = '1' else unsigned(y_r);
    
    i_add_out <= unsigned(i_r) + 1;
    xy_add_out <= unsigned(x_r) + unsigned(y_r);

    n_eq_0 <= '1' when unsigned(n_r) = 0 else '0';
    i_le_n <= '1' when unsigned(i_r) <= unsigned(n_r) else '0';

    result <= std_logic_vector(result_r);
end default_arch;
