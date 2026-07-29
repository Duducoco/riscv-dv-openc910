# Enable T-Head extended instructions in MXSTATUS.THEADISAEE.
li x5, 0x400000
csrs 0x7c0, x5

# Enable floating-point state for bare-mode tests (mstatus.FS = Initial).
li x5, 0x2000
csrs mstatus, x5
