# pixel_riscv_soc

_pixel\_riscv\_soc_ is a System-on-Chip for calibration of pixelated hybrid X-ray detectors.

The main parts of the SoC are the RISC-V-based Central Processing Unit
([Ibex](https://github.com/lowRISC/ibex)) and Pixel Matrix Controller (PMC).

PMC is the peripheral designed to work with an X-ray detector, that integrates simple coprocessor
used for detector control and serializers implemented for SoC-detector data exchange acceleration.

The SoC has been verified by simulations and FPGA-based prototype implementation.

## X-ray detector calibration
In order to estimate the SoC performance, the numbers of processor cycles consumed during the execution
of the three detector-based algorithms were measured. Results of the measurements taken before
and after the implementation of hardware accelerators (serializers) are presented in the table below.

| Algorithm             | Software execution | Hardware accelerators usage | Ratio |
|:---------------------:|:------------------:|:---------------------------:|:-----:|
| Counters readout      |            253 040 |                       8 040 |  31.5 |
| Configuration loading |            201 811 |                       8 345 |  24.2 |
| Matrix calibration    |         54 873 510 |                   2 669 020 |  20.6 |


## Authors

Paweł Skrzypiec <<pawel.skrzypiec@agh.edu.pl>>

Robert Szczygieł <<robert.szczygiel@agh.edu.pl>>
