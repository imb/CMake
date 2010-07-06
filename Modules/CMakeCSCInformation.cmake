# Set up rule variables for C#.

SET(CMAKE_CSC_SOURCE_FILE_EXTENSIONS cs)

# The .backtrace points back to the original source when it gets to the
# CSC link time. Import libraries, &etc, follow the same princpal. These
# constructs are part of the CSC adapter and are not platform dependent.
SET(CMAKE_CSC_OUTPUT_EXTENSION       .backtrace.cs)
SET(CMAKE_CSC_IMPORT_LIBRARY_PREFIX  .backtrace.lib)

INCLUDE(Platform/${CMAKE_SYSTEM_NAME}-${CMAKE_CSC_COMPILER_ID})


SET(CMAKE_CSC_FLAGS_INIT "$ENV{CFLAGS} ${CMAKE_CSC_FLAGS_INIT}")
# avoid just having a space as the initial value for the cache 
IF(CMAKE_CSC_FLAGS_INIT STREQUAL " ")
  SET(CMAKE_CSC_FLAGS_INIT)
ENDIF(CMAKE_CSC_FLAGS_INIT STREQUAL " ")
SET (CMAKE_CSC_FLAGS "${CMAKE_CSC_FLAGS_INIT}" CACHE STRING
     "Flags used by the compiler during all build types.")

IF(NOT CMAKE_NOT_USING_CONFIG_FLAGS)
  IF(NOT CMAKE_NO_BUILD_TYPE)
    SET (CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE_INIT} CACHE STRING 
      "Choose the type of build, options are: None (CMAKE_CSC_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
  ENDIF()
  SET(CMAKE_CSC_FLAGS_DEBUG
      "${CMAKE_CSC_FLAGS_DEBUG_INIT}" CACHE STRING
    "Flags used by the compiler during debug builds.")
  SET(CMAKE_CSC_FLAGS_MINSIZEREL 
      "${CMAKE_CSC_FLAGS_MINSIZEREL_INIT}" CACHE STRING
    "Flags used by the compiler during release minsize builds.")
  SET(CMAKE_CSC_FLAGS_RELEASE "${CMAKE_CSC_FLAGS_RELEASE_INIT}" CACHE STRING
    "Flags used by the compiler during release builds (/MD /Ob1 /Oi /Ot /Oy /Gs will produce slightly less optimized but smaller files).")
  SET(CMAKE_CSC_FLAGS_RELWITHDEBINFO 
      "${CMAKE_CSC_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING
      "Flags used by the compiler during Release with Debug Info builds.")
ENDIF()


INCLUDE(CMakeCommonLanguageInclude)



# C# Compilers take a set of source files to generate the final executable.
SET(CMAKE_CSC_COMPILE_OBJECT
    "<CMAKE_CSC_COMPILER> compile_object <SOURCE> <OBJECT>"
)


SET(CMAKE_CSC_CREATE_SHARED_LIBRARY 
    "<CMAKE_CSC_COMPILER> shared_library /nologo /target:library /out:<TARGET> ---objects <OBJECTS>"
)

# This may be overloaded to take advantage of the /target:module flag,
# which I think just compiles a "bunch-o-iasm" that can be combined in a
# final DLL or EXE.
SET(CMAKE_CSC_CREATE_SHARED_MODULE 
    "${CMAKE_COMMAND} -E echo CMAKE_CSC_CREATE_SHARED_MODULE"
)


SET(CMAKE_CSC_CREATE_STATIC_LIBRARY
    "${CMAKE_COMMAND} -E echo CREATE_STATIC_LIBRARY"
)



SET(CMAKE_CSC_LINK_EXECUTABLE 
    "<CMAKE_CSC_COMPILER> link_executable /nologo /target:exe /out:<TARGET> ---objects <OBJECTS>"
)

SET(CMAKE_CSC_INFORMATION_LOADED 1)

