fetchto = "../../ip_cores"

files = [
    "clbv2_wr_ref_top.vhd",
    "clbv2_wr_ref_top.ucf",
    "clbv2_wr_ref_top.bmm",
]

modules = {
    "local" : [
        "../../",
        "../../board/clbv2",
    ],
    "git" : [
        "git://ohwr.org/hdl-core-lib/general-cores.git",
        "git://ohwr.org/hdl-core-lib/etherbone-core.git",
    ],
}
