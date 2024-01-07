// **********************************************************************************************************************
// 
// Copyright (c)2017-2023, Mike Dailly. All Rights reserved.
// 
// File:			Sprite.cs
// Created:			24/12/2017
// Author:			Mike
// Project:			LemConv
// Description:		Sprite container
// 
// Date				Version		BY		Comment
// ----------------------------------------------------------------------------------------------------------------------
// 24/12/2017		V1.0.0      MJD     1st version
// 
// **********************************************************************************************************************
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tools
{
    public class Sprite
    {
        public uint[] Raw;
        /// <summary>Sprite x drawing offset </summary>
        public int XOff;
        /// <summary>Sprite x drawing offset </summary>
        public int YOff;
        /// <summary>Actual WIDTH of Raw[]</summary>
        public int Width;
        /// <summary>Actual HEIGHTof Raw[]</summary>
        public int Height;
        /// <summary>Uncropped width of sprite </summary>
        public int FullWidth;
        /// <summary>Uncropped height of sprite</summary>
        public int FullHeight;

        /// <summary>Uncropped height of sprite</summary>
        public string Filename;

        // #############################################################################################
        /// <summary>
        ///     Get/Set array access into the image
        /// </summary>
        /// <param name="_x">x coordinate</param>
        /// <param name="_y">y coordinate</param>
        /// <returns>pixel</returns>
        // #############################################################################################
        public uint this[int _x, int _y]
        {
            get
            {
                return Raw[_x + (_y * Width)];

            }
            set
            {
                Raw[_x + (_y * Width)] = value;
            }
        }

        // #############################################################################################
        /// <summary>
        ///     Create a new sprite
        /// </summary>
        /// <param name="_w">width of sprite</param>
        /// <param name="_h">height of sprite</param>
        // #############################################################################################
        public Sprite(int _w, int _h)
        {
            Raw = new uint[_w * _h];
            for (int i = 0; i < (_w * _h); i++) Raw[i] = 0xffff00ff;        // full magenta is transparent
            Width = _w;
            Height = _h;
        }


        // #############################################################################################
        /// <summary>
        ///     Crop the sprites
        /// </summary>
        /// <param name="_xoff">x start of crop</param>
        /// <param name="_yoff">y start of crop</param>
        /// <param name="_width">width of new sprite</param>
        /// <param name="_height">height of new sprite</param>
        // #############################################################################################
        public void Crop(int _xoff,int _yoff, int _width, int _height)
        {
            int index =0;
            uint[] NewImage = new uint[_width * _height];
            for(int y = _yoff; y < (_yoff + _height); y++)
            {
                for (int x = _xoff; x < (_xoff + _width); x++)
                {
                    NewImage[index++] = this[x, y];
                }
            }
            Raw = NewImage;
            Width = _width;
            Height = _height;
        }


        // #############################################################################################
        /// <summary>
        ///     Save the sprite to a PNG
        /// </summary>
        /// <param name="_filename"></param>
        /// <param name="pal"></param>
        // #############################################################################################
        public void SavePNG(string _filename = "")
        {
            if (_filename == "") _filename = Filename;

            Image img = new Image(Width,Height);
            for(int y = 0; y < Height; y++)
            {
                for (int x = 0; x < Width; x++)
                {
                    uint b = this[x, y];
                    if (b == 0xffff00ff)
                    {
                        img[x, y] = 0x00000000;     // make transparent
                    }
                    else
                    {
                        img[x, y] = b;
                    }
                }
            }
            img.Save(_filename);
        }



        // #############################################################################################
        /// <summary>
        ///     Save the sprite to a PNG
        /// </summary>
        /// <param name="_filename"></param>
        /// <param name="pal"></param>
        // #############################################################################################
        public void Save24Bit(string _filename = "")
        {
            if (_filename == "") _filename = Filename;

            byte[] Buff = new byte[Width * Height * 3];

            int index = 0;
            for (int y = 0; y < Height; y++)
            {
                for (int x = 0; x < Width; x++)
                {
                    uint b = this[x, y];
                    Buff[index++] = (byte)(b & 0xff);
                    Buff[index++] = (byte) ((b >> 8) & 0xff);
                    Buff[index++] = (byte)((b >> 16) & 0xff);
                }
            }
            File.WriteAllBytes(_filename, Buff);
        }

        // #############################################################################################
        /// <summary>
        ///     Save the sprite to a 2222 format raw data file
        /// </summary>
        /// <param name="_filename">Filename to save to</param>
        // #############################################################################################
        public void Save2222Format(string _filename = "")
        {
            if (_filename == "") _filename = Filename;

            byte[] Buff = new byte[Width * Height];

            int index = 0;
            for (int y = 0; y < Height; y++)
            {
                for (int x = 0; x < Width; x++)
                {
                    uint b = this[x, y];

                    // Transparent?
                    if((b&0x00ffffff)==0xFF00FF)
                    {
                        b = 0;
                    }
                    int col = (byte)((b & 0xff) >> 6)<<4;
                    col |= (byte)((b & 0xff00) >> 14)<<2;
                    col |= (byte)((b & 0xff0000) >> 22);
                    col |= (byte)((b & 0xff000000) >> 30)<<6;
                    Buff[index++] = (byte) (col&0xff);
                }
            }
            File.WriteAllBytes(_filename, Buff);
        }


        /// <summary>
        ///     Draw this sprite onto the provided image
        /// </summary>
        /// <param name="_img"></param>
        /// <param name="_xx"></param>
        /// <param name="_yy"></param>
        public void Draw(Image _img, int _xx, int _yy)
        {
            // loop through all pixels
            for (int y = 0; y < Height; y++)
            {
                int xx = _xx;
                for (int x = 0; x < Width; x++)
                {
                    _img[xx++, _yy] = this[x, y];
                }
                _yy++;
            }
        }

        // ##################################################################################################################################
        /// <summary>
        ///     Grab a sprite from an image
        /// </summary>
        /// <param name="_img">Image to grab from</param>
        /// <param name="_x">X Origin</param>
        /// <param name="_y">Y Origin</param>
        /// <param name="_w">Width of sprite to grab</param>
        /// <param name="_h">Height of sprite to grab</param>
        // ##################################################################################################################################
        public static Sprite GrabSprite(Image _img, int _x,int _y, int _w, int _h)
        {
            Sprite s = new Sprite(_w, _h);
            
            for (int y = 0; y < _h; y++)
            {
                for (int x = 0; x < _w; x++)
                {
                    s[x, y] = _img[_x + x, _y + y];
                }
            }

            return s;
        }

        // ##################################################################################################################################
        /// <summary>
        ///     Grab a stack of sprites from an image
        /// </summary>
        /// <param name="_img"></param>
        /// <param name="_w"></param>
        /// <param name="_h"></param>
        /// <param name="_OutName"></param>
        /// <param name="_OutExt"></param>
        /// <param name="_max">Max number of sprites to grab</param>
        // ##################################################################################################################################
        public static void Grab(Image _img, int _w, int _h, string _OutName, string _OutExt, int _max)
        {
            int SprNum = 0;
            int w = (_img.Width + (_w - 1)) / _w;
            int h = (_img.Height+ (_h - 1)) / _h;

            List<Sprite> Sprites = new List<Sprite>();
            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    Sprite s = GrabSprite(_img, x*_w, y*_h, _w, _h);
                    s.Filename = _OutName + SprNum.ToString() + _OutExt;
                    s.Save2222Format(s.Filename);
                    //s.SavePNG(_OutName + SprNum.ToString() + ".png");
                    SprNum++;
                    _max--;
                    if (_max == 0) return;
                }
            }

        }
    }
}
