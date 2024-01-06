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
360         IF s%(i%) = 0 GOTO 650
370         x% = p%(i%)
380         y% = q%(i%)
390         J%=0
400         KL% = x% DIV 8
410         M% =  v%(x% AND 7)
420         FOR N% = 1 TO 5
430             a% = KL% + ((y%-N%)*40)
440             O% = (?(o%+a%) AND M%)
450             IF O% = 0 THEN N%=10 ELSE J%=J%-1
460         NEXT
470         IF NOT(  J% = 0 ) THEN GOTO 530
480             FOR N% = 0 TO 4
490                 a% = KL% + ((y%+N%)*40)
500                 O% = (?(o%+a%) AND M%)
510                 IF O% = 0 THEN J%=J%+1 ELSE N%=10
520             NEXT
530         IF NOT(  J%=-5 ) THEN GOTO 560
540             r%(i%) = -r%(i%)
550             IF r%(i%) = 1 THEN u%(i%)=j_l% ELSE u%(i%)=j_k%
560         IF J%<>-5 THEN y% = y%+J%
570         IF J%<4 THEN x% = x% + r%(i%)
580         p%(i%) = x%
590         q%(i%) = y%
600         VDU 23,27,4,i%
610         VDU 23,27,13,(x%-6);y%-10;
620         f% = (t%(i%) + 1) AND 7
630         t%(i%) = f%
640         VDU 23, 27, 10, f% + u%(i%)
650     NEXT
660     VDU 23, 27, 15
670 ENDPROC
680 DEF FNGetCollision(O%,R%)
690 a% = (O% DIV 8) + (R%*40)
700 M% = v%(O% AND 7)
710 =(?(o%+a%) AND M%)
720 DEF PROCDrawLevel
730     S_T%=24
740     FOR y%=0 TO 160 STEP 32
750         FOR x%=0 TO 288 STEP 32
760             VDU 23, 27, 32, S_T%;
770             VDU 23, 27, 3, x%; y%;
780             S_T% = S_T% + 1
790         NEXT
800     NEXT
810 ENDPROC
820 DEF PROCInit
830     U% = 98
840     V% = 49
850     v%(0)=1
860     v%(1)=2
870     v%(2)=4
880     v%(3)=8
890     v%(4)=16
900     v%(5)=32
910     v%(6)=64
920     v%(7)=128
930     FOR i%=0 TO e_g%
940         p%(i%) = U%
950         q%(i%) = V%
960         r%(i%) = 1
970         s%(i%) = 0
980         t%(i%) = 0
990         u%(i%) = j_l%
1000     NEXT
1010     PRINT "Loading Collision"
1020     OSCLI("LOAD data\coll.dat " + STR$(z%+o%) )
1030     PROCLoadGraphics
1040 ENDPROC
1050 DEF PROCLoadGraphics
1060     VDU 23,1,0
1070     W_X%=0
1080     FOR i%=0 TO 23
1090         f$ = "data\lem"+STR$(i%)+".spr"
1100         PROCLoadBitmap(f$,W_X%,16,10)
1110         W_X% = W_X% + 1
1120     NEXT
1130     IF NOT(  c_d% =0 ) THEN GOTO 1210
1140          FOR i%=0 TO 59
1150              f$ = "data\back"+STR$(i%)+".spr"
1160              PRINT "Name: "+f$
1170              PROCLoadBitmap(f$,W_X%,32,32)
1180              W_X% = W_X% + 1
1190          NEXT
1200          CLS
1210     IF NOT(  c_d% = 1 ) THEN GOTO 1340
1220         CLS
1230         i%=0
1240         FOR y%=0 TO 160 STEP 32
1250             FOR x%=0 TO 288 STEP 32
1260                 f$ = "data\back"+STR$(i%)+".spr"
1270                 PROCLoadBitmap(f$,W_X%,32,32)
1280                 VDU 23, 27, 32, W_X%;
1290                 VDU 23, 27, 3, x%; y%;
1300                 W_X% = W_X% + 1
1310                 i% = i% + 1
1320             NEXT
1330         NEXT
1340     FOR i%=0 TO e_g%
1350         VDU 23,27,4,i%
1360         VDU 23,27,5
1370         FOR b%=0 TO 23
1380             VDU 23, 27, &26, b%;
1390         NEXT
1400         VDU 23,27,11
1410     NEXT
1420     VDU 23,27,4,0
1430     VDU 23,27,13,30;30;
1440     VDU 23,27,10,1
1450     VDU 23,27,15
1460     VDU 23,27,7,e_g%
1470 ENDPROC
1480 DEF PROCLoadBitmap(f$,n%,w%,h%)
1490     OSCLI("LOAD " + f$ + " " + STR$(z%+m%))
1500     ba% = w%*h%
1510     VDU 23, 0 160, n%; 2;
1520     VDU 23, 0 160, n%; 0,ba%;
1530     FOR E%=0 TO ba%-1
1540         VDU ?(m%+E%)
1550     NEXT
1560     VDU 23, 0, 160, n%; 14
1570     VDU 23, 27, 32, n%;
1580     VDU 23, 27, 33, w%; h%; 1
1590 ENDPROC
