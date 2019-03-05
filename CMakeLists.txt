cmake_minimum_required(VERSION 2.8)
project(version)

# <-- Version Module
set(CMAKE_MODULE_DIR ${CMAKE_SOURCE_DIR}/cmake/modules)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_DIR} ${CMAKE_MODULE_PATH})
include(GetGitRevision)
include_directories(${CMAKE_BINARY_DIR})
set(VERSION_FILE ${CMAKE_BINARY_DIR}/version.c)

add_custom_target(git-revision
	COMMAND cmake 
	-D CMAKE_MODULE_DIR=${CMAKE_MODULE_DIR}
	-D CMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
	-P ${CMAKE_SOURCE_DIR}/cmake/modules/GetGitRevision.cmake)
# Version Module -->


include_directories(${CMAKE_SOURCE_DIR}/include)
add_executable(version ${CMAKE_SOURCE_DIR}/src/main.c ${VERSION_FILE})
add_dependencies(version git-revision)
# <-- Version Module
print_version_info()
# Version Module -->
