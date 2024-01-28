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
280     IF(F_G% = 0) THEN PROCClearMaskShape(200,64,0)
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
410 DEF PROCClearMaskShape(x%,y%,n%)
420     n% = 0
430     J% = ?(q%+n%)
440     J% = J% + (?(q%+n%+1)*256)
450     w% = ?(q%+n%+2)
460     h% = ?(q%+n%+3)
470     K% = ?(q%+n%+4)
480     L% = ?(q%+n%+5)
490     n% = n% + 6
500     M% = n%
510     FOR i%=0 TO h%
520         VDU 23, 0, 160, (H%); 5,    &C5, (320*y%)+x%+(320*i%); w%+1;
530         FOR b%= 0 TO w%
540             VDU ?(q%+n%+b%)
550         NEXT
560         n% = n% + b%
570     NEXT
580     N% = x% AND 7
590     N% = N% * (K%*L%)
600     N% = N% + ((w%+1)*(h%+1))
610     N% = N% + M%
620     PRINT " "
630     PRINT "off="+STR$(N%)
640     O% = (x%/8) + (y%*40)
650     P% = p% + O%
660     Q% = q% + N%
670     FOR R% =0 TO (L%-1)
680         FOR S% =0 TO (K%-1)
690             ?P% = ?Q% AND ?P%
700             Q% = Q% + 1
710             P% = P% + 1
720         NEXT
730         P% = P% + (40-K%)
740     NEXT
750 ENDPROC
760 DEF PROCProcessLemmings
770     IF E%=e_g% GOTO 830
780     C% = C% - 1
790     IF NOT(  C%=0 ) THEN GOTO 830
800         C% = D%
810         u%(E%) = 1
820         E% = E% + 1
830     FOR i%=0 TO e_g%
840         IF u%(i%) = 0 GOTO 1130
850         x% = r%(i%)
860         y% = s%(i%)
870         W%=0
880         XY% = x% DIV 8
890         Z% =  A%(x% AND 7)
900         P% = p%+XY% + ((y%-1)*40)
910         FOR R% = 1 TO 5
920             IF (?P% AND Z%) = 0 THEN R%=10 ELSE W%=W%-1
930              P% = P% - 40
940         NEXT
950         IF NOT(  W% = 0 ) THEN GOTO 1010
960             P% = p% + XY% + (y%*40)
970             FOR R% = 0 TO 4
980                 IF (?P% AND Z%) = 0 THEN W%=W%+1 ELSE R%=10
990                 P% = P% + 40
1000             NEXT
1010         IF NOT(  W%=-5 ) THEN GOTO 1040
1020             t%(i%) = -t%(i%)
1030             IF t%(i%) = 1 THEN z%(i%)=j_l% ELSE z%(i%)=j_k%
1040         IF W%<>-5 THEN y% = y%+W%
1050         IF W%<4 THEN x% = x% + t%(i%)
1060         r%(i%) = x%
1070         s%(i%) = y%
1080         VDU 23,27,4,i%
1090         VDU 23,27,13,(x%-6);y%-10;
1100         f% = (v%(i%) + 1) AND 7
1110         v%(i%) = f%
1120         VDU 23, 27, 10, f% + z%(i%)
1130     NEXT
1140     VDU 23, 27, 15
1150 ENDPROC
1160 DEF FNGetCollision(bc%,bd%)
1170 a% = (bc% DIV 8) + (bd%*40)
1180 Z% = A%(bc% AND 7)
1190 =(?(p%+a%) AND Z%)
1200 DEF PROCInit
1210     be% = 98
1220     bf% = 49
1230     A%(0)=1
1240     A%(1)=2
1250     A%(2)=4
1260     A%(3)=8
1270     A%(4)=16
1280     A%(5)=32
1290     A%(6)=64
1300     A%(7)=128
1310     FOR i%=0 TO e_g%
1320         r%(i%) = be%
1330         s%(i%) = bf%
1340         t%(i%) = 1
1350         u%(i%) = 0
1360         v%(i%) = 0
1370         z%(i%) = j_l%
1380     NEXT
1390     PRINT "Loading Collision"
1400     OSCLI("LOAD data\coll.dat " + STR$(B%+p%) )
1410     PRINT "Loading Masks"
1420     OSCLI("LOAD data\masks.spr " + STR$(B%+q%))
1430     PROCLoadGraphics
1440 ENDPROC
1450 DEF PROCLoadGraphics
1460     VDU 23,1,0
1470     PRINT "Loading Sprites"
1480     bg_bh%=0
1490     FOR i%=0 TO 23
1500         f$ = "data\lem"+STR$(i%)+".spr"
1510         PROCLoadBitmap(f$,bg_bh%,16,10)
1520         bg_bh% = bg_bh% + 1
1530     NEXT
1540     PRINT "Loading Background"
1550     PROCLoadLargeBitmap("data\background.spr",bg_bh%,320,192)
1560     H% = bg_bh%
1570     VDU 23, 27, 32, H%;
1580     VDU 23, 27, 3, 0; 0;
1590     bg_bh% = bg_bh% + 1
1600     FOR i%=0 TO e_g%
1610         VDU 23,27,4,i%
1620         VDU 23,27,5
1630         FOR b%=0 TO 23
1640             VDU 23, 27, &26, b%;
1650         NEXT
1660         VDU 23,27,11
1670     NEXT
1680     VDU 23,27,4,0
1690     VDU 23,27,13,30;30;
1700     VDU 23,27,10,1
1710     VDU 23,27,15
1720     VDU 23,27,7,e_g%
1730 ENDPROC
1740 DEF PROCLoadMasks(f$,n%)
1750     OSCLI("LOAD " + f$ + " " + STR$(B%+o%))
1760     FOR bi%=0 TO n%-1
1770         q[bi%] = ?(o%+bi%)
1780     NEXT
1790 ENDPROC
1800 DEF PROCLoadBitmap(f$,n%,w%,h%)
1810     OSCLI("LOAD " + f$ + " " + STR$(B%+o%))
1820     bj% = w%*h%
1830     VDU 23, 0 160, n%; 2;
1840     VDU 23, 0 160, n%; 0,bj%;
1850     FOR bi%=0 TO bj%-1
1860         VDU ?(o%+bi%)
1870     NEXT
1880     VDU 23, 0, 160, n%; 14
1890     VDU 23, 27, 32, n%;
1900     VDU 23, 27, 33, w%; h%; 1
1910 ENDPROC
1920 DEF PROCLoadLargeBitmap(f$,n%,w%,h%)
1930     PRINT "Load file: "+f$
1940     ba% = OPENIN f$
1950     bj% = w%*h%
1960     VDU 23, 0 160, n%; 2;
1970     bb% = 1024
1980     bc% = bj%
1990      REPEAT
2000        IF bc% < bb% THEN bb% = bc%
2010        bc% = bc% - bb%
2020        PRINT ".";       : 
2030        VDU 23, 0, 160, n%; 0, bb%;
2040        FOR i% = 1 TO bb%
2050          VDU BGET#ba%
2060        NEXT
2070      UNTIL bc% = 0
2080     CLOSE #ba%
2090     VDU 23, 0, 160, n%; 14
2100     VDU 23, 27, 32, n%;
2110     VDU 23, 27, 33, w%; h%; 1
2120 ENDPROC
