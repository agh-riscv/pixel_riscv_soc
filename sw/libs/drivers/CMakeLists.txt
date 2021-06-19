cmake_minimum_required(VERSION 3.19)

add_library(drivers)

target_include_directories(drivers PUBLIC
    include
    include/pmc_regs
    include/spi_regs
    include/timer_regs
    include/uart_regs
)

target_sources(drivers PRIVATE
    src/code_ram.cpp
    src/core.cpp
    src/gpio.cpp
    src/pmc.cpp
    src/pmcc.cpp
    src/spi.cpp
    src/timer.cpp
    src/uart.cpp
)
