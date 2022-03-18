cmake_minimum_required(VERSION 3.19)

set(CMAKE_CXX_COMPILER /opt/riscv/bin/riscv32-unknown-elf-g++)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")

set(app "command_interpreter" CACHE STRING "")
set(target "sim" CACHE STRING "")

project(pixel_riscv_soc VERSION 1.0.0 LANGUAGES CXX ASM)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
    -fno-common \
    -fno-exceptions \
    -fno-non-call-exceptions \
    -fno-rtti \
    -fno-use-cxa-atexit \
    -fvisibility=hidden \
    -march=rv32imc \
    -mabi=ilp32 \
    -mcmodel=medany \
    -nostdlib \
    -Os \
    -Wall \
    -Wextra \
    -Werror \
")

if (${target} STREQUAL "arty")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DARTY")
elseif (${target} STREQUAL "asic")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DASIC")
elseif (${target} STREQUAL "basys")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBASYS")
elseif (${target} STREQUAL "kintex")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DKINTEX")
elseif (${target} STREQUAL "sim")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DSIM")
else()
    message(SEND_ERROR "Incorrect target: ${target}")
    return()
endif()

if (NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/apps/${app}")
    message(SEND_ERROR "Incorrect application: ${app}")
    return()
endif()

add_subdirectory(apps/${app})
add_subdirectory(bootloader)
add_subdirectory(libs)
