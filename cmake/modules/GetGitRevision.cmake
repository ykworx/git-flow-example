if(NOT GIT_FOUND)
	find_package(Git)
endif()

# Git executable is extracted from parameters.
execute_process(
	COMMAND bash "-c" "${GIT_EXECUTABLE} describe --always --dirty"
	OUTPUT_VARIABLE APP_VERSION_SHA1)
string(REGEX REPLACE "(.*)\n$" "\\1" APP_VERSION_SHA1 ${APP_VERSION_SHA1})
execute_process(
	COMMAND bash "-c" "${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD"
	OUTPUT_VARIABLE BRANCH)
string(REGEX REPLACE "(.*)\n$" "\\1" BRANCH ${BRANCH})
execute_process(
	COMMAND bash "-c" "${GIT_EXECUTABLE} tag -l --merged master --sort=-*authordate | head -n1" 
	OUTPUT_VARIABLE LATEST)

if(${LATEST})
	string(REGEX REPLACE "(.*)\n$" "\\1" LATEST ${LATEST})
	execute_process(
		COMMAND bash "-c" "${GIT_EXECUTABLE} rev-list HEAD ^${LATEST} --ancestry-path ${LATEST} --count"
		OUTPUT_VARIABLE COUNT)
else()
	set(COUNT 0)
	set(LATEST "0.0.0")
endif()

string(REGEX REPLACE "^([0-9]+)\\..*" "\\1" APP_VERSION_MAJOR ${LATEST})
string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" APP_VERSION_MINOR ${LATEST})
string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" PATCH ${LATEST})

if(${BRANCH} STREQUAL "master")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${PATCH}-${APP_VERSION_SHA1})
elseif(${BRANCH} MATCHES "^develop.*")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${PATCH}-beta-${APP_VERSION_SHA1})
elseif(${BRANCH} MATCHES "^feature/.*")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${PATCH}-alpha-${APP_VERSION_SHA1})
elseif(${BRANCH} MATCHES "^release/.*")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${PATCH}-rc-${APP_VERSION_SHA1})
else()
	message(FATAL_ERROR "Current branch is invalid, please change working branch (develop/feature/release/master)")
endif()

configure_file(
	${CMAKE_MODULE_DIR}/version.h.in 
	${CMAKE_BINARY_DIR}/version.h)
configure_file(
	${CMAKE_MODULE_DIR}/version.c.in 
	${CMAKE_BINARY_DIR}/version.c)

function(print_version_info)
	message(STATUS "========================================")
	message(STATUS "  PROJECT     ${CMAKE_PROJECT_NAME}")
	message(STATUS "  VERSION     ${APP_VERSION}")
	message(STATUS "  GIT BRANCH  ${BRANCH}")
	message(STATUS "  GIT LATEST  ${LATEST}")
	message(STATUS "  GIT COMMIT  ${COUNT}")
	message(STATUS "  GIT SHA1    ${APP_VERSION_SHA1}")
	message(STATUS "========================================")
endfunction()
