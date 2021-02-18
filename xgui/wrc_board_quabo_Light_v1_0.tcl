# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "g_dpram_initf" -parent ${Page_0}
  ipgui::add_param $IPINST -name "g_simulation" -parent ${Page_0}


}

proc update_PARAM_VALUE.g_dpram_initf { PARAM_VALUE.g_dpram_initf } {
	# Procedure called to update g_dpram_initf when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.g_dpram_initf { PARAM_VALUE.g_dpram_initf } {
	# Procedure called to validate g_dpram_initf
	return true
}

proc update_PARAM_VALUE.g_simulation { PARAM_VALUE.g_simulation } {
	# Procedure called to update g_simulation when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.g_simulation { PARAM_VALUE.g_simulation } {
	# Procedure called to validate g_simulation
	return true
}


proc update_MODELPARAM_VALUE.g_dpram_initf { MODELPARAM_VALUE.g_dpram_initf PARAM_VALUE.g_dpram_initf } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.g_dpram_initf}] ${MODELPARAM_VALUE.g_dpram_initf}
}

proc update_MODELPARAM_VALUE.g_simulation { MODELPARAM_VALUE.g_simulation PARAM_VALUE.g_simulation } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.g_simulation}] ${MODELPARAM_VALUE.g_simulation}
}

