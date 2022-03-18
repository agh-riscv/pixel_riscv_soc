cmake_minimum_required(VERSION 3.19)

add_library(libdrivers)

target_include_directories(libdrivers PUBLIC
    include
)

target_include_directories(libdrivers PRIVATE
    include/libdrivers
)

target_sources(libdrivers PRIVATE
    src/code_ram.cpp
    src/common.cpp
    src/core.cpp
    src/gpio.cpp
    src/iomux.cpp
    src/pmc.cpp
    src/spi.cpp
    src/timer.cpp
    src/uart.cpp
)
