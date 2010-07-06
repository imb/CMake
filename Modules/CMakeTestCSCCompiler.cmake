INCLUDE(CMakeTestCompilerCommon)

IF(NOT CMAKE_CSC_COMPILER_WORKS)
    PrintTestCompilerStatus("CSC" "")
    FILE(WRITE
        ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testCSCCompiler.cs
        "public class MainEntry {public static void Main() {}}"
    )
    TRY_COMPILE(CMAKE_CSC_COMPILER_WORKS 
        ${CMAKE_BINARY_DIR} 
        ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testCSCCompiler.cs
        OUTPUT_VARIABLE OUTPUT)
    SET(CSC_TEST_WAS_RUN 1)
ENDIF()

IF(NOT CMAKE_CSC_COMPILER_WORKS)
    PrintTestCompilerStatus("CSC" " -- broken")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "Determining if the CSC compiler works failed with "
        "the following output:\n${OUTPUT}\n\n")
    MESSAGE(FATAL_ERROR "The CSC compiler \"${CMAKE_CSC_COMPILER}\" "
        "is not able to compile a simple test program.\nIt fails "
        "with the following output:\n ${OUTPUT}\n\n"
        "CMake will not be able to correctly generate this project.")
ELSE()
  IF(CSC_TEST_WAS_RUN)
    PrintTestCompilerStatus("CSC" " -- works")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Determining if the CSC compiler works passed with "
      "the following output:\n${OUTPUT}\n\n")
  ENDIF()
  SET(CMAKE_CSC_COMPILER_WORKS 1 CACHE INTERNAL "")
ENDIF()
