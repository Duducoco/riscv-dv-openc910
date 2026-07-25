# Enable T-Head extended instructions in MXSTATUS.THEADISAEE.
li x5, 0x400000
csrs 0x7c0, x5
