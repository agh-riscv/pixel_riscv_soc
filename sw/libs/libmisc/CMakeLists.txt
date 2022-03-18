cmake_minimum_required(VERSION 3.19)

add_library(libmisc)

target_link_libraries(libmisc PRIVATE
    libdrivers
)

target_include_directories(libmisc PUBLIC
    include
)

target_include_directories(libmisc PRIVATE
    include/libmisc
)

target_sources(libmisc PRIVATE
    src/debug.cpp
    src/delay.cpp
    src/pixel_matrix.cpp
    src/pm_controller.cpp
    src/pmcc_programmer.cpp
    src/string_ops.cpp
    src/ui.cpp
)
