	component sys_jamb is
		port (
			clk_clk            : in    std_logic                    := 'X';             -- clk
			reset_reset_n      : in    std_logic                    := 'X';             -- reset_n
			memrst_reset       : in    std_logic                    := 'X';             -- reset
			master_reset_reset : out   std_logic;                                       -- reset
			io_dq              : inout std_logic_vector(7 downto 0) := (others => 'X'); -- dq
			io_rwds            : inout std_logic                    := 'X';             -- rwds
			io_ckout           : out   std_logic;                                       -- ckout
			io_ckoutn          : out   std_logic;                                       -- ckoutn
			io_csn             : out   std_logic;                                       -- csn
			io_rstn            : out   std_logic                                        -- rstn
		);
	end component sys_jamb;

	u0 : component sys_jamb
		port map (
			clk_clk            => CONNECTED_TO_clk_clk,            --          clk.clk
			reset_reset_n      => CONNECTED_TO_reset_reset_n,      --        reset.reset_n
			memrst_reset       => CONNECTED_TO_memrst_reset,       --       memrst.reset
			master_reset_reset => CONNECTED_TO_master_reset_reset, -- master_reset.reset
			io_dq              => CONNECTED_TO_io_dq,              --           io.dq
			io_rwds            => CONNECTED_TO_io_rwds,            --             .rwds
			io_ckout           => CONNECTED_TO_io_ckout,           --             .ckout
			io_ckoutn          => CONNECTED_TO_io_ckoutn,          --             .ckoutn
			io_csn             => CONNECTED_TO_io_csn,             --             .csn
			io_rstn            => CONNECTED_TO_io_rstn             --             .rstn
		);

