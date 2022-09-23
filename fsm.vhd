library ieee;
use ieee.std_logic_1164.all;

entity fsm is
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        go   : in  std_logic;
        done : out std_logic;

        n_en       : out std_logic;
        result_en  : out std_logic;
        result_sel : out std_logic;
        x_en       : out std_logic;
        x_sel      : out std_logic;
        y_en       : out std_logic;
        y_sel      : out std_logic;
        i_en       : out std_logic;
        i_sel      : out std_logic;

        n_eq_0 : in std_logic;
        i_le_n : in std_logic
        );
end fsm;

architecture default_arch of fsm is
    type state_t is (START, IF_COND, COMPLETE_1, COMPLETE_2, LOOP_COND, CONTINUE, RESTART);
    signal state_r, next_state: state_t;    
begin
    process(clk, rst)
    begin
        if (rst = '1') then
            state_r <= START;
        elsif (rising_edge(clk)) then
            state_r <= next_state;
        end if;
    end process;

    process(state_r, go, n_eq_0, i_le_n)
    begin
        done <= '0';
        n_en <= '0';
        i_sel <= '0';
        i_en <= '0';
        x_sel <= '0';
        x_en <= '0';
        y_sel <= '0';
        y_en <= '0';
        result_sel <= '0';
        result_en <= '0';
        next_state <= state_r;
        case (state_r) is
            when START =>
                n_en <= '1';
                if (go = '1') then
                    x_sel <= '1';
                    x_en <='1';
                    y_sel <= '1';
                    y_en <='1';
                    i_sel <= '1';
                    i_en <= '1';
    
                    next_state <= IF_COND;
                end if;

            
            when IF_COND =>
                if (n_eq_0 = '1') then
                    next_state <= COMPLETE_1;
                else
                    next_state <= LOOP_COND;
                end if;
            

            when COMPLETE_1 =>
                --done <= '1';
                --result <= std_logic_vector(x_r);
                result_sel <= '1';
                result_en <= '1';
                next_state <= RESTART;


            --    state_r <= IF_COND_2;
            
            --when IF_COND_2 =>
            --    if (unsigned(n_r) = 1) then
            --        state_r <= COMPLETE_2;
            --    else
            --        state_r <= ELSE_BODY_2;
            --    end if;
            
                --temp := (others => '0');
                --n_i := to_integer(unsigned(n));
                --i := 2;
                --i_sel <= '0';
                --i_en <= '1';

            when LOOP_COND =>
                if (i_le_n = '0') then
                    next_state <= COMPLETE_2;
                else
                --temp := resize(unsigned(x_r), 32) + resize(unsigned(y_r), 32);
                --x_r := y_r;
                x_sel <= '0';
                x_en <= '1';
                --y_r := temp;
                y_sel <= '0';
                y_en <= '1';                    
                --i := i + 1;
               
                next_state <= CONTINUE;
                
                end if;
            
            when CONTINUE =>
                i_sel <= '0';
                i_en <= '1'; 
                next_state <= LOOP_COND;
            
            when COMPLETE_2 =>
                
                result_en <= '1';
                --result <= std_logic_vector(y_r);
                result_sel <= '0';
                next_state <= RESTART;
            


            when RESTART =>
                --n_r <= n;
                done <= '1';
                n_en <= '1';
                if (go = '1') then
                    x_sel <= '1';
                    x_en <='1';
                    y_sel <= '1';
                    y_en <='1';
                    i_sel <= '1';
                    i_en <= '1';
    
                    next_state <= IF_COND;
                end if;
            when others => null;
        end case;

    end process;
end default_arch;
