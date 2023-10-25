rem ****************************************************************************************************************
rem Simple Lemmings Demo
rem ****************************************************************************************************************

rem 320x240 16 colour
rem vdu 22,137		
vdu 22,8		
cls

rem Change to 0 to ALWAYS draw the level, and 1 to draw on load only
init_seq% = 1

MAX_LEM%=20
FRAME_LBASE%=8	:	rem Left facing frames
FRAME_RBASE%=0	:	rem Right facing frames

rem vdu 19,1,1,0,0,0
dim FileBuffer% 6400
dim CollisionBuffer%(6400)
dim LemX%(20)
dim LemY%(20)
dim LemDir%(20)
dim LemActive%(20)
dim LemFrame%(20)
dim LemFrameBase%(20)

dim bits%(8)
MB%=&40000
Counter%=20
MaxCounter%=20
ActiveLem%=0


rem initialise everything
PROCInit

:MainLoop
	rem *fx 19
	if init_seq%=0 then procDrawLevel
		
	procProcessLemmings

	goto MainLoop


end


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
		for yy% = 1 to 5
			c% = FNGetCollision(x%,y%-yy%)
			if c% = 0 then yy%=10 else yd%=yd%-1
		next

		rem if no "wall" or hill, then check for falling
		if yd% = 0 then
			rem no "up", so Check "down" collision for falling
			for yy% = 0 to 4
				c% = FNGetCollision(x%,y%+yy%)
				if c% = 0 then yd%=yd%+1 else yy%=10
			next
		endif

		rem Too high to walk up, so turn around - a climber would normally be activated here
		if yd%=-5 then 
			LemDir%(i%) = -LemDir%(i%)
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
endproc


rem ****************************************************************************************************************
rem 	get collision at pixel cx,cy
rem ****************************************************************************************************************
def FNGetCollision(cx%,cy%) 
a% = (cx% div 8) + (cy%*40)
bit% = bits%(cx% and 7)	
=(CollisionBuffer%(a%) and bit%)



rem ****************************************************************************************************************
rem 	Render the level...
rem ****************************************************************************************************************
def procDrawLevel

	i%=24
	for y%=0 to 160 step 32
		for x%=0 to 288 step 32
			vdu 23, 27, 0, i%
			vdu 23, 27, 3, x%; y%;
			i% = i% + 1
		next
	next

endproc


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

	rem Load the collision map
	rem PROCLoadData("data\coll.dat",CollisionBuffer%,6400)
	print "Loading Collision"
	oscli("LOAD data\coll.dat " + str$(MB%+FileBuffer%) )
	for i%=0 to 6400
		CollisionBuffer%(i%) = ?(FileBuffer%+i%) 
	next


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
	for i%=0 to 23
		f$ = "data\lem"+str$(i%)+".spr"
		PROCLoadSprite(f$,i%,16,10)
	next


	if init_seq% =0 then
		rem Load level "tiles"	
		for i%=24 to 82
			f$ = "data\back"+str$(i%-24)+".spr"
			print "Name: "+f$
			PROCLoadBitmap(f$,i%,32,32)
		next
		cls
	endif

	if init_seq% = 1 then
		cls
		rem Load level "tiles" and draw as we go
		i%=0
		for y%=0 to 160 step 32
			for x%=0 to 288 step 32
				f$ = "data\back"+str$(i%)+".spr"

				rem load bitmap into slot 24
				PROCLoadBitmap(f$,24,32,32)
			
				rem draw bitmap 24
				vdu 23, 27, 0, 24
				vdu 23, 27, 3, x%; y%;
				i% = i% + 1
			next
		next

	endif

	rem setup sprites
	for i%=0 to MAX_LEM%
		rem select sprite
		vdu 23,27,4,i%
		rem clear current frames
		vdu 23,27,5
		rem Add bitmap to sprite frames
		for b%=0 to 23
			vdu 23,27,6, b%
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
rem Load a bitmap into VDP RAM - pinched from sprite demo
rem F$ - Filename of bitmap
rem N% - Bitmap number
rem W% - Bitmap width
rem H% - Bitmap height
rem ****************************************************************************************************************
def PROCLoadSprite(f$,n%,w%,h%)
	print "Name: "+f$
	oscli("LOAD " + f$ + " " + str$(MB%+FileBuffer%))
	vdu 23,27,0,n%
	vdu 23,27,1,w%;h%;
	for index%=0 to (w%*h%*3)-1 step 3
		r% = ?(FileBuffer%+index%+2) 
		g% = ?(FileBuffer%+index%+1) 
		b% = ?(FileBuffer%+index%+0) 
		a% = 255
		if r%=255 and g%=0 and b%=255 then a%=0
		
		vdu r%
		vdu g%
		vdu b%
		vdu a%
	next
endproc


rem ****************************************************************************************************************
rem Load a bitmap into VDP RAM - pinched from sprite demo
rem F$ - Filename of bitmap
rem N% - Bitmap number
rem W% - Bitmap width
rem H% - Bitmap height
rem ****************************************************************************************************************
def PROCLoadBitmap(f$,n%,w%,h%)
	oscli("LOAD " + f$ + " " + str$(MB%+FileBuffer%))
	vdu 23,27,0,n%
	vdu 23,27,1,w%;h%;
	for index%=0 to (w%*h%*3)-1 step 3
		vdu ?(FileBuffer%+index%+2) 
		vdu ?(FileBuffer%+index%+1) 
		vdu ?(FileBuffer%+index%+0) 
		vdu 255
	next
endproc



