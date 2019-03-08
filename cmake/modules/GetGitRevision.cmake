if(NOT GIT_FOUND)
	find_package(Git)
endif()

# Git executable is extracted from parameters.
execute_process(
	COMMAND bash "-c" "${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD"
	OUTPUT_VARIABLE BRANCH)
string(REGEX REPLACE "(.*)\n$" "\\1" BRANCH ${BRANCH})

execute_process(
	COMMAND bash "-c" "${GIT_EXECUTABLE} describe --tag --always --dirty" OUTPUT_VARIABLE GIT_DESCRIBE)
string(REGEX REPLACE "(.*)\n$" "\\1" GIT_DESCRIBE ${GIT_DESCRIBE})

if(${BRANCH} STREQUAL "master")
	if(${GIT_DESCRIBE} MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+$")
		set(VERSION ${GIT_DESCRIBE})
	else()
		message(FATAL_ERROR "Master branch shoud not modify, Please use develop branch") 
	endif()
elseif(${BRANCH} MATCHES "^develop.*")
	# 0.0.1-1-g123456-dirty
	if(${GIT_DESCRIBE} MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-g.*")
		string(REGEX REPLACE "(^[0-9]+\\.[0-9]+\\.[0-9]+)-[0-9]+-g.*" "\\1" VERSION ${GIT_DESCRIBE})
		string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+-([0-9]+)-g.*" "\\1" COMMIT ${GIT_DESCRIBE})
		string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-(\\.*)" "\\1" SHA1_DIRTY ${GIT_DESCRIBE})
	# 0.0.1-g123456-dirty
	elseif(${GIT_DESCRIBE} MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+.*")
		string(REGEX REPLACE "(^[0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1" VERSION ${GIT_DESCRIBE})
		set(COMMIT 0)
		execute_process(
			COMMAND bash "-c" "${GIT_EXECUTABLE} describe --always --dirty" OUTPUT_VARIABLE GIT_DESCRIBE)
		string(REGEX REPLACE "(.*)\n$" "g\\1" SHA1_DIRTY ${GIT_DESCRIBE})
	endif()
	set(APP_VERSION ${VERSION}-${COMMIT}-beta-${SHA1_DIRTY})
elseif(${BRANCH} MATCHES "^feature/.*")
	# 0.0.1-1-g123456-dirty
	if(${GIT_DESCRIBE} MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-g.*")
		string(REGEX REPLACE "(^[0-9]+\\.[0-9]+\\.[0-9]+)-[0-9]+-g.*" "\\1" VERSION ${GIT_DESCRIBE})
		string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+-([0-9]+)-g.*" "\\1" COMMIT ${GIT_DESCRIBE})
		string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-(\\.*)" "\\1" SHA1_DIRTY ${GIT_DESCRIBE})
	# 0.0.1-g123456-dirty
	elseif(${GIT_DESCRIBE} MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+.*")
		string(REGEX REPLACE "(^[0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1" VERSION ${GIT_DESCRIBE})
		set(COMMIT 0)
		execute_process(
			COMMAND bash "-c" "${GIT_EXECUTABLE} describe --always --dirty" OUTPUT_VARIABLE GIT_DESCRIBE)
		string(REGEX REPLACE "(.*)\n$" "g\\1" SHA1_DIRTY ${GIT_DESCRIBE})
	endif()
	set(APP_VERSION ${VERSION}-${COMMIT}-alpha-${SHA1_DIRTY})
elseif(${BRANCH} MATCHES "^release/.*")
	string(REGEX REPLACE "^release/(.*)" "\\1" VERSION ${BRANCH})
	execute_process(
		COMMAND bash "-c" "${GIT_EXECUTABLE} rev-list HEAD ^${BRANCH} --count" OUTPUT_VARIABLE COMMIT)
	string(REGEX REPLACE "(.*)\n$" "\\1" COMMIT ${COMMIT})
	execute_process(
		COMMAND bash "-c" "${GIT_EXECUTABLE} rev-parse --short HEAD" OUTPUT_VARIABLE SHA1)
	string(REGEX REPLACE "(.*)\n$" "\\1" SHA1 ${SHA1})
	execute_process(
		COMMAND bash "-c" "${GIT_EXECUTABLE} describe --always --dirty" OUTPUT_VARIABLE DIRTY)
	if(${DIRTY} MATCHES ".*-dirty\n$")
		set(DIRTY "-dirty")
	else()
		set(DIRTY "")
	endif()
	set(APP_VERSION ${VERSION}-rc${COMMIT}-g${SHA1}${DIRTY})
else()
	message(FATAL_ERROR "Current branch is invalid, please change working branch (develop/feature/release/master/hotfix)")
endif()

string(REGEX REPLACE "^([0-9]+)\\..*" "\\1" APP_VERSION_MAJOR ${VERSION})
string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" APP_VERSION_MINOR ${VERSION})
string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" APP_VERSION_PATCH ${VERSION})

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
	message(STATUS "  GIT TAG     ${VERSION}")
	message(STATUS "  GIT COMMIT  ${COMMIT}")
	message(STATUS "  GIT SHA1    ${GIT_SHA1_DIRTY}")
	message(STATUS "========================================")
endfunction()
