// **********************************************************************************************************************
// 
// Copyright (c)2017-2023, Mike Dailly. All Rights reserved.
// 
// File:			Program.cs
// Created:			30/10/2017
// Author:			Mike
// Project:			Tools
// Description:		Main graphics conversion. 
// 
// Date				Version		BY		Comment
// ----------------------------------------------------------------------------------------------------------------------
// 30/10/2017		V1.0.0      MJD     1st version
// 18/10/2023		V1.0.1      MJD     Imported from LemConv
// 
// **********************************************************************************************************************
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Tools
{
    class Program
    {
        /// <summary>Input file</summary>
        public static string InFile = "";
        /// <summary>Outputfile</summary>
        public static string OutFile = "";
        /// <summary>Outputfile</summary>
        public static string OutFileExt = "";
        /// <summary>The NEXT data folder</summary>
        public static string DestFolder = "";

        public static bool GrabSprites = false;
        public static bool GrabCollision = false;

        public static int max_count = 0x7fffffff;

        /// <summary>Grabbed sprites</summary>
        public static List<Sprite> Sprites = new List<Sprite>();

        /// <summary>Grabbed sprites</summary>
        public static int GridWidth = 16;
        public static int GridHeight = 16;

        // ####################################################################################
        /// <summary>
        ///     A commandline gird = "16x16" or "32x32"
        /// </summary>
        /// <param name="_size"></param>
        // ####################################################################################
        public static void ReadGridSize(string _size )
        {
            _size = _size.ToLower();
            int pos = _size.IndexOf('x');

            if (pos < 0) return;
            string xsize = _size.Substring(0, pos);
            string ysize = _size.Substring(pos+1);

            int.TryParse(xsize, out GridWidth);
            int.TryParse(ysize, out GridHeight);
        }

        public static uint ReadNumber(string _num)
        {
            uint v;
            UInt32.TryParse(_num, out v);
            return v;
        }
        // ####################################################################################
        /// Function:   <summary>
        ///                 Parse all arguments
        ///             </summary>
        /// In:         <param name="_args">the argument array</param>
        // ####################################################################################
        public static void ParseArguments(string[] _args)
        {
            int i = 0;
            while (i < _args.Length)
            {
                string a = _args[i];
                switch (a)
                {
                    case "-spr":
                        GrabSprites = true;
                        ReadGridSize(_args[i+1]);
                        i++;
                        break;
                    case "-max":
                        max_count = (int)ReadNumber(_args[i + 1]);
                        i++;
                        break;
                    case "-col":
                        GrabCollision = true;
                        break;

                    //case "-bmp": bBMP256Conv = true; break;         // convert BMP into 256 colour
                    //case "-png": bBMP256Clamp = true; break;        // clamp all colours to spec next colours
                    default:
                        break;
                }
                i++;
            }

            InFile = _args[_args.Length - 2];
            OutFile = _args[_args.Length - 1];

            OutFileExt = Path.GetExtension(OutFile);
            OutFile = Path.Combine( Path.GetDirectoryName(OutFile),Path.GetFileNameWithoutExtension(OutFile));
        }



        // ####################################################################################
        /// <summary>
        ///     Grab a collision map - anything non-zero
        /// </summary>
        /// <param name="_img"></param>
        // ####################################################################################
        static void ProcessCollision(Image _img)
        {
            byte[] coll;

            int ww = (_img.Width + 7) / 8;
            coll = new byte[ww * _img.Height];

            for(int y=0;y<_img.Height;y++)
            {
                for (int  x = 0; x < _img.Width; x++)
                {
                    UInt32 col = _img[x, y];
                    if ((col & 0xffffff) != 0)
                    {
                        int b = (x / 8);
                        int bit = x & 7;
                        int index = b + (y * _img.Width / 8);
                        coll[index] |= (byte) (1 << bit);
                    }
                }
            }

            try
            {
                File.WriteAllBytes(OutFile + OutFileExt, coll);
            }
            catch { }
        }

        // ####################################################################################
        /// Function:   <summary>
        ///                 Main loop
        ///             </summary>
        /// In:         <param name="_args">the argument array</param>
        // ####################################################################################
        [STAThread]
        static void Main(string[] _args)
        {
            ParseArguments(_args);

            Image img = new Image(InFile);

            if (GrabSprites) Sprite.Grab(img, GridWidth, GridHeight, OutFile, OutFileExt, max_count);
            if (GrabCollision) ProcessCollision(img);
        }
    }
}
