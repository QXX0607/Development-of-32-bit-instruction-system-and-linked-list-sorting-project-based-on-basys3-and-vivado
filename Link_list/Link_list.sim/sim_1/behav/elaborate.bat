@echo off
set xv_path=E:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto 058f647f84944422b817d78917b2a240 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot top_behav xil_defaultlib.top xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
