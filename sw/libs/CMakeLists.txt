cmake_minimum_required(VERSION 3.19)

add_subdirectory(libdrivers)
add_subdirectory(libmisc)

add_library(libs INTERFACE)

target_link_libraries(libs INTERFACE
    libdrivers
    libmisc
)
