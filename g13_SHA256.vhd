-- entity name: g13_SHA256
--
-- Version 1.0
-- Authors: (list the group member names here)
-- Date: March ??, 2021 (enter the date of the latest edit to the file)
library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;

entity g13_SHA256 is
    port (
        hash_out : out std_logic_vector(255 downto 0);
        RESET, CLK : in std_logic
    );
end g13_SHA256;

architecture lab3 of g13_SHA256 is

    signal Kt : std_logic_vector(31 downto 0) := X"428a2f98";
    signal Wt : std_logic_vector(31 downto 0) := x"00000000";
    -- initial hash values
    signal h0 : std_logic_vector(31 downto 0) := x"6a09e667";
    signal h1 : std_logic_vector(31 downto 0) := x"bb67ae85";
    signal h2 : std_logic_vector(31 downto 0) := x"3c6ef372";
    signal h3 : std_logic_vector(31 downto 0) := x"a54ff53a";
    signal h4 : std_logic_vector(31 downto 0) := x"510e527f";
    signal h5 : std_logic_vector(31 downto 0) := x"9b05688c";
    signal h6 : std_logic_vector(31 downto 0) := x"1f83d9ab";
    signal h7 : std_logic_vector(31 downto 0) := x"5be0cd19";

    type SHA_256_STATE is (INIT, RUN, IDLE);
    signal state : SHA_256_STATE;

    signal A_o, B_o, C_o, D_o, E_o, F_o, G_o, H_o : std_logic_vector(31 downto 0);
    signal LD : std_logic;
    signal round_count : integer range 0 to 63;

    COMPONENT g13_Hash_Core
        PORT (
            A_o, B_o, C_o, D_o, E_o, F_o, G_o, H_o : inout std_logic_vector(31 downto 0);
            A_i, B_i, C_i, D_i, E_i, F_i, G_i, H_i : in std_logic_vector(31 downto 0);
            Kt_i, Wt_i : in std_logic_vector(31 downto 0);
            LD, CLK : in std_logic
        );
    END COMPONENT;

begin
    i1 : g13_Hash_Core
        PORT MAP (
            A_o => A_o, B_o => B_o,
            C_o => C_o, D_o => D_o, E_o => E_o,
            F_o => F_o, G_o => G_o, H_o => H_o, 
            A_i => h0, B_i => h1, C_i => h2, D_i => h3,
            E_i => h4, F_i => h5, G_i => h6, H_i => h7, 
            Kt_i => Kt, Wt_i => Wt,
            LD => LD, CLK => CLK
        );
    
    hash_out <= A_o & B_o & C_o & D_o & E_o & F_o & G_o & H_o; -- concatenate to form the 256-bit hash output

    process(RESET, CLK)
    begin
        if RESET = '1' then
            state <= INIT;
        elsif rising_edge(CLK) then
            case state is
                when INIT =>
                    LD <= '1';
                    state <= RUN;
                    round_count <= 0;
                when RUN =>
                    LD <= '0';
                    round_count <= round_count + 1;
                    if round_count = 63 then
                        state <= IDLE;
                    end if;
                when IDLE =>
                    -- Maintain the IDLE state until RESET
                    LD <= '0';
            end case;
        end if;
    end process;

end lab3;
