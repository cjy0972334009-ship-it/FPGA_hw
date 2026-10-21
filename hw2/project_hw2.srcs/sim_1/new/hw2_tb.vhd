library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hw2_tb is
end hw2_tb;

architecture behavior of hw2_tb is

    -- 宣告待測模組 (UUT)，必須與 hw2 剛修改的 Port 一模一樣
    component hw2
        Port ( 
            clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            pwm : out STD_LOGIC;
            out_upbnd1 : out STD_LOGIC_VECTOR(7 downto 0);
            out_upbnd2 : out STD_LOGIC_VECTOR(7 downto 0);
            out_cnt1   : out STD_LOGIC_VECTOR(7 downto 0);
            out_cnt2   : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- 系統輸入訊號
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    -- 系統與觀察用輸出訊號
    signal pwm        : std_logic;
    signal out_upbnd1 : std_logic_vector(7 downto 0);
    signal out_upbnd2 : std_logic_vector(7 downto 0);
    signal out_cnt1   : std_logic_vector(7 downto 0);
    signal out_cnt2   : std_logic_vector(7 downto 0);

    constant clk_period : time := 20 ns;

begin

    -- 例化並連線
    uut: hw2 port map (
        clk        => clk,
        rst        => rst,
        pwm        => pwm,
        out_upbnd1 => out_upbnd1,
        out_upbnd2 => out_upbnd2,
        out_cnt1   => out_cnt1,
        out_cnt2   => out_cnt2
    );

    -- 產生連續時脈
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- 產生重置訊號啟動電路
    stim_proc: process
    begin
        rst <= '0';
        wait for 100 ns;  
        rst <= '1';
        wait;
    end process;

end behavior;