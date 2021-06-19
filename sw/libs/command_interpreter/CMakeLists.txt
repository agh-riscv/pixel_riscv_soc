cmake_minimum_required(VERSION 3.19)

add_library(command_interpreter)

target_link_libraries(command_interpreter PRIVATE
    drivers
    misc
)

target_include_directories(command_interpreter PUBLIC
    include
)

target_sources(command_interpreter PRIVATE
    src/command_parser.cpp
    src/command_interpreter.cpp
)
