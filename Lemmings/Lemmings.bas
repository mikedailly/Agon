rem ****************************************************************************************************************
rem Simple Lemmings Demo
rem ****************************************************************************************************************

rem 320x240 16 colour
rem vdu 22,137		
vdu 22,8		
cls

rem Change to 0 to ALWAYS draw the level, and 1 to draw on load only
MASK_SIZE=370	:	rem size of the mask file
MAX_LEM%=20
FRAME_LBASE%=8	:	rem Left facing frames
FRAME_RBASE%=0	:	rem Right facing frames

Curs% = 128		:	rem Cursor buffer/bitmap

rem vdu 19,1,1,0,0,0
dim FileBuffer% 6400
dim CollisionBuffer% 6400
dim Masks% 6400
dim LemX%(20)
dim LemY%(20)
dim LemDir%(20)
dim LemActive%(20)
dim LemFrame%(20)
dim LemFrameBase%(20)

dim bits%(8)
MB%=&40000
Counter%=17
MaxCounter%=17
ActiveLem%=0


rem initialise everything
PROCInit


change_counter%=100
:MainLoop
	rem *fx 19

	rem draw background	
	vdu 23, 27, 32, background%; 
	vdu 23, 27, 3, 0; 0;

	procProcessLemmings


	change_counter% = change_counter%-1
	if(change_counter% = 0) then procClearBombShape(200,64,0)

	goto MainLoop

end

x%=0


rem ****************************************************************************************************************
rem 	Draw into the background
rem ****************************************************************************************************************
def procDrawInToBackground(x%,y%)

	for i%=0 to 15
		VDU 23, 0, 160, (background%); 5,    &C2, (320*y%)+x%+(320*i%); 16;
		for b%= 0 to 15
			vdu 255
		next
	next

	procDrawLevel

endproc


rem ****************************************************************************************************************
rem 	Draw into the background
rem x% - X coord of mask
rem y% - Y coord of mask
rem n% - mask to use
rem ****************************************************************************************************************
def procClearBombShape(x%,y%,n%)

	n% = 0

	w% = ?(Masks%+n%)
	n% = n% + 1
	h% = ?(Masks%+n%)
	n% = n% + 1

	for i%=0 to h%
		VDU 23, 0, 160, (background%); 5,    &C5, (320*y%)+x%+(320*i%); w%+1;
		for b%= 0 to w%
			vdu ?(Masks%+n%+b%)
		next
		n% = n% + b%
	next


	rem procDrawLevel

endproc


rem ****************************************************************************************************************
rem 	Process all lemmings
rem ****************************************************************************************************************
def PROCProcessLemmings

	rem process entrance and dropping lemmings after the counter counts down to zero
	if ActiveLem%=MAX_LEM% goto SkipCounter
	Counter% = Counter% - 1
	if Counter%=0 then 
		Counter% = MaxCounter%
		LemActive%(ActiveLem%) = 1
		ActiveLem% = ActiveLem% + 1
	endif
:SkipCounter


	rem loop around all sprites
	for i%=0 to MAX_LEM%

		rem if lemming isn't active, then skip it
		if LemActive%(i%) = 0 goto LemNotActive

		rem copy out coords for faster access
		x% = LemX%(i%)
		y% = LemY%(i%)

		rem Check UP for climbing first
		yd%=0
		x8% = x% div 8
		bit% =  bits%(x% and 7)
		

		rem work out the byte in the collision map we're about to start with
		cb% = CollisionBuffer%+x8% + ((y%-1)*40)
		for yy% = 1 to 5	
			rem PEEK collision map and AND it with the column bit the lemming is in.		
			if (?cb% and bit%) = 0 then yy%=10 else yd%=yd%-1
			rem move UP a row of pixels (y-1)
			 cb% = cb% - 40
		next


		rem if no "wall" or hill, then check for falling
		if yd% = 0 then
			rem no "up", so Check "down" collision for falling

			rem work out the byte in the collision map we're about to start with
			cb% = CollisionBuffer% + x8% + (y%*40)
			for yy% = 0 to 4
				rem PEEK collision map and AND it with the column bit the lemming is in.		
				if (?cb% and bit%) = 0 then yd%=yd%+1 else yy%=10
				rem move DOWN a row of pixels (y-1)
				cb% = cb% + 40
			next

		endif

		rem Too high to walk up, so turn around - a climber would normally be activated here
		if yd%=-5 then 
			LemDir%(i%) = -LemDir%(i%)
			rem LemActive%(i%) = 0
			if LemDir%(i%) = 1 then LemFrameBase%(i%)=FRAME_RBASE% else LemFrameBase%(i%)=FRAME_LBASE%
		endif
		
		rem ELSE add on the Y delta
		if yd%<>-5 then y% = y%+yd%

		rem if not falling, then move on X - should really be made a faller here
		if yd%<4 then x% = x% + LemDir%(i%)

		rem store coords back into array
		LemX%(i%) = x%
		LemY%(i%) = y%

		rem select sprite and set new position
		vdu 23,27,4,i%
		vdu 23,27,13,(x%-6);y%-10;
		
		rem setup next animation frame
		f% = (LemFrame%(i%) + 1) and 7
		LemFrame%(i%) = f%

		vdu 23, 27, 10, f% + LemFrameBase%(i%)

:LemNotActive
	next
	VDU 23, 27, 15


	VDU 5
	MOVE 0,400

endproc


rem ****************************************************************************************************************
rem 	get collision at pixel cx,cy
rem ****************************************************************************************************************
def FNGetCollision(cx%,cy%) 
a% = (cx% div 8) + (cy%*40)

bit% = bits%(cx% and 7)	
=(?(CollisionBuffer%+a%) and bit%)



rem ****************************************************************************************************************
rem 	Initialise the demo
rem ****************************************************************************************************************
def PROCInit

	rem Setup lemming "start" point
	StartX% = 98
	StartY% = 49

	rem build up bitfield mask array for collision lookup
	bits%(0)=1
	bits%(1)=2
	bits%(2)=4
	bits%(3)=8
	bits%(4)=16
	bits%(5)=32
	bits%(6)=64
	bits%(7)=128

	rem Init all lemmings - but disable them
	for i%=0 to MAX_LEM%
		LemX%(i%) = StartX%
		LemY%(i%) = StartY%
		LemDir%(i%) = 1
		LemActive%(i%) = 0
		LemFrame%(i%) = 0
		LemFrameBase%(i%) = FRAME_RBASE%
	next

	rem Load the collision map directly into the collision buffer (the same way files do)
	print "Loading Collision"
	oscli("LOAD data\coll.dat " + str$(MB%+CollisionBuffer%) )

	print "Loading Masks"
	oscli("LOAD data\masks.spr " + str$(MB%+Masks%))
	

	rem Load all -graphics
	procLoadGraphics

endproc

rem ****************************************************************************************************************
rem 	Load in all graphics and sprites
rem ****************************************************************************************************************
def procLoadGraphics
	rem Disable cursor
	VDU 23,1,0

	rem Load lemming "sprites"
	print "Loading Sprites"
	buffer_id%=0
	for i%=0 to 23
		f$ = "data\lem"+str$(i%)+".spr"
		PROCLoadBitmap(f$,buffer_id%,16,10)
		buffer_id% = buffer_id% + 1
	next

	print "Loading Background"
	PROCLoadLargeBitmap("data\background.spr",buffer_id%,320,192)
	background% = buffer_id%

	rem draw bitmap "buffer_id%"
	VDU 23, 27, 32, background%; 
	vdu 23, 27, 3, 0; 0;

	buffer_id% = buffer_id% + 1


	rem load cursors
rem	PROCLoadBitmap("data\cur0.spr",Curs%,16,16)
rem	PROCLoadBitmap("data\cur1.spr",Curs%+1,16,16)
rem	VDU 23,0,&89,0
rem	VDU 23, 27, 32, Curs%; 
rem	VDU 23, 27, 64, 8, 8

rem command 0 is enable, 
rem 1 is disable, 
rem 2 is reset, 
rem 3 sets the cursor using a 16-bit value (a bitmap ID that's already been set up using VDU 23,27,&40,hotx,hoty or for values 0-18 pre-existing fab-gl defined cursors) - use value 65535 to hide the cursor
rem 4, x; y; (16-bit values) sets the cursor position
rem 5 is reserved (it's intended to take x1,y1,x2,y2 to set screen area for mouse)
rem 6-10 are configuration things, setting sample rate, resolutiuon, scaling, acceleration and wheel acceleration


	rem setup sprites adding frames to each one
	for i%=0 to MAX_LEM%
		rem select sprite
		vdu 23,27,4,i%
		rem clear current frames
		vdu 23,27,5
		rem Add bitmap to sprite frames
		for b%=0 to 23
			rem Add bitmap to the current sprite
			VDU 23, 27, &26, b%;
		next		
		vdu 23,27,11
	next

	vdu 23,27,4,0
	vdu 23,27,13,30;30;
	vdu 23,27,10,1
	vdu 23,27,15
	vdu 23,27,7,MAX_LEM%
endproc

rem ****************************************************************************************************************
rem Loads Mask array
rem F$ - Filename of masks
rem N% - size of file to read in
rem ****************************************************************************************************************
def PROCLoadMasks(f$,n%)
	oscli("LOAD " + f$ + " " + str$(MB%+FileBuffer%))

	rem Write block to a buffer
	for index%=0 to n%-1
		Masks[index%] = ?(FileBuffer%+index%)
	next
endproc

rem ****************************************************************************************************************
rem Load a 2222 foramt bitmap into VDP RAM
rem F$ - Filename of bitmap
rem N% - Bitmap number
rem W% - Bitmap width
rem H% - Bitmap height
rem ****************************************************************************************************************
def PROCLoadBitmap(f$,n%,w%,h%)
	oscli("LOAD " + f$ + " " + str$(MB%+FileBuffer%))
	fsize% = w%*h%

	rem create a buffer and clear it, ready for loading the bitmap into
	VDU 23, 0 160, n%; 2;

	rem Write block to a buffer
	VDU 23, 0 160, n%; 0,fsize%;
	for index%=0 to fsize%-1
		vdu ?(FileBuffer%+index%)
	next

	rem consolidate blocks in a buffer
	VDU 23, 0, 160, n%; 14

	rem  Select bitmap (using a buffer ID)
	VDU 23, 27, 32, n%;

	rem  Create bitmap from buffer
	VDU 23, 27, 33, w%; h%; 1
endproc


rem ****************************************************************************************************************
rem Load a 2222 foramt bitmap into VDP RAM
rem F$ - Filename of bitmap
rem N% - Bitmap number
rem W% - Bitmap width
rem H% - Bitmap height
rem ****************************************************************************************************************
def PROCLoadLargeBitmap(f$,n%,w%,h%)
	rem oscli("LOAD " + f$ + " " + str$(MB%+FileBuffer%))
	print "Load file: "+f$
	infile% = OPENIN f$
	fsize% = w%*h%

	rem create a buffer and clear it, ready for loading the bitmap into
	VDU 23, 0 160, n%; 2;

	rem Write block to a buffer
	rem VDU 23, 0 160, n%; 0,fsize%;
	counter%=0

	blockSize% = 1024
	left% = fsize%
	 REPEAT
	   IF left% < blockSize% THEN blockSize% = left%
	   left% = left% - blockSize%
	   PRINT ".";       : REM Show progress
	   VDU 23, 0, 160, n%; 0, blockSize%;
	   FOR i% = 1 TO blockSize%
	     VDU BGET#infile%
	   NEXT
	 UNTIL left% = 0

	CLOSE #infile%

	rem consolidate blocks in a buffer
	VDU 23, 0, 160, n%; 14

	rem  Select bitmap (using a buffer ID)
	VDU 23, 27, 32, n%;

	rem  Create bitmap from buffer
	VDU 23, 27, 33, w%; h%; 1
endproc

