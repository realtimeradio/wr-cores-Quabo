fetchto = "../../ip_cores"

files = [
    "clbv3_wr_ref_top.vhd",
    "clbv3_wr_ref_top.ucf",
    "clbv3_wr_ref_top.bmm",
]

modules = {
    "local" : [
        "../../",
        "../../board/clbv3",
    ],
    "git" : [
        "git://ohwr.org/hdl-core-lib/general-cores.git",
        "git://ohwr.org/hdl-core-lib/etherbone-core.git",
    ],
}
