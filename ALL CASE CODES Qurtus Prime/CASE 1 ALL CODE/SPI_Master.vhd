----------------------------------------------------------------------------------------------------------------------
--  Generics:    SPI_MODE, can be 0, 1, 2, or 3.                     
--              Can be configured in one of 4 modes:-
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

entity SPI_MASTER is
    generic (
      CPOL       : in std_logic;   --clock polarity mode
      CPHA       : in std_logic;   --clock phase mode
      DATA_LENGTH: integer := 8;    -- data bit length 
      CLK_DIV    : integer := 4   --system clock cycles per 1/2 period of sclk
    );
    port (
      CLK           : in  std_logic; --free running clock
      RST_N         : in  std_logic; --asynchronous active low reset
      TX_DATA       : in std_logic_vector(DATA_LENGTH-1 downto 0); --transmitted data
      TX_DATA_VALID : in std_logic; --transmit data valid
      MISO          : in std_logic; --master in slave out
      MOSI          : out  std_logic; --master out slave in
      SCLK          : out std_logic; -- serial clock
      SS_N          : out std_logic; --slave select active low
      RX_DATA       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      RX_DATA_VALID : out std_logic --receved data valid
    );
end SPI_MASTER;

architecture Behavioral of SPI_MASTER is
    signal sample_edge          : std_logic := '0'; --current clk_div;
    signal TX_SHIFT_REGISTER    : std_logic_vector(7 downto 0);
    signal RX_SHIFT_REGISTER    : std_logic_vector(7 downto 0);
    signal TX_BIT_COUNTER       : integer range 0 to 8;
    signal RX_BIT_COUNTER       : integer range 0 to 8;
    signal SS_N_INT             : std_logic;
    signal SCLK_INT             : std_logic;

begin

SS_N <= SS_N_INT;
SCLK <= SCLK_INT;
MOSI <= TX_SHIFT_REGISTER(7);
RX_DATA <= RX_SHIFT_REGISTER;

-- SCLK Generation Process
process (CLK, RST_N)
  begin
    if RST_N = '0' then
      SCLK_INT <= CPOL;
      sample_edge <= '0';
    elsif RISING_EDGE(CLK) then
        if CPHA = '0' then
            -- Leading Edge (Data sampled on rising edge)
            if sample_edge = '0' then
                sample_edge <= '1';
                SCLK_INT <= NOT SCLK_INT; -- Toggle the clock
            else
                sample_edge <= '0';
            end if;
        else
            -- Trailing Edge (Data sampled on falling edge)
            if sample_edge = '1' then
                sample_edge <= '1';
                SCLK_INT <= NOT SCLK_INT; -- Toggle the clock
            else
                sample_edge <= '1';
            end if;
        end if;
    end if;
end process;

-- SS_N Process
process (CLK, RST_N)
  begin
    if RST_N = '0' then
     SS_N_INT <= '1';
    elsif TX_DATA_VALID = '1' then
         SS_N_INT <= '0';
    elsif TX_DATA_VALID = '0' then
        if TX_BIT_COUNTER = 8 then
            SS_N_INT <= '1';
        end if; 
    end if;
end process;

-- SPI Transmission Process
TX_CPOL_falling : if CPOL = '0' generate --falling edge TX
    process(SCLK_INT, RST_N)
    begin
        if RST_N = '0' then
            TX_SHIFT_REGISTER <= (others => '0');
            TX_BIT_COUNTER <= 0;
        elsif FALLING_EDGE(SCLK_INT) then
            if TX_DATA_VALID = '1' and TX_BIT_COUNTER = 0 then
                TX_SHIFT_REGISTER <= TX_DATA;
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;

            elsif TX_DATA_VALID = '1' and TX_BIT_COUNTER /= 8 then
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER(6 downto 0) & '1';
            else  
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER;
                TX_BIT_COUNTER <= 0;
            end if;
        end if;
    end process;
end generate TX_CPOL_falling;

TX_CPOL_rising : if CPOL = '1' generate --rising edge TX
    process(SCLK_INT, RST_N)
    begin
        if RST_N = '0' then
            TX_SHIFT_REGISTER <= (others => '0');
            TX_BIT_COUNTER <= 0;
        elsif RISING_EDGE(SCLK_INT) then
            if TX_DATA_VALID = '1' and TX_BIT_COUNTER = 0 then
                TX_SHIFT_REGISTER <= TX_DATA;
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;

            elsif TX_DATA_VALID = '1' and TX_BIT_COUNTER /= 8 then
                TX_BIT_COUNTER <= TX_BIT_COUNTER + 1;
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER(6 downto 0) & '1';
            else  
                TX_SHIFT_REGISTER <= TX_SHIFT_REGISTER;
                TX_BIT_COUNTER <= 0;
            end if;
        end if;
    end process;
end generate TX_CPOL_rising;


-- SPI Reception Process
RX_falling :  if CPOL = '0' generate --falling edge RX
    process (SCLK_INT,RST_N)
    begin
        if RST_N = '0' then
            RX_SHIFT_REGISTER <= (others => '0');
            RX_BIT_COUNTER <= 0;
            RX_DATA_VALID <= '0';
        elsif FALLING_EDGE(SCLK_INT) then
            
            if SS_N_INT = '0' and RX_BIT_COUNTER = 0 then
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MISO;
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_DATA_VALID <= '0';

            elsif SS_N_INT = '0' and RX_BIT_COUNTER /= 8 then
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MISO;
            else 
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MISO;
                RX_DATA_VALID <= '1';
                RX_BIT_COUNTER <= 0;
            end if;
            
        end if;
    end process;
end generate RX_falling;

RX_rising :  if CPOL = '1' generate --rising edge RX
    process (SCLK_INT,RST_N)
    begin
        if RST_N = '0' then
            RX_SHIFT_REGISTER <= (others => '0');
            RX_BIT_COUNTER <= 0;
            RX_DATA_VALID <= '0';
        elsif RISING_EDGE(SCLK_INT) then
            
            if SS_N_INT = '0' and RX_BIT_COUNTER = 0 then
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MISO;
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_DATA_VALID <= '0';

            elsif SS_N_INT = '0' and RX_BIT_COUNTER /= 8 then
                RX_BIT_COUNTER <= RX_BIT_COUNTER + 1;
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MISO;
            else 
                RX_SHIFT_REGISTER <= RX_SHIFT_REGISTER(6 downto 0) & MISO;
                RX_DATA_VALID <= '1';
                RX_BIT_COUNTER <= 0;
            end if;
            
        end if;
    end process;
end generate RX_rising;

end Behavioral;