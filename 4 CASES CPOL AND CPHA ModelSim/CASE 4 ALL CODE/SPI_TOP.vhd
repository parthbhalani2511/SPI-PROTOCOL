library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity SPI_TOP is
    generic (
      CPOL       :in std_logic;   --clock polarity mode
      CPHA       :in std_logic;   --clock phase mode
      DATA_LENGTH: integer := 8;    -- data bit length 
      CLK_DIV    : integer := 4   --system clock cycles per 1/2 period of sclk
    );
    port (
      CLK           : in  std_logic; --free running clock
      RST_N         : in  std_logic; --asynchronous active low reset
      TX_DATA_VALID_M : in std_logic; --transmit data valid
      TX_DATA_S       : in std_logic_vector(DATA_LENGTH-1 downto 0); --transmitted data
      TX_DATA_M       : in std_logic_vector(DATA_LENGTH-1 downto 0); --transmitted data
      RX_DATA_M       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      RX_DATA_VALID_M : out std_logic; --receved data valid
      RX_DATA_S       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      RX_DATA_VALID_S : out std_logic --receved data valid
    );
end SPI_TOP;

architecture Behavioral of SPI_TOP is

    signal SCLK_w : std_logic; -- Serial Clock signal
    signal SS_N_w : std_logic; -- Slave Select signal
    signal MOSI_w : std_logic; -- Master Out Slave In signal
    signal MISO_w : std_logic; -- Master In Slave Out signal

-- Instantiate SPI Master and Slave
component SPI_MASTER is
    generic(
        CPOL       : in std_logic;   --clock polarity mode
        CPHA       : in std_logic;   --clock phase mode
        DATA_LENGTH: integer := 8;   -- data bit length
        CLK_DIV    : integer := 8   --system clock cycles per 1/2 period of sclk
        );
    Port(    
        CLK           : in  std_logic; --free running clock
        RST_N         : in  std_logic; --asynchronous active low reset
        SCLK          : out std_logic; -- serial clock
        SS_N          : out std_logic; --slave select active low
        MOSI          : out  std_logic; --master out slave in
        MISO          : in std_logic; --master in slave out
        RX_DATA       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
        RX_DATA_VALID : out std_logic; --receved data valid
        TX_DATA       : in std_logic_vector(DATA_LENGTH-1 downto 0); --transmitted data
        TX_DATA_VALID : in std_logic --transmit data valid 
        );
end Component;

component SPI_SLAVE is
    generic(
        CPOL       :in std_logic;   --clock polarity mode
        CPHA       :in std_logic;   --clock phase mode
        DATA_LENGTH: integer := 8 -- data bit length
        );
    Port(  
        SCLK          : in  std_logic; --spi clk
        SS_N          : in  std_logic; --slave select active low
        MOSI          : in  std_logic; --master out slave in
        MISO          : out std_logic; --master in slave out
        RST_N         : in  std_logic; --asynchronous active low reset
        RX_DATA       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
        RX_DATA_VALID : out std_logic; --receved data valid
        TX_DATA       : in std_logic_vector(DATA_LENGTH-1 downto 0) --transmitted data  
        );
end component;

begin 

UUT_MASTER : entity work.SPI_MASTER
        generic map (
            CPOL => CPOL,
            CPHA => CPHA,
            DATA_LENGTH => DATA_LENGTH,
            CLK_DIV => CLK_DIV
        )
        port map (
            CLK => CLK,
            RST_N => RST_N,
            SCLK => SCLK_w,
            SS_N => SS_N_w,
            MOSI => MOSI_w,
            MISO => MISO_w,
            RX_DATA => RX_DATA_M,
            RX_DATA_VALID => RX_DATA_VALID_M,
            TX_DATA => TX_DATA_M,
            TX_DATA_VALID => TX_DATA_VALID_M
        );

    UUT_SLAVE : entity work.SPI_SLAVE
        generic map (
            CPOL => CPOL,
            CPHA => CPHA,
            DATA_LENGTH => DATA_LENGTH
        )
        port map (
            SCLK => SCLK_w,
            SS_N => SS_N_w,
            MOSI => MOSI_w,
            MISO => MISO_w,
            RST_N => RST_N,
            RX_DATA => RX_DATA_S,
            RX_DATA_VALID => RX_DATA_VALID_S,
            TX_DATA => TX_DATA_S
        );
end Behavioral;