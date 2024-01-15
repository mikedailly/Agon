10 VDU 22,8
20 CLS
30 c_d=370    :    
40 e_g%=20
50 j_k%=8    :    
60 j_l%=0    :    
70 m% = 128        :    
80 DIM o% 6400
90 DIM p% 6400
100 DIM q% 6400
110 DIM r%(20)
120 DIM s%(20)
130 DIM t%(20)
140 DIM u%(20)
150 DIM v%(20)
160 DIM z%(20)
170 DIM A%(8)
180 B%=&40000
190 C%=17
200 D%=17
210 E%=0
220 PROCInit
230 F_G%=100
240     VDU 23, 27, 32, H%;
250     VDU 23, 27, 3, 0; 0;
260     PROCProcessLemmings
270     F_G% = F_G%-1
280     IF(F_G% = 0) THEN PROCClearBombShape(200,64,0)
290     GOTO 240
300 END
310 x%=0
320 DEF PROCDrawInToBackground(x%,y%)
330     FOR i%=0 TO 15
340         VDU 23, 0, 160, (H%); 5,    &C2, (320*y%)+x%+(320*i%); 16;
350         FOR b%= 0 TO 15
360             VDU 255
370         NEXT
380     NEXT
390     PROCDrawLevel
400 ENDPROC
410 DEF PROCClearBombShape(x%,y%,n%)
420     n% = 0
430     w% = ?(q%+n%)
440     n% = n% + 1
450     h% = ?(q%+n%)
460     n% = n% + 1
470     FOR i%=0 TO h%
480         VDU 23, 0, 160, (H%); 5,    &C5, (320*y%)+x%+(320*i%); w%+1;
490         FOR b%= 0 TO w%
500             VDU ?(q%+n%+b%)
510         NEXT
520         n% = n% + b%
530     NEXT
540 ENDPROC
550 DEF PROCProcessLemmings
560     IF E%=e_g% GOTO 620
570     C% = C% - 1
580     IF NOT(  C%=0 ) THEN GOTO 620
590         C% = D%
600         u%(E%) = 1
610         E% = E% + 1
620     FOR i%=0 TO e_g%
630         IF u%(i%) = 0 GOTO 930
640         x% = r%(i%)
650         y% = s%(i%)
660         M%=0
670         NO% = x% DIV 8
680         P% =  A%(x% AND 7)
690         Q% = p%+NO% + ((y%-1)*40)
700         FOR R% = 1 TO 5
710             IF (?Q% AND P%)  = 0 THEN R%=10 ELSE M%=M%-1
720              Q% = Q% - 40
730         NEXT
740         IF NOT(  M% = 0 ) THEN GOTO 800
750             Q% = p% + NO% + (y%*40)
760             FOR R% = 0 TO 4
770                 IF (?Q% AND P%)  = 0 THEN M%=M%+1 ELSE R%=10
780                 Q% = Q% + 40
790             NEXT
800         IF NOT(  M%=-5 ) THEN GOTO 830
810             t%(i%) = -t%(i%)
820             IF t%(i%) = 1 THEN z%(i%)=j_l% ELSE z%(i%)=j_k%
830         IF M%<>-5 THEN y% = y%+M%
840         IF M%<4 THEN x% = x% + t%(i%)
850         r%(i%) = x%
860         s%(i%) = y%
870         VDU 23,27,4,i%
880         VDU 23,27,13,(x%-6);y%-10;
890         f% = (v%(i%) + 1) AND 7
900         v%(i%) = f%
910         VDU 23,27,4,i%
920         VDU 23, 27, 10, f% + z%(i%)
930     NEXT
940     VDU 23, 27, 15
950     VDU 5
960     MOVE 0,400
970 ENDPROC
980 DEF FNGetCollision(U%,V%)
990 a% = (U% DIV 8) + (V%*40)
1000 P% = A%(U% AND 7)
1010 =(?(p%+a%) AND P%)
1020 DEF PROCInit
1030     W% = 98
1040     X% = 49
1050     A%(0)=1
1060     A%(1)=2
1070     A%(2)=4
1080     A%(3)=8
1090     A%(4)=16
1100     A%(5)=32
1110     A%(6)=64
1120     A%(7)=128
1130     FOR i%=0 TO e_g%
1140         r%(i%) = W%
1150         s%(i%) = X%
1160         t%(i%) = 1
1170         u%(i%) = 0
1180         v%(i%) = 0
1190         z%(i%) = j_l%
1200     NEXT
1210     PRINT "Loading Collision"
1220     OSCLI("LOAD data\coll.dat " + STR$(B%+p%) )
1230     PRINT "Loading Masks"
1240     OSCLI("LOAD data\masks.spr " + STR$(B%+q%))
1250     PROCLoadGraphics
1260 ENDPROC
1270 DEF PROCLoadGraphics
1280     VDU 23,1,0
1290     PRINT "Loading Sprites"
1300     Y_Z%=0
1310     FOR i%=0 TO 23
1320         f$ = "data\lem"+STR$(i%)+".spr"
1330         PROCLoadBitmap(f$,Y_Z%,16,10)
1340         Y_Z% = Y_Z% + 1
1350     NEXT
1360     PRINT "Loading Background"
1370     PROCLoadLargeBitmap("data\background.spr",Y_Z%,320,192)
1380     H% = Y_Z%
1390     VDU 23, 27, 32, H%;
1400     VDU 23, 27, 3, 0; 0;
1410     Y_Z% = Y_Z% + 1
1420     FOR i%=0 TO e_g%
1430         VDU 23,27,4,i%
1440         VDU 23,27,5
1450         FOR b%=0 TO 23
1460             VDU 23, 27, &26, b%;
1470         NEXT
1480         VDU 23,27,11
1490     NEXT
1500     VDU 23,27,4,0
1510     VDU 23,27,13,30;30;
1520     VDU 23,27,10,1
1530     VDU 23,27,15
1540     VDU 23,27,7,e_g%
1550 ENDPROC
1560 DEF PROCLoadMasks(f$,n%)
1570     OSCLI("LOAD " + f$ + " " + STR$(B%+o%))
1580     FOR ba%=0 TO n%-1
1590         q[ba%] = ?(o%+ba%)
1600     NEXT
1610 ENDPROC
1620 DEF PROCLoadBitmap(f$,n%,w%,h%)
1630     OSCLI("LOAD " + f$ + " " + STR$(B%+o%))
1640     bb% = w%*h%
1650     VDU 23, 0 160, n%; 2;
1660     VDU 23, 0 160, n%; 0,bb%;
1670     FOR ba%=0 TO bb%-1
1680         VDU ?(o%+ba%)
1690     NEXT
1700     VDU 23, 0, 160, n%; 14
1710     VDU 23, 27, 32, n%;
1720     VDU 23, 27, 33, w%; h%; 1
1730 ENDPROC
1740 DEF PROCLoadLargeBitmap(f$,n%,w%,h%)
1750     PRINT "Load file: "+f$
1760     bc% = OPENIN f$
1770     bb% = w%*h%
1780     VDU 23, 0 160, n%; 2;
1790     G%=0
1800     bd% = 1024
1810     be% = bb%
1820      REPEAT
1830        IF be% < bd% THEN bd% = be%
1840        be% = be% - bd%
1850        PRINT ".";       : 
1860        VDU 23, 0, 160, n%; 0, bd%;
1870        FOR i% = 1 TO bd%
1880          VDU BGET#bc%
1890        NEXT
1900      UNTIL be% = 0
1910     CLOSE #bc%
1920     VDU 23, 0, 160, n%; 14
1930     VDU 23, 27, 32, n%;
1940     VDU 23, 27, 33, w%; h%; 1
1950 ENDPROC
