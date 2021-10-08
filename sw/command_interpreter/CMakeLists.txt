cmake_minimum_required(VERSION 3.19)

string(REGEX MATCH "[^\/]+$" app "${CMAKE_CURRENT_LIST_DIR}")

add_executable(${app})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
    -Wl,-Map=${app}.map \
")

target_link_libraries(${app} PRIVATE
    libs
)

target_link_options(${app} PRIVATE
    -T ${CMAKE_CURRENT_SOURCE_DIR}/../common/link.ld
)

target_include_directories(${app} PUBLIC
    include
)

target_sources(${app} PRIVATE
    ../common/crt0.S
    src/command_interpreter.cpp
    src/command_parser.cpp
    src/main.cpp
)

add_custom_command(TARGET ${app} POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -SD ${app} > ${app}.dis
    COMMAND ${CMAKE_OBJCOPY} -O binary ${app} ${app}.bin
    COMMAND srec_cat ${app}.bin -binary -fill 0x00 --within ${app}.bin -binary --range-padding 4 -offset 0x0000 -byte-swap 4 -o ${app}.vmem -vmem
)
