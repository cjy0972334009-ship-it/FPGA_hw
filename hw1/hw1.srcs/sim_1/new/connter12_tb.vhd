library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_connter12 is
end tb_connter12;

architecture Behavioral of tb_connter12 is

    -- 宣告待測元件 (UUT)
    component connter12
        Port ( 
            clk      : in  STD_LOGIC;
            rest     : in  STD_LOGIC;
            connter1 : out STD_LOGIC_VECTOR (3 downto 0);
            connter2 : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- 測試訊號宣告
    signal clk_tb      : STD_LOGIC := '0';
    signal rest_tb     : STD_LOGIC := '0';
    signal connter1_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal connter2_tb : STD_LOGIC_VECTOR (7 downto 0);

    -- 設定時脈週期 (100MHz = 10ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 元件映射
    uut: connter12 port map (
        clk      => clk_tb,
        rest     => rest_tb,
        connter1 => connter1_tb,
        connter2 => connter2_tb
    );

    -- 時脈產生程序 (Clock Process)
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 測試激勵訊號程序 (Stimulus Process)
    stim_proc: process
    begin
        -- 1. 重置階段 (非同步低電位重置)
        rest_tb <= '0';
        wait for 25 ns;

        -- 2. 釋放重置，開始測試
        rest_tb <= '1';

        -- 3. 運行足夠長的週期以觀察完整交替：
        -- connter1 跑 10 週期 + connter2 跑 237 週期 ? 250 週期
        -- 跑 300 個週期 (3000 ns) 可完整看到 1 輪交替並進入第 2 輪
        wait for CLK_PERIOD * 300;

        -- 4. 結束模擬
        wait;
    end process;

end Behavioral;