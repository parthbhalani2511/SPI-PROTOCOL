library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_SPI_CASE3 is
end TB_SPI_CASE3;

architecture Behavioral of TB_SPI_CASE3 is

    constant CPOL_VAL          : std_logic := '1'; -- Set the CPOL value here
    constant CPHA_VAL          : std_logic := '0'; -- Set the CPHA value here
    constant DATA_LENGTH       : integer := 8; -- data bit length 
    constant CLK_DIV           : integer := 4;   --system clock cycles per 1/2 period of sclk
    signal CLK                 : std_logic := '0'; -- Clock signal
    signal RST_N               : std_logic := '1'; -- Reset signal
    signal TB_RX_DATA_M        : std_logic_vector(DATA_LENGTH-1 downto 0); -- Serial Clock signal
    signal TB_RX_DATA_VALID_M  : std_logic := '0'; -- Slave Select signal
    signal TB_TX_DATA_M        : std_logic_vector(DATA_LENGTH-1 downto 0); -- Master Out Slave In signal
    signal TB_TX_DATA_VALID_M  : std_logic := '0'; -- Master In Slave Out signal
    signal TB_RX_DATA_S        : std_logic_vector(DATA_LENGTH-1 downto 0); -- Serial Clock signal
    signal TB_RX_DATA_VALID_S  : std_logic := '0'; -- Slave Select signal
    signal TB_TX_DATA_S        : std_logic_vector(DATA_LENGTH-1 downto 0); -- Master Out Slave In signal
        

-- Instantiate SPI Master and Slave
component SPI_TOP_3 is
    generic (
      CPOL       :in std_logic := '1';   --clock polarity mode
      CPHA       :in std_logic := '0';   --clock phase mode
      DATA_LENGTH: integer;    -- data bit length 
      CLK_DIV    : integer   --system clock cycles per 1/2 period of sclk
    );
    port (
      CLK             : in  std_logic; --free running clock
      RST_N           : in  std_logic; --asynchronous active low reset
      RX_DATA_M       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      RX_DATA_VALID_M : out std_logic; --receved data valid
      TX_DATA_M       : in std_logic_vector(DATA_LENGTH-1 downto 0); --transmitted data
      TX_DATA_VALID_M : in std_logic; --transmit data valid
      RX_DATA_S       : out  std_logic_vector(DATA_LENGTH-1 downto 0); --received data
      RX_DATA_VALID_S : out std_logic; --receved data valid
      TX_DATA_S       : in std_logic_vector(DATA_LENGTH-1 downto 0) --transmitted data
    );
end Component;

begin

    UUT_TOP : SPI_TOP_3
        generic map (
            CPOL => CPOL_VAL,
            CPHA => CPHA_VAL,
            DATA_LENGTH => DATA_LENGTH,
            CLK_DIV => CLK_DIV 
        )
        port map (
            CLK => CLK,
            RST_N => RST_N,
            RX_DATA_M => TB_RX_DATA_M,
            RX_DATA_VALID_M => TB_RX_DATA_VALID_M,
            TX_DATA_M => TB_TX_DATA_M,
            TX_DATA_VALID_M => TB_TX_DATA_VALID_M,
            RX_DATA_S => TB_RX_DATA_S,
            RX_DATA_VALID_S => TB_RX_DATA_VALID_S,
            TX_DATA_S => TB_TX_DATA_S
        );


-- Clock generation process
process
    begin
        CLK <= not CLK after 5 ns; -- Toggle the clock every 5 ns
        wait for 2.5 ns; -- Wait half of the clock period
end process;


-- Stimulus process
STIMULUS: process
    begin

 -- Initialize signals
        RST_N <= '0';
        wait until RISING_EDGE(CLK);
        RST_N <= '1';

-- Start a sequence of transactions
        TB_TX_DATA_M <= "10010101";
        TB_TX_DATA_S <= "11011101";
        TB_TX_DATA_VALID_M <= '1';

        -- Wait for transaction to complete
        wait until TB_RX_DATA_VALID_M = '1';
        -- Display received data
        report "Master Received Data: " & integer'image(to_integer(ieee.numeric_std.UNSIGNED(TB_RX_DATA_M)));
        wait until TB_RX_DATA_VALID_S = '1';
        -- Display received data
        report "Slave Received Data: " & integer'image(to_integer(ieee.numeric_std.UNSIGNED(TB_RX_DATA_S)));
        wait until TB_TX_DATA_VALID_M = '1';
        -- wait until RISING_EDGE(CLK);

end process STIMULUS;

end Behavioral;