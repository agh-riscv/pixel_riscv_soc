cmake_minimum_required(VERSION 3.19)

add_subdirectory(command_interpreter)
add_subdirectory(drivers)
add_subdirectory(misc)

add_library(libs INTERFACE)

target_link_libraries(libs INTERFACE
    command_interpreter
    drivers
    misc
)
