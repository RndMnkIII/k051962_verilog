# k051962_verilog

!["051962"](https://github.com/RndMnkIII/k051962_verilog/blob/main/img/konami_051962.jpg)

This is a preliminar simulation written in Verilog for the Konami k051962 Tile Layer Generator
used in many Konami arcade game machines at the end of 80's and beginning of 90's. This is used together
with his twin k052109 IC. This code is based on the schematics released by @Furrtek which was able to
trace the internal channeled gate array structure of this IC and identify the functions that were used.

https://github.com/furrtek/VGChips/tree/master/Konami

## Usage:
You need to have installed Icarus verilog and GTKWave in your system (Linux/MacOS/Windows/WSL2).

Open a terminal and run:

```
iverilog -o k051962_CLOCKS_tb.vvp k051962_CLOCKS_tb.v k051962.v vc_in.v fujitsu_AV_UnitCellLibrary_DLY.v
vvp k051962_CLOCKS_tb.vvp -lxt2
gtkwave k051962_CLOCKS_tb.lxt&
```
You can store your gtkwave signals layout as a *.gtkw file.


## GFX ROM simulation:
```
iverilog -o gfx_rom_tb.vvp gfx_rom_tb.v gfx_rom.v
vvp gfx_rom_tb.vvp -lxt2
gtkwave gfx_rom_tb.lxt&
```

!["GFX Tile ROMs Test Bench"](https://github.com/RndMnkIII/k051962_verilog/blob/main/img/gtkwave_GFX_TILE_ROMS_DATA_TESTBENCH.png)

## GFX Tile ROM data to k051962 simulation:
```
iverilog -o k051962_GFX_ROM_interface_tb.vvp k051962_GFX_ROM_interface_tb.v gfx_rom.v k051962.v vc_in.v fujitsu_AV_UnitCellLibrary_DLY.v
vvp k051962_GFX_ROM_interface_tb.vvp -lxt2
gtkwave k051962_GFX_ROM_interface_tb.lxt&
```
load the `k051962_GFX_ROM_interface_tb.gtkw` file into GTKWave to show a layout with signals of interest.

!["GFX Data to k051962 Test Bench"](https://github.com/RndMnkIII/k051962_verilog/blob/main/img/gtkwave_GFX_DATA_TO_K051962_TESTBENCH.png)

Any suggestion or improvement will be welcome!




