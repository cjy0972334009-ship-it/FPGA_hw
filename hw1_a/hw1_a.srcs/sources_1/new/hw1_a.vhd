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

    -- 狀態控制旗標
    type state_type is (RUN_CNT1, RUN_CNT2);
    signal current_state : state_type;

    signal cnt1_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal cnt2_reg : STD_LOGIC_VECTOR (7 downto 0);
    
    signal cnt1_done, cnt2_done : STD_LOGIC;

begin

    cnt1 <= cnt1_reg;
    cnt2 <= cnt2_reg;

    --------------------------------------------------------------------
    -- 【關鍵修正】把 done 訊號改為「組合邏輯」
    -- 只要達到目標值，done 立刻為 '1'，讓狀態機能在下一個 Clock 馬上切換，避免多數一拍
    --------------------------------------------------------------------
    cnt1_done <= '1' when cnt1_reg = "1001" else '0';       -- 當 cnt1 到 9 時觸發
    cnt2_done <= '1' when cnt2_reg = "00010001" else '0';   -- 當 cnt2 到 17 時觸發

    --------------------------------------------------------------------
    -- 控制器：只負責仲裁輪流狀態
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
    -- 獨立 Process 1：完全專注負責 cnt1 的上數與歸零
    --------------------------------------------------------------------
    p_cnt1: process(clk, rest)
    begin
        if rest = '0' then
            cnt1_reg  <= "0000";
        elsif rising_edge(clk) then
            if current_state = RUN_CNT1 then
                if cnt1_reg < "1001" then
                    cnt1_reg <= cnt1_reg + 1;
                else
                    cnt1_reg  <= "0000";
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- 獨立 Process 2：完全專注負責 cnt2 的下數與重置
    --------------------------------------------------------------------
    p_cnt2: process(clk, rest)
    begin
        if rest = '0' then
            cnt2_reg  <= "11111101";
        elsif rising_edge(clk) then
            if current_state = RUN_CNT2 then
                if cnt2_reg > "00010001" then
                    cnt2_reg <= cnt2_reg - 1;
                else
                    cnt2_reg  <= "11111101";
                end if;
            end if;
        end if;
    end process;

end Behavioral;