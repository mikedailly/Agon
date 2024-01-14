md C:\source\Agon\Bin\Emu\sdcard
md C:\source\Agon\Bin\Emu\sdcard\data
..\bin\Tools.exe -spr 320x192 C:\source\Agon\Lemmings\Graphics\level1_short.png C:\source\Agon\Bin\Emu\sdcard\data\background.spr
del C:\source\Agon\Bin\Emu\sdcard\data\background.spr
rename C:\source\Agon\Bin\Emu\sdcard\data\background0.spr background.spr
..\bin\Tools.exe -spr 16x16 C:\source\Agon\Lemmings\Graphics\Cursor.png C:\source\Agon\Bin\Emu\sdcard\data\cur.spr
..\bin\Tools.exe -spr 16x10 -max 24 C:\source\Agon\Lemmings\Graphics\Lemmings.png C:\source\Agon\Bin\Emu\sdcard\data\lem.spr
..\bin\Tools.exe -col C:\source\Agon\Lemmings\Graphics\collision.png C:\source\Agon\Bin\Emu\sdcard\data\coll.dat
..\bin\Tools.exe -mask C:\source\Agon\Lemmings\Graphics\masks.png C:\source\Agon\Bin\Emu\sdcard\data\masks.spr
