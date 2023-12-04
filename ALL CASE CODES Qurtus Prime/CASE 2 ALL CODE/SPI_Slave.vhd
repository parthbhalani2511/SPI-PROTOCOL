----------------------------------------------------------------------------------------------------------------------
--  Generics:    SPI_MODE, can be 0, 1, 2, or 3.                     
--              Can be configured in one of 4 modes:
--              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
--               0   |             0             |        0
--               1   |             0             |        1
--               2   |             1             |        0
--               3   |             1             |        1
---------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity SPI_SLAVE is
    generic (
      CPOL       :in std_logic;   --clock polarity mode
      CPHA       :in std_logic;   --clock phase mode
      DATA_LENGTH: integer := 8 -- data bit length
    );
    port (
      SCLK          : in  std_logic; --spi clk
      SS_N          : in  std_logic; --slave select active low
      MOSI          : in  std_logic; --master out slave in
      MISO          : out std_logic; --master in slave out
      RST_N         : in  std_logic; --asynchronous active low reset
      RX_DATA       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      RX_DATA_VALID : out std_logic; --receved data valid
      TX_DATA       : in std_logic_vector(DATA_LENGTH-1 downto 0) --transmitted data
    );
end SPI_SLAVE;

architecture Behavioral of SPI_SLAVE is
    signal TX_SHIFT_REGISTER    : std_logic_vector(7 downto 0);
    signal RX_SHIFT_REGISTER    : std_logic_vector(7 downto 0);
    signal TX_BIT_COUNTER       : integer range 0 to 8;
    signal RX_BIT_COUNTER       : integer range 0 to 8;
    
begin
RX_DATA <= RX_SHIFT_REGISTER;
MISO <= TX_SHIFT_REGISTER(7);

-- RX
rx_CPOL_falling : if CPOL = '0' generate  -- falling edge RX
    process (SCLK,RST_N)
    begin
        if RST_N = '0' then
            RX_SHIFT_REGISTER <= (others => '0');
            RX_BIT_COUNTER <= 0;
            RX_DATA_VALID <= '0';
        elsif FALLING_EDGE(SCLK) then
            
            if SS_N = '0' and RX_BIT_COUNTER = 0 then
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MOSI;
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_DATA_VALID <= '0';

            elsif SS_N = '0' and RX_BIT_COUNTER /= 8 then
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MOSI;
            else 
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MOSI;
                RX_DATA_VALID <= '1';
                RX_BIT_COUNTER <= 0;
            end if;
            
        end if;
    end process;
end generate rx_CPOL_falling;

rx_CPOL_rising : if CPOL = '1' generate  --rising edge RX
    process (SCLK,RST_N)
    begin
        if RST_N = '0' then
            RX_SHIFT_REGISTER <= (others => '0');
            RX_BIT_COUNTER <= 0;
            RX_DATA_VALID <= '0';
        elsif RISING_EDGE(SCLK) then
            
            if SS_N = '0' and RX_BIT_COUNTER = 0 then
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MOSI;
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_DATA_VALID <= '0';

            elsif SS_N = '0' and RX_BIT_COUNTER /= 8 then
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MOSI;
            else 
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MOSI;
                RX_DATA_VALID <= '1';
                RX_BIT_COUNTER <= 0;
            end if;
            
        end if;
    end process;
end generate rx_CPOL_rising;

-- TX
tx_falling :  if CPOL = '0' generate
    process(SCLK, RST_N)
    begin
        if RST_N = '0' then
            TX_SHIFT_REGISTER <= (others => '0');
            TX_BIT_COUNTER <= 0;
        
        elsif FALLING_EDGE(SCLK) then
            if SS_N = '0' and TX_BIT_COUNTER = 0 then
                TX_SHIFT_REGISTER <= TX_DATA;
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;
            elsif SS_N = '0' and TX_BIT_COUNTER /= 8 then
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER(6 downto 0) & '1';
            else  
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER;
                TX_BIT_COUNTER <= 0;
            end if;
        end if;
    end process;
end generate tx_falling;

tx_rising : if CPOL = '1' generate 
    process(SCLK, RST_N)
    begin
        if RST_N = '0' then
            TX_SHIFT_REGISTER <= (others => '0');
            TX_BIT_COUNTER <= 0;
        
        elsif RISING_EDGE(SCLK) then
            if SS_N = '0' and TX_BIT_COUNTER = 0 then
                TX_SHIFT_REGISTER <= TX_DATA;
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;
            elsif SS_N = '0' and TX_BIT_COUNTER /= 8 then
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER(6 downto 0) & '1';
            else  
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER;
                TX_BIT_COUNTER <= 0;
            end if;
        end if;
    end process;
end generate tx_rising;
  
end Behavioral;