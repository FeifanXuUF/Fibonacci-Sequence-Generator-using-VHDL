-- Greg Stitt
-- University of Florida

-- This testbench implements a simple constrained-random verification strategy
-- for the Fibonacci calculator. It also verifies the correct timing of the
-- done signal.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fib_crv_tb is
end fib_crv_tb;

architecture crv of fib_crv_tb is

    constant NUM_TESTS : integer := 10000;
    constant MAX_N : integer := 47;

    signal clk_en : std_logic := '1';
    signal clk    : std_logic := '0';
    signal rst    : std_logic;
    signal go     : std_logic;
    signal n      : std_logic_vector(5 downto 0);
    signal result : std_logic_vector(31 downto 0);
    signal done   : std_logic;

    signal check_done_low : std_logic;
    signal prev_done      : std_logic;
    signal prev_go        : std_logic;
    signal done_fell      : std_logic;

    -- Reference model
    function model(n : std_logic_vector(5 downto 0)) return unsigned is
        variable i                  : unsigned(5 downto 0);
        variable x, y, temp, result : unsigned(31 downto 0);
        
    begin
        i := to_unsigned(2, i'length);
        x := to_unsigned(0, x'length);
        y := to_unsigned(1, y'length);

        if (unsigned(n) = 0) then
            return to_unsigned(0, x'length);
        end if;

        while (i <= unsigned(n)) loop
            temp := x + y;
            x    := y;
            y    := temp;
            i    := i + 1;
        end loop;

        return y;
        
    end function;
    
begin

    -- Instantiate the design under test.
    DUT : entity work.fib
        port map (
            clk    => clk,
            rst    => rst,
            go     => go,
            n      => n,
            result => result,
            done   => done
            );

    clk <= not clk and clk_en after 5 ns;

    -- Generate tests, drive the inputs, monitor the output, and verify the
    -- output.
    process
        variable seed1, seed2 : positive := 1;
        variable rand_val     : real;

        variable min_test : boolean := false;
        variable max_test : boolean := false;
        
        variable passed, failed : integer;
    begin
        passed := 0;
        failed := 0;

        -- Reset the design.
        rst <= '1';
        go  <= '0';
        n   <= (others => '0');
        for i in 0 to 3 loop
            wait until rising_edge(clk);
        end loop;

        -- Clear reset.
        rst <= '0';
        wait until rising_edge(clk);

        for i in 0 to NUM_TESTS-1 loop

            -- Generate data input.
            uniform(seed1, seed2, rand_val);
            n <= std_logic_vector(to_unsigned(integer(floor(rand_val * real(MAX_N+1))), n'length));

            go <= '1';
            wait until rising_edge(clk);

            -- Check for coverage of max and min n values.
            if (unsigned(n) = 0) then
                min_test := true;
            elsif (unsigned(n) = 47) then
                max_test := true;
            end if;
                                
            go <= '0';

            -- Wait for done to fall to '0'. Done should always be 1 after the
            -- assertion of go, which is checked by a concurrent
            -- assertion. This just makes sure the rest of the testbench still
            -- works when that error occurs.
            if (done = '1') then
                wait until rising_edge(clk) and done = '0' for 1 us;
            end if;

            -- Wait until done is asserted (unless it already is).
            if (done = '0') then
                wait until rising_edge(clk) and done = '1' for 5 us;
            end if;

            -- Check for errors
            if (done = '0') then
                report "Test failed: done never asserted.";
                failed := failed + 1;
            elsif (unsigned(result) = model(n)) then
                passed := passed + 1;
            else
                report "Test failed: result " & integer'image(to_integer(unsigned(result))) & " instead of " & integer'image(to_integer(model(n)));
                failed := failed + 1;
            end if;

            -- Wait in between tests to allow for errors involving done not
            -- being asserted indefinitely.
            for i in 0 to 3 loop
                wait until rising_edge(clk);
            end loop;
        end loop;

        clk_en <= '0';
        -- Check for coverage of minimum and maximum N values.
        if (not min_test) then
            report "Coverage failure: did not test n=0.";
        end if;                

        if (not max_test) then
            report "Coverage failure: did not test n=47.";
        end if;                

        -- Report final message.
        report "Tests completed: " & integer'image(passed) & " passed, " & integer'image(failed) & " failed.";
        wait;
    end process;

    -- We also need to make sure that done is cleared within one cycle of go
    -- being asserted. With PSL or SystemVerilog, this is trivial:
    --
    -- assert property (@(posedge clk) disable iff (rst) go && done |=> !done);
    --
    -- However, in vanilla VHDL without PSL, we have to check this manually.
    -- I use the following process to know when I should check to see if
    -- done is '0'.

    process(clk, rst)
    begin
        if (rst = '1') then
            check_done_low <= '0';
        elsif (rising_edge(clk)) then
            check_done_low <= go and done;
        end if;
    end process;

    -- I then use an assert to make sure done is low at the appropriate time.
    assert(not(rising_edge(clk) and check_done_low = '1' and done = '1')) report "Done not cleared after assertion of go.";


    -- We should also ideally check to see if done remains asserted
    -- indefinitely until go is asserted again. With PSL, that would be as
    -- simple as:
    --
    -- assert property (@(posedge clk) disable iff (rst) $fell(done) |-> $past(go,1));
    --
    -- As an alternative, we can include code to detect if done has fallen,
    -- while also tracking the previous value of go.
    
    process(clk, rst)
    begin
        if (rst = '1') then
            prev_done <= '0';
            prev_go <= '0';          
        elsif (rising_edge(clk)) then
            prev_done <= done;
            prev_go   <= go;
        end if;
    end process;

    -- Done falls if it is currently '0' and was previously '1'.
    done_fell <= '1' when done = '0' and prev_done = '1' else '0';

    -- We can check to see if done is asserted indefinitely by reporting an
    -- error if done has fallen without go being asserted.
    assert(not(rising_edge(clk) and done_fell = '1' and prev_go = '0')) report "Done cleared before assertion of go.";        
    
end crv;
