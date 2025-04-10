	component sys is
		port (
			jtag_uart_0_irq_irq : out   std_logic;                                       -- irq
			rst_reset           : in    std_logic                    := 'X';             -- reset
			refclk_clk          : in    std_logic                    := 'X';             -- clk
			memrst_reset        : in    std_logic                    := 'X';             -- reset
			io_dq               : inout std_logic_vector(7 downto 0) := (others => 'X'); -- dq
			io_rwds             : inout std_logic                    := 'X';             -- rwds
			io_ckout            : out   std_logic;                                       -- ckout
			io_ckoutn           : out   std_logic;                                       -- ckoutn
			io_csn              : out   std_logic;                                       -- csn
			io_rstn             : out   std_logic                                        -- rstn
		);
	end component sys;

	u0 : component sys
		port map (
			jtag_uart_0_irq_irq => CONNECTED_TO_jtag_uart_0_irq_irq, -- jtag_uart_0_irq.irq
			rst_reset           => CONNECTED_TO_rst_reset,           --             rst.reset
			refclk_clk          => CONNECTED_TO_refclk_clk,          --          refclk.clk
			memrst_reset        => CONNECTED_TO_memrst_reset,        --          memrst.reset
			io_dq               => CONNECTED_TO_io_dq,               --              io.dq
			io_rwds             => CONNECTED_TO_io_rwds,             --                .rwds
			io_ckout            => CONNECTED_TO_io_ckout,            --                .ckout
			io_ckoutn           => CONNECTED_TO_io_ckoutn,           --                .ckoutn
			io_csn              => CONNECTED_TO_io_csn,              --                .csn
			io_rstn             => CONNECTED_TO_io_rstn              --                .rstn
		);

