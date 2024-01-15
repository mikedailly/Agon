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
630         IF u%(i%) = 0 GOTO 920
640         x% = r%(i%)
650         y% = s%(i%)
660         M%=0
670         NO% = x% DIV 8
680         P% =  A%(x% AND 7)
690         Q% = p%+NO% + ((y%-1)*40)
700         FOR R% = 1 TO 5
710             IF (?Q% AND P%) = 0 THEN R%=10 ELSE M%=M%-1
720              Q% = Q% - 40
730         NEXT
740         IF NOT(  M% = 0 ) THEN GOTO 800
750             Q% = p% + NO% + (y%*40)
760             FOR R% = 0 TO 4
770                 IF (?Q% AND P%) = 0 THEN M%=M%+1 ELSE R%=10
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
910         VDU 23, 27, 10, f% + z%(i%)
920     NEXT
930     VDU 23, 27, 15
940     VDU 5
950     MOVE 0,400
960 ENDPROC
970 DEF FNGetCollision(U%,V%)
980 a% = (U% DIV 8) + (V%*40)
990 P% = A%(U% AND 7)
1000 =(?(p%+a%) AND P%)
1010 DEF PROCInit
1020     W% = 98
1030     X% = 49
1040     A%(0)=1
1050     A%(1)=2
1060     A%(2)=4
1070     A%(3)=8
1080     A%(4)=16
1090     A%(5)=32
1100     A%(6)=64
1110     A%(7)=128
1120     FOR i%=0 TO e_g%
1130         r%(i%) = W%
1140         s%(i%) = X%
1150         t%(i%) = 1
1160         u%(i%) = 0
1170         v%(i%) = 0
1180         z%(i%) = j_l%
1190     NEXT
1200     PRINT "Loading Collision"
1210     OSCLI("LOAD data\coll.dat " + STR$(B%+p%) )
1220     PRINT "Loading Masks"
1230     OSCLI("LOAD data\masks.spr " + STR$(B%+q%))
1240     PROCLoadGraphics
1250 ENDPROC
1260 DEF PROCLoadGraphics
1270     VDU 23,1,0
1280     PRINT "Loading Sprites"
1290     Y_Z%=0
1300     FOR i%=0 TO 23
1310         f$ = "data\lem"+STR$(i%)+".spr"
1320         PROCLoadBitmap(f$,Y_Z%,16,10)
1330         Y_Z% = Y_Z% + 1
1340     NEXT
1350     PRINT "Loading Background"
1360     PROCLoadLargeBitmap("data\background.spr",Y_Z%,320,192)
1370     H% = Y_Z%
1380     VDU 23, 27, 32, H%;
1390     VDU 23, 27, 3, 0; 0;
1400     Y_Z% = Y_Z% + 1
1410     FOR i%=0 TO e_g%
1420         VDU 23,27,4,i%
1430         VDU 23,27,5
1440         FOR b%=0 TO 23
1450             VDU 23, 27, &26, b%;
1460         NEXT
1470         VDU 23,27,11
1480     NEXT
1490     VDU 23,27,4,0
1500     VDU 23,27,13,30;30;
1510     VDU 23,27,10,1
1520     VDU 23,27,15
1530     VDU 23,27,7,e_g%
1540 ENDPROC
1550 DEF PROCLoadMasks(f$,n%)
1560     OSCLI("LOAD " + f$ + " " + STR$(B%+o%))
1570     FOR ba%=0 TO n%-1
1580         q[ba%] = ?(o%+ba%)
1590     NEXT
1600 ENDPROC
1610 DEF PROCLoadBitmap(f$,n%,w%,h%)
1620     OSCLI("LOAD " + f$ + " " + STR$(B%+o%))
1630     bb% = w%*h%
1640     VDU 23, 0 160, n%; 2;
1650     VDU 23, 0 160, n%; 0,bb%;
1660     FOR ba%=0 TO bb%-1
1670         VDU ?(o%+ba%)
1680     NEXT
1690     VDU 23, 0, 160, n%; 14
1700     VDU 23, 27, 32, n%;
1710     VDU 23, 27, 33, w%; h%; 1
1720 ENDPROC
1730 DEF PROCLoadLargeBitmap(f$,n%,w%,h%)
1740     PRINT "Load file: "+f$
1750     bc% = OPENIN f$
1760     bb% = w%*h%
1770     VDU 23, 0 160, n%; 2;
1780     G%=0
1790     bd% = 1024
1800     be% = bb%
1810      REPEAT
1820        IF be% < bd% THEN bd% = be%
1830        be% = be% - bd%
1840        PRINT ".";       : 
1850        VDU 23, 0, 160, n%; 0, bd%;
1860        FOR i% = 1 TO bd%
1870          VDU BGET#bc%
1880        NEXT
1890      UNTIL be% = 0
1900     CLOSE #bc%
1910     VDU 23, 0, 160, n%; 14
1920     VDU 23, 27, 32, n%;
1930     VDU 23, 27, 33, w%; h%; 1
1940 ENDPROC
