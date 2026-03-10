# Find Crypto++
#
# This module defines:
#  Crypto++_FOUND - True if Crypto++ was found
#  Crypto++_INCLUDE_DIR - The Crypto++ include directory
#  Crypto++_LIBRARIES - The Crypto++ libraries

find_path(Crypto++_INCLUDE_DIR cryptlib.h
    PATH_SUFFIXES crypto++ cryptopp
)

find_library(Crypto++_LIBRARIES
    NAMES cryptopp crypto++
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Crypto++ DEFAULT_MSG Crypto++_LIBRARIES Crypto++_INCLUDE_DIR)

mark_as_advanced(Crypto++_INCLUDE_DIR Crypto++_LIBRARIES)
