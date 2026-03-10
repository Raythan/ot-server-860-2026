cmake_minimum_required(VERSION 2.8)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(tfs)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(cotire)

add_compile_options(-Wall -Werror -pipe -fvisibility=hidden)

set(CMAKE_CXX_FLAGS_PERFORMANCE "${CMAKE_CXX_FLAGS_RELEASE} -march=native")

if (CMAKE_COMPILER_IS_GNUCXX)
    add_compile_options(-fno-strict-aliasing)
endif()

include(FindCXX11)
include(FindLTO)

# Find packages.
find_package(Crypto++ REQUIRED)
find_package(PugiXML REQUIRED)
find_package(GMP REQUIRED)
find_package(MySQL)
find_package(Threads)

# Selects LuaJIT if user defines or auto-detected
option(USE_LUAJIT "Use LuaJIT" ON)

if(USE_LUAJIT)
	find_package(LuaJIT)
	if(NOT LuaJIT_FOUND)
		message(STATUS "LuaJIT not found, falling back to standard Lua.")
		set(USE_LUAJIT OFF CACHE BOOL "Use LuaJIT" FORCE)
	endif()
endif()

if(NOT USE_LUAJIT)
	# If we are falling back to standard Lua, make sure we don't use cached LuaJIT variables
	if(LUA_LIBRARY MATCHES "luajit")
		unset(LUA_LIBRARY CACHE)
		unset(LUA_LIBRARIES CACHE)
		unset(LUA_INCLUDE_DIR CACHE)
	endif()
	find_package(Lua REQUIRED)
endif()

find_package(Boost 1.53.0 COMPONENTS system filesystem iostreams REQUIRED)

add_subdirectory(src)
add_executable(tfs ${tfs_SRC})

include_directories(${MYSQL_INCLUDE_DIR} ${LUA_INCLUDE_DIR} ${Boost_INCLUDE_DIRS} ${PUGIXML_INCLUDE_DIR} ${Crypto++_INCLUDE_DIR} ${GMP_INCLUDE_DIR})
target_link_libraries(tfs ${MYSQL_CLIENT_LIBS} ${LUA_LIBRARIES} ${Boost_LIBRARIES} ${Boost_FILESYSTEM_LIBRARY} ${PUGIXML_LIBRARIES} ${Crypto++_LIBRARIES} ${GMP_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})

set_target_properties(tfs PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "src/otpch.h")
set_target_properties(tfs PROPERTIES COTIRE_ADD_UNITY_BUILD FALSE)
cotire(tfs)
