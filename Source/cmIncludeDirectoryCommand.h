/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2000-2009 Kitware, Inc., Insight Software Consortium

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/
#ifndef cmIncludeDirectoryCommand_h
#define cmIncludeDirectoryCommand_h

#include "cmCommand.h"

/** \class cmIncludeDirectoryCommand
 * \brief Add include directories to the build.
 *
 * cmIncludeDirectoryCommand is used to specify directory locations
 * to search for included files.
 */
class cmIncludeDirectoryCommand : public cmCommand
{
public:
  /**
   * This is a virtual constructor for the command.
   */
  virtual cmCommand* Clone() 
    {
    return new cmIncludeDirectoryCommand;
    }

  /**
   * This is called when the command is first encountered in
   * the CMakeLists.txt file.
   */
  virtual bool InitialPass(std::vector<std::string> const& args,
                           cmExecutionStatus &status);

  /**
   * The name of the command as specified in CMakeList.txt.
   */
  virtual const char* GetName() { return "include_directories";}

  /**
   * Succinct documentation.
   */
  virtual const char* GetTerseDocumentation() 
    {
    return "Add include directories to the build.";
    }
  
  /**
   * More documentation.
   */
  virtual const char* GetFullDocumentation()
    {
    return
      "  include_directories([AFTER|BEFORE] [SYSTEM] dir1 dir2 ...)\n"
      "Add the given directories to those searched by the compiler for "
      "include files. By default the directories are appended onto "
      "the current list of directories. This default behavior can be "
      "changed by setting CMAKE_include_directories_BEFORE to ON. "
      "By using BEFORE or AFTER you can select between appending and "
      "prepending, independent from the default. "
      "If the SYSTEM option is given the compiler will be told that the "
      "directories are meant as system include directories on some "
      "platforms.";
    }
  
  cmTypeMacro(cmIncludeDirectoryCommand, cmCommand);

protected:
  // used internally
  void AddDirectory(const char *arg, bool before, bool system);
};



#endif
