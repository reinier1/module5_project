@echo off
xcopy ..\ALU\alu.vhd . /Y
xcopy ..\Control-unit\control_unit.vhd . /Y
xcopy ..\Control-unit\alu_package.vhd . /Y
xcopy ..\Control-unit\control_package.vhd . /Y
xcopy ..\Debug\debug.vhd . /Y
xcopy ..\Debug\inoutput.vhd . /Y
xcopy ..\Debug\top_level_debug.vhd . /Y
xcopy ..\Memory\four-byte-enable.vhd . /Y
xcopy ..\Memory\one-byte-enable.vhd . /Y
xcopy ..\Memory-interface\memory_controller.vhd . /Y
xcopy ..\Processor\top_level_processor.vhd . /Y
xcopy ..\Registers\registers.vhd . /Y