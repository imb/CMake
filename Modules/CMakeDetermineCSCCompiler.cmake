# Determine the compiler to use for C# programs.
#
# NOTE, the generator may set the CMAKE_CSC_COMPILER before loading this
# file. 
#
# Sets the following variables:
#   CMAKE_CSC_COMPILER
#

IF(NOT CMAKE_CSC_COMPILER)
    SET(CMAKE_CSC_COMPILER_INIT NOTFOUND)

    # Prefer the environment variable CSC
    IF($ENV{CSC} MATCHES ".+")
        GET_FILENAME_COMPONENT(CMAKE_CSC_COMPILER_INIT $ENV{CSC} PROGRAM PROGRAM_ARGS CMAKE_CSC_FLAGS_ENV_INIT)
        IF(CMAKE_CSC_FLAGS_ENV_INIT)
            SET(CMAKE_CSC_COMPILER_ARG1 "${CMAKE_CSC_FLAGS_ENV_INIT}" CACHE STRING "First argument to the CSC compiler")
        ENDIF()
        IF(NOT EXISTS ${CMAKE_CSC_COMPILER_INIT})
            MESSAGE(FATAL_ERROR "Could not find compiler set in environment variable CSC:\n$ENV{CSC}.\n${CMAKE_CSC_COMPILER_INIT}")
        ENDIF()
    ENDIF()

    # Next prefer the generator specificed compiler.
    IF(CMAKE_GENERATOR0_CSC)
        IF(NOT CMAKE_CSC_COMPILER_INIT)
          SET(CMAKE_CSC_COMPILER_INIT ${CMAKE_GENERATOR_CSC})
        ENDIF(NOT CMAKE_CSC_COMPILER_INIT)
    ENDIF()

    # Finally list compilers to try.
    IF(CMAKE_CSC_COMPILER_INIT)
        SET(CMAKE_CSC_COMPILER_LIST ${CMAKE_CSC_COMPILER_INIT})
    ELSE()
       SET(CMAKE_CSC_COMPILER_LIST ${_CMAKE_TOOLCHAIN_PREFIX}csc)
    ENDIF()

    SET(_CMAKE_CSC_PATHS 
        [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\MSBuild\\ToolsVersions\\3.5;MSBuildToolsPath]
        [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\MSBuild\\ToolsVersions\\2.0;MSBuildToolsPath]
    )

    # Find the compiler.
    FIND_PROGRAM(_CMAKE_CSC_COMPILER NAMES ${CMAKE_CSC_COMPILER_LIST} PATHS ${_CMAKE_CSC_PATHS} DOC "C# compiler")
    IF(CMAKE_CSC_COMPILER_INIT AND NOT _CMAKE_CSC_COMPILER)
        SET(_CMAKE_CSC_COMPILER "${CMAKE_CSC_COMPILER_INIT}" CACHE FILEPATH "C# compiler" FORCE)
    ENDIF()


    # ----------------------------------------------
    # C# Adapter
    # ----------------------------------------------
    # 
    # The CSC adapter is used to help translate a CMake style of doing
    # things into a C# style. CMake grew up from a two-part compile/link
    # system, whereas C# is a single step compile/link. The
    # adapter should really only be used for "Makefile" style compiles.
    #
    # We use a configuration file on our adapter to allow us to set lots
    # of useful configuration information right into the compiled code.
    #
    # The adapter is only needed for makefile generators.
    #
    IF(NOT CMAKE_GENERATOR MATCHES "Visual")
        SET(CMAKE_CSC_ADAPTER
            ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/csc_adapt.exe
        )
        SET(CMAKE_CSC_ADAPTER_CONFIG_SRC
             ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/csc_config.cs
        )
        CONFIGURE_FILE(${CMAKE_ROOT}/Modules/CSCAdapt/csc_config.cs.in
            ${CMAKE_CSC_ADAPTER_CONFIG_SRC}
        )
        SET(CMAKE_CSC_ADAPTER_SRC
	    ${CMAKE_ROOT}/Modules/CSCAdapt/csc_adapt.cs
	)
        MESSAGE(STATUS "Build C# adapter")
	FILE(TO_NATIVE_PATH ${_CMAKE_CSC_COMPILER} _CMAKE_CSC_COMPILER_NATIVE)
        FILE(TO_NATIVE_PATH ${CMAKE_CSC_ADAPTER} CMAKE_CSC_ADAPTER_NATIVE)
	FILE(TO_NATIVE_PATH ${CMAKE_CSC_ADAPTER_CONFIG_SRC} CMAKE_CSC_ADAPTER_CONFIG_SRC_NATIVE)
        FILE(TO_NATIVE_PATH ${CMAKE_CSC_ADAPTER_SRC} CMAKE_CSC_ADAPTER_SRC_NATIVE)
	SET(CMAKE_CSC_ADAPTER_COMPILE_CMD 
		"${_CMAKE_CSC_COMPILER_NATIVE}"
                /target:exe 
               	/out:${CMAKE_CSC_ADAPTER_NATIVE}
		"${CMAKE_CSC_ADAPTER_SRC_NATIVE}"
		"${CMAKE_CSC_ADAPTER_CONFIG_SRC_NATIVE}"
	)
        MESSAGE(STATUS "Build C# adapter: ${CMAKE_CSC_ADAPTER_COMPILE_CMD}")
        EXECUTE_PROCESS(
            COMMAND ${CMAKE_CSC_ADAPTER_COMPILE_CMD} 
	    OUTPUT_VARIABLE CMAKE_CSC_ADAPTER_MAKE_OUTPUT
	    ERROR_VARIABLE  CMAKE_CSC_ADAPTER_MAKE_OUTPUT
	    OUTPUT_STRIP_TRAILING_WHITESPACE
	    RESULT_VARIABLE CMAKE_CSC_ADAPTER_MAKE_RESULT
        )
        IF(NOT "${CMAKE_CSC_ADAPTER_MAKE_RESULT}" MATCHES "^0$")
            message(STATUS "Build C# adapter - failed.")
            message(FATAL_ERROR
                "Unable to build the C# adapter (${CMAKE_CSC_ADAPTER_MAKE_RESULT}).\n"
                "It failed with the following output:\n"
                "'${CMAKE_CSC_ADAPTER_MAKE_OUTPUT}'\n"
		"Compile command was:\n"
		"${CMAKE_CSC_ADAPTER_COMPILE_CMD}"
            )
        ELSE()
            message(STATUS "Build C# adapter: ${CMAKE_CSC_ADAPTER}")
        ENDIF()
        SET(CMAKE_CSC_COMPILER ${CMAKE_CSC_ADAPTER})
        SET(_CMAKE_CSC_COMPILER )
    ELSE()
        SET(CMAKE_CSC_COMPILER ${_CMAKE_CSC_COMPILER})
    ENDIF()
ENDIF()

# We don't want to pick up our adapter, so read from the actual compiler name.
GET_FILENAME_COMPONENT(CMAKE_CSC_COMPILER_ID ${_CMAKE_CSC_COMPILER} NAME_WE)


CONFIGURE_FILE(${CMAKE_ROOT}/Modules/CMakeCSCCompiler.cmake.in
    ${CMAKE_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/CMakeCSCCompiler.cmake
)


# In C/C++ world this is CC/CXX.
SET(CMAKE_CSC_COMPILER_ENV_VAR "CSC")