debImport "-2012" "-f" "files.f" -autoalias
debLoadSimResult \
           /home/david/Desktop/我想这应该是完全体了 (copy)/riscv_cpu_design(1)/riscv_cpu_design/sim/novas.fsdb
verdiWindowResize -win $_Verdi_1 "55" -14 "2493" "1176"
srcSignalView -on
srcHBSelect "riscv_sim.U_RISCV.U_RF" -win $_nTrace1
srcSetScope -win $_nTrace1 "riscv_sim.U_RISCV.U_RF" -delim "."
srcSignalViewSelect "riscv_sim.U_RISCV.U_RF.WR_WB\[4:0\]"
srcSignalViewExpand -row 13
srcHBSelect "riscv_sim.U_RISCV.U_DM" -win $_nTrace1
srcSetScope -win $_nTrace1 "riscv_sim.U_RISCV.U_DM" -delim "."
srcSignalViewExpand -row 10
srcSignalViewSelect "riscv_sim.U_RISCV.U_DM.memory\[20\]\[31:0\]"
wvCreateWindow
srcSignalViewAddSelectedToWave -win $_nTrace1
wvSetCursor -win $_nWave2 8977.924881 -snap {("G2" 0)}
wvZoomAll -win $_nWave2
srcHBSelect "riscv_sim.U_RISCV.U_RF" -win $_nTrace1
srcSetScope -win $_nTrace1 "riscv_sim.U_RISCV.U_RF" -delim "."
srcSignalViewExpand -row 13
srcSignalViewSelect "riscv_sim.U_RISCV.U_RF.register\[28\]\[31:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "riscv_sim.U_RISCV.U_RF.register\[27\]\[31:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "riscv_sim.U_RISCV.U_RF.register\[29\]\[31:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
wvZoom -win $_nWave2 86532.100999 97238.912685
debExit
