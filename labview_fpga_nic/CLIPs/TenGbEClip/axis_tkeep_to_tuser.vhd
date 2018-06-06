library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_tkeep_to_tuser is
    port (
        tuser : out std_logic_vector(2 downto 0);
        tkeep  : in std_logic_vector(7 downto 0)
    );
end axis_tkeep_to_tuser;

architecture any of axis_tkeep_to_tuser is
begin
  process (tkeep)
  begin
    case tkeep is
      when "11111111" => tuser <= "000";
      when "00000001" => tuser <= "001";
      when "00000011" => tuser <= "010";
      when "00000111" => tuser <= "011";
      when "00001111" => tuser <= "100";
      when "00011111" => tuser <= "101";
      when "00111111" => tuser <= "110";
      when "01111111" => tuser <= "111";
      when others     => tuser <= "000";
    end case;
  end process;
end any;
