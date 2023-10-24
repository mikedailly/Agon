using AgonBasic;
using System;
using System.Text;

namespace MyApp // Note: actual namespace depends on the project name.
{
    internal class Program
    {
        static string InFile = "";
        static string OutFile = "";

        static bool DropComments = false;
        static bool PackVariables = false;

        static void ParseCommadLine(string[] _args)
        {
            foreach(string s in _args)
            {
                switch(s)
                {
                    case "-rem":
                        DropComments = true;
                        break;
                    case "-var":
                        PackVariables = true;
                        break;
                }
            }

            int l = _args.Length;
            InFile = _args[l - 2];
            OutFile = _args[l - 1];
        }



        static void Main(string[] _args)
        {
            if (_args.Length < 2)
            {
                Console.WriteLine("AgonBasic [opt]<in> <out>");
                Console.WriteLine("   -var   optimised variable renaming");
                Console.WriteLine("   -rem   remove all comments");
                return;
            }
            ParseCommadLine(_args);


            Console.WriteLine("Loading file: " + InFile);


            string[] lines;
            try
            {
                lines = File.ReadAllLines(InFile);
            }
            catch
            {
                Console.WriteLine("Error loading file: " + InFile);
                return;
            }

            Console.WriteLine("Processing");
            Converter converter = new Converter();
            converter.DropComments = DropComments;
            converter.PackVariables = PackVariables;
            string output = converter.Process(lines);

            if (converter.Errors != 0)
            {
                Environment.ExitCode = -1;
            }
            else
            {
                File.WriteAllText(OutFile, output);
            }
            Console.WriteLine("Done.");
        }
    }
}