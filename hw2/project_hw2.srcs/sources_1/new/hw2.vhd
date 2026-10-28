library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity hw2 is
    Port ( 
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;                    -- BTNC (高電位觸發重置)
        gear_period : in  STD_LOGIC_VECTOR(1 downto 0); -- SW1, SW0：週期檔位 (3s, 5s, 8s, 10s)
        gear_bright : in  STD_LOGIC;                    -- SW2：亮度檔位 (0: 50% / 1: 100%)
        gear_res    : in  STD_LOGIC;                    -- SW4：解析度選擇 (0: 高 / 1: 低)
        pwm         : out STD_LOGIC                     -- LED0 輸出
    );
end hw2;

architecture Behavioral of hw2 is

    component hw1
        Port ( 
            clk    : in  STD_LOGIC;
            rst    : in  STD_LOGIC;
            up1    : in  STD_LOGIC_VECTOR(7 downto 0);
            up2    : in  STD_LOGIC_VECTOR(7 downto 0);           
            count1 : out STD_LOGIC_VECTOR(7 downto 0);
            count2 : out STD_LOGIC_VECTOR(7 downto 0);
            pwm    : out STD_LOGIC           
        );
    end component;
    
    signal upbnd1     : STD_LOGIC_VECTOR(7 downto 0);
    signal upbnd2     : STD_LOGIC_VECTOR(7 downto 0);
    signal cnt1       : STD_LOGIC_VECTOR(7 downto 0);
    signal cnt2       : STD_LOGIC_VECTOR(7 downto 0);
    
    type STATE_TYPE is (DKing, BRing);
    signal state : STATE_TYPE;
    
    -- 動態邊界與步進大小
    signal MAX_BOUND  : STD_LOGIC_VECTOR(7 downto 0);
    constant MIN_BOUND: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; -- 0 (0% 最暗)
    signal step_size  : STD_LOGIC_VECTOR(7 downto 0);
    
    -- 23-bit 計數器與 GLAZE 常數
    signal PWMcnt     : STD_LOGIC_VECTOR(22 downto 0);
    signal GLAZE      : STD_LOGIC_VECTOR(22 downto 0);

begin

    u_hw1 : hw1
    port map (
        clk    => clk,
        rst    => rst,
        up1    => upbnd1,
        up2    => upbnd2,           
        count1 => cnt1,
        count2 => cnt2,
        pwm    => pwm  
    );

    --------------------------------------------------------------------
    -- 加分項一：亮度 Ceiling 控制 (SW2: 2個檔位)
    --------------------------------------------------------------------
    process(gear_bright)
    begin
        if gear_bright = '0' then
            MAX_BOUND <= "01111111"; -- 50% 最高亮度 (127)
        else
            MAX_BOUND <= "11111111"; -- 100% 最高亮度 (255)
        end if;
    end process;

    --------------------------------------------------------------------
    -- 加分項二：解析度 Resolution 切換 (SW4)
    --------------------------------------------------------------------
    process(gear_res)
    begin
        if gear_res = '0' then
            step_size <= "00000001"; -- 高解析度：步進 1 (共 256 階)
        else
            step_size <= "00000100"; -- 低解析度：步進 4 (共 64 階)
        end if;
    end process;

    --------------------------------------------------------------------
    -- 加分項三：動態時基運算 (週期與解析度切換)
    --------------------------------------------------------------------
    process(gear_period, gear_res)
    begin
        if gear_res = '0' then
            -- 高解析度 (256 階)
            case gear_period is
                when "00" => GLAZE <= "00000100011111001101011"; -- 3秒
                when "01" => GLAZE <= "00000111101110110101000"; -- 5秒
                when "10" => GLAZE <= "00001011111101110110011"; -- 8秒
                when others => GLAZE <= "00001110111101011010000"; -- 10秒
            end case;
        else
            -- 低解析度 (64 階)
            case gear_period is
                when "00" => GLAZE <= "00100111100001001000110"; -- 3秒
                when "01" => GLAZE <= "00111011100110101100010"; -- 5秒
                when "10" => GLAZE <= "01011110101111000010000"; -- 8秒
                when others => GLAZE <= "01110110101111111011000"; -- 10秒
            end case;
        end if;
    end process;

    --------------------------------------------------------------------
    -- 分頻計時器 (Active-High Reset)
    --------------------------------------------------------------------
    PWM_Timer: process(clk, rst)
    begin
        if rst = '1' then
            PWMcnt <= (others => '0');
        elsif rising_edge(clk) then
            if PWMcnt >= GLAZE then
                PWMcnt <= (others => '0');
            else
                PWMcnt <= PWMcnt + 1;
            end if;
        end if;
    end process PWM_Timer;

    --------------------------------------------------------------------
    -- FSM 狀態控制器
    --------------------------------------------------------------------
    FSM_top: process(clk, rst)
    begin
        if rst = '1' then
            state <= DKing;
        elsif rising_edge(clk) then
            case state is
                when DKing =>
                    if upbnd1 <= MIN_BOUND then
                        state <= BRing;
                    end if;
                when BRing =>
                    if upbnd1 >= MAX_BOUND then
                        state <= DKing;
                    end if;                
                when others =>
                    null;
            end case;
        end if;
    end process FSM_top;
    
    --------------------------------------------------------------------
    -- 上限變數 1 調整
    --------------------------------------------------------------------
    Upper_bound1: process(clk, rst)
    begin
        if rst = '1' then
            upbnd1 <= MAX_BOUND;
        elsif rising_edge(clk) then
            case state is
                when DKing =>
                    if PWMcnt = GLAZE then 
                        if upbnd1 >= step_size then
                            upbnd1 <= upbnd1 - step_size;
                        else
                            upbnd1 <= MIN_BOUND;
                        end if;
                    end if;
                when BRing =>
                    if PWMcnt = GLAZE then  
                        if upbnd1 + step_size <= MAX_BOUND then
                            upbnd1 <= upbnd1 + step_size;
                        else
                            upbnd1 <= MAX_BOUND;
                        end if;
                    end if;               
                when others =>
                    null;
            end case;            
        end if;    
    end process Upper_bound1;

    --------------------------------------------------------------------
    -- 上限變數 2 調整
    --------------------------------------------------------------------
    Upper_bound2: process(clk, rst)
    begin
        if rst = '1' then
            upbnd2 <= "00000000";
        elsif rising_edge(clk) then
            case state is
                when DKing =>
                    if PWMcnt = GLAZE then 
                        upbnd2 <= "11111111" - upbnd1;
                    end if;
                when BRing =>
                    if PWMcnt = GLAZE then 
                        upbnd2 <= "11111111" - upbnd1;
                    end if;               
                when others =>
                    null;
            end case;            
        end if;    
    end process Upper_bound2;

end Behavioral;