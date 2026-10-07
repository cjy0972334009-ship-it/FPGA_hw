library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity hw1_a is
    Port ( 
        clk  : in  STD_LOGIC;
        rest : in  STD_LOGIC;
        cnt1 : out STD_LOGIC_VECTOR (3 downto 0);
        cnt2 : out STD_LOGIC_VECTOR (7 downto 0)
    );
end hw1_a;

architecture Behavioral of hw1_a is

    -- 篈北篨夹
    type state_type is (RUN_CNT1, RUN_CNT2);
    signal current_state : state_type;

    signal cnt1_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal cnt2_reg : STD_LOGIC_VECTOR (7 downto 0);
    
    signal cnt1_done, cnt2_done : STD_LOGIC;

begin

    cnt1 <= cnt1_reg;
    cnt2 <= cnt2_reg;

    --------------------------------------------------------------------
    -- 北竟璽砫ヲ掉近瑈篈
    --------------------------------------------------------------------
    p_fsm: process(clk, rest)
    begin
        if rest = '0' then
            current_state <= RUN_CNT1;
        elsif rising_edge(clk) then
            case current_state is
                when RUN_CNT1 =>
                    if cnt1_done = '1' then
                        current_state <= RUN_CNT2;
                    end if;
                when RUN_CNT2 =>
                    if cnt2_done = '1' then
                        current_state <= RUN_CNT1;
                    end if;
            end case;
        end if;
    end process;

    --------------------------------------------------------------------
    -- 縒ミ Process 1Ч盡猔璽砫 cnt1 计籔耴箂
    --------------------------------------------------------------------
    p_cnt1: process(clk, rest)
    begin
        if rest = '0' then
            cnt1_reg  <= "0000";
            cnt1_done <= '0';
        elsif rising_edge(clk) then
            cnt1_done <= '0';
            if current_state = RUN_CNT1 then
                if cnt1_reg < "1001" then
                    cnt1_reg <= cnt1_reg + 1;
                else
                    cnt1_reg  <= "0000";
                    cnt1_done <= '1';
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- 縒ミ Process 2Ч盡猔璽砫 cnt2 计籔竚
    --------------------------------------------------------------------
    p_cnt2: process(clk, rest)
    begin
        if rest = '0' then
            cnt2_reg  <= "11111101";
            cnt2_done <= '0';
        elsif rising_edge(clk) then
            cnt2_done <= '0';
            if current_state = RUN_CNT2 then
                if cnt2_reg > "00010001" then
                    cnt2_reg <= cnt2_reg - 1;
                else
                    cnt2_reg  <= "11111101";
                    cnt2_done <= '1';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
