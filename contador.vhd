library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity contador_0_99 is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an  : out STD_LOGIC_VECTOR (7 downto 0));
end contador_0_99;

architecture Behavioral of contador_0_99 is
    signal cnt : integer range 0 to 99 := 0;
    signal cnt_decenas, cnt_unidades : integer range 0 to 9 := 0;
    signal tmp_seg : STD_LOGIC_VECTOR(6 downto 0);
    signal btn_reg, btn_next : STD_LOGIC := '0';
    signal refresh_counter : integer range 0 to 1000 := 0; -- Control de multiplexación


    
    -- Decodificador de un dígito
    function DecodeDigit(digit : integer) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when 0 => return "0000001"; -- 0
            when 1 => return "1001111"; -- 1
            when 2 => return "0010010"; -- 2
            when 3 => return "0000110"; -- 3
            when 4 => return "1001100"; -- 4
            when 5 => return "0100100"; -- 5
            when 6 => return "0100000"; -- 6
            when 7 => return "0001111"; -- 7
            when 8 => return "0000000"; -- 8
            when 9 => return "0000100"; -- 9
            when others => return "1111111"; -- Estado por defecto
        end case;
    end function;

begin

    -- Proceso para el manejo del botón (debounce y edge detection)
    process(clk)
    begin
        if rising_edge(clk) then
            btn_reg <= btn;
            btn_next <= btn_reg;
            if btn_next = '1' and btn_reg = '0' then -- Detectar flanco ascendente
                if cnt < 99 then
                    cnt <= cnt + 1;
                else
                    cnt <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Dividir el contador en decenas y unidades
    process(clk)
    begin
        if rising_edge(clk) then
            cnt_decenas <= cnt / 10;
            cnt_unidades <= cnt mod 10;

            -- Proceso de multiplexación
            if refresh_counter < 500 then
                tmp_seg <= DecodeDigit(cnt_unidades);
                an <= "11111110"; -- Activar el display de unidades
            else
                tmp_seg <= DecodeDigit(cnt_decenas);
                an <= "11111101"; -- Activar el display de decenas
            end if;

            -- Actualizar contador de refresco
            if refresh_counter < 1000 then
                refresh_counter <= refresh_counter + 1;
            else
                refresh_counter <= 0;
            end if;
        end if;
    end process;

    -- Asignación a los segmentos
 seg <= tmp_seg;

end Behavioral;