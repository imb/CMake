/* Adapter executable.

The purpose of this adapter is to forward commands along to the CSC.EXE
interface from a CMake interface.

CMake grew up from a C/C++ world of compilers and linkers, but C# was
born in an age that took source code straight to its final form, without
an intermediate stage.

The adapter is really only needed to interact with the "Makefile"
generators, a Visual studio generator should proceed to build using a
proper csproj.

Command line arguments for C# are different than from C/C++, in so far
as the first argument is the program name. So keep that in mind when
reviewing the following rules for this adapter.

Arguments and Conventions:

    ARG0 - Subcommand. Subcommand's mimic the standard CMakeXXXInformation
    fields,

       compile_object
       shared_library
       link_exectuable
       
       (static_library and shared_module are not applicable)

    The sub-commands will take arguments that start with a "/" and
    directly forward them to the underlying csc. Any command with a "---"
    will be handled by the sub-command.

    Each subcommand has the following usage:

    compile_object
        --source : the source file.
        --object : a desired object file.

        Note: That we are doing some trickery here to "compile" objects.
*/

using System;
using System.Collections;
using System.Text;

class CSC
{
    string arguments = null;

    public CSC(string arguments) {
        this.arguments = arguments;
    }
    public CSC(ArrayList arguments) {
    }
    public CSC(string[] arguments)
    {
        this.arguments = string.Join(" ", arguments);
    }

    public int Invoke()
    {
        string csc_compiler = CMakeVars.NormPath(CMakeVars.CSC_COMPILER);

        Console.WriteLine(
                "csc_adapter - csc : " + CMakeVars.CSC_COMPILER + "\n"
        );
        Console.WriteLine(
                "csc_adapter - arguments : " + this.arguments 
                );

        System.Diagnostics.Process proc = new System.Diagnostics.Process();
        proc.StartInfo.FileName = csc_compiler;
        proc.StartInfo.Arguments = this.arguments;
        proc.StartInfo.Verb = "Compile";
        proc.StartInfo.CreateNoWindow = true;
        proc.StartInfo.UseShellExecute = false;
        proc.StartInfo.RedirectStandardError = true;
        proc.StartInfo.RedirectStandardOutput = true;
        proc.StartInfo.RedirectStandardInput = true;
        proc.Start();
        System.IO.StreamWriter stdin = proc.StandardInput;
        System.IO.StreamReader stderr = proc.StandardError;
        System.IO.StreamReader stdout = proc.StandardOutput;
        stdin.AutoFlush = true;
        proc.WaitForExit();
        int exitCode = proc.ExitCode;
        proc.Close();
        /* Would be nice to synchronize, one fine day. */
        Console.Write(stdout.ReadToEnd());
        Console.Write(stderr.ReadToEnd());
        Console.WriteLine(
                String.Format(
                    "csc_adapter - exit code : {0}", exitCode
                    )
                );
        return exitCode;
    }
}


class CompileObject
{
    string source = null;
    string object_ = null;

    public CompileObject(string[] args)
    {
        /* First argument is the sub-command, the rest of them are what
        interest us. */
        if (args.Length != 3)
        {
            throw new ApplicationException(
                    String.Format(
                        "compile_object - invalid arguments, require " +
                        "<SOURCE> and <OBJECT>. Recieved: " +
                        "{0}",
                        args
                     )
                );
        }
        this.source = args[1];
        this.object_ = args[2];
    }

    public int Invoke()
    {
        /* What we do here is insert a little line into the "object"
        file that "back traces" to the source file. So later, when 
        the other adapters work on the data, they can figure out
        the original source by looking at the back trace. */
        System.IO.StreamWriter sw = new System.IO.StreamWriter(this.object_);
        sw.WriteLine(this.source);
        sw.Close();
        return 0;
    }
}


class Linker
{
    string csc_args =null;

    string BackTraceSourceFile(string backtraceFile)
    {
        System.IO.StreamReader sr = new System.IO.StreamReader(backtraceFile);
        string s = sr.ReadToEnd();
        return s.Trim();
    }
     
    public Linker(string[] args) 
    {
        /* Lets not pretend to be "elegant" here, just get it done for
        now. Absorb all flags, but when you see "---" we are dealing
        with "our" flags. */
        StringBuilder build_args = new StringBuilder();       
        bool is_parsing_objects = false;
        for(int i=1; i < args.Length; ++i ) {
            string a = args[i];
            if ( a.StartsWith("---") ) {
                /* Well for now there is only one possible flag. */
                is_parsing_objects = true;
            } else if ( is_parsing_objects ) {
                string src_file = this.BackTraceSourceFile(a);
                build_args.Append(src_file);
                build_args.Append(" ");
            } else {
                build_args.Append(a);
                build_args.Append(" ");
            }
        }
        this.csc_args = build_args.ToString();
    }

    public int Invoke() {
        CSC csc = new CSC(this.csc_args);
        return csc.Invoke();
    }
}


class TestCSC
{
    string source = null;

    public TestCSC(string[] args)
    {
        /* Should only be two arguments long, first is the subcommand, second
        is the file we want to compile. */
        if (args.Length != 2)
        {
            throw new ApplicationException(
                "try_compile - requires test source file to compile"
                );
        }
        this.source = args[1];
    }

    public int Invoke()
    {
        CSC csc = new CSC(this.source);
        return csc.Invoke();
    }
}


class CscAdapt
{
    static int _Main(string[] args)
    {
        int exitCode = 0;
        if (args.Length == 0)
        {
            throw new ApplicationException(
                "missing sub command"
                );
        }
        if (args[0] == "compile_object")
        {
            if ( args.Length == 2 ) {
                /* Then we are testing the adapter! */
                TestCSC tc = new TestCSC(args);
                exitCode = tc.Invoke();
            } else {
                CompileObject co = new CompileObject(args);
                exitCode = co.Invoke();
            }
        }
        else if (args[0] == "test_csc")
        {
            TestCSC tc = new TestCSC(args);
            exitCode = tc.Invoke();
        }
        else if (args[0] == "link_executable") {
            Linker le = new Linker(args);
            exitCode = le.Invoke();
        }
        else if (args[0] == "shared_library")
        {
            Linker sl = new Linker(args);
            exitCode = sl.Invoke();
        } 
        else
        {
            throw new ApplicationException(
                    String.Format(
                        "unknown sub command - {0}",
                        args[0]
                        )
                    );
        }
        return exitCode;
    }

    static int Main(string[] args)
    {
        int exitCode = -1;
        try
        {
            exitCode = _Main(args);
        }
        catch (ApplicationException e)
        {
            Console.WriteLine("error : {0}", e.ToString());
            Console.WriteLine(
                    "No. Args={0}", args.Length
                    );
            foreach(string arg in args) {
                Console.WriteLine(" - {0}", arg); 
            }
            exitCode = 1;
        }
        return exitCode;
    }
}
