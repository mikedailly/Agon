using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace AgonBasic
{
    public class Converter
    {
        public int Errors = 0;
        int LineNumber = 10;
        int LineIncrement = 10;
        int TabSize = 4;
        string Tab = "";
        StringBuilder output = new StringBuilder();

        /// <summary>Drop comments</summary>
        public bool DropComments = false;

        /// <summary>Rename all variables to "short" versions</summary>
        public bool PackVariables = false;

        /// <summary>BBC keywords</summary>
        string[] KeyWords = {
                                "AND","ABS","ACS","ADVAL","ASC","ASN","ATN","AUTO",
                                "BGET","BPUT",
                                "COLOUR","COLOR","CALL","CHAIN","CHR","CLEAR","CLOSE","CLG","CLS","COS","COUNT",
                                "DATA","DEG","DEF","DELETE","DIV","DIM","DRAW",
                                "ENDPROC","END","ENDIF","ENVELOPE","ELSE","EVAL","ERL","ERROR","EOF","EOR","ERR","EXP","EXT",
                                "FOR","FALSE","FN","FX",
                                "GOTO","GET","GET$","GOSUB","GCOL",
                                "HIMEM",
                                "INPUT","IF","INKEY","INKEY$", "INT","INSTR",
                                "LIST","LINE","LOAD","LOMEM","LOCAL","LEFT","LEN","LET","LOG","LN",
                                "MID","MODE","MOD","MOVE",
                                "NEXT","NEW","NOT",
                                "OLD","ON","OFF","OR","OPENIN","OPENOUT","OPENUP","OSCLI",
                                "PRINT","PAGE","PTR","PI","PLOT","POINT","PROC","POS","PUT",
                                "RETURN","REPEAT","REPORT","READ","REM","RUN","RAD","RESTORE","RIGHT","RND","RENUMBER",
                                "STEP","SAVE","SGN","SIN","SQR","SPC","STR","STR$","STRING","SOUND","STOP",
                                "TAN","THEN","TO","TAB","TRACE","TIME","TRUE",
                                "UNTIL","USR",
                                "VDU","VAL","VPOS",
                                "WIDTH"
                            };
        
        Dictionary<string, string> VariableLookup = new Dictionary<string, string>();
        Dictionary<string, int> UsedVariables = new Dictionary<string, int>();

        Dictionary<string, bool> VariableReserved = new Dictionary<string, bool>();

        Dictionary<string, int> LabelLookup = new Dictionary<string, int>();


        // #############################################################################################################################
        /// <summary>
        ///     Conversion error
        /// </summary>
        /// <param name="_error">The error line</param>
        /// <param name="_line">line number the error was on (source)</param>
        // #############################################################################################################################
        public void ELine(string _error, int _line)
        {
            Console.WriteLine("ERROR ("+_line.ToString()+"): Unbalanced IF/ENDIF pair");
            Errors++;
        }


        // #############################################################################################################################
        /// <summary>
        ///     Generate a TAB replacement
        /// </summary>
        /// <returns>The </returns>
        // #############################################################################################################################
        private void GenTab()
        {
            Tab = "";
            for(int i = 0; i < TabSize; i++)
            {
                Tab += " ";
            }
        }


        // #############################################################################################################################
        /// <summary>
        ///     Is this character a symbol?
        /// </summary>
        /// <param name="_c">Character to test</param>
        /// <returns>True for yes, False for no</returns>
        // #############################################################################################################################
        public bool isSymbol(char _c)
        {
            //string symbols = "!\"()£$%^&*_-=+[]{}#~'@;:,<.>/?\\|";
            // Don't include $  %  & or  .
            string symbols = "!\"()£^*_-=+[]{}#~'@;:,<>/?\\|";
            if (symbols.IndexOf(_c) > 0) return true;
            return false;
        }


        // #############################################################################################################################
        /// <summary>
        ///     Is this character a whitespace?
        /// </summary>
        /// <param name="_c">Character to test</param>
        /// <returns>True for yes, False for no</returns>
        // #############################################################################################################################
        public bool isWhiteSpace(char _c)
        {
            if (_c == ' ' || _c == '\t') 
                return true;
            else
                return false;
        }


        // #############################################################################################################################
        /// <summary>
        ///     Check for keywords, and if found, upper case it.
        /// </summary>
        /// <param name="_test">string to test</param>
        /// <returns>test string back, or uppercased keyword</returns>
        // #############################################################################################################################
        public string DoKeyWord(string _test, out bool found)
        {
            found = false;
            string t = _test.ToUpper();
            foreach(string keyword in KeyWords)
            {
                if (keyword == t)
                {
                    found = true;
                    return t;
                }
            }
            return _test;
        }

        // #############################################################################################################################
        /// <summary>
        ///     Scan the string from the current position,and read a "word" out
        /// </summary>
        /// <param name="_line">string to scan</param>
        /// <param name="_index">starting position</param>
        /// <param name="_index_out">next character position to read, or -1 for end of string</param>
        /// <returns>
        ///     WORD to read, or null for none - past end of string
        /// </returns>
        // #############################################################################################################################
        public string ReadWord(string _line, int _index, out int _index_out)
        {
            if (_index < 0 || _index >= _line.Length)
            {
                _index_out = -1;
                return "";
            }

            string s = "";
            char c = _line[_index];

            if(isWhiteSpace(c))
            {
                _index_out = _index+1;
                return ""+c;
            }

            // read a string?
            if( c=='"')
            {
                s = "\"";
                _index++;
                while (_index < _line.Length)
                {
                    c = _line[_index++];
                    s += c;
                    if (c == '"') break;                    
                }
                _index_out = _index;
                return s;
            }


            // Just a symbol?
            if (isSymbol(c))
            {
                _index_out = _index + 1;
                return ""+c;
            }

            
            // Now read out a "word"
            bool start = true;
            bool number = false;
            while (_index<_line.Length)
            {
                c = _line[_index];
                if( isSymbol(c))
                {
                    _index_out = _index;
                    return s;
                }                

                if( start )
                {
                    // if we're "starting" on a number, then read numbers only
                    if (c >= '0' && c <= '9')
                    {
                        number = true;
                        start = false;
                    }
                }


                if (number)
                {
                    if ((c >= '0' && c <= '9') || c=='.')
                    {
                        s = s + c;
                        _index++;
                    }
                    else
                    {
                        _index_out = _index;
                        return s;
                    }
                }
                else
                {
                    if( isSymbol(c) || isWhiteSpace(c))
                    {
                        _index_out = _index;
                        return s;
                    }

                    s = s + c;
                    _index++;
                }
            }

            _index_out = -1;
            return s;
        }


        // #############################################################################################################################
        /// <summary>
        ///     Parse a whole line into BBC Basic format
        /// </summary>
        /// <param name="_line">Line string to parse</param>
        // #############################################################################################################################
        public bool ParseLine(string _line, int pass)
        {
            if (string.IsNullOrEmpty(_line.Trim())) return false;        // drop empty lines
            if(DropComments) if (_line.Trim().ToLower().StartsWith("rem")) return false;              // drop label lines

            // Label?
            if (_line.StartsWith(":") && pass == 1)
            {
                int ignore = 0;
                string label = ReadWord(_line, 1, out ignore);
                if (!string.IsNullOrWhiteSpace(label))
                {
                    LabelLookup.Add(label, LineNumber);
                }
                return false;
            }
            else if (_line.StartsWith(":") && pass == 2) return false;

            int index = 0;
            bool first = true;
            while (true)
            {
                string s = ReadWord(_line, index, out index);
                if (index == -1 && string.IsNullOrEmpty(s)) break;  // end of line
                if (DropComments && s.ToLower().StartsWith("rem")) break;


                // add line number to start of line
                if (first)
                {
                    output.Append(LineNumber.ToString());
                    output.Append(' ');
                    first = false;
                }


                // Look up GOTO symbols on pass 2 - once defined
                if (pass == 2)
                {
                    int line_number = 0;
                    if (LabelLookup.TryGetValue(s, out line_number))
                    {
                        s = line_number.ToString();
                    }
                }


                bool found = false;
                string word = DoKeyWord(s, out found);
                if (word.ToLower().StartsWith("proc"))
                {
                    word = "PROC" + word.Substring(4);
                }
                else if (word.ToLower().StartsWith("fn"))
                {
                    word = "FN" + word.Substring(2);
                }
                else
                {
                    // did we find a keyword,a number (inc HEX which starts with a &) or a symbol? if not we have an ID
                    char c = word[0];
                    if (!found && (c <'0' || c > '9') && !isSymbol(c) && !isWhiteSpace(c) && c!='&')
                    {
                        // Add symbol to pool on pass 1
                        string post_string = ""+word[word.Length - 1];
                        if (post_string == "$" || post_string == "%"){
                            word = word.Substring(0, word.Length - 1);
                        }
                        else
                        {
                            post_string = "";
                        }
                        if (pass == 1)
                        {
                            int cnt = 0;
                            if( UsedVariables.TryGetValue(word,out cnt))
                            {
                                cnt++;
                            }
                            UsedVariables[word] = cnt;
                        }
                        else
                        {
                            // Lookup symbols on pass 2
                            string shortvar;
                            int ln;
                            // If this is a goto label, ignore it.
                            if (!LabelLookup.TryGetValue(word, out ln))
                            {
                                if (VariableLookup.TryGetValue(word, out shortvar))
                                {
                                    word = shortvar;
                                }
                            }
                            word += post_string;
                        }
                    }
                }
                output.Append(word);
            }
            if(!first) output.AppendLine();
            return true;
        }

        // #############################################################################################################################
        /// <summary>
        ///     Generate avariable name
        /// </summary>
        /// <param name="_i"></param>
        /// <returns></returns>
        // #############################################################################################################################
        string GenVariable(int _i)
        {            
            string letters1 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
            string letters2 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            string v = "";

            if (_i == 0) return ""+letters1[0];

            int offset = 0;
            while (_i != 0)
            {
                string letters = letters2;
                if (_i < letters2.Length) letters = letters1;

                int r = _i% letters.Length;
                v = letters[r+offset] +v;

                _i = _i / letters.Length;
            }

            return v;
        }

        // #############################################################################################################################
        /// <summary>
        ///     Parse a whole line into BBC Basic format
        /// </summary>
        /// <param name="_line">Line string to parse</param>
        // #############################################################################################################################
        public void DefineSymbols(string[] _lines)
        {
            LineNumber = 10;
            LineIncrement = 10;            
            foreach (string line in _lines)
            {
                if (string.IsNullOrEmpty(line.Trim())) continue;                       // drop empty lines
                if (DropComments && line.Trim().ToLower().StartsWith("rem")) continue;   // drop comments?

                if (ParseLine(line, 1))
                {
                    LineNumber += LineIncrement;
                }
            }
            output.Clear();


            // Now define all symbols

            if (PackVariables)
            {
                // BASIC also uses A,B,C,D,E,H,L,P and O f for assember stuff

                // first find all single letter variables, and reserve them.
                int VariableNumber = 0;
                foreach (KeyValuePair<string, int> p in UsedVariables)
                {
                    if (p.Key.Length == 1)
                    {
                        VariableReserved.Add(p.Key, true);
                    }
                }

                // Now generate a custom variable for every variable>1 letter
                foreach (KeyValuePair<string, int> p in UsedVariables)
                {
                    if (p.Key.Length != 1)
                    {
                        while (true)
                        {
                            string v = GenVariable(VariableNumber++);
                            bool b = false;
                            if (!VariableReserved.TryGetValue(v, out b))
                            {
                                VariableLookup.Add(p.Key, v);
                                break;
                            }
                        }
                    }
                }
            }
        }


        // #############################################################################################################################
        /// <summary>
        ///     Run through the file and replace all TABS with spaces
        /// </summary>
        /// <param name="_lines"></param>
        /// <returns>new file</returns>
        // #############################################################################################################################
        public string[] PreProcessTAB(string[] _lines)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < _lines.Length; i++)
            {
                string s = _lines[i];
                sb.Clear();
                for (int l = 0; l < s.Length; l++)
                {
                    char c = s[l];
                    if(c == '\t')
                    {
                        sb.Append(Tab);
                    }
                    else
                    {
                        sb.Append(c);
                    }
                }
                _lines[i]=sb.ToString().TrimEnd();
            }
            return _lines;
        }


        // #############################################################################################################################
        /// <summary>
        ///     Find IF/THEN in the line
        /// </summary>
        /// <param name="_src">source string</param>
        /// <param name="_sub">substring to look for</param>
        /// <returns>
        ///     the index of the substring, or -1;
        /// </returns>
        // #############################################################################################################################
        public int find(string _src, string _sub)
        {
            string src = _src.ToLower();
            int pos = src.IndexOf(" "+_sub+" ");
            if (pos >= 0) return pos+1;

            if (src.StartsWith(_sub + " ")) return 0;

            if (src.EndsWith(" "+_sub)) return _src.Length-(_sub.Length);

            if (src == _sub) return 0;

            return -1;
        }


        // #############################################################################################################################
        /// <summary>
        ///     Try and pre-process IF statements so that we can have an ENDIF
        /// </summary>
        /// <param name="_lines"></param>
        // #############################################################################################################################
        public string[] PreProcessIF(string[] _lines)
        {
            Stack<IFStore> IFStack = new Stack<IFStore>();
            string goto_label = "gotolabel";
            int goto_label_num = 0;

            for(int i = 0; i < _lines.Length; i++)
            {
                string s = _lines[i].TrimEnd();
                int ifpos = find(s, "if");
                if (ifpos >= 0)
                {
                    // if this IF isn't a single line IF, then we have an ENDIF case
                    int thenpos = -1;
                    if ( s.EndsWith("then")) 
                    {
                        thenpos = s.Length - 4;
                        IFStack.Push( new IFStore(i,ifpos,thenpos) );
                    }
                }

                // found an end if? If so look at the last "IF" that ends with an "THEN" (not single line IF)
                int endifpos= find(s, "endif");
                if (endifpos >= 0)
                {
                    // unbalanced IF/ENDIF? 
                    if(IFStack.Count==0)
                    {
                        ELine("ERROR: Unbalanced IF/ENDIF pair, line ", i);
                    }
                    else
                    {
                        string label = goto_label + goto_label_num.ToString();
                        goto_label_num++;

                        IFStore store = IFStack.Pop();
                        string ss = _lines[store.line];
                        ss = ss.Insert(store.then_index, ") ");
                        ss = ss + " goto " + label;
                        ss = ss.Insert(store.if_index+2, " NOT( ");
                        _lines[store.line] = ss;

                        _lines[i] = ":" + label;
                    }
                }
            }

            return _lines;
        }


        // #############################################################################################################################
        /// <summary>
        ///     Process a whole file, adding line numbers and making keywords upper case
        /// </summary>
        /// <param name="_lines"></param>
        // #############################################################################################################################
        public string Process(string[] _lines)
        {
            string s="";
            GenTab();

            PreProcessTAB(_lines);              // scan the whole file and replace tabs
            PreProcessIF(_lines);               // scan the whole file and look for IF/ENDIF pairs

            LineNumber = 10;
            LineIncrement = 10;

            DefineSymbols(_lines);              // define all "goto" labels

            LineNumber = 10;
            foreach (string line in _lines)
            {
                if( ParseLine(line,2))
                {
                    LineNumber += LineIncrement;
                }
            }

            return output.ToString();
        }
    }
}
