library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        go     : in  std_logic;
        n      : in  std_logic_vector(5 downto 0);
        result : out std_logic_vector(31 downto 0);
        done   : out std_logic
        );
end fib;

-- TODO: Add your FSMD architecture here.

architecture fsmd of fib is
    type state_t is (START, IF_COND, ELSE_BODY, COMPLETE_1, COMPLETE_2, LOOP_COND, CONTINUE);
    signal state_r: state_t;
    signal n_r : std_logic_vector(n'range);  
begin
    process(rst, clk, n)
    variable temp : unsigned(31 downto 0);
    variable x_r : unsigned(31 downto 0);
    variable y_r : unsigned(31 downto 0);
    variable i : integer;  
    begin
        
        if (rst = '1') then
            done <= '0';
            result <= (others => '0');
            state_r <= START;
        elsif (rising_edge(clk)) then
            case (state_r) is
                when START =>
                    n_r <= n;
                    if (go = '1') then
                        done <= '0';
                        x_r := (others => '0');
                        y_r := "00000000000000000000000000000001";                    
    
                        state_r <= IF_COND;

                    end if;
                
                when IF_COND =>
                    if (unsigned(n_r) = 0) then
                        state_r <= COMPLETE_1;
                    else
                        state_r <= ELSE_BODY;
                    end if;

                when COMPLETE_1 =>
                    done <= '1';
                    result <= std_logic_vector(x_r);
                    
                    state_r <= START;
                
                when ELSE_BODY =>
                    i := 2;
                    state_r <= LOOP_COND;
               
                when LOOP_COND =>
                    if i > unsigned(n) then
                        state_r <= COMPLETE_2;
                    else
                        state_r <= CONTINUE;
                    end if;

                when CONTINUE =>
                    temp := resize(unsigned(x_r), 32) + resize(unsigned(y_r), 32);
                    x_r := y_r;
                    y_r := temp;
                    i := i + 1;
                    state_r <= LOOP_COND;



                when COMPLETE_2 =>
                    done <= '1';
                    result <= std_logic_vector(y_r);
                    
                    state_r <= START;
                
                when others => null;

            end case;
        end if;
    end process;
end fsmd;


-- TODO: Complete the FSM+D architecture here. Some signals are provided to
-- speed things up. You only need to connect the FSM and datapath together.

architecture fsm_plus_d of fib is

    signal n_en       : std_logic;
    signal result_en  : std_logic;
    signal result_sel : std_logic;
    signal x_en       : std_logic;
    signal x_sel      : std_logic;
    signal y_en       : std_logic;
    signal y_sel      : std_logic;
    signal i_en       : std_logic;
    signal i_sel      : std_logic;
    signal n_eq_0     : std_logic;
    signal i_le_n     : std_logic;

begin
    U_FSM : entity work.fsm
    port map(
        clk => clk,
        rst => rst,
        go => go,
        done => done,

        n_en => n_en,
        result_en => result_en,
        result_sel => result_sel,
        x_en => x_en,
        x_sel => x_sel,
        y_en => y_en,
        y_sel => y_sel,
        i_en => i_en,
        i_sel => i_sel,

        n_eq_0 => n_eq_0,
        i_le_n => i_le_n
    );

    U_DP : entity work.datapath
    port map(
        clk => clk,
        rst => rst,
        n => n,
        result => result,

        n_en => n_en,
        result_en => result_en,
        result_sel => result_sel,
        x_en => x_en,
        x_sel => x_sel,
        y_en => y_en,
        y_sel => y_sel,
        i_en => i_en,
        i_sel => i_sel,

        n_eq_0 => n_eq_0,
        i_le_n => i_le_n
    );
    
end fsm_plus_d;


-- TODO: Change the architecture that is used to simulate and synthesis each
-- architecture.

architecture default_arch of fib is
begin

    --U_FIB : entity work.fib(fsmd)
    U_FIB : entity work.fib(fsm_plus_d)
        port map (
            clk    => clk,
            rst    => rst,
            go     => go,
            n      => n,
            result => result,
            done   => done
            );

end default_arch;
