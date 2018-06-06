library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_tuser_to_tkeep is
    port (
        tuser : in std_logic_vector(2 downto 0);
        tkeep  : out std_logic_vector(7 downto 0)
    );
end axis_tuser_to_tkeep;

architecture any of axis_tuser_to_tkeep is
begin
  process (tuser)
  begin
    case tuser is
      when "000"  => tkeep <= "11111111";
      when "001"  => tkeep <= "00000001";
      when "010"  => tkeep <= "00000011";
      when "011"  => tkeep <= "00000111";
      when "100"  => tkeep <= "00001111";
      when "101"  => tkeep <= "00011111";
      when "110"  => tkeep <= "00111111";
      when "111"  => tkeep <= "01111111";
      when others => tkeep <= "11111111";
    end case;
  end process;
end any;
