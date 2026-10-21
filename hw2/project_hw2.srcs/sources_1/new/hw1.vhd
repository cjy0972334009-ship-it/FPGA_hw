library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity hw1 is
    Port ( 
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        up1    : in  STD_LOGIC_VECTOR (7 downto 0);
        up2    : in  STD_LOGIC_VECTOR (7 downto 0);
        count1 : out STD_LOGIC_VECTOR (7 downto 0);
        count2 : out STD_LOGIC_VECTOR (7 downto 0);
        pwm    : out STD_LOGIC                      
    );
end hw1;

architecture Behavioral of hw1 is
    signal count1_t : STD_LOGIC_VECTOR (7 downto 0);
    signal count2_t : STD_LOGIC_VECTOR (7 downto 0);
    signal state    : STD_LOGIC; 
begin
    count1 <= count1_t;
    count2 <= count2_t;
    pwm    <= state;

    -- 狀態控制
    process(clk, rst)
    begin
        if rst = '0' then 
            state <= '0';
        elsif rising_edge(clk) then
            if state = '0' then
                if count1_t >= up1 then
                    state <= '1';
                end if;
            else
                if count2_t >= up2 then
                    state <= '0';
                end if;
            end if;
        end if;
    end process;

    -- count1 計數 (state = '0' 時動作，其餘維持 0)
    process(clk, rst)
    begin
        if rst = '0' then 
            count1_t <= (others => '0');
        elsif rising_edge(clk) then
            if state = '0' then
                if count1_t >= up1 then
                    count1_t <= (others => '0');
                else
                    count1_t <= count1_t + 1;
                end if;
            end if;
        end if;
    end process;

    -- count2 計數 (state = '1' 時動作，其餘維持 0)
    process(clk, rst)
    begin
        if rst = '0' then 
            count2_t <= (others => '0');
        elsif rising_edge(clk) then
            if state = '1' then
                if count2_t >= up2 then
                    count2_t <= (others => '0');
                else
                    count2_t <= count2_t + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;