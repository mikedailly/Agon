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

        /// <summary>pre-rotayted</summary>
        public byte[] Masks;
        // #############################################################################################
        /// <summary>
        ///     Get/Set array access into the image
        /// </summary>
        /// <param name="_x">x coordinate</param>
        /// <param name="_y">y coordinate</param
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


        // ##################################################################################################################################
        /// <summary>
        ///     Draw this sprite onto the provided image
        /// </summary>
        /// <param name="_img"></param>
        /// <param name="_xx"></param>
        /// <param name="_yy"></param>
        // ##################################################################################################################################
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

        // ##################################################################################################################################
        /// <summary>
        ///     Take the sprite data, and generate pre-rotated 1 bit masks
        /// </summary>
        // ##################################################################################################################################
        private void GenerateBitmasks()
        {
            int w = ((Width + 7) / 8)+1;
            int h = Height;

            byte[] Memory = new byte[2+(8 * w * h)];
            Memory[0] = (byte)w;
            Memory[1] = (byte)h;

            int index = 2;
            for (int i = 0; i < 8; i++)
            {
                // fill mask
                for(int f = 0; f < (w * h); f++)
                {
                    Memory[f + index] = 0xff;
                }

                // Now loop through the mask and clear bits
                for (int yy = 0; yy < Height; yy++)
                {
                    for (int xx = 0; xx < Width; xx++)
                    {
                        uint col = this[xx, yy];
                        if ((col & 0xffffff) != 0)
                        {
                            int off = (xx >> 3) + (yy * w);
                            int mask = 1 << (xx & 7);
                            Memory[index + off] &= (byte)~mask;
                        }
                    }
                }

                // Now rotate the mask by "i" bits
                if (i != 0)
                {
                    for (int yy = 0; yy < h; yy++)
                    {
                        // can't be bothered doing a barrel shift, so just rotate each line "r" times
                        for (int r = 0; r < i; r++)
                        {
                            byte bit = 0x80;
                            int off = (yy * w);
                            for (int xx = 0; xx < w; xx++)
                            {
                                byte col = Memory[index + off];
                                byte bit2 = (byte)(col & 1);
                                col = (byte)((col >> 1) | bit);
                                if (bit2 == 0) bit = 0x00; else bit = 0x80;
                                off++;
                            }
                        }
                    }
                }

                // next mask
                index += (w * h);
            }



            // Now make the "RAW" image fit everything for saving later
            Masks = Memory;            
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
        public static void GrabMasks(Image _img, string _OutName, string _OutExt, int _max)
        {
            int len = _img.Raw.Length;
            int index = 0;

            List<Sprite> masks = new List<Sprite>();
            while(index<len)
            {
                UInt32 rect_col = _img.Raw[index++];
                if ((rect_col & 0x00ffffff) == 0xFF00FF) continue;     // transparent?

                // Get width
                int lstart = index - 1;
                int width = 0;
                while(index < len)
                {
                    UInt32 c = _img.Raw[index++];
                    if (c == rect_col) continue;
                    break;
                }
                if (lstart > len) break;
                index--;
                width = (index - lstart)-2;

                // Get height
                index = lstart+_img.Width;
                int height= 0;
                while (lstart < len)
                {
                    UInt32 c = _img.Raw[index];
                    index += _img.Width;
                    if (c == rect_col) continue;
                    break;
                }
                if (lstart > len) break;
                index -= _img.Width;
                height = ((index - lstart)/_img.Width)-2;

                // remember start of sprite
                index = lstart;

                // get start of mask on image
                lstart = (lstart + _img.Width) + 1;

                // Now copy the image into a 
                Sprite s = new Sprite(width, height);
                int sprindex = 0;
                int maskindex = 0;
                for(int y=0;y<height;y++)
                {
                    sprindex = lstart;
                    for (int x=0;x<width;x++)
                    {
                        UInt32 c = _img.Raw[sprindex++];

                        // Transparent?
                        if ((c & 0x00ffffff) == 0xFF00FF)
                        {
                            c = 0;
                        }
                        else
                        {
                            c = 0xff;
                        }
                        s.Raw[maskindex++] = (byte)(c&0xff);
                    }
                    lstart += _img.Width;
                }
                s.GenerateBitmasks();
                masks.Add(s);




                // clear mask from image
                width += 2;
                height += 2;
                lstart = index;
                index += width;
                sprindex = 0;
                for (int y = 0; y < height; y++)
                {
                    sprindex = lstart;
                    for (int x = 0; x < width; x++)
                    {
                        _img.Raw[sprindex++] = 0xFFFF00FF;
                    }
                    lstart += _img.Width;
                }
            }

            // Now write out all masks
            int total_size = 0;
            foreach(Sprite s in masks)
            {
                total_size += s.Raw.Length + 2;         // width,height, [size]
                total_size += s.Masks.Length;           // bitmasks + width + height
                total_size += 2;                        // total size - to allow skipping
            }

            byte[] Buff = new byte[total_size];
            index = 0;
            foreach (Sprite s in masks)
            {
                // work out ""skip" bytes"
                int total = s.Masks.Length + s.Masks.Length + 2;
                Buff[index++] = (byte)(total & 0xff);
                Buff[index++] = (byte) ((total>>8) & 0xff);
                Buff[index++] = (byte) (s.Width-1);
                Buff[index++] = (byte) (s.Height-1);
                Buff[index++] = s.Masks[0];             // mask width
                Buff[index++] = s.Masks[1];             // mask height

                for (int i = 0; i < s.Raw.Length; i++)
                {
                    Buff[index++] = (byte) ((255^s.Raw[i]&0xff)|0xc0);     // invert mask
                }

                // Now copy the mask in
                Array.Copy(s.Masks, 2, Buff, index, s.Masks.Length - 2);
                index += s.Masks.Length - 2;
            }

            File.WriteAllBytes(_OutName+_OutExt, Buff);
        }
    }
}
