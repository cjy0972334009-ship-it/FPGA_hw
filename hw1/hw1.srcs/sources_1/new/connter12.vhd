library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity connter12 is
    Port ( 
        clk      : in  STD_LOGIC;
        rest     : in  STD_LOGIC;
        connter1 : out STD_LOGIC_VECTOR (3 downto 0);
        connter2 : out STD_LOGIC_VECTOR (7 downto 0)
    );
end connter12;

architecture Behavioral of connter12 is

    signal connter1_t : STD_LOGIC_VECTOR (3 downto 0);
    signal connter2_t : STD_LOGIC_VECTOR (7 downto 0);
    
    -- 近瑈北篨夹'0' 近 connter1 璸计'1' 近 connter2 璸计
    signal turn       : STD_LOGIC;

begin

    -- 块钡絬
    connter1 <= connter1_t;
    connter2 <= connter2_t;

    process(clk, rest)
    begin
        if rest = '0' then 
            connter1_t <= "0000";
            connter2_t <= "11111101"; -- 253
            turn       <= '0';        -- 竚パ connter1 秨﹍计

        elsif rising_edge(clk) then

            -- 近材舱璸计竟计
            if turn = '0' then
                if connter1_t < "1001" then
                    connter1_t <= connter1_t + 1;
                else
                    connter1_t <= "0000"; -- 计骸 9 耴箂
                    turn       <= '1';    -- ち传北舦倒 connter2
                end if;

            -- 近材舱璸计竟计
            else
                if connter2_t > "00010001" then
                    connter2_t <= connter2_t - 1;
                else
                    connter2_t <= "11111101"; -- 计 17 竚
                    turn       <= '0';        -- ち传北舦 connter1
                end if;
            end if;

        end if;
    end process;

end Behavioral;