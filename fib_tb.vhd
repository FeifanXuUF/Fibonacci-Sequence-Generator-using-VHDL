library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fib_tb is
end fib_tb;

architecture tb of fib_tb is
    signal clk    :   std_logic := '1';
    signal rst    :   std_logic;
    signal go     :   std_logic;
    signal n      :   std_logic_vector(5 downto 0);
    signal result :   std_logic_vector(31 downto 0);
    signal done   :   std_logic;  
begin
    UUT : entity work.fib(default_arch)
    port map (
        clk => clk,
        rst => rst,
        go => go,
        done => done,
        n => n,
        result => result);
    clk <= not clk after 5 ns;
    process
    begin
        n <= std_logic_vector(to_unsigned(0,6));
        go <= '0';
        rst <= '1';
        wait until rising_edge(clk);
        rst <= '0';
        wait until rising_edge(clk);
        
        
        
        n <= std_logic_vector(to_unsigned(5,6));
        go <= '1';
        wait until rising_edge(clk);
        go <= '0';
        wait until rising_edge(clk);
        wait until done = '1';
        assert(unsigned(result) = 5) report "ERROR: Incorrect result." severity failure;

        n <= std_logic_vector(to_unsigned(10,6));
        go <= '1';
        wait until rising_edge(clk);
        go <= '0';
        wait until rising_edge(clk);
        wait until done = '1';
        assert(unsigned(result) = 55) report "ERROR: Incorrect result." severity failure;

        n <= std_logic_vector(to_unsigned(27,6));
        go <= '1';
        wait until rising_edge(clk);
        go <= '0';
        wait until rising_edge(clk);
        wait until done = '1';
        assert(unsigned(result) = 196418) report "ERROR: Incorrect result." severity failure;

        n <= std_logic_vector(to_unsigned(31,6));
        go <= '1';
        wait until rising_edge(clk);
        go <= '0';
        wait until rising_edge(clk);
        wait until done = '1';
        assert(unsigned(result) = 1346269) report "ERROR: Incorrect result." severity failure;

        n <= std_logic_vector(to_unsigned(39,6));
        go <= '1';
        wait until rising_edge(clk);
        go <= '0';
        wait until rising_edge(clk);
        wait until done = '1';
        assert(unsigned(result) = 63245986) report "ERROR: Incorrect result." severity failure;

        n <= std_logic_vector(to_unsigned(46,6));
        go <= '1';
        wait until rising_edge(clk);
        go <= '0';
        wait until rising_edge(clk);
        wait until done = '1';
        assert(unsigned(result) = 1836311903) report "ERROR: Incorrect result." severity failure;

        n <= std_logic_vector(to_unsigned(47,6));
        go <= '1';
        wait until rising_edge(clk);
        go <= '0';
        wait until rising_edge(clk);
        wait until done = '1';
        assert(unsigned(result) = "10110001000110010010010011100001") report "ERROR: Incorrect result." severity failure;




        wait;
    end process;


    --process
    --begin
    --   wait for 6000 ns; --run the simulation for this duration
    --    assert false
    --        report "simulation ended"
    --        severity failure;
    --end process;
end tb;
