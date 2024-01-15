10 VDU 22,8
20 CLS
30 c_d% = 2
40 e_g=370    :    
50 j_k%=20
60 l_m%=8    :    
70 l_o%=0    :    
80 p% = 128        :    
90 DIM q% 6400
100 DIM r% 6400
110 DIM s% 6400
120 DIM t%(20)
130 DIM u%(20)
140 DIM v%(20)
150 DIM z%(20)
160 DIM A%(20)
170 DIM B%(20)
180 DIM C%(8)
190 D%=&40000
200 E%=17
210 F%=17
220 G%=0
230 PROCInit
240 H_I%=100
250     VDU 23, 27, 32, J%;
260     VDU 23, 27, 3, 0; 0;
270     PROCProcessLemmings
280     H_I% = H_I%-1
290     IF(H_I% = 0) THEN PROCClearBombShape(200,64,0)
300     GOTO 250
310 END
320 x%=0
330 DEF PROCDrawInToBackground(x%,y%)
340     FOR i%=0 TO 15
350         VDU 23, 0, 160, (J%); 5,    &C2, (320*y%)+x%+(320*i%); 16;
360         FOR b%= 0 TO 15
370             VDU 255
380         NEXT
390     NEXT
400     PROCDrawLevel
410 ENDPROC
420 DEF PROCClearBombShape(x%,y%,n%)
430     n% = 0
440     w% = ?(s%+n%)
450     n% = n% + 1
460     h% = ?(s%+n%)
470     n% = n% + 1
480     FOR i%=0 TO h%
490         VDU 23, 0, 160, (J%); 5,    &C5, (320*y%)+x%+(320*i%); w%+1;
500         FOR b%= 0 TO w%
510             VDU ?(s%+n%+b%)
520         NEXT
530         n% = n% + b%
540     NEXT
550 ENDPROC
560 DEF PROCProcessLemmings
570     IF G%=j_k% GOTO 630
580     E% = E% - 1
590     IF NOT(  E%=0 ) THEN GOTO 630
600         E% = F%
610         z%(G%) = 1
620         G% = G% + 1
630     FOR i%=0 TO j_k%
640         IF z%(i%) = 0 GOTO 920
650         x% = t%(i%)
660         y% = u%(i%)
670         O%=0
680         PQ% = x% DIV 8
690         R% =  C%(x% AND 7)
700         FOR S% = 1 TO 5
710             a% = PQ% + ((y%-S%)*40)
720             IF (?(r%+a%) AND R%)  = 0 THEN S%=10 ELSE O%=O%-1
730         NEXT
740         IF NOT(  O% = 0 ) THEN GOTO 790
750             FOR S% = 0 TO 4
760                 a% = PQ% + ((y%+S%)*40)
770                 IF (?(r%+a%) AND R%)  = 0 THEN O%=O%+1 ELSE S%=10
780             NEXT
790         IF NOT(  O%=-5 ) THEN GOTO 820
800             v%(i%) = -v%(i%)
810             IF v%(i%) = 1 THEN B%(i%)=l_o% ELSE B%(i%)=l_m%
820         IF O%<>-5 THEN y% = y%+O%
830         IF O%<4 THEN x% = x% + v%(i%)
840         t%(i%) = x%
850         u%(i%) = y%
860         VDU 23,27,4,i%
870         VDU 23,27,13,(x%-6);y%-10;
880         f% = (A%(i%) + 1) AND 7
890         A%(i%) = f%
900         VDU 23,27,4,i%
910         VDU 23, 27, 10, f% + B%(i%)
920     NEXT
930     VDU 23, 27, 15
940     VDU 5
950     MOVE 0,400
960 ENDPROC
970 DEF FNGetCollision(V%,W%)
980 a% = (V% DIV 8) + (W%*40)
990 R% = C%(V% AND 7)
1000 =(?(r%+a%) AND R%)
1010 DEF PROCDrawLevel
1020     IF NOT(  c_d% = 2 ) THEN GOTO 1050
1030             VDU 23, 27, 32, J%;
1040             VDU 23, 27, 3, 0; 0;
1050     IF NOT(  c_d% <> 2 ) THEN GOTO 1140
1060         Z_ba%=24
1070         FOR y%=0 TO 160 STEP 32
1080             FOR x%=0 TO 288 STEP 32
1090                 VDU 23, 27, 32, Z_ba%;
1100                 VDU 23, 27, 3, x%; y%;
1110                 Z_ba% = Z_ba% + 1
1120             NEXT
1130         NEXT
1140 ENDPROC
1150 DEF PROCInit
1160     bb% = 98
1170     bc% = 49
1180     C%(0)=1
1190     C%(1)=2
1200     C%(2)=4
1210     C%(3)=8
1220     C%(4)=16
1230     C%(5)=32
1240     C%(6)=64
1250     C%(7)=128
1260     FOR i%=0 TO j_k%
1270         t%(i%) = bb%
1280         u%(i%) = bc%
1290         v%(i%) = 1
1300         z%(i%) = 0
1310         A%(i%) = 0
1320         B%(i%) = l_o%
1330     NEXT
1340     PRINT "Loading Collision"
1350     OSCLI("LOAD data\coll.dat " + STR$(D%+r%) )
1360     PRINT "Loading Masks"
1370     OSCLI("LOAD data\masks.spr " + STR$(D%+s%))
1380     PROCLoadGraphics
1390 ENDPROC
1400 DEF PROCLoadGraphics
1410     VDU 23,1,0
1420     PRINT "Loading Sprites"
1430     bd_be%=0
1440     FOR i%=0 TO 23
1450         f$ = "data\lem"+STR$(i%)+".spr"
1460         PROCLoadBitmap(f$,bd_be%,16,10)
1470         bd_be% = bd_be% + 1
1480     NEXT
1490     PRINT "Loading Background"
1500     IF NOT(  c_d% =0 ) THEN GOTO 1580
1510          FOR i%=0 TO 59
1520              f$ = "data\back"+STR$(i%)+".spr"
1530              PRINT "Name: "+f$
1540              PROCLoadBitmap(f$,bd_be%,32,32)
1550              bd_be% = bd_be% + 1
1560          NEXT
1570          CLS
1580     IF NOT(  c_d% = 1 ) THEN GOTO 1720
1590         CLS
1600         i%=0
1610         J% = bd_be%
1620         FOR y%=0 TO 160 STEP 32
1630             FOR x%=0 TO 288 STEP 32
1640                 f$ = "data\back"+STR$(i%)+".spr"
1650                 PROCLoadBitmap(f$,bd_be%,32,32)
1660                 VDU 23, 27, 32, bd_be%;
1670                 VDU 23, 27, 3, x%; y%;
1680                 bd_be% = bd_be% + 1
1690                 i% = i% + 1
1700             NEXT
1710         NEXT
1720     IF NOT(  c_d% =2 ) THEN GOTO 1780
1730         PROCLoadLargeBitmap("data\background.spr",bd_be%,320,192)
1740         J% = bd_be%
1750         VDU 23, 27, 32, J%;
1760         VDU 23, 27, 3, 0; 0;
1770         bd_be% = bd_be% + 1
1780     FOR i%=0 TO j_k%
1790         VDU 23,27,4,i%
1800         VDU 23,27,5
1810         FOR b%=0 TO 23
1820             VDU 23, 27, &26, b%;
1830         NEXT
1840         VDU 23,27,11
1850     NEXT
1860     VDU 23,27,4,0
1870     VDU 23,27,13,30;30;
1880     VDU 23,27,10,1
1890     VDU 23,27,15
1900     VDU 23,27,7,j_k%
1910 ENDPROC
1920 DEF PROCLoadMasks(f$,n%)
1930     OSCLI("LOAD " + f$ + " " + STR$(D%+q%))
1940     FOR bi%=0 TO n%-1
1950         s[bi%] = ?(q%+bi%)
1960     NEXT
1970 ENDPROC
1980 DEF PROCLoadBitmap(f$,n%,w%,h%)
1990     OSCLI("LOAD " + f$ + " " + STR$(D%+q%))
2000     bj% = w%*h%
2010     VDU 23, 0 160, n%; 2;
2020     VDU 23, 0 160, n%; 0,bj%;
2030     FOR bi%=0 TO bj%-1
2040         VDU ?(q%+bi%)
2050     NEXT
2060     VDU 23, 0, 160, n%; 14
2070     VDU 23, 27, 32, n%;
2080     VDU 23, 27, 33, w%; h%; 1
2090 ENDPROC
2100 DEF PROCLoadLargeBitmap(f$,n%,w%,h%)
2110     PRINT "Load file: "+f$
2120     ba% = OPENIN f$
2130     bj% = w%*h%
2140     VDU 23, 0 160, n%; 2;
2150     I%=0
2160     bb% = 1024
2170     bc% = bj%
2180      REPEAT
2190        IF bc% < bb% THEN bb% = bc%
2200        bc% = bc% - bb%
2210        PRINT ".";       : 
2220        VDU 23, 0, 160, n%; 0, bb%;
2230        FOR i% = 1 TO bb%
2240          VDU BGET#ba%
2250        NEXT
2260      UNTIL bc% = 0
2270     CLOSE #ba%
2280     VDU 23, 0, 160, n%; 14
2290     VDU 23, 27, 32, n%;
2300     VDU 23, 27, 33, w%; h%; 1
2310 ENDPROC
