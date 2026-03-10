# Find LTO
#
# This module checks if Link Time Optimization (LTO) is supported by the compiler
# and adds the necessary flags to CMAKE_CXX_FLAGS and CMAKE_EXE_LINKER_FLAGS.

include(CheckCXXCompilerFlag)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # Check for LTO support
    check_cxx_compiler_flag("-flto" LTO_SUPPORTED)
    if(LTO_SUPPORTED)
        message(STATUS "LTO (Link Time Optimization) is supported and enabled.")
        add_compile_options("-flto")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto")
        set(LTO_FOUND TRUE)
    else()
        message(STATUS "LTO (Link Time Optimization) is not supported by your compiler.")
        set(LTO_FOUND FALSE)
    endif()
else()
    set(LTO_FOUND FALSE)
endif()
