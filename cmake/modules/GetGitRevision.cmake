if(NOT GIT_FOUND)
	find_package(Git)
endif()

# Git executable is extracted from parameters.
execute_process(
	COMMAND bash "-c" "${GIT_EXECUTABLE} describe --always --dirty" OUTPUT_VARIABLE APP_VERSION_SHA1)
if(NOT ${APP_VERSION_SHA1})
  execute_process(
    COMMAND bash "-c" "${GIT_EXECUTABLE} rev-parse --short HEAD" OUTPUT_VARIABLE APP_VERSION_SHA1)
    string(REGEX REPLACE "(.*)\n$" "g\\1" APP_VERSION_SHA1 ${APP_VERSION_SHA1})
else()
  string(REGEX MATCH "g.*\n$" APP_VERSION_SHA1 ${APP_VERSION_SHA1})
  string(REGEX REPLACE "(.*)\n$" "\\1" APP_VERSION_SHA1 ${APP_VERSION_SHA1})
endif()

execute_process(
	COMMAND bash "-c" "${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD"
	OUTPUT_VARIABLE BRANCH)
string(REGEX REPLACE "(.*)\n$" "\\1" BRANCH ${BRANCH})
execute_process(
  COMMAND bash "-c" "${GIT_EXECUTABLE} tag -l --merged master --sort=-*authordate | head -n1" 
  OUTPUT_VARIABLE MASTER_TAG)

if(MASTER_TAG)
  string(REGEX REPLACE "(.*)\n$" "\\1" MASTER_TAG ${MASTER_TAG})
	execute_process(
    COMMAND bash "-c" "${GIT_EXECUTABLE} rev-list HEAD ^${MASTER_TAG} --ancestry-path ${MASTER_TAG} --count"
    OUTPUT_VARIABLE COMMIT)
  string(REGEX REPLACE "(.*)\n$" "\\1" COMMIT ${COMMIT})
else()
  set(COMMIT 0)
  set(MASTER_TAG "0.0.0")
endif()

if(${BRANCH} MATCHES "^release/.*")
  string(REGEX REPLACE "^release/(.*)" "\\1" LATEST ${BRANCH})
else()
  set(LATEST ${MASTER_TAG})
endif()

string(REGEX REPLACE "^([0-9]+)\\..*" "\\1" APP_VERSION_MAJOR ${LATEST})
string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" APP_VERSION_MINOR ${LATEST})
string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" APP_VERSION_PATCH ${LATEST})

if(${BRANCH} STREQUAL "master")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${APP_VERSION_PATCH}-${APP_VERSION_SHA1})
elseif(${BRANCH} MATCHES "^develop.*")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${APP_VERSION_PATCH}-beta-${APP_VERSION_SHA1})
elseif(${BRANCH} MATCHES "^feature/.*")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${APP_VERSION_PATCH}-alpha-${APP_VERSION_SHA1})
elseif(${BRANCH} MATCHES "^release/.*")
	set(APP_VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${APP_VERSION_PATCH}-rc-${APP_VERSION_SHA1})
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
  message(STATUS "  GIT RELEASE ${MASTER_TAG}")
  message(STATUS "  GIT COMMIT  ${COMMIT}")
	message(STATUS "  GIT SHA1    ${APP_VERSION_SHA1}")
	message(STATUS "========================================")
endfunction()
