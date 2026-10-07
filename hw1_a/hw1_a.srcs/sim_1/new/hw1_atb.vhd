library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hw1_a_tb is
-- 測試程式不需要 Port 宣告
end hw1_a_tb;

architecture Behavioral of hw1_a_tb is

    -- 宣告待測元件 (DUT)
    component hw1_a
        Port ( 
            clk  : in  STD_LOGIC;
            rest : in  STD_LOGIC;
            cnt1 : out STD_LOGIC_VECTOR (3 downto 0);
            cnt2 : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- 宣告連接的訊號
    signal clk_tb  : STD_LOGIC := '0';
    signal rest_tb : STD_LOGIC := '0';
    signal cnt1_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal cnt2_tb : STD_LOGIC_VECTOR (7 downto 0);

    -- 定義時脈週期為 10 ns (頻率 100MHz)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 例化(接線)主程式元件
    uut: hw1_a port map (
        clk  => clk_tb,
        rest => rest_tb,
        cnt1 => cnt1_tb,
        cnt2 => cnt2_tb
    );

    -- 產生時脈訊號 (Clock)
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 產生激勵訊號 (Stimulus)
    stim_proc: process
    begin
        -- 1. 系統重置 (Active-Low)
        -- 你的主程式是 if rest = '0' then 觸發重置
        rest_tb <= '0'; 
        wait for 20 ns;  -- 維持重置狀態 2 個 Clock 週期

        -- 2. 釋放重置
        -- 給予 '1' 讓狀態機與計數器開始正常運作
        rest_tb <= '1'; 
        
        -- 3. 讓系統運作一段足夠長的時間來觀察輪流切換
        -- cnt1 需要 10 個 Clock (100 ns)
        -- cnt2 從 253 倒數至 17 需要 237 個 Clock (2370 ns)
        -- 一個完整輪迴約需 2470 ns。這裡設定跑 6000 ns 讓你可觀察兩次完整的循環
        wait for 6000 ns; 

        -- 4. 結束模擬 (暫停 process)
        wait; 
    end process;

end Behavioral;