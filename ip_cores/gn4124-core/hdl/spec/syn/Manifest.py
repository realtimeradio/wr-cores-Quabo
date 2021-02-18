target = "xilinx"
action = "synthesis"

syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "fgg484"
syn_top = "spec_gn4124_test"
syn_project = "spec_gn4124_test.xise"
syn_tool = "ise"

files = ["../spec_gn4124_test.ucf",
	 "../ip_cores/l2p_fifo.ngc"]

modules = { "local" : ["../rtl",
                       "../../common/rtl",
                       "../../gn4124core/rtl"],
            "git" : "git://ohwr.org/hdl-core-lib/general-cores.git::proposed_master"}

fetchto = "../ip_cores"

