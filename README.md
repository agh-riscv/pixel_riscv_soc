# pixel_riscv_soc

_pixel\_riscv\_soc_ is a System-on-Chip for calibration of pixelated hybrid X-ray detectors.

The main parts of the SoC are the RISC-V-based Central Processing Unit
([Ibex](https://github.com/lowRISC/ibex)) and Pixel Matrix Controller (PMC).

PMC is the peripheral designed to work with an X-ray detector, that integrates simple coprocessor
used for detector control and serializers implemented for SoC-detector data exchange acceleration.

The SoC has been verified by simulations and FPGA-based prototype implementation.

![System-on-Chip architecture](doc/img/soc_arch.svg?raw=true "System-on-Chip architecture")

## Bitstream generation
```bash
./tools/bitstream_generator.sh
```

## Authors

Paweł Skrzypiec <<pawel.skrzypiec@agh.edu.pl>>

Robert Szczygieł <<robert.szczygiel@agh.edu.pl>>
