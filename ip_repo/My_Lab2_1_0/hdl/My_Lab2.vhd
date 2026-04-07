library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity My_Lab2 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 7
	);
	port (
		-- Users to add ports here
        ac_mclk : out STD_LOGIC;
        ac_adc_sdata : in STD_LOGIC;
        ac_dac_sdata : out STD_LOGIC;
        ac_bclk : out STD_LOGIC;
        ac_lrclk : out STD_LOGIC;
        scl : inout STD_LOGIC;
        sda : inout STD_LOGIC;    
        tmds : out  STD_LOGIC_VECTOR (3 downto 0);
        tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
        sw: out std_logic_vector(2 downto 0);
        cw: in std_logic_vector (2 downto 0);
        btn: in    STD_LOGIC_VECTOR(4 downto 0);
        switch: in    STD_LOGIC_VECTOR(3 downto 0); 
        exWrAddr: in std_logic_vector(9 downto 0);
        exWen: in std_logic;
        Lbus_out, Rbus_out: out std_logic_vector(15 downto 0);
        exLbus, exRbus: in std_logic_vector(15 downto 0);
        flagQ: out std_logic;   
        flagClear: in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end My_Lab2;

architecture arch_imp of My_Lab2 is

	-- component declaration
	component My_Lab2_slave_lite_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 7
		);
		port (
        ac_mclk : out STD_LOGIC;
        ac_adc_sdata : in STD_LOGIC;
        ac_dac_sdata : out STD_LOGIC;
        ac_bclk : out STD_LOGIC;
        ac_lrclk : out STD_LOGIC;
        scl : inout STD_LOGIC;
        sda : inout STD_LOGIC;    
        tmds : out  STD_LOGIC_VECTOR (3 downto 0);
        tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
        sw: out std_logic_vector(2 downto 0);
        cw: in std_logic_vector (2 downto 0);
        btn: in    STD_LOGIC_VECTOR(4 downto 0);
        switch: in    STD_LOGIC_VECTOR(3 downto 0);
        exWrAddr: in std_logic_vector(9 downto 0);
        exWen, exSel: in std_logic;
        Lbus_out, Rbus_out: out std_logic_vector(15 downto 0);
        exLbus, exRbus: in std_logic_vector(15 downto 0);
        flagQ: out std_logic;   
        flagClear: in std_logic;
        
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component My_Lab2_slave_lite_v1_0_S00_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
My_Lab2_slave_lite_v1_0_S00_AXI_inst : My_Lab2_slave_lite_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    --FIX BELOW
        ac_mclk => ac_mclk,
		ac_adc_sdata => ac_adc_sdata,
		ac_dac_sdata => ac_dac_sdata,
		ac_bclk => ac_bclk,
		ac_lrclk => ac_lrclk,
        scl => scl,
        sda => sda,
		tmds => tmds,
		tmdsb => tmdsb,
		sw => sw,
		cw => cw,
		btn => btn, 
		switch => switch,
		
		
		--fix section
		exWrAddr => "0000000000",
		exWen => '0', 
		exSel => switch(2), 
		Lbus_out => OPEN, 
		Rbus_out => OPEN,
		exLbus => "0000000000000000",
		exRbus => "0000000000000000",		
		flagQ => OPEN,
		flagClear => '0',
		--end of section
		
		
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
