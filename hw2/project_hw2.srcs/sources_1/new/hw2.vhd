library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity hw2 is
    Port ( 
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        pwm        : out STD_LOGIC;
        out_upbnd1 : out STD_LOGIC_VECTOR(7 downto 0);
        out_upbnd2 : out STD_LOGIC_VECTOR(7 downto 0);
        out_cnt1   : out STD_LOGIC_VECTOR(7 downto 0);
        out_cnt2   : out STD_LOGIC_VECTOR(7 downto 0)
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
    
    signal upbnd1 : STD_LOGIC_VECTOR(7 downto 0);
    signal upbnd2 : STD_LOGIC_VECTOR(7 downto 0);
    signal cnt1   : STD_LOGIC_VECTOR(7 downto 0);
    signal cnt2   : STD_LOGIC_VECTOR(7 downto 0);
    
    type STATE_TYPE is (DKing, BRing);
    signal state : STATE_TYPE;
    
    -- 邊界限制：40 到 200 (共 160 階)
	constant MAX_BOUND : STD_LOGIC_VECTOR(7 downto 0) := "11001000"; -- 200 (上限)
    constant MIN_BOUND : STD_LOGIC_VECTOR(7 downto 0) := "00101000"; -- 40  (下限)
    constant INIT_UP2  : STD_LOGIC_VECTOR(7 downto 0) := "00110111"; -- 55  (255 - 200 互補)
    
    -- 50MHz 下數 1,250,000 次 = 25ms (換算成 21 位元二進位)
    signal PWMcnt  : STD_LOGIC_VECTOR(20 downto 0);
    constant GLAZE : STD_LOGIC_VECTOR(20 downto 0) := "000000000000001111111"; --3秒   8秒100110001001011010000

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

    -- 時間分頻器：每 25ms 歸零一次
    PWM_Timer: process(clk, rst)
    begin
        if rst = '0' then
            PWMcnt <= (others => '0');
        elsif rising_edge(clk) then
            if PWMcnt >= GLAZE then
                PWMcnt <= (others => '0');
            else
                PWMcnt <= PWMcnt + 1;
            end if;
        end if;
    end process PWM_Timer;

    -- 狀態機：控制變暗或變亮
    FSM_top: process(clk, rst)
    begin
        if rst = '0' then
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
    
    -- 調整 upbnd1 (每 25ms 跳一步)
    Upper_bound1: process(clk, rst)
    begin
        if rst = '0' then
            upbnd1 <= MAX_BOUND;
        elsif rising_edge(clk) then
            case state is
                when DKing =>
                    if PWMcnt = GLAZE then 
                        upbnd1 <= upbnd1 - 1;
                    end if;
                when BRing =>
                    if PWMcnt = GLAZE then  
                        upbnd1 <= upbnd1 + 1;
                    end if;               
                when others =>
                    null;
            end case;            
        end if;    
    end process Upper_bound1;

    -- 調整 upbnd2 (維持互補)
    Upper_bound2: process(clk, rst)
    begin
        if rst = '0' then
            upbnd2 <= INIT_UP2;
        elsif rising_edge(clk) then
            case state is
                when DKing =>
                    if PWMcnt = GLAZE then 
                        upbnd2 <= upbnd2 + 1;
                    end if;
                when BRing =>
                    if PWMcnt = GLAZE then 
                        upbnd2 <= upbnd2 - 1;
                    end if;               
                when others =>
                    null;
            end case;            
        end if;    
    end process Upper_bound2;

    out_upbnd1 <= upbnd1;
    out_upbnd2 <= upbnd2;
    out_cnt1   <= cnt1;
    out_cnt2   <= cnt2;

end Behavioral;