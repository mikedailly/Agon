10 VDU 22,8
20 CLS
30 d_e% = 1
40 j_k%=20
50 l_m%=8    :    
60 l_o%=0    :    
70 DIM p% 6400
80 DIM q%(6400)
90 DIM s%(20)
100 DIM t%(20)
110 DIM u%(20)
120 DIM v%(20)
130 DIM z%(20)
140 DIM A%(20)
150 DIM B%(8)
160 C%=&40000
170 D%=20
180 E%=20
190 F%=0
200 PROCInit
210     IF d_e%=0 THEN PROCDrawLevel
220     PROCProcessLemmings
230     GOTO 210
240 END
250 DEF PROCProcessLemmings
260     IF F%=j_k% GOTO 320
270     D% = D% - 1
280     IF NOT(  D%=0 ) THEN GOTO 320
290         D% = E%
300         v%(F%) = 1
310         F% = F% + 1
320     FOR i%=0 TO j_k%
330         IF v%(i%) = 0 GOTO 580
340         x% = s%(i%)
350         y% = t%(i%)
360         K%=0
370         FOR L% = 1 TO 5
380             c% = FNGetCollision(x%,y%-L%)
390             IF c% = 0 THEN L%=10 ELSE K%=K%-1
400         NEXT
410         IF NOT(  K% = 0 ) THEN GOTO 460
420             FOR L% = 0 TO 4
430                 c% = FNGetCollision(x%,y%+L%)
440                 IF c% = 0 THEN K%=K%+1 ELSE L%=10
450             NEXT
460         IF NOT(  K%=-5 ) THEN GOTO 490
470             u%(i%) = -u%(i%)
480             IF u%(i%) = 1 THEN A%(i%)=l_o% ELSE A%(i%)=l_m%
490         IF K%<>-5 THEN y% = y%+K%
500         IF K%<4 THEN x% = x% + u%(i%)
510         s%(i%) = x%
520         t%(i%) = y%
530         VDU 23,27,4,i%
540         VDU 23,27,13,(x%-6);y%-10;
550         f% = (z%(i%) + 1) AND 7
560         z%(i%) = f%
570         VDU 23, 27, 10, f% + A%(i%)
580     NEXT
590     VDU 23, 27, 15
600 ENDPROC
610 DEF FNGetCollision(O%,P%)
620 a% = (O% DIV 8) + (P%*40)
630 Q% = B%(O% AND 7)
640 =(q%(a%) AND Q%)
650 DEF PROCDrawLevel
660     i%=24
670     FOR y%=0 TO 128 STEP 32
680         FOR x%=0 TO 288 STEP 32
690             VDU 23, 27, 0, i%
700             VDU 23, 27, 3, x%; y%;
710             i% = i% + 1
720         NEXT
730     NEXT
740 ENDPROC
750 DEF PROCInit
760     R% = 98
770     S% = 49
780     B%(0)=1
790     B%(1)=2
800     B%(2)=4
810     B%(3)=8
820     B%(4)=16
830     B%(5)=32
840     B%(6)=64
850     B%(7)=128
860     FOR i%=0 TO j_k%
870         s%(i%) = R%
880         t%(i%) = S%
890         u%(i%) = 1
900         v%(i%) = 0
910         z%(i%) = 0
920         A%(i%) = l_o%
930     NEXT
940     PRINT "Loading Collision"
950     OSCLI("LOAD data\coll.dat " + STR$(C%+p%) )
960     FOR i%=0 TO 6400
970         q%(i%) = ?(p%+i%)
980     NEXT
990     PROCLoadGraphics
1000 ENDPROC
1010 DEF PROCLoadGraphics
1020     VDU 23,1,0
1030     FOR i%=0 TO 23
1040         f$ = "data\lem"+STR$(i%)+".spr"
1050         PROCLoadSprite(f$,i%,16,10)
1060     NEXT
1070     IF NOT(  d_e% =0 ) THEN GOTO 1140
1080         FOR i%=24 TO 73
1090             f$ = "data\back"+STR$(i%-24)+".spr"
1100             PRINT "Name: "+f$
1110             PROCLoadBitmap(f$,i%,32,32)
1120         NEXT
1130         CLS
1140     IF NOT(  d_e% = 1 ) THEN GOTO 1260
1150         CLS
1160         i%=0
1170         FOR y%=0 TO 160 STEP 32
1180             FOR x%=0 TO 288 STEP 32
1190                 f$ = "data\back"+STR$(i%)+".spr"
1200                 PROCLoadBitmap(f$,24,32,32)
1210                 VDU 23, 27, 0, 24
1220                 VDU 23, 27, 3, x%; y%;
1230                 i% = i% + 1
1240             NEXT
1250         NEXT
1260     FOR i%=0 TO j_k%
1270         VDU 23,27,4,i%
1280         VDU 23,27,5
1290         FOR b%=0 TO 23
1300             VDU 23,27,6, b%
1310         NEXT
1320         VDU 23,27,11
1330     NEXT
1340     VDU 23,27,4,0
1350     VDU 23,27,13,30;30;
1360     VDU 23,27,10,1
1370     VDU 23,27,15
1380     VDU 23,27,7,j_k%
1390 ENDPROC
1400 DEF PROCLoadSprite(f$,n%,w%,h%)
1410     PRINT "Name: "+f$
1420     OSCLI("LOAD " + f$ + " " + STR$(C%+p%))
1430     VDU 23,27,0,n%
1440     VDU 23,27,1,w%;h%;
1450     FOR V%=0 TO (w%*h%*3)-1 STEP 3
1460         r% = ?(p%+V%+2)
1470         g% = ?(p%+V%+1)
1480         b% = ?(p%+V%+0)
1490         a% = 255
1500         IF r%=255 AND g%=0 AND b%=255 THEN a%=0
1510         VDU r%
1520         VDU g%
1530         VDU b%
1540         VDU a%
1550     NEXT
1560 ENDPROC
1570 DEF PROCLoadBitmap(f$,n%,w%,h%)
1580     OSCLI("LOAD " + f$ + " " + STR$(C%+p%))
1590     VDU 23,27,0,n%
1600     VDU 23,27,1,w%;h%;
1610     FOR V%=0 TO (w%*h%*3)-1 STEP 3
1620         VDU ?(p%+V%+2)
1630         VDU ?(p%+V%+1)
1640         VDU ?(p%+V%+0)
1650         VDU 255
1660     NEXT
1670 ENDPROC
