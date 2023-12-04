library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity SPI_TOP_1 is
    generic (
      CPOL       :in std_logic := '1';   --clock polarity mode
      CPHA       :in std_logic := '1';   --clock phase mode
      DATA_LENGTH: integer := 8;    -- data bit length 
      CLK_DIV    : integer := 4   --system clock cycles per 1/2 period of sclk
    );
    port (
      CLK             : in  std_logic; --free running clock
      RST_N           : in  std_logic; --asynchronous active low reset
      M_SCLK          : out  std_logic; --external SCLK MASTER
      M_SS_N          : out std_logic; -- external SS_N MASTER
      M_MOSI          : out std_logic; --external MOSI MASTER
      M_MISO          : in std_logic; -- external MISO MASTER
      S_SCLK          : in std_logic; --external SCLK SLAVE
      S_SS_N          : in std_logic; --external SCLK SLAVE
      S_MOSI          : in std_logic; --external S_MOSI SLAVE
      S_MISO          : out std_logic -- external S_MISO SLAVE
      -- TX_DATA_VALID_M : in std_logic; --transmit data valid
      -- TX_DATA_S       : in std_logic_vector(DATA_LENGTH-1 downto 0); --transmitted data
      -- TX_DATA_M       : in std_logic_vector(DATA_LENGTH-1 downto 0); --transmitted data
      -- RX_DATA_M       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      -- RX_DATA_VALID_M : out std_logic; --receved data valid
      -- RX_DATA_S       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      -- RX_DATA_VALID_S : out std_logic; --receved data valid
    );
end SPI_TOP_1;

architecture Behavioral of SPI_TOP_1 is
    signal CONNECTED_TO_source : std_logic_vector(8 downto 0); 
    signal m_rx_data           : std_logic_vector(7 downto 0);
    signal m_rx_data_valid     : std_logic;
    signal m_tx_data           : std_logic_vector(7 downto 0);
    signal m_tx_data_valid     : std_logic;
    signal s_rx_data           : std_logic_vector(7 downto 0);
    signal s_rx_data_valid     : std_logic;
    signal s_tx_data           :std_logic_vector(7 downto 0);


-- Instantiate SPI Master and Slave
component SPI_MASTER is
    generic(
        CPOL       : in std_logic := '1';   --clock polarity mode
        CPHA       : in std_logic := '1';   --clock phase mode
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

component JTAGSOURCES is
    port (
        source     : out std_logic_vector(8 downto 0); -- source
        source_clk : in  std_logic := 'X'  -- clk
    );
end component JTAGSOURCES;


component SPI_SLAVE is
    generic(
        CPOL       :in std_logic := '1';   --clock polarity mode
        CPHA       :in std_logic := '1';   --clock phase mode
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
            SCLK => M_SCLK,
            SS_N => M_SS_N,
            MOSI => M_MOSI,
            MISO => M_MISO,
            RX_DATA => m_rx_data,
            RX_DATA_VALID => m_rx_data_valid,
            TX_DATA => m_tx_data,
            TX_DATA_VALID => m_tx_data_valid
        );

u0 : component JTAGSOURCES
		port map (
			source     => CONNECTED_TO_source,--    sources.source
			source_clk => CLK  -- source_clk.clk
		);

        m_tx_data <= CONNECTED_TO_source(8 downto 1);
        m_tx_data_valid <= CONNECTED_TO_source(0);

UUT_SLAVE : entity work.SPI_SLAVE
        generic map (
            CPOL => CPOL,
            CPHA => CPHA,
            DATA_LENGTH => DATA_LENGTH
        )
        port map (
            SCLK => S_SCLK,
            SS_N => S_SS_N,
            MOSI => S_MOSI,
            MISO => S_MISO,
            RST_N => RST_N,
            RX_DATA => s_rx_data,
            RX_DATA_VALID => s_rx_data_valid,
            TX_DATA => s_tx_data
        );

        s_tx_data <= s_rx_data;
end Behavioral;