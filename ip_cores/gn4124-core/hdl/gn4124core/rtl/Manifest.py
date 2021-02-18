files = ["dma_controller.vhd",
         "dma_controller_wb_slave.vhd",
         "l2p_arbiter.vhd",
         "l2p_dma_master.vhd",
         "p2l_decode32.vhd",
         "p2l_dma_master.vhd",
         "wbmaster32.vhd",
]

if action == "simulation":
    files.append("../../spec/ip_cores/l2p_fifo.vhd")
elif action == "synthesis":
    files.append("../../spec/ip_cores/l2p_fifo.ngc")

modules = { "local" : "spartan6"}


