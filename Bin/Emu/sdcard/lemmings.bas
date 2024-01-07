10 VDU 22,8
20 CLS
30 c_d% = 1
40 e_g%=20
50 j_k%=8    :    
60 j_l%=0    :    
70 DIM m% 6400
80 DIM o% 6400
90 DIM p%(20)
100 DIM q%(20)
110 DIM r%(20)
120 DIM s%(20)
130 DIM t%(20)
140 DIM u%(20)
150 DIM v%(8)
160 z%=&40000
170 A%=20
180 B%=20
190 C%=0
200 PROCInit
210     IF c_d%=0 THEN PROCDrawLevel
220     PROCProcessLemmings
230     GOTO 210
240 END
250 x% = p%(E%)
260 y% = q%(E%)
270 F% = t%(E%)
280 DEF PROCProcessLemmings
290     IF C%=e_g% GOTO 350
300     A% = A% - 1
310     IF NOT(  A%=0 ) THEN GOTO 350
320         A% = B%
330         s%(C%) = 1
340         C% = C% + 1
350     FOR i%=0 TO e_g%
360         IF s%(i%) = 0 GOTO 630
370         x% = p%(i%)
380         y% = q%(i%)
390         J%=0
400         KL% = x% DIV 8
410         M% =  v%(x% AND 7)
420         FOR N% = 1 TO 5
430             a% = KL% + ((y%-N%)*40)
440             IF (?(o%+a%) AND M%)  = 0 THEN N%=10 ELSE J%=J%-1
450         NEXT
460         IF NOT(  J% = 0 ) THEN GOTO 510
470             FOR N% = 0 TO 4
480                 a% = KL% + ((y%+N%)*40)
490                 IF (?(o%+a%) AND M%)  = 0 THEN J%=J%+1 ELSE N%=10
500             NEXT
510         IF NOT(  J%=-5 ) THEN GOTO 540
520             r%(i%) = -r%(i%)
530             IF r%(i%) = 1 THEN u%(i%)=j_l% ELSE u%(i%)=j_k%
540         IF J%<>-5 THEN y% = y%+J%
550         IF J%<4 THEN x% = x% + r%(i%)
560         p%(i%) = x%
570         q%(i%) = y%
580         VDU 23,27,4,i%
590         VDU 23,27,13,(x%-6);y%-10;
600         f% = (t%(i%) + 1) AND 7
610         t%(i%) = f%
620         VDU 23, 27, 10, f% + u%(i%)
630     NEXT
640     VDU 23, 27, 15
650 ENDPROC
660 DEF FNGetCollision(Q%,R%)
670 a% = (Q% DIV 8) + (R%*40)
680 M% = v%(Q% AND 7)
690 =(?(o%+a%) AND M%)
700 DEF PROCDrawLevel
710     S_T%=24
720     FOR y%=0 TO 160 STEP 32
730         FOR x%=0 TO 288 STEP 32
740             VDU 23, 27, 32, S_T%;
750             VDU 23, 27, 3, x%; y%;
760             S_T% = S_T% + 1
770         NEXT
780     NEXT
790 ENDPROC
800 DEF PROCInit
810     U% = 98
820     V% = 49
830     v%(0)=1
840     v%(1)=2
850     v%(2)=4
860     v%(3)=8
870     v%(4)=16
880     v%(5)=32
890     v%(6)=64
900     v%(7)=128
910     FOR i%=0 TO e_g%
920         p%(i%) = U%
930         q%(i%) = V%
940         r%(i%) = 1
950         s%(i%) = 0
960         t%(i%) = 0
970         u%(i%) = j_l%
980     NEXT
990     PRINT "Loading Collision"
1000     OSCLI("LOAD data\coll.dat " + STR$(z%+o%) )
1010     PROCLoadGraphics
1020 ENDPROC
1030 DEF PROCLoadGraphics
1040     VDU 23,1,0
1050     W_X%=0
1060     FOR i%=0 TO 23
1070         f$ = "data\lem"+STR$(i%)+".spr"
1080         PROCLoadBitmap(f$,W_X%,16,10)
1090         W_X% = W_X% + 1
1100     NEXT
1110     IF NOT(  c_d% =0 ) THEN GOTO 1190
1120          FOR i%=0 TO 59
1130              f$ = "data\back"+STR$(i%)+".spr"
1140              PRINT "Name: "+f$
1150              PROCLoadBitmap(f$,W_X%,32,32)
1160              W_X% = W_X% + 1
1170          NEXT
1180          CLS
1190     IF NOT(  c_d% = 1 ) THEN GOTO 1320
1200         CLS
1210         i%=0
1220         FOR y%=0 TO 160 STEP 32
1230             FOR x%=0 TO 288 STEP 32
1240                 f$ = "data\back"+STR$(i%)+".spr"
1250                 PROCLoadBitmap(f$,W_X%,32,32)
1260                 VDU 23, 27, 32, W_X%;
1270                 VDU 23, 27, 3, x%; y%;
1280                 W_X% = W_X% + 1
1290                 i% = i% + 1
1300             NEXT
1310         NEXT
1320     FOR i%=0 TO e_g%
1330         VDU 23,27,4,i%
1340         VDU 23,27,5
1350         FOR b%=0 TO 23
1360             VDU 23, 27, &26, b%;
1370         NEXT
1380         VDU 23,27,11
1390     NEXT
1400     VDU 23,27,4,0
1410     VDU 23,27,13,30;30;
1420     VDU 23,27,10,1
1430     VDU 23,27,15
1440     VDU 23,27,7,e_g%
1450 ENDPROC
1460 DEF PROCLoadBitmap(f$,n%,w%,h%)
1470     OSCLI("LOAD " + f$ + " " + STR$(z%+m%))
1480     ba% = w%*h%
1490     VDU 23, 0 160, n%; 2;
1500     VDU 23, 0 160, n%; 0,ba%;
1510     FOR E%=0 TO ba%-1
1520         VDU ?(m%+E%)
1530     NEXT
1540     VDU 23, 0, 160, n%; 14
1550     VDU 23, 27, 32, n%;
1560     VDU 23, 27, 33, w%; h%; 1
1570 ENDPROC
