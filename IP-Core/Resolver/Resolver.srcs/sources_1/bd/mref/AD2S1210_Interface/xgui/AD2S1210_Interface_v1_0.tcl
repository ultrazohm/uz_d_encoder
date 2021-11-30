# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "SPI_Datalength" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPI_Slavenumber" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPI_clk_div" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPI_cont" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPI_cpha" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPI_cpol" -parent ${Page_0}


}

proc update_PARAM_VALUE.SPI_Datalength { PARAM_VALUE.SPI_Datalength } {
	# Procedure called to update SPI_Datalength when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_Datalength { PARAM_VALUE.SPI_Datalength } {
	# Procedure called to validate SPI_Datalength
	return true
}

proc update_PARAM_VALUE.SPI_Slavenumber { PARAM_VALUE.SPI_Slavenumber } {
	# Procedure called to update SPI_Slavenumber when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_Slavenumber { PARAM_VALUE.SPI_Slavenumber } {
	# Procedure called to validate SPI_Slavenumber
	return true
}

proc update_PARAM_VALUE.SPI_clk_div { PARAM_VALUE.SPI_clk_div } {
	# Procedure called to update SPI_clk_div when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_clk_div { PARAM_VALUE.SPI_clk_div } {
	# Procedure called to validate SPI_clk_div
	return true
}

proc update_PARAM_VALUE.SPI_cont { PARAM_VALUE.SPI_cont } {
	# Procedure called to update SPI_cont when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_cont { PARAM_VALUE.SPI_cont } {
	# Procedure called to validate SPI_cont
	return true
}

proc update_PARAM_VALUE.SPI_cpha { PARAM_VALUE.SPI_cpha } {
	# Procedure called to update SPI_cpha when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_cpha { PARAM_VALUE.SPI_cpha } {
	# Procedure called to validate SPI_cpha
	return true
}

proc update_PARAM_VALUE.SPI_cpol { PARAM_VALUE.SPI_cpol } {
	# Procedure called to update SPI_cpol when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_cpol { PARAM_VALUE.SPI_cpol } {
	# Procedure called to validate SPI_cpol
	return true
}


proc update_MODELPARAM_VALUE.SPI_Datalength { MODELPARAM_VALUE.SPI_Datalength PARAM_VALUE.SPI_Datalength } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_Datalength}] ${MODELPARAM_VALUE.SPI_Datalength}
}

proc update_MODELPARAM_VALUE.SPI_Slavenumber { MODELPARAM_VALUE.SPI_Slavenumber PARAM_VALUE.SPI_Slavenumber } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_Slavenumber}] ${MODELPARAM_VALUE.SPI_Slavenumber}
}

proc update_MODELPARAM_VALUE.SPI_cpha { MODELPARAM_VALUE.SPI_cpha PARAM_VALUE.SPI_cpha } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_cpha}] ${MODELPARAM_VALUE.SPI_cpha}
}

proc update_MODELPARAM_VALUE.SPI_cpol { MODELPARAM_VALUE.SPI_cpol PARAM_VALUE.SPI_cpol } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_cpol}] ${MODELPARAM_VALUE.SPI_cpol}
}

proc update_MODELPARAM_VALUE.SPI_cont { MODELPARAM_VALUE.SPI_cont PARAM_VALUE.SPI_cont } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_cont}] ${MODELPARAM_VALUE.SPI_cont}
}

proc update_MODELPARAM_VALUE.SPI_clk_div { MODELPARAM_VALUE.SPI_clk_div PARAM_VALUE.SPI_clk_div } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_clk_div}] ${MODELPARAM_VALUE.SPI_clk_div}
}

