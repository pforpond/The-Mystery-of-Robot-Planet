REM THE MYSTERY OF ROBOT PLANET
REM Powered by VaME 2.0
REM Danni Pond

RANDOMIZE TIMER

REM icon
$EXEICON:'data\icon.ico'
_ICON

setup:
REM error handling
ON ERROR GOTO setuperror
REM Pad Layer
REM Custom types
LET booting = 1
TYPE DevType
    ID AS INTEGER
    Name AS STRING * 256
END TYPE
TYPE ButtonMapType
    ID AS INTEGER
    Name AS STRING * 10
END TYPE
REDIM SHARED MyDevices(0) AS DevType
DIM SHARED ChosenController
REM Initialize ButtonMap for the assignment routine
DIM SHARED ButtonMap(1 TO 8) AS ButtonMapType
LET padi = 1
ButtonMap(padi).Name = "START": padi = padi + 1
ButtonMap(padi).Name = "UP": padi = padi + 1
ButtonMap(padi).Name = "DOWN": padi = padi + 1
ButtonMap(padi).Name = "LEFT": padi = padi + 1
ButtonMap(padi).Name = "RIGHT": padi = padi + 1
ButtonMap(padi).Name = "USE": padi = padi + 1
ButtonMap(padi).Name = "INVENTORY": padi = padi + 1
ButtonMap(padi).Name = "BACK": padi = padi + 1
padskip:
REM setup begins
LET xxit = _EXIT
LET itime = TIMER: REM timer function
LET ctime = 0: REM timer function
$RESIZE:STRETCH
REM check os
IF INSTR(_OS$, "[WINDOWS]") THEN LET ros$ = "win"
IF INSTR(_OS$, "[LINUX]") THEN LET ros$ = "lnx"
IF INSTR(_OS$, "[MACOSX]") THEN LET ros$ = "mac"
REM data location values
LET dloc$ = "data\": REM data folder
LET aloc$ = "data\a\": REM audio folder
LET cloc$ = "data\c\": REM character sprite folder
LET csloc$ = "data\cs\": REM cutscene data folder
LET iloc$ = "data\i\": REM inventory data folder
LET mloc$ = "data\m\": REM map data folder
LET oloc$ = "data\o\": REM object metadata folder
LET ploc$ = "data\p\": REM part data folder
LET sloc$ = "data\s\": REM character talk sprite folder
LET tloc$ = "data\t\": REM terminal data folder
LET wloc$ = "data\w\": REM warp data folder
REM Engine Variables
OPEN dloc$ + "data.ddf" FOR INPUT AS #1
INPUT #1, hertz, pace, resx, resy, refresh, foot, footpace, direction, stillfoot, sps, spsloop, title$
CLOSE #1
REM save data
OPEN dloc$ + "savedata.ddf" FOR INPUT AS #3
INPUT #3, mapno, bgx, bgy, direction, credits, pocketnos, musicon, screenmode, gamepad, charmodel$
CLOSE #3
REM bloat.fuu
OPEN dloc$ + "bloat.fuu" FOR INPUT AS #4
INPUT #4, introfuu
CLOSE #4
IF introfuu = 1 THEN
    OPEN dloc$ + "bloat.fuu" FOR OUTPUT AS #5
    PRINT #5, 0
    CLOSE #5
END IF
IF screenmode = 2 THEN _FULLSCREEN _OFF
IF screenmode = 1 THEN _FULLSCREEN _SQUAREPIXELS
_TITLE title$
REM load font
LET f& = _LOADFONT(dloc$ + "v.ttf", 10)
REM window settings
SCREEN _NEWIMAGE(resx, resy, 32)
_MOUSEHIDE
REM enable font + colour
COLOR &HFFFCFCFC, 0
_FONT f&
REM into + main menu
LET cmapno = mapno
LET mapno = 0
IF gamepad = 1 THEN GOSUB padsetup
IF introfuu = 0 THEN LET partname$ = "intro": GOSUB partdisplay
COLOR &HFFFCFCFC
LET booting = 0
GOSUB terminal
LET mapno = cmapno
IF mapno = 0 THEN LET mapno = 1: LET bgx = 1: LET bgy = 1
IF charmodel$ = "none" THEN
    GOSUB choosegender
    IF gamepad = 0 THEN GOSUB tutorial: REM character select + tutorial!!!
    LET partname$ = "part1": GOSUB partdisplay
END IF
REM character images
GOSUB charload
REM maps
GOSUB mapload
REM game engine
LET gameon = 0
GOTO game

setuperror:
SCREEN 0
_TITLE "Error!"
CLS
PRINT "Metadata Error!"
PRINT: PRINT "Data folder incomplete. Please reinstall."
PRINT
PRINT "Error Code: "; ERR; " on Line: "; _ERRORLINE
END

choosegender:
REM character select
LET male$ = "ivan"
LET female$ = "eliza"
LET gloop = 1
LET malea = _LOADIMAGE(sloc$ + male$ + "1.png")
LET maleb = _LOADIMAGE(sloc$ + male$ + "2.png")
LET femalea = _LOADIMAGE(sloc$ + female$ + "1.png")
LET femaleb = _LOADIMAGE(sloc$ + female$ + "2.png")
LET arrowr = _LOADIMAGE(iloc$ + "arrowr.png")
LET arrowl = _LOADIMAGE(iloc$ + "arrowl.png")
charrebound:
CLS
LOCATE 1, 25: PRINT "choose your gender"
LET ggloop = 1
IF gamepad = 0 THEN
    DO
        IF gloop = 1 THEN
            IF ggloop = 1 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), malea
            IF ggloop = 2 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), maleb
            _PUTIMAGE ((resx / 2) + (35 / 2), (resy / 2) - (15 / 2)), arrowr
            LOCATE 2, 55: PRINT "be male"
        END IF
        IF gloop = 2 THEN
            IF ggloop = 1 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), femalea
            IF ggloop = 2 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), femaleb
            _PUTIMAGE ((resx / 2) - 35, (resy / 2) - (15 / 2)), arrowl
            LOCATE 2, 50: PRINT "be female"
        END IF
        IF TIMER MOD 2 THEN
            LET ggloop = 2
        ELSE
            LET ggloop = 1
        END IF
        LET i$ = UCASE$(INKEY$): REM user input
        IF i$ = CHR$(0) + CHR$(77) THEN LET gloop = 2: GOTO charrebound
        IF i$ = CHR$(0) + CHR$(75) THEN LET gloop = 1: GOTO charrebound
        IF i$ = " " THEN
            IF gloop = 1 THEN LET charmodel$ = male$
            IF gloop = 2 THEN LET charmodel$ = female$
            GOTO charselectend
        END IF
    LOOP
END IF
IF gamepad = 1 THEN
    DO
        IF gloop = 1 THEN
            IF ggloop = 1 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), malea
            IF ggloop = 2 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), maleb
            _PUTIMAGE ((resx / 2) + (35 / 2), (resy / 2) - (15 / 2)), arrowr
            LOCATE 2, 55: PRINT "be male"
        END IF
        IF gloop = 2 THEN
            IF ggloop = 1 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), femalea
            IF ggloop = 2 THEN _PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2)), femaleb
            _PUTIMAGE ((resx / 2) - 35, (resy / 2) - (15 / 2)), arrowl
            LOCATE 2, 50: PRINT "be female"
        END IF
        IF TIMER MOD 2 THEN
            LET ggloop = 2
        ELSE
            LET ggloop = 1
        END IF
        IF GetButton("RIGHT", 0) THEN LET gloop = 2: DO: LOOP UNTIL GetButton("RIGHT", 0) = GetButton.NotFound: GOTO charrebound
        IF GetButton("LEFT", 0) THEN LET gloop = 1: DO: LOOP UNTIL GetButton("LEFT", 0) = GetButton.NotFound: GOTO charrebound
        IF GetButton("USE", 0) THEN
            IF gloop = 1 THEN LET charmodel$ = male$
            IF gloop = 2 THEN LET charmodel$ = female$
            DO: LOOP UNTIL GetButton("USE", 0) = GetButton.NotFound:
            GOTO charselectend
        END IF
    LOOP
END IF
charselectend:
GOSUB keycatcher
_FREEIMAGE malea: _FREEIMAGE maleb:
_FREEIMAGE femalea: _FREEIMAGE femaleb
_FREEIMAGE arrowr: _FREEIMAGE arrowl
IF charmodel$ = male$ THEN
    IF ros$ = "win" THEN SHELL _HIDE "copy data\i\g\i\*.* data\i\ /y"
    IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "cp data/i/g/i/*.* data/i/"
END IF
IF charmodel$ = female$ THEN
    IF ros$ = "win" THEN SHELL _HIDE "copy data\i\g\e\*.* data\i\ /y"
    IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "cp data/i/g/e/*.* data/i/"
END IF
RETURN

tutorial:
REM Tutorial Sub
LET tutorial1 = _LOADIMAGE(tloc$ + "tutorial1.png")
LET tutorial2 = _LOADIMAGE(tloc$ + "tutorial2.png")
_DISPLAY
FOR i% = 255 TO 0 STEP -5
    _LIMIT 50
    _PUTIMAGE (-1, -1)-(160, 144), tutorial1
    LINE (-1, -1)-(160, 144), _RGBA(0, 0, 0, i%), BF
    _DISPLAY
NEXT
REM Keystroke Buffer Spam
GOSUB keycatcher
DO: LOOP WHILE INKEY$ = ""
FOR i% = 0 TO 255 STEP 5
    _LIMIT 50
    _PUTIMAGE (-1, -1)-(160, 144), tutorial1
    LINE (-1, -1)-(160, 144), _RGBA(0, 0, 0, i%), BF
    _DISPLAY
NEXT
FOR i% = 255 TO 0 STEP -5
    _LIMIT 50
    _PUTIMAGE (-1, -1)-(160, 144), tutorial2
    LINE (-1, -1)-(160, 144), _RGBA(0, 0, 0, i%), BF
    _DISPLAY
NEXT
REM Keystroke Buffer Spam
GOSUB keycatcher
DO: LOOP WHILE INKEY$ = ""
FOR i% = 0 TO 255 STEP 5
    _LIMIT 50
    _PUTIMAGE (-1, -1)-(160, 144), tutorial2
    LINE (-1, -1)-(160, 144), _RGBA(0, 0, 0, i%), BF
    _DISPLAY
NEXT
_AUTODISPLAY
CLS
_FREEIMAGE tutorial1: _FREEIMAGE tutorial2
RETURN

charload:
REM load character images
LET pf = _LOADIMAGE(cloc$ + charmodel$ + "-f.png")
LET pfr = _LOADIMAGE(cloc$ + charmodel$ + "-fr.png")
LET pfl = _LOADIMAGE(cloc$ + charmodel$ + "-fl.png")
LET pr = _LOADIMAGE(cloc$ + charmodel$ + "-r.png")
LET prr = _LOADIMAGE(cloc$ + charmodel$ + "-rr.png")
LET prl = _LOADIMAGE(cloc$ + charmodel$ + "-rl.png")
LET pl = _LOADIMAGE(cloc$ + charmodel$ + "-l.png")
LET pll = _LOADIMAGE(cloc$ + charmodel$ + "-ll.png")
LET plr = _LOADIMAGE(cloc$ + charmodel$ + "-lr.png")
LET pb = _LOADIMAGE(cloc$ + charmodel$ + "-b.png")
LET pbr = _LOADIMAGE(cloc$ + charmodel$ + "-br.png")
LET pbl = _LOADIMAGE(cloc$ + charmodel$ + "-bl.png")
RETURN

toggle:
REM toggles window and fullscreen
REM fullscreen to window
IF screenmode = 1 THEN
    _FULLSCREEN _OFF
    LET screenmode = 2
    _TITLE title$
    IF cn1$ = "WINDOW" THEN LET cn1$ = "FULLSCREEN"
    IF cn2$ = "WINDOW" THEN LET cn2$ = "FULLSCREEN"
    IF cn3$ = "WINDOW" THEN LET cn3$ = "FULLSCREEN"
    IF cn4$ = "WINDOW" THEN LET cn4$ = "FULLSCREEN"
    IF cn5$ = "WINDOW" THEN LET cn5$ = "FULLSCREEN"
    RETURN
END IF
REM window to fullscreen
IF screenmode = 2 THEN
    _FULLSCREEN _SQUAREPIXELS
    LET screenmode = 1
    _TITLE title$
    IF cn1$ = "FULLSCREEN" THEN LET cn1$ = "WINDOW"
    IF cn2$ = "FULLSCREEN" THEN LET cn2$ = "WINDOW"
    IF cn3$ = "FULLSCREEN" THEN LET cn3$ = "WINDOW"
    IF cn4$ = "FULLSCREEN" THEN LET cn4$ = "WINDOW"
    IF cn5$ = "FULLSCREEN" THEN LET cn5$ = "WINDOW"
    RETURN
END IF

musictoggle:
REM toggles menu display for music
IF musicon = 1 THEN
    REM music (displays 'music + SFX')
    IF cn1$ = "MUSIC ONLY" THEN LET cn1$ = "MUSIC + SFX"
    IF cn2$ = "MUSIC ONLY" THEN LET cn2$ = "MUSIC + SFX"
    IF cn3$ = "MUSIC ONLY" THEN LET cn3$ = "MUSIC + SFX"
    IF cn4$ = "MUSIC ONLY" THEN LET cn4$ = "MUSIC + SFX"
    IF cn5$ = "MUSIC ONLY" THEN LET cn5$ = "MUSIC + SFX"
END IF
IF musicon = 2 THEN
    REM music (displays 'sfx')
    IF cn1$ = "MUSIC + SFX" THEN LET cn1$ = "SFX ONLY"
    IF cn2$ = "MUSIC + SFX" THEN LET cn2$ = "SFX ONLY"
    IF cn3$ = "MUSIC + SFX" THEN LET cn3$ = "SFX ONLY"
    IF cn4$ = "MUSIC + SFX" THEN LET cn4$ = "SFX ONLY"
    IF cn5$ = "MUSIC + SFX" THEN LET cn5$ = "SFX ONLY"
END IF
IF musicon = 3 THEN
    REM music (displays 'mute')
    IF cn1$ = "SFX ONLY" THEN LET cn1$ = "MUTE"
    IF cn2$ = "SFX ONLY" THEN LET cn2$ = "MUTE"
    IF cn3$ = "SFX ONLY" THEN LET cn3$ = "MUTE"
    IF cn4$ = "SFX ONLY" THEN LET cn4$ = "MUTE"
    IF cn5$ = "SFX ONLY" THEN LET cn5$ = "MUTE"
END IF
IF musicon = 0 THEN
    REM music (displays 'music')
    IF cn1$ = "MUTE" THEN LET cn1$ = "MUSIC ONLY"
    IF cn2$ = "MUTE" THEN LET cn2$ = "MUSIC ONLY"
    IF cn3$ = "MUTE" THEN LET cn3$ = "MUSIC ONLY"
    IF cn4$ = "MUTE" THEN LET cn4$ = "MUSIC ONLY"
    IF cn5$ = "MUTE" THEN LET cn5$ = "MUSIC ONLY"
END IF
RETURN

mapload:
REM map chooser
LET mapc = 0
IF mapno = 1 THEN LET mapfile$ = "map1": LET mapdata$ = "item1": LET mapdir$ = "m1"
IF mapno = 2 THEN LET mapfile$ = "map2": LET mapdata$ = "item2": LET mapdir$ = "m2"
IF mapno = 3 THEN LET mapfile$ = "map3": LET mapdata$ = "item3": LET mapdir$ = "m3"
IF mapno = 4 THEN LET mapfile$ = "map4": LET mapdata$ = "item4": LET mapdir$ = "m4"
IF mapno = 5 THEN LET mapfile$ = "map5": LET mapdata$ = "item5": LET mapdir$ = "m5"
IF mapno = 6 THEN LET mapfile$ = "map6": LET mapdata$ = "item6": LET mapdir$ = "m6"
IF mapno = 7 THEN LET mapfile$ = "map7": LET mapdata$ = "item7": LET mapdir$ = "m7"
IF mapno = 8 THEN LET mapfile$ = "map8": LET mapdata$ = "item8": LET mapdir$ = "m8"
IF mapno = 9 THEN LET mapfile$ = "map9": LET mapdata$ = "item9": LET mapdir$ = "m9"
IF mapno = 10 THEN LET mapfile$ = "map10": LET mapdata$ = "item10": LET mapdir$ = "m10"
IF mapno = 11 THEN LET mapfile$ = "map11": LET mapdata$ = "item11": LET mapdir$ = "m11"
IF mapno = 12 THEN LET mapfile$ = "map12": LET mapdata$ = "item12": LET mapdir$ = "m12"
IF mapno = 13 THEN LET mapfile$ = "map13": LET mapdata$ = "item13": LET mapdir$ = "m13"
IF mapno = 14 THEN LET mapfile$ = "map14": LET mapdata$ = "item14": LET mapdir$ = "m14"
IF mapno = 15 THEN LET mapfile$ = "map15": LET mapdata$ = "item15": LET mapdir$ = "m15"
IF mapno = 16 THEN LET mapfile$ = "map16": LET mapdata$ = "item16": LET mapdir$ = "m16"
IF mapno = 17 THEN LET mapfile$ = "map17": LET mapdata$ = "item17": LET mapdir$ = "m17"
IF mapno = 18 THEN LET mapfile$ = "map18": LET mapdata$ = "item18": LET mapdir$ = "m18"
IF mapno = 19 THEN LET mapfile$ = "map19": LET mapdata$ = "item19": LET mapdir$ = "m19"
IF mapno = 20 THEN LET mapfile$ = "map20": LET mapdata$ = "item20": LET mapdir$ = "m20"
IF mapno = 21 THEN LET mapfile$ = "map21": LET mapdata$ = "item21": LET mapdir$ = "m21"
IF mapno = 22 THEN LET mapfile$ = "map22": LET mapdata$ = "item22": LET mapdir$ = "m22"
IF mapno = 23 THEN LET mapfile$ = "map23": LET mapdata$ = "item23": LET mapdir$ = "m23"
IF mapno = 24 THEN LET mapfile$ = "map24": LET mapdata$ = "item24": LET mapdir$ = "m24"
IF mapno = 25 THEN LET mapfile$ = "map25": LET mapdata$ = "item25": LET mapdir$ = "m25"
IF mapno = 26 THEN LET mapfile$ = "map26": LET mapdata$ = "item26": LET mapdir$ = "m26"
IF mapno = 27 THEN LET mapfile$ = "map27": LET mapdata$ = "item27": LET mapdir$ = "m27"
IF mapno = 28 THEN LET mapfile$ = "map28": LET mapdata$ = "item28": LET mapdir$ = "m28"
IF mapno = 29 THEN LET mapfile$ = "map29": LET mapdata$ = "item29": LET mapdir$ = "m29"
IF mapno = 30 THEN LET mapfile$ = "map30": LET mapdata$ = "item30": LET mapdir$ = "m30"
IF mapno = 31 THEN LET mapfile$ = "map31": LET mapdata$ = "item31": LET mapdir$ = "m31"
IF mapno = 32 THEN LET mapfile$ = "map32": LET mapdata$ = "item32": LET mapdir$ = "m32"
IF mapno = 33 THEN LET mapfile$ = "map33": LET mapdata$ = "item33": LET mapdir$ = "m33"
IF mapno = 34 THEN LET mapfile$ = "map34": LET mapdata$ = "item34": LET mapdir$ = "m34"
IF mapno = 35 THEN LET mapfile$ = "map35": LET mapdata$ = "item35": LET mapdir$ = "m35"
IF mapno = 36 THEN LET mapfile$ = "map36": LET mapdata$ = "item36": LET mapdir$ = "m36"
IF mapno = 37 THEN LET mapfile$ = "map37": LET mapdata$ = "item37": LET mapdir$ = "m37"
IF mapno = 38 THEN LET mapfile$ = "map38": LET mapdata$ = "item38": LET mapdir$ = "m38"
IF mapno = 39 THEN LET mapfile$ = "map39": LET mapdata$ = "item39": LET mapdir$ = "m39"
IF mapno = 40 THEN LET mapfile$ = "map40": LET mapdata$ = "item40": LET mapdir$ = "m40"
IF mapno = 41 THEN LET mapfile$ = "map41": LET mapdata$ = "item41": LET mapdir$ = "m41"
IF mapno = 42 THEN LET mapfile$ = "map42": LET mapdata$ = "item42": LET mapdir$ = "m42"
IF mapno = 43 THEN LET mapfile$ = "map43": LET mapdata$ = "item43": LET mapdir$ = "m43"
IF mapno = 44 THEN LET mapfile$ = "map44": LET mapdata$ = "item44": LET mapdir$ = "m44"
IF mapno = 45 THEN LET mapfile$ = "map45": LET mapdata$ = "item45": LET mapdir$ = "m45"
IF mapno = 46 THEN LET mapfile$ = "map46": LET mapdata$ = "item46": LET mapdir$ = "m46"
IF mapno = 47 THEN LET mapfile$ = "map47": LET mapdata$ = "item47": LET mapdir$ = "m47"
IF mapno = 48 THEN LET mapfile$ = "map48": LET mapdata$ = "item48": LET mapdir$ = "m48"
IF mapno = 49 THEN LET mapfile$ = "map49": LET mapdata$ = "item49": LET mapdir$ = "m49"
IF mapno = 50 THEN LET mapfile$ = "map50": LET mapdata$ = "item50": LET mapdir$ = "m50"
IF mapno = 51 THEN LET mapfile$ = "map51": LET mapdata$ = "item51": LET mapdir$ = "m51"
IF mapno = 52 THEN LET mapfile$ = "map52": LET mapdata$ = "item52": LET mapdir$ = "m52"
IF mapno = 53 THEN LET mapfile$ = "map53": LET mapdata$ = "item53": LET mapdir$ = "m53"
IF mapno = 54 THEN LET mapfile$ = "map54": LET mapdata$ = "item54": LET mapdir$ = "m54"
REM IF mapno = 55 THEN LET mapfile$ = "map55": LET mapdata$ = "item55": LET mapdir$ = "m55"
REM IF mapno = 56 THEN LET mapfile$ = "map56": LET mapdata$ = "item56": LET mapdir$ = "m56"
REM IF mapno = 57 THEN LET mapfile$ = "map57": LET mapdata$ = "item57": LET mapdir$ = "m57"
REM IF mapno = 58 THEN LET mapfile$ = "map58": LET mapdata$ = "item58": LET mapdir$ = "m58"
REM IF mapno = 59 THEN LET mapfile$ = "map59": LET mapdata$ = "item59": LET mapdir$ = "m59"
REM IF mapno = 60 THEN LET mapfile$ = "map60": LET mapdata$ = "item60": LET mapdir$ = "m60"
REM IF mapno = 61 THEN LET mapfile$ = "map61": LET mapdata$ = "item61": LET mapdir$ = "m61"
REM IF mapno = 62 THEN LET mapfile$ = "map62": LET mapdata$ = "item62": LET mapdir$ = "m62"
REM IF mapno = 63 THEN LET mapfile$ = "map63": LET mapdata$ = "item63": LET mapdir$ = "m63"
REM IF mapno = 64 THEN LET mapfile$ = "map64": LET mapdata$ = "item64": LET mapdir$ = "m64"
REM part chooser
IF mapno >= 1 AND mapno <= 54 THEN LET part = 1
REM pocketnos adder
IF mapno > 3 THEN LET pocketnos = 10
REM mapc
OPEN mloc$ + "c" + mapdir$ + ".ddf" FOR INPUT AS #3
INPUT #3, mapc
CLOSE #3
IF mapc = 0 THEN
    LET map = _LOADIMAGE(mloc$ + mapfile$ + ".png")
    LET mapb = _LOADIMAGE(mloc$ + mapfile$ + "b.png")
END IF
IF mapc = 1 THEN
    LET map = _LOADIMAGE(mloc$ + mapfile$ + "c.png")
    LET mapb = _LOADIMAGE(mloc$ + mapfile$ + "bc.png")
END IF
OPEN mloc$ + mapfile$ + ".ddf" FOR INPUT AS #1
INPUT #1, bgresx, bgresy, limitx1, limity1, limitx2, limity2, musicfile$
CLOSE #1
OPEN mloc$ + mapdata$ + ".ddf" FOR INPUT AS #2
INPUT #2, itemno, item1$, item1x1, item1y1, item1x2, item1y2, item2$, item2x1, item2y1, item2x2, item2y2, item3$, item3x1, item3y1, item3x2, item3y2, item4$, item4x1, item4y1, item4x2, item4y2, item5$, item5x1, item5y1, item5x2, item5y2, item6$, item6x1, item6y1, item6x2, item6y2, item7$, item7x1, item7y1, item7x2, item7y2, item8$, item8x1, item8y1, item8x2, item8y2, item9$, item9x1, item9y1, item9x2, item9y2, item10$, item10x1, item10y1, item10x2, item10y2, item11$, item11x1, item11y1, item11x2, item11y2, item12$, item12x1, item12y1, item12x2, item12y2, item13$, item13x1, item13y1, item13x2, item13y2, item14$, item14x1, item14y1, item14x2, item14y2, item15$, item15x1, item15y1, item15x2, item15y2, item16$, item16x1, item16y1, item16x2, item16y2, item17$, item17x1, item17y1, item17x2, item17y2, item18$, item18x1, item18y1, item18x2, item18y2, item19$, item19x1, item19y1, item19x2, item19y2, item20$, item20x1, item20y1, item20x2, item20y2, item21$, item21x1, item21y1, item21x2, item21y2, item22$, item22x1, item22y1, item22x2, item22y2, item23$, item23x1, item23y1, item23x2, item23y2, item24$, item24x1, item24y1, item24x2, item24y2, item25$, item25x1, item25y1, item25x2, item25y2, item26$, item26x1, item26y1, item26x2, item26y2, item27$, item27x1, item27y1, item27x2, item27y2, item28$, item28x1, item28y1, item28x2, item28y2, item29$, item29x1, item29y1, item29x2, item29y2, item30$, item30x1, item30y1, item30x2, item30y2, item31$, item31x1, item31y1, item31x2, item31y2, item32$, item32x1, item32y1, item32x2, item32y2, item33$, item33x1, item33y1, item33x2, item33y2, item34$, item34x1, item34y1, item34x2, item34y2, item35$, item35x1, item35y1, item35x2, item35y2, item36$, item36x1, item36y1, item36x2, item36y2, item37$, item37x1, item37y1, item37x2, item37y2, item38$, item38x1, item38y1, item38x2, item38y2, item39$, item39x1, item39y1, item39x2, item39y2, item40$, item40x1, item40y1, item40x2, item40y2
CLOSE #2
IF mapc = 1 THEN LET itemno = itemno - 1
GOSUB playmusic
RETURN

item:
REM items
FOR itemloop = 1 TO itemno
    IF itemloop = 1 THEN GOSUB item1
    IF itemloop = 2 THEN GOSUB item2
    IF itemloop = 3 THEN GOSUB item3
    IF itemloop = 4 THEN GOSUB item4
    IF itemloop = 5 THEN GOSUB item5
    IF itemloop = 6 THEN GOSUB item6
    IF itemloop = 7 THEN GOSUB item7
    IF itemloop = 8 THEN GOSUB item8
    IF itemloop = 9 THEN GOSUB item9
    IF itemloop = 10 THEN GOSUB item10
    IF itemloop = 11 THEN GOSUB item11
    IF itemloop = 12 THEN GOSUB item12
    IF itemloop = 13 THEN GOSUB item13
    IF itemloop = 14 THEN GOSUB item14
    IF itemloop = 15 THEN GOSUB item15
    IF itemloop = 16 THEN GOSUB item16
    IF itemloop = 17 THEN GOSUB item17
    IF itemloop = 18 THEN GOSUB item18
    IF itemloop = 19 THEN GOSUB item19
    IF itemloop = 20 THEN GOSUB item20
    IF itemloop = 21 THEN GOSUB item21
    IF itemloop = 22 THEN GOSUB item22
    IF itemloop = 23 THEN GOSUB item23
    IF itemloop = 24 THEN GOSUB item24
    IF itemloop = 25 THEN GOSUB item25
    IF itemloop = 26 THEN GOSUB item26
    IF itemloop = 27 THEN GOSUB item27
    IF itemloop = 28 THEN GOSUB item28
    IF itemloop = 29 THEN GOSUB item29
    IF itemloop = 30 THEN GOSUB item30
    IF itemloop = 31 THEN GOSUB item31
    IF itemloop = 32 THEN GOSUB item32
    IF itemloop = 33 THEN GOSUB item33
    IF itemloop = 34 THEN GOSUB item34
    IF itemloop = 35 THEN GOSUB item35
    IF itemloop = 36 THEN GOSUB item36
    IF itemloop = 37 THEN GOSUB item37
    IF itemloop = 38 THEN GOSUB item38
    IF itemloop = 39 THEN GOSUB item39
    IF itemloop = 40 THEN GOSUB item40
NEXT itemloop
RETURN

item1:
REM item1
REM object selector
IF bgx <= item1x1 AND bgx >= item1x2 THEN LET by1 = 1
IF bgy <= item1y1 AND bgy >= item1y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item1$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item1x1 AND bgx > item1x2 THEN LET by1 = 1
IF bgy < item1y1 AND bgy > item1y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item1y2
    IF direction = 2 THEN LET bgy = item1y1
    IF direction = 3 THEN LET bgx = item1x1
    IF direction = 4 THEN LET bgx = item1x2
    LET selectitem$ = item1$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item2:
REM item2
REM object selector
IF bgx <= item2x1 AND bgx >= item2x2 THEN LET by1 = 1
IF bgy <= item2y1 AND bgy >= item2y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item2$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item2x1 AND bgx > item2x2 THEN LET by1 = 1
IF bgy < item2y1 AND bgy > item2y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item2y2
    IF direction = 2 THEN LET bgy = item2y1
    IF direction = 3 THEN LET bgx = item2x1
    IF direction = 4 THEN LET bgx = item2x2
    LET selectitem$ = item2$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item3:
REM item3
REM object selector
IF bgx <= item3x1 AND bgx >= item3x2 THEN LET by1 = 1
IF bgy <= item3y1 AND bgy >= item3y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item3$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item3x1 AND bgx > item3x2 THEN LET by1 = 1
IF bgy < item3y1 AND bgy > item3y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item3y2
    IF direction = 2 THEN LET bgy = item3y1
    IF direction = 3 THEN LET bgx = item3x1
    IF direction = 4 THEN LET bgx = item3x2
    LET selectitem$ = item3$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item4:
REM item4
REM object selector
IF bgx <= item4x1 AND bgx >= item4x2 THEN LET by1 = 1
IF bgy <= item4y1 AND bgy >= item4y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item4$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item4x1 AND bgx > item4x2 THEN LET by1 = 1
IF bgy < item4y1 AND bgy > item4y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item4y2
    IF direction = 2 THEN LET bgy = item4y1
    IF direction = 3 THEN LET bgx = item4x1
    IF direction = 4 THEN LET bgx = item4x2
    LET selectitem$ = item4$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item5:
REM item5
REM object selector
IF bgx <= item5x1 AND bgx >= item5x2 THEN LET by1 = 1
IF bgy <= item5y1 AND bgy >= item5y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item5$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item5x1 AND bgx > item5x2 THEN LET by1 = 1
IF bgy < item5y1 AND bgy > item5y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item5y2
    IF direction = 2 THEN LET bgy = item5y1
    IF direction = 3 THEN LET bgx = item5x1
    IF direction = 4 THEN LET bgx = item5x2
    LET selectitem$ = item5$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item6:
REM item6
REM object selector
IF bgx <= item6x1 AND bgx >= item6x2 THEN LET by1 = 1
IF bgy <= item6y1 AND bgy >= item6y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item6$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item6x1 AND bgx > item6x2 THEN LET by1 = 1
IF bgy < item6y1 AND bgy > item6y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item6y2
    IF direction = 2 THEN LET bgy = item6y1
    IF direction = 3 THEN LET bgx = item6x1
    IF direction = 4 THEN LET bgx = item6x2
    LET selectitem$ = item6$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item7:
REM item7
REM object selector
IF bgx <= item7x1 AND bgx >= item7x2 THEN LET by1 = 1
IF bgy <= item7y1 AND bgy >= item7y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item7$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item7x1 AND bgx > item7x2 THEN LET by1 = 1
IF bgy < item7y1 AND bgy > item7y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item7y2
    IF direction = 2 THEN LET bgy = item7y1
    IF direction = 3 THEN LET bgx = item7x1
    IF direction = 4 THEN LET bgx = item7x2
    LET selectitem$ = item7$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item8:
REM item8
REM object selector
IF bgx <= item8x1 AND bgx >= item8x2 THEN LET by1 = 1
IF bgy <= item8y1 AND bgy >= item8y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item8$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item8x1 AND bgx > item8x2 THEN LET by1 = 1
IF bgy < item8y1 AND bgy > item8y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item8y2
    IF direction = 2 THEN LET bgy = item8y1
    IF direction = 3 THEN LET bgx = item8x1
    IF direction = 4 THEN LET bgx = item8x2
    LET selectitem$ = item8$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item9:
REM item9
REM object selector
IF bgx <= item9x1 AND bgx >= item9x2 THEN LET by1 = 1
IF bgy <= item9y1 AND bgy >= item9y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item9$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item9x1 AND bgx > item9x2 THEN LET by1 = 1
IF bgy < item9y1 AND bgy > item9y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item9y2
    IF direction = 2 THEN LET bgy = item9y1
    IF direction = 3 THEN LET bgx = item9x1
    IF direction = 4 THEN LET bgx = item9x2
    LET selectitem$ = item9$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item10:
REM item10
REM object selector
IF bgx <= item10x1 AND bgx >= item10x2 THEN LET by1 = 1
IF bgy <= item10y1 AND bgy >= item10y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item10$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item10x1 AND bgx > item10x2 THEN LET by1 = 1
IF bgy < item10y1 AND bgy > item10y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item10y2
    IF direction = 2 THEN LET bgy = item10y1
    IF direction = 3 THEN LET bgx = item10x1
    IF direction = 4 THEN LET bgx = item10x2
    LET selectitem$ = item10$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item11:
REM item11
REM object selector
IF bgx <= item11x1 AND bgx >= item11x2 THEN LET by1 = 1
IF bgy <= item11y1 AND bgy >= item11y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item11$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item11x1 AND bgx > item11x2 THEN LET by1 = 1
IF bgy < item11y1 AND bgy > item11y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item11y2
    IF direction = 2 THEN LET bgy = item11y1
    IF direction = 3 THEN LET bgx = item11x1
    IF direction = 4 THEN LET bgx = item11x2
    LET selectitem$ = item11$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item12:
REM item12
REM object selector
IF bgx <= item12x1 AND bgx >= item12x2 THEN LET by1 = 1
IF bgy <= item12y1 AND bgy >= item12y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item12$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item12x1 AND bgx > item12x2 THEN LET by1 = 1
IF bgy < item12y1 AND bgy > item12y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item12y2
    IF direction = 2 THEN LET bgy = item12y1
    IF direction = 3 THEN LET bgx = item12x1
    IF direction = 4 THEN LET bgx = item12x2
    LET selectitem$ = item12$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item13:
REM item13
REM object selector
IF bgx <= item13x1 AND bgx >= item13x2 THEN LET by1 = 1
IF bgy <= item13y1 AND bgy >= item13y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item13$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item13x1 AND bgx > item13x2 THEN LET by1 = 1
IF bgy < item13y1 AND bgy > item13y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item13y2
    IF direction = 2 THEN LET bgy = item13y1
    IF direction = 3 THEN LET bgx = item13x1
    IF direction = 4 THEN LET bgx = item13x2
    LET selectitem$ = item13$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item14:
REM item14
REM object selector
IF bgx <= item14x1 AND bgx >= item14x2 THEN LET by1 = 1
IF bgy <= item14y1 AND bgy >= item14y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item14$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item14x1 AND bgx > item14x2 THEN LET by1 = 1
IF bgy < item14y1 AND bgy > item14y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item14y2
    IF direction = 2 THEN LET bgy = item14y1
    IF direction = 3 THEN LET bgx = item14x1
    IF direction = 4 THEN LET bgx = item14x2
    LET selectitem$ = item14$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item15:
REM item15
REM object selector
IF bgx <= item15x1 AND bgx >= item15x2 THEN LET by1 = 1
IF bgy <= item15y1 AND bgy >= item15y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item15$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item15x1 AND bgx > item15x2 THEN LET by1 = 1
IF bgy < item15y1 AND bgy > item15y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item15y2
    IF direction = 2 THEN LET bgy = item15y1
    IF direction = 3 THEN LET bgx = item15x1
    IF direction = 4 THEN LET bgx = item15x2
    LET selectitem$ = item15$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item16:
REM item16
REM object selector
IF bgx <= item16x1 AND bgx >= item16x2 THEN LET by1 = 1
IF bgy <= item16y1 AND bgy >= item16y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item16$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item16x1 AND bgx > item16x2 THEN LET by1 = 1
IF bgy < item16y1 AND bgy > item16y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item16y2
    IF direction = 2 THEN LET bgy = item16y1
    IF direction = 3 THEN LET bgx = item16x1
    IF direction = 4 THEN LET bgx = item16x2
    LET selectitem$ = item16$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item17:
REM item17
REM object selector
IF bgx <= item17x1 AND bgx >= item17x2 THEN LET by1 = 1
IF bgy <= item17y1 AND bgy >= item17y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item17$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item17x1 AND bgx > item17x2 THEN LET by1 = 1
IF bgy < item17y1 AND bgy > item17y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item17y2
    IF direction = 2 THEN LET bgy = item17y1
    IF direction = 3 THEN LET bgx = item17x1
    IF direction = 4 THEN LET bgx = item17x2
    LET selectitem$ = item17$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item18:
REM item18
REM object selector
IF bgx <= item18x1 AND bgx >= item18x2 THEN LET by1 = 1
IF bgy <= item18y1 AND bgy >= item18y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item18$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item18x1 AND bgx > item18x2 THEN LET by1 = 1
IF bgy < item18y1 AND bgy > item18y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item18y2
    IF direction = 2 THEN LET bgy = item18y1
    IF direction = 3 THEN LET bgx = item18x1
    IF direction = 4 THEN LET bgx = item18x2
    LET selectitem$ = item18$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item19:
REM item19
REM object selector
IF bgx <= item19x1 AND bgx >= item19x2 THEN LET by1 = 1
IF bgy <= item19y1 AND bgy >= item19y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item19$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item19x1 AND bgx > item19x2 THEN LET by1 = 1
IF bgy < item19y1 AND bgy > item19y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item19y2
    IF direction = 2 THEN LET bgy = item19y1
    IF direction = 3 THEN LET bgx = item19x1
    IF direction = 4 THEN LET bgx = item19x2
    LET selectitem$ = item19$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item20:
REM item20
REM object selector
IF bgx <= item20x1 AND bgx >= item20x2 THEN LET by1 = 1
IF bgy <= item20y1 AND bgy >= item20y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item20$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item20x1 AND bgx > item20x2 THEN LET by1 = 1
IF bgy < item20y1 AND bgy > item20y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item20y2
    IF direction = 2 THEN LET bgy = item20y1
    IF direction = 3 THEN LET bgx = item20x1
    IF direction = 4 THEN LET bgx = item20x2
    LET selectitem$ = item20$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item21:
REM item21
REM object selector
IF bgx <= item21x1 AND bgx >= item21x2 THEN LET by1 = 1
IF bgy <= item21y1 AND bgy >= item21y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item21$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item21x1 AND bgx > item21x2 THEN LET by1 = 1
IF bgy < item21y1 AND bgy > item21y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item21y2
    IF direction = 2 THEN LET bgy = item21y1
    IF direction = 3 THEN LET bgx = item21x1
    IF direction = 4 THEN LET bgx = item21x2
    LET selectitem$ = item21$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item22:
REM item22
REM object selector
IF bgx <= item22x1 AND bgx >= item22x2 THEN LET by1 = 1
IF bgy <= item22y1 AND bgy >= item22y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item22$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item22x1 AND bgx > item22x2 THEN LET by1 = 1
IF bgy < item22y1 AND bgy > item22y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item22y2
    IF direction = 2 THEN LET bgy = item22y1
    IF direction = 3 THEN LET bgx = item22x1
    IF direction = 4 THEN LET bgx = item22x2
    LET selectitem$ = item22$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item23:
REM item23
REM object selector
IF bgx <= item23x1 AND bgx >= item23x2 THEN LET by1 = 1
IF bgy <= item23y1 AND bgy >= item23y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item23$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item23x1 AND bgx > item23x2 THEN LET by1 = 1
IF bgy < item23y1 AND bgy > item23y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item23y2
    IF direction = 2 THEN LET bgy = item23y1
    IF direction = 3 THEN LET bgx = item23x1
    IF direction = 4 THEN LET bgx = item23x2
    LET selectitem$ = item23$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item24:
REM item24
REM object selector
IF bgx <= item24x1 AND bgx >= item24x2 THEN LET by1 = 1
IF bgy <= item24y1 AND bgy >= item24y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item24$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item24x1 AND bgx > item24x2 THEN LET by1 = 1
IF bgy < item24y1 AND bgy > item24y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item24y2
    IF direction = 2 THEN LET bgy = item24y1
    IF direction = 3 THEN LET bgx = item24x1
    IF direction = 4 THEN LET bgx = item24x2
    LET selectitem$ = item24$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item25:
REM item25
REM object selector
IF bgx <= item25x1 AND bgx >= item25x2 THEN LET by1 = 1
IF bgy <= item25y1 AND bgy >= item25y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item25$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item25x1 AND bgx > item25x2 THEN LET by1 = 1
IF bgy < item25y1 AND bgy > item25y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item25y2
    IF direction = 2 THEN LET bgy = item25y1
    IF direction = 3 THEN LET bgx = item25x1
    IF direction = 4 THEN LET bgx = item25x2
    LET selectitem$ = item25$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item26:
REM item26
REM object selector
IF bgx <= item26x1 AND bgx >= item26x2 THEN LET by1 = 1
IF bgy <= item26y1 AND bgy >= item26y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item26$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item26x1 AND bgx > item26x2 THEN LET by1 = 1
IF bgy < item26y1 AND bgy > item26y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item26y2
    IF direction = 2 THEN LET bgy = item26y1
    IF direction = 3 THEN LET bgx = item26x1
    IF direction = 4 THEN LET bgx = item26x2
    LET selectitem$ = item26$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item27:
REM item27
REM object selector
IF bgx <= item27x1 AND bgx >= item27x2 THEN LET by1 = 1
IF bgy <= item27y1 AND bgy >= item27y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item27$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item27x1 AND bgx > item27x2 THEN LET by1 = 1
IF bgy < item27y1 AND bgy > item27y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item27y2
    IF direction = 2 THEN LET bgy = item27y1
    IF direction = 3 THEN LET bgx = item27x1
    IF direction = 4 THEN LET bgx = item27x2
    LET selectitem$ = item27$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item28:
REM item28
REM object selector
IF bgx <= item28x1 AND bgx >= item28x2 THEN LET by1 = 1
IF bgy <= item28y1 AND bgy >= item28y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item28$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item28x1 AND bgx > item28x2 THEN LET by1 = 1
IF bgy < item28y1 AND bgy > item28y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item28y2
    IF direction = 2 THEN LET bgy = item28y1
    IF direction = 3 THEN LET bgx = item28x1
    IF direction = 4 THEN LET bgx = item28x2
    LET selectitem$ = item28$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item29:
REM item29
REM object selector
IF bgx <= item29x1 AND bgx >= item29x2 THEN LET by1 = 1
IF bgy <= item29y1 AND bgy >= item29y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item29$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item29x1 AND bgx > item29x2 THEN LET by1 = 1
IF bgy < item29y1 AND bgy > item29y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item29y2
    IF direction = 2 THEN LET bgy = item29y1
    IF direction = 3 THEN LET bgx = item29x1
    IF direction = 4 THEN LET bgx = item29x2
    LET selectitem$ = item29$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item30:
REM item30
REM object selector
IF bgx <= item30x1 AND bgx >= item30x2 THEN LET by1 = 1
IF bgy <= item30y1 AND bgy >= item30y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item30$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item30x1 AND bgx > item30x2 THEN LET by1 = 1
IF bgy < item30y1 AND bgy > item30y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item30y2
    IF direction = 2 THEN LET bgy = item30y1
    IF direction = 3 THEN LET bgx = item30x1
    IF direction = 4 THEN LET bgx = item30x2
    LET selectitem$ = item30$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item31:
REM item31
REM object selector
IF bgx <= item31x1 AND bgx >= item31x2 THEN LET by1 = 1
IF bgy <= item31y1 AND bgy >= item31y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item31$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item31x1 AND bgx > item31x2 THEN LET by1 = 1
IF bgy < item31y1 AND bgy > item31y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item31y2
    IF direction = 2 THEN LET bgy = item31y1
    IF direction = 3 THEN LET bgx = item31x1
    IF direction = 4 THEN LET bgx = item31x2
    LET selectitem$ = item31$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item32:
REM item32
REM object selector
IF bgx <= item32x1 AND bgx >= item32x2 THEN LET by1 = 1
IF bgy <= item32y1 AND bgy >= item32y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item32$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item32x1 AND bgx > item32x2 THEN LET by1 = 1
IF bgy < item32y1 AND bgy > item32y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item32y2
    IF direction = 2 THEN LET bgy = item32y1
    IF direction = 3 THEN LET bgx = item32x1
    IF direction = 4 THEN LET bgx = item32x2
    LET selectitem$ = item32$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item33:
REM item33
REM object selector
IF bgx <= item33x1 AND bgx >= item33x2 THEN LET by1 = 1
IF bgy <= item33y1 AND bgy >= item33y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item33$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item33x1 AND bgx > item33x2 THEN LET by1 = 1
IF bgy < item33y1 AND bgy > item33y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item33y2
    IF direction = 2 THEN LET bgy = item33y1
    IF direction = 3 THEN LET bgx = item33x1
    IF direction = 4 THEN LET bgx = item33x2
    LET selectitem$ = item33$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item34:
REM item34
REM object selector
IF bgx <= item34x1 AND bgx >= item34x2 THEN LET by1 = 1
IF bgy <= item34y1 AND bgy >= item34y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item34$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item34x1 AND bgx > item34x2 THEN LET by1 = 1
IF bgy < item34y1 AND bgy > item34y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item34y2
    IF direction = 2 THEN LET bgy = item34y1
    IF direction = 3 THEN LET bgx = item34x1
    IF direction = 4 THEN LET bgx = item34x2
    LET selectitem$ = item34$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item35:
REM item35
REM object selector
IF bgx <= item35x1 AND bgx >= item35x2 THEN LET by1 = 1
IF bgy <= item35y1 AND bgy >= item35y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item35$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item35x1 AND bgx > item35x2 THEN LET by1 = 1
IF bgy < item35y1 AND bgy > item35y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item35y2
    IF direction = 2 THEN LET bgy = item35y1
    IF direction = 3 THEN LET bgx = item35x1
    IF direction = 4 THEN LET bgx = item35x2
    LET selectitem$ = item35$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item36:
REM item36
REM object selector
IF bgx <= item36x1 AND bgx >= item36x2 THEN LET by1 = 1
IF bgy <= item36y1 AND bgy >= item36y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item36$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item36x1 AND bgx > item36x2 THEN LET by1 = 1
IF bgy < item36y1 AND bgy > item36y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item36y2
    IF direction = 2 THEN LET bgy = item36y1
    IF direction = 3 THEN LET bgx = item36x1
    IF direction = 4 THEN LET bgx = item36x2
    LET selectitem$ = item36$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item37:
REM item37
REM object selector
IF bgx <= item37x1 AND bgx >= item37x2 THEN LET by1 = 1
IF bgy <= item37y1 AND bgy >= item37y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item37$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item37x1 AND bgx > item37x2 THEN LET by1 = 1
IF bgy < item37y1 AND bgy > item37y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item37y2
    IF direction = 2 THEN LET bgy = item37y1
    IF direction = 3 THEN LET bgx = item37x1
    IF direction = 4 THEN LET bgx = item37x2
    LET selectitem$ = item37$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item38:
REM item38
REM object selector
IF bgx <= item38x1 AND bgx >= item38x2 THEN LET by1 = 1
IF bgy <= item38y1 AND bgy >= item38y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item38$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item38x1 AND bgx > item38x2 THEN LET by1 = 1
IF bgy < item38y1 AND bgy > item38y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item38y2
    IF direction = 2 THEN LET bgy = item38y1
    IF direction = 3 THEN LET bgx = item38x1
    IF direction = 4 THEN LET bgx = item38x2
    LET selectitem$ = item38$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item39:
REM item39
REM object selector
IF bgx <= item39x1 AND bgx >= item39x2 THEN LET by1 = 1
IF bgy <= item39y1 AND bgy >= item39y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item39$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item39x1 AND bgx > item39x2 THEN LET by1 = 1
IF bgy < item39y1 AND bgy > item39y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item39y2
    IF direction = 2 THEN LET bgy = item39y1
    IF direction = 3 THEN LET bgx = item39x1
    IF direction = 4 THEN LET bgx = item39x2
    LET selectitem$ = item39$
END IF
LET by1 = 0: LET by2 = 0
RETURN

item40:
REM item40
REM object selector
IF bgx <= item40x1 AND bgx >= item40x2 THEN LET by1 = 1
IF bgy <= item40y1 AND bgy >= item40y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN LET selectitem$ = item40$
LET by1 = 0: LET by2 = 0
REM border keeper
IF bgx < item40x1 AND bgx > item40x2 THEN LET by1 = 1
IF bgy < item40y1 AND bgy > item40y2 THEN LET by2 = 1
IF by1 = 1 AND by2 = 1 THEN
    IF direction = 1 THEN LET bgy = item40y2
    IF direction = 2 THEN LET bgy = item40y1
    IF direction = 3 THEN LET bgx = item40x1
    IF direction = 4 THEN LET bgx = item40x2
    LET selectitem$ = item40$
END IF
LET by1 = 0: LET by2 = 0
RETURN

border:
REM border keeper
IF bgx > limitx1 THEN LET bgx = limitx1
IF bgx < limitx2 THEN LET bgx = limitx2
IF bgy > limity1 THEN LET bgy = limity1
IF bgy < limity2 THEN LET bgy = limity2
RETURN

inputter:
REM input manager
REM Diagonal disabler
REM arrow keys
IF _KEYDOWN(18432) AND _KEYDOWN(19712) THEN GOTO diagonalcheat
IF _KEYDOWN(18432) AND _KEYDOWN(19200) THEN GOTO diagonalcheat
IF _KEYDOWN(20480) AND _KEYDOWN(19712) THEN GOTO diagonalcheat
IF _KEYDOWN(20480) AND _KEYDOWN(19200) THEN GOTO diagonalcheat
IF _KEYDOWN(18432) AND _KEYDOWN(20480) THEN GOTO diagonalcheat
IF _KEYDOWN(19712) AND _KEYDOWN(19200) THEN GOTO diagonalcheat
REM Gamepad Diagonal Disabler
IF gamepad = 1 THEN
    IF GetButton("UP", 0) AND GetButton("LEFT", 0) THEN GOTO diagonalcheat
    IF GetButton("UP", 0) AND GetButton("RIGHT", 0) THEN GOTO diagonalcheat
    IF GetButton("DOWN", 0) AND GetButton("LEFT", 0) THEN GOTO diagonalcheat
    IF GetButton("DOWN", 0) AND GetButton("RIGHT", 0) THEN GOTO diagonalcheat
    IF GetButton("UP", 0) AND GetButton("DOWN", 0) THEN GOTO diagonalcheat
    IF GetButton("RIGHT", 0) AND GetButton("LEFT", 0) THEN GOTO diagonalcheat
END IF
REM Gamepad controls
IF gamepad = 1 THEN
    REM pad up
    IF GetButton("UP", 0) THEN
        LET cbgy = bgy
        LET bgy = bgy + pace
        LET refresh = 1
        LET direction = 1
        LET sps = 0
        LET selectitem$ = ""
    END IF
    REM pad down
    IF GetButton("DOWN", 0) THEN
        LET cbgy = bgy
        LET bgy = bgy - pace
        LET refresh = 1
        LET direction = 2
        LET sps = 0
        LET selectitem$ = ""
    END IF
    REM pad right
    IF GetButton("RIGHT", 0) THEN
        LET cbgx = bgx
        LET bgx = bgx - pace
        LET refresh = 1
        LET direction = 3
        LET sps = 0
        LET selectitem$ = ""
    END IF
    REM pad left
    IF GetButton("LEFT", 0) THEN
        LET cbgx = bgx
        LET bgx = bgx + pace
        LET refresh = 1
        LET direction = 4
        LET sps = 0
        LET selectitem$ = ""
    END IF
END IF
REM keyboard up
IF _KEYDOWN(18432) THEN
    LET cbgy = bgy
    LET bgy = bgy + pace
    LET refresh = 1
    LET direction = 1
    LET sps = 0
    LET selectitem$ = ""
END IF
REM keyboard down
IF _KEYDOWN(20480) THEN
    LET cbgy = bgy
    LET bgy = bgy - pace
    LET refresh = 1
    LET direction = 2
    LET sps = 0
    LET selectitem$ = ""
END IF
REM keyboard right
IF _KEYDOWN(19712) THEN
    LET cbgx = bgx
    LET bgx = bgx - pace
    LET refresh = 1
    LET direction = 3
    LET sps = 0
    LET selectitem$ = ""
END IF
REM keyboard left
IF _KEYDOWN(19200) THEN
    LET cbgx = bgx
    LET bgx = bgx + pace
    LET refresh = 1
    LET direction = 4
    LET sps = 0
    LET selectitem$ = ""
END IF
diagonalcheat: REM goto for if diagonal movement detected
REM Gamepads
IF gamepad = 1 THEN
    IF GetButton("START", 0) THEN
        LET pmapdir$ = mapdir$
        LET mapdir$ = "mainmenu"
        LET pmusicfile$ = musicfile$
        GOSUB terminal
        LET mapdir$ = pmapdir$
        LET musicfile$ = pmusicfile$
        GOSUB playmusic
        GOSUB redraw
    END IF
    IF GetButton("INVENTORY", 0) THEN GOSUB inventory
    IF GetButton("USE", 0) THEN
        IF selectitem$ = "WARP1" THEN GOSUB warp
        IF selectitem$ = "WARP2" THEN GOSUB warp
        IF selectitem$ = "WARP3" THEN GOSUB warp
        IF selectitem$ = "WARP4" THEN GOSUB warp
        IF selectitem$ <> "" THEN LET object$ = selectitem$: GOSUB object
    END IF
END IF
REM Keyboards
IF a$ = "" THEN LET sps = sps + 1
IF a$ = "Q" THEN
    LET pmapdir$ = mapdir$
    LET mapdir$ = "mainmenu"
    LET pmusicfile$ = musicfile$
    GOSUB terminal
    LET mapdir$ = pmapdir$
    LET musicfile$ = pmusicfile$
    GOSUB playmusic
    GOSUB redraw
END IF
IF a$ = "I" THEN GOSUB inventory
IF a$ = " " THEN
    IF selectitem$ = "WARP1" THEN GOSUB warp
    IF selectitem$ = "WARP2" THEN GOSUB warp
    IF selectitem$ = "WARP3" THEN GOSUB warp
    IF selectitem$ = "WARP4" THEN GOSUB warp
    IF selectitem$ <> "" THEN LET object$ = selectitem$: GOSUB object
END IF
REM SPECIAL ENGINE FUNCTIONS
REM IF a$ = "#" THEN GOSUB special
REM IF a$ = "Z" THEN GOSUB spacetravel
RETURN

special:
REM SPECIAL ENGINE FUNCTIONS
CLS
LET oldcharmodel$ = charmodel$
PRINT "mapno: "; mapno
PRINT "charmodel: "; charmodel$
PRINT "slow: "; slow
PRINT "noclip: "; noclip
PRINT "map c:"; mapc
PRINT: PRINT
LET oldmapc = mapc
LET oldmapno = mapno
INPUT "mapno: "; mapno
IF mapno = 0 THEN LET mapno = oldmapno
INPUT "item: "; cheatitem$
IF cheatitem$ <> "" THEN
    OPEN iloc$ + cheatitem$ + ".ddf" FOR OUTPUT AS #1
    PRINT #1, 1
    CLOSE #1
END IF
INPUT "charmodel: "; charmodel$
IF charmodel$ = "iv" THEN LET charmodel$ = "ivanarmour"
IF charmodel$ <> "" THEN GOSUB charload
IF charmodel$ = "" THEN LET charmodel$ = oldcharmodel$
INPUT "slow: "; slow
IF slow = 0 THEN LET pace = 2
IF slow = 1 THEN LET pace = 1
INPUT "noclip: "; noclip
INPUT "map c:"; mapc
CLS
IF mapno <> oldmapno THEN GOSUB mapload
IF noclip = 0 THEN
    OPEN mloc$ + mapdata$ + ".ddf" FOR INPUT AS #2
    INPUT #2, itemno, item1$, item1x1, item1y1, item1x2, item1y2, item2$, item2x1, item2y1, item2x2, item2y2, item3$, item3x1, item3y1, item3x2, item3y2, item4$, item4x1, item4y1, item4x2, item4y2, item5$, item5x1, item5y1, item5x2, item5y2, item6$, item6x1, item6y1, item6x2, item6y2, item7$, item7x1, item7y1, item7x2, item7y2, item8$, item8x1, item8y1, item8x2, item8y2, item9$, item9x1, item9y1, item9x2, item9y2, item10$, item10x1, item10y1, item10x2, item10y2, item11$, item11x1, item11y1, item11x2, item11y2, item12$, item12x1, item12y1, item12x2, item12y2, item13$, item13x1, item13y1, item13x2, item13y2, item14$, item14x1, item14y1, item14x2, item14y2, item15$, item15x1, item15y1, item15x2, item15y2, item16$, item16x1, item16y1, item16x2, item16y2, item17$, item17x1, item17y1, item17x2, item17y2, item18$, item18x1, item18y1, item18x2, item18y2, item19$, item19x1, item19y1, item19x2, item19y2, item20$, item20x1, item20y1, item20x2, item20y2, item21$, item21x1, item21y1, item21x2, item21y2, item22$, item22x1, item22y1, item22x2, item22y2, item23$, item23x1, item23y1, item23x2, item23y2, item24$, item24x1, item24y1, item24x2, item24y2, item25$, item25x1, item25y1, item25x2, item25y2, item26$, item26x1, item26y1, item26x2, item26y2, item27$, item27x1, item27y1, item27x2, item27y2, item28$, item28x1, item28y1, item28x2, item28y2, item29$, item29x1, item29y1, item29x2, item29y2, item30$, item30x1, item30y1, item30x2, item30y2, item31$, item31x1, item31y1, item31x2, item31y2, item32$, item32x1, item32y1, item32x2, item32y2, item33$, item33x1, item33y1, item33x2, item33y2, item34$, item34x1, item34y1, item34x2, item34y2, item35$, item35x1, item35y1, item35x2, item35y2, item36$, item36x1, item36y1, item36x2, item36y2, item37$, item37x1, item37y1, item37x2, item37y2, item38$, item38x1, item38y1, item38x2, item38y2, item39$, item39x1, item39y1, item39x2, item39y2, item40$, item40x1, item40y1, item40x2, item40y2
    CLOSE #2
END IF
IF mapc <> oldmapc THEN
    IF mapc > 1 THEN LET mapc = 1
    OPEN mloc$ + "c" + mapdir$ + ".ddf" FOR OUTPUT AS #3
    PRINT #3, mapc
    CLOSE #3
    GOSUB mapload
END IF
IF mapc = 1 THEN LET itemno = itemno - 1
IF noclip = 1 THEN LET itemno = 0
GOSUB redraw
RETURN

spacetravel:
REM spacetravel sub
GOSUB fadeout
CLS
LET star1x = INT(RND * resx)
LET star2x = INT(RND * resx)
LET star3x = INT(RND * resx)
LET star4x = INT(RND * resx)
LET star5x = INT(RND * resx)
LET star6x = INT(RND * resx)
LET star1y = INT(RND * resy)
LET star2y = INT(RND * resy)
LET star3y = INT(RND * resy)
LET star4y = INT(RND * resy)
LET star5y = INT(RND * resy)
LET star6y = INT(RND * resy)
REM LET posx = (resx / 2) - (160 / 2)
LET posx = 300
LET posy = (resy / 2) - (60 / 2)
LET ship1 = _LOADIMAGE(csloc$ + "ship1.png")
DO
    COLOR &HFFFCFCFC
    LINE (star1x, star1y)-(star1x, star1y)
    LINE (star2x, star2y)-(star2x, star2y)
    LINE (star3x, star3y)-(star3x, star3y)
    LINE (star4x, star4y)-(star4x, star4y)
    LINE (star5x, star5y)-(star5x, star5y)
    LINE (star6x, star6y)-(star6x, star6y)
    COLOR &HFF000000
    LINE (star1x - 1, star1y)-(star1x - 1, star1y)
    LINE (star2x - 1, star2y)-(star2x - 1, star2y)
    LINE (star3x - 1, star3y)-(star3x - 1, star3y)
    LINE (star4x - 1, star4y)-(star4x - 1, star4y)
    LINE (star5x - 1, star5y)-(star5x - 1, star5y)
    LINE (star6x - 1, star6y)-(star6x - 1, star6y)
    _PUTIMAGE (posx, posy), ship1
    LET star1x = star1x + 1
    LET star2x = star2x + 1
    LET star3x = star3x + 1
    LET star4x = star4x + 1
    LET star5x = star5x + 1
    LET star6x = star6x + 1
    LET posx = posx - 1
    IF star1x > 160 THEN LET star1x = 0: LET star1y = INT(RND * resy)
    IF star2x > 160 THEN LET star2x = 0: LET star2y = INT(RND * resy)
    IF star3x > 160 THEN LET star3x = 0: LET star3y = INT(RND * resy)
    IF star4x > 160 THEN LET star4x = 0: LET star4y = INT(RND * resy)
    IF star5x > 160 THEN LET star5x = 0: LET star5y = INT(RND * resy)
    IF star6x > 160 THEN LET star6x = 0: LET star6y = INT(RND * resy)
    _DELAY 0.01
LOOP UNTIL posx = -300
COLOR &HFFFCFCFC
_FREEIMAGE ship1
CLS
LET posx = (resx / 2) - (13 / 2)
LET posy = (resy / 2) - (16 / 2)
GOSUB fadein
RETURN


warp:
REM manages warps
LET warpon = 0: LET warpdest = 0: LET warpdx = 0: LET warpdy = 0
OPEN wloc$ + mapdir$ + ".ddf" FOR INPUT AS #1
INPUT #1, warpnos, warpon1, warpdest1, warpdx1, warpdy1, warpdd1, warpon2, warpdest2, warpdx2, warpdy2, warpdd2, warpon3, warpdest3, warpdx3, warpdy3, warpdd3, warpon4, warpdest4, warpdx4, warpdy4, warpdd4
CLOSE #1
IF selectitem$ = "WARP1" THEN
    LET warpon = warpon1
    LET warpdest = warpdest1
    LET warpdx = warpdx1
    LET warpdy = warpdy1
    LET warpdd = warpdd1
END IF
IF selectitem$ = "WARP2" THEN
    LET warpon = warpon2
    LET warpdest = warpdest2
    LET warpdx = warpdx2
    LET warpdy = warpdy2
    LET warpdd = warpdd2
END IF
IF selectitem$ = "WARP3" THEN
    LET warpon = warpon3
    LET warpdest = warpdest3
    LET warpdx = warpdx3
    LET warpdy = warpdy3
    LET warpdd = warpdd3
END IF
IF selectitem$ = "WARP4" THEN
    LET warpon = warpon4
    LET warpdest = warpdest4
    LET warpdx = warpdx4
    LET warpdy = warpdy4
    LET warpdd = warpdd4
END IF
IF warpon = 0 THEN
    LET talker$ = "YOU"
    LET talkline1$ = "This warp is"
    LET talkline2$ = "disabled."
    LET talkline3$ = ""
    LET talkline4$ = "Maybe there is"
    LET talkline5$ = "a way to"
    LET talkline6$ = "get it working."
    GOSUB talkscreen
    RETURN
END IF
IF warpon = 1 THEN
    LET mapno = warpdest
    GOSUB warpani
    GOSUB redraw
END IF
RETURN

warpani:
REM warp animation
LET adelay = 0.1
LET aniloop = 0
REM walk onto warp
DO
    IF direction = 1 THEN
        LET cbgy = bgy
        LET bgy = bgy + pace
    END IF
    IF direction = 2 THEN
        LET cbgy = bgy
        LET bgy = bgy - pace
    END IF
    IF direction = 3 THEN
        LET cbgx = bgx
        LET bgx = bgx - pace
    END IF
    IF direction = 4 THEN
        LET cbgx = bgx
        LET bgx = bgx + pace
    END IF
    GOSUB redraw
    _DELAY adelay
    LET aniloop = aniloop + 1
LOOP UNTIL aniloop >= 5
REM spin
LET direction = 1
LET aniloop = 0
DO
    GOSUB redraw
    _DELAY adelay
    LET direction = direction + 1
    IF direction > 4 THEN LET direction = 1
    LET aniloop = aniloop + 1
LOOP UNTIL aniloop >= 5
LET soundfile$ = "warpup": GOSUB audio
REM spin and up
LET adelay = 0.01
LET aniloop = 0
DO
    GOSUB redraw
    _DELAY adelay
    LET bgy = bgy + pace
    LET direction = direction + 1
    IF direction > 4 THEN LET direction = 1
    LET aniloop = aniloop + 1
    CLS
LOOP UNTIL aniloop = 10 + bgresy
REM change map
_FREEIMAGE map
_FREEIMAGE mapb
GOSUB mapload
LET bgx = warpdx: LET bgy = (warpdy + (pace * 100)) + bgresy
LET aniloop = 0
REM spin and down
DO
    GOSUB redraw
    _DELAY adelay
    LET bgy = bgy - pace
    LET direction = direction + 1
    IF direction > 4 THEN LET direction = 1
    CLS
LOOP UNTIL bgy <= warpdy
LET soundfile$ = "warpdown": GOSUB audio
REM walk off warp
LET direction = warpdd
LET adelay = 0.1
DO
    IF direction = 1 THEN
        LET cbgy = bgy
        LET bgy = bgy + pace
    END IF
    IF direction = 2 THEN
        LET cbgy = bgy
        LET bgy = bgy - pace
    END IF
    IF direction = 3 THEN
        LET cbgx = bgx
        LET bgx = bgx - pace
    END IF
    IF direction = 4 THEN
        LET cbgx = bgx
        LET bgx = bgx + pace
    END IF
    GOSUB redraw
    _DELAY adelay
    LET aniloop = aniloop + 1
LOOP UNTIL aniloop >= 5
RETURN

talkscreen:
REM talk screen
LET talkscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
CLS
_PUTIMAGE (-resx, -resy)-(resx, resy), talkscreen
IF talker$ = "" THEN LET talker$ = "you"
IF objecttype = 8 THEN LET talker$ = "you"
LET talker$ = LCASE$(talker$)
IF talker$ <> "you" THEN
    LET talkpic1 = _LOADIMAGE(sloc$ + talker$ + "1.png")
    LET talkpic2 = _LOADIMAGE(sloc$ + talker$ + "2.png")
END IF
IF talker$ = "you" THEN
    LET talkpic1 = _LOADIMAGE(sloc$ + charmodel$ + "1.png")
    LET talkpic2 = _LOADIMAGE(sloc$ + charmodel$ + "2.png")
END IF
LET tdelay = .5
LET talkloop = 1
_PUTIMAGE (resx - 35, resy - 41), talkpic1
PRINT talker$
PRINT
PRINT talkline1$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT talkline2$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT talkline3$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT talkline4$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT talkline5$
_DELAY tdelay: LET tdelay = .5
PRINT talkline6$
PRINT: PRINT
PRINT "..."
IF gamepad = 1 THEN PRINT "(press back)"
REM Keystroke Buffer Spam
IF gamepad = 1 THEN
    DO
    LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
END IF
GOSUB keycatcher
IF gamepad = 0 THEN
    REM KEYBOARD
    DO
        IF talkloop = 1 THEN _PUTIMAGE (resx - 35, resy - 41), talkpic1: LET talkloop = 2: GOTO talkloop
        IF talkloop = 2 THEN _PUTIMAGE (resx - 35, resy - 41), talkpic2: LET talkloop = 1: GOTO talkloop
        talkloop:
        _DELAY tdelay
    LOOP WHILE INKEY$ = ""
END IF
IF gamepad = 1 THEN
    REM GAMEPAD
    DO
        IF talkloop = 1 THEN _PUTIMAGE (resx - 35, resy - 41), talkpic1: LET talkloop = 2: GOTO talkloop2
        IF talkloop = 2 THEN _PUTIMAGE (resx - 35, resy - 41), talkpic2: LET talkloop = 1: GOTO talkloop2
        talkloop2:
        _DELAY tdelay
    LOOP UNTIL GetButton("BACK", 0)
END IF
IF gamepad = 1 THEN
    DO
    LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
END IF
GOSUB keycatcher
CLS
_FREEIMAGE talkpic1: _FREEIMAGE talkpic2: _FREEIMAGE talkscreen
GOSUB redraw
RETURN

cutscene:
REM cutscene sub
LET adelay = 0.1
OPEN obmap$ + mapdir$ + "\" + object$ + "-CS.ddf" FOR INPUT AS #1
INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
CLOSE #1
freshcutscene:
LET csperson$ = LCASE$(csperson$)
REM NOT YOU CUTSCENE
IF csperson$ <> "you" THEN
    LET notyoucutscene = 1
    LET cspf = _LOADIMAGE(cloc$ + csperson$ + "-f.png")
    LET cspfr = _LOADIMAGE(cloc$ + csperson$ + "-fr.png")
    LET cspfl = _LOADIMAGE(cloc$ + csperson$ + "-fl.png")
    LET cspr = _LOADIMAGE(cloc$ + csperson$ + "-r.png")
    LET csprr = _LOADIMAGE(cloc$ + csperson$ + "-rr.png")
    LET csprl = _LOADIMAGE(cloc$ + csperson$ + "-rl.png")
    LET cspl = _LOADIMAGE(cloc$ + csperson$ + "-l.png")
    LET cspll = _LOADIMAGE(cloc$ + csperson$ + "-ll.png")
    LET csplr = _LOADIMAGE(cloc$ + csperson$ + "-lr.png")
    LET cspb = _LOADIMAGE(cloc$ + csperson$ + "-b.png")
    LET cspbr = _LOADIMAGE(cloc$ + csperson$ + "-br.png")
    LET cspbl = _LOADIMAGE(cloc$ + csperson$ + "-bl.png")
    IF csd1 >= 1 AND csd1 <= 4 THEN
        FOR move = 1 TO csm1
            IF csd1 = 1 THEN LET csy = csy - pace
            IF csd1 = 2 THEN LET csy = csy + pace
            IF csd1 = 3 THEN LET csx = csx + pace
            IF csd1 = 4 THEN LET csx = csx - pace
            LET csdirection = csd1
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd1 = 666 THEN GOSUB endbeta
    IF csd1 = 10 THEN GOSUB spacetravel
    IF csd1 = 9 THEN GOSUB moveon
    IF csd1 = 0 THEN GOTO notyoucutsceneend
    IF csd1 = 5 THEN
        OPEN csloc$ + txtdata1$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd1 = 6 THEN
        REM spin
        LET csdirection = 1
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
        LOOP UNTIL aniloop >= 5
        LET soundfile$ = "warpup": GOSUB audio
        REM spin and up
        LET adelay = 0.01
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csy = csy - pace
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
            CLS
        LOOP UNTIL aniloop = 10 + bgresy
    END IF
    IF csd1 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata1$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        _FREEIMAGE cspf: _FREEIMAGE cspfr: _FREEIMAGE cspfl: _FREEIMAGE cspr: _FREEIMAGE csprr: _FREEIMAGE csprl: _FREEIMAGE cspl: _FREEIMAGE cspll: _FREEIMAGE csplr: _FREEIMAGE cspb: _FREEIMAGE cspbr: _FREEIMAGE cspbl
        GOTO freshcutscene
    END IF
    IF csd1 = 8 THEN
        REM new map
        LET mapno = csm1
        GOSUB mapload
    END IF
    IF csd2 >= 1 AND csd2 <= 4 THEN
        FOR move = 1 TO csm2
            IF csd2 = 1 THEN LET csy = csy - pace
            IF csd2 = 2 THEN LET csy = csy + pace
            IF csd2 = 3 THEN LET csx = csx + pace
            IF csd2 = 4 THEN LET csx = csx - pace
            LET csdirection = csd2
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd2 = 666 THEN GOSUB endbeta
    IF csd2 = 10 THEN GOSUB spacetravel
    IF csd2 = 9 THEN GOSUB moveon
    IF csd2 = 0 THEN GOTO notyoucutsceneend
    IF csd2 = 5 THEN
        OPEN csloc$ + txtdata2$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd2 = 6 THEN
        REM spin
        LET csdirection = 1
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
        LOOP UNTIL aniloop >= 5
        LET soundfile$ = "warpup": GOSUB audio
        REM spin and up
        LET adelay = 0.01
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csy = csy - pace
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
            CLS
        LOOP UNTIL aniloop = 10 + bgresy
    END IF
    IF csd2 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata2$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        _FREEIMAGE cspf: _FREEIMAGE cspfr: _FREEIMAGE cspfl: _FREEIMAGE cspr: _FREEIMAGE csprr: _FREEIMAGE csprl: _FREEIMAGE cspl: _FREEIMAGE cspll: _FREEIMAGE csplr: _FREEIMAGE cspb: _FREEIMAGE cspbr: _FREEIMAGE cspbl
        GOTO freshcutscene
    END IF
    IF csd2 = 8 THEN
        REM new map
        LET mapno = csm2
        GOSUB mapload
    END IF
    IF csd3 >= 1 AND csd3 <= 4 THEN
        FOR move = 1 TO csm3
            IF csd3 = 1 THEN LET csy = csy - pace
            IF csd3 = 2 THEN LET csy = csy + pace
            IF csd3 = 3 THEN LET csx = csx + pace
            IF csd3 = 4 THEN LET csx = csx - pace
            LET csdirection = csd3
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd3 = 666 THEN GOSUB endbeta
    IF csd3 = 10 THEN GOSUB spacetravel
    IF csd3 = 9 THEN GOSUB moveon
    IF csd3 = 0 THEN GOTO notyoucutsceneend
    IF csd3 = 5 THEN
        OPEN csloc$ + txtdata3$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd3 = 6 THEN
        REM spin
        LET csdirection = 1
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
        LOOP UNTIL aniloop >= 5
        LET soundfile$ = "warpup": GOSUB audio
        REM spin and up
        LET adelay = 0.01
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csy = csy - pace
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
            CLS
        LOOP UNTIL aniloop = 10 + bgresy
    END IF
    IF csd3 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata3$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        _FREEIMAGE cspf: _FREEIMAGE cspfr: _FREEIMAGE cspfl: _FREEIMAGE cspr: _FREEIMAGE csprr: _FREEIMAGE csprl: _FREEIMAGE cspl: _FREEIMAGE cspll: _FREEIMAGE csplr: _FREEIMAGE cspb: _FREEIMAGE cspbr: _FREEIMAGE cspbl
        GOTO freshcutscene
    END IF
    IF csd3 = 8 THEN
        REM new map
        LET mapno = csm3
        GOSUB mapload
    END IF
    IF csd4 >= 1 AND csd4 <= 4 THEN
        FOR move = 1 TO csm4
            IF csd4 = 1 THEN LET csy = csy - pace
            IF csd4 = 2 THEN LET csy = csy + pace
            IF csd4 = 3 THEN LET csx = csx + pace
            IF csd4 = 4 THEN LET csx = csx - pace
            LET csdirection = csd4
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd4 = 666 THEN GOSUB endbeta
    IF csd4 = 10 THEN GOSUB spacetravel
    IF csd4 = 9 THEN GOSUB moveon
    IF csd4 = 0 THEN GOTO notyoucutsceneend
    IF csd4 = 5 THEN
        OPEN csloc$ + txtdata4$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd4 = 6 THEN
        REM spin
        LET csdirection = 1
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
        LOOP UNTIL aniloop >= 5
        LET soundfile$ = "warpup": GOSUB audio
        REM spin and up
        LET adelay = 0.01
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csy = csy - pace
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
            CLS
        LOOP UNTIL aniloop = 10 + bgresy
    END IF
    IF csd4 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata4$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        _FREEIMAGE cspf: _FREEIMAGE cspfr: _FREEIMAGE cspfl: _FREEIMAGE cspr: _FREEIMAGE csprr: _FREEIMAGE csprl: _FREEIMAGE cspl: _FREEIMAGE cspll: _FREEIMAGE csplr: _FREEIMAGE cspb: _FREEIMAGE cspbr: _FREEIMAGE cspbl
        GOTO freshcutscene
    END IF
    IF csd4 = 8 THEN
        REM new map
        LET mapno = csm4
        GOSUB mapload
    END IF
    IF csd5 >= 1 AND csd5 <= 4 THEN
        FOR move = 1 TO csm5
            IF csd5 = 1 THEN LET csy = csy - pace
            IF csd5 = 2 THEN LET csy = csy + pace
            IF csd5 = 3 THEN LET csx = csx + pace
            IF csd5 = 4 THEN LET csx = csx - pace
            LET csdirection = csd5
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd5 = 666 THEN GOSUB endbeta
    IF csd5 = 10 THEN GOSUB spacetravel
    IF csd5 = 9 THEN GOSUB moveon
    IF csd5 = 0 THEN GOTO notyoucutsceneend
    IF csd5 = 5 THEN
        OPEN csloc$ + txtdata5$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd5 = 6 THEN
        REM spin
        LET csdirection = 1
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
        LOOP UNTIL aniloop >= 5
        LET soundfile$ = "warpup": GOSUB audio
        REM spin and up
        LET adelay = 0.01
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csy = csy - pace
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
            CLS
        LOOP UNTIL aniloop = 10 + bgresy
    END IF
    IF csd5 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata5$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        _FREEIMAGE cspf: _FREEIMAGE cspfr: _FREEIMAGE cspfl: _FREEIMAGE cspr: _FREEIMAGE csprr: _FREEIMAGE csprl: _FREEIMAGE cspl: _FREEIMAGE cspll: _FREEIMAGE csplr: _FREEIMAGE cspb: _FREEIMAGE cspbr: _FREEIMAGE cspbl
        GOTO freshcutscene
    END IF
    IF csd5 = 8 THEN
        REM new map
        LET mapno = csm5
        GOSUB mapload
    END IF
    IF csd6 >= 1 AND csd6 <= 4 THEN
        FOR move = 1 TO csm6
            IF csd6 = 1 THEN LET csy = csy - pace
            IF csd6 = 2 THEN LET csy = csy + pace
            IF csd6 = 3 THEN LET csx = csx + pace
            IF csd6 = 4 THEN LET csx = csx - pace
            LET csdirection = csd6
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd6 = 666 THEN GOSUB endbeta
    IF csd6 = 10 THEN GOSUB spacetravel
    IF csd6 = 9 THEN GOSUB moveon
    IF csd6 = 0 THEN GOTO notyoucutsceneend
    IF csd6 = 5 THEN
        OPEN csloc$ + txtdata6$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd6 = 6 THEN
        REM spin
        LET csdirection = 1
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
        LOOP UNTIL aniloop >= 5
        LET soundfile$ = "warpup": GOSUB audio
        REM spin and up
        LET adelay = 0.01
        LET aniloop = 0
        DO
            GOSUB redraw
            _DELAY adelay
            LET csy = csy - pace
            LET csdirection = csdirection + 1
            IF csdirection > 4 THEN LET csdirection = 1
            LET aniloop = aniloop + 1
            CLS
        LOOP UNTIL aniloop = 10 + bgresy
    END IF
    IF csd6 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata6$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        _FREEIMAGE cspf: _FREEIMAGE cspfr: _FREEIMAGE cspfl: _FREEIMAGE cspr: _FREEIMAGE csprr: _FREEIMAGE csprl: _FREEIMAGE cspl: _FREEIMAGE cspll: _FREEIMAGE csplr: _FREEIMAGE cspb: _FREEIMAGE cspbr: _FREEIMAGE cspbl
        GOTO freshcutscene
    END IF
    IF csd6 = 8 THEN
        REM new map
        LET mapno = csm6
        GOSUB mapload
    END IF
    notyoucutsceneend:
    ON ERROR GOTO evilcheat
    _FREEIMAGE cspf: _FREEIMAGE cspfr: _FREEIMAGE cspfl: _FREEIMAGE cspr: _FREEIMAGE csprr: _FREEIMAGE csprl: _FREEIMAGE cspl: _FREEIMAGE cspll: _FREEIMAGE csplr: _FREEIMAGE cspb: _FREEIMAGE cspbr: _FREEIMAGE cspbl
    evilcheat:
    LET notyoucutscene = 0
END IF
REM YOU CUTSCENE
IF csperson$ = "you" THEN
    IF csd1 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata1$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        GOTO freshcutscene
    END IF
    IF csd1 >= 1 AND csd1 <= 4 THEN
        FOR move = 1 TO csm1
            LET ctime = (TIMER - itime): REM time keeper
            IF csd1 = 1 THEN LET bgy = bgy + pace
            IF csd1 = 2 THEN LET bgy = bgy - pace
            IF csd1 = 3 THEN LET bgx = bgx - pace
            IF csd1 = 4 THEN LET bgx = bgx + pace
            LET direction = csd1
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd1 = 666 THEN GOSUB endbeta
    IF csd1 = 10 THEN GOSUB spacetravel
    IF csd1 = 9 THEN GOSUB moveon
    IF csd1 = 0 THEN RETURN
    IF csd1 = 5 THEN
        OPEN csloc$ + txtdata1$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd1 = 6 THEN
        LET oldselect$ = selectitem$
        IF csm1 = 1 THEN LET selectitem$ = "WARP1"
        IF csm1 = 2 THEN LET selectitem$ = "WARP2"
        IF csm1 = 3 THEN LET selectitem$ = "WARP3"
        IF csm1 = 4 THEN LET selectitem$ = "WARP4"
        GOSUB warp
        LET selectitem$ = oldselect$
    END IF
    IF csd2 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata2$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        GOTO freshcutscene
    END IF
    IF csd2 >= 1 AND csd2 <= 4 THEN
        FOR move = 1 TO csm2
            LET ctime = (TIMER - itime): REM time keeper
            IF csd2 = 1 THEN LET bgy = bgy + pace
            IF csd2 = 2 THEN LET bgy = bgy - pace
            IF csd2 = 3 THEN LET bgx = bgx - pace
            IF csd2 = 4 THEN LET bgx = bgx + pace
            LET direction = csd2
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd2 = 666 THEN GOSUB endbeta
    IF csd2 = 10 THEN GOSUB spacetravel
    IF csd2 = 9 THEN GOSUB moveon
    IF csd2 = 0 THEN RETURN
    IF csd2 = 5 THEN
        OPEN csloc$ + txtdata2$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd2 = 6 THEN
        LET oldselect$ = selectitem$
        IF csm2 = 1 THEN LET selectitem$ = "WARP1"
        IF csm2 = 2 THEN LET selectitem$ = "WARP2"
        IF csm2 = 3 THEN LET selectitem$ = "WARP3"
        IF csm2 = 4 THEN LET selectitem$ = "WARP4"
        GOSUB warp
        LET selectitem$ = oldselect$
    END IF
    IF csd3 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata3$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        GOTO freshcutscene
    END IF
    IF csd3 >= 1 AND csd3 <= 4 THEN
        FOR move = 1 TO csm3
            LET ctime = (TIMER - itime): REM time keeper
            IF csd3 = 1 THEN LET bgy = bgy + pace
            IF csd3 = 2 THEN LET bgy = bgy - pace
            IF csd3 = 3 THEN LET bgx = bgx - pace
            IF csd3 = 4 THEN LET bgx = bgx + pace
            LET direction = csd3
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd3 = 666 THEN GOSUB endbeta
    IF csd3 = 10 THEN GOSUB spacetravel
    IF csd3 = 9 THEN GOSUB moveon
    IF csd3 = 0 THEN RETURN
    IF csd3 = 5 THEN
        OPEN csloc$ + txtdata3$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd3 = 6 THEN
        LET oldselect$ = selectitem$
        IF csm3 = 1 THEN LET selectitem$ = "WARP1"
        IF csm3 = 2 THEN LET selectitem$ = "WARP2"
        IF csm3 = 3 THEN LET selectitem$ = "WARP3"
        IF csm3 = 4 THEN LET selectitem$ = "WARP4"
        GOSUB warp
        LET selectitem$ = oldselect$
    END IF
    IF csd4 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata4$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        GOTO freshcutscene
    END IF
    IF csd4 >= 1 AND csd4 <= 4 THEN
        FOR move = 1 TO csm4
            LET ctime = (TIMER - itime): REM time keeper
            IF csd4 = 1 THEN LET bgy = bgy + pace
            IF csd4 = 2 THEN LET bgy = bgy - pace
            IF csd4 = 3 THEN LET bgx = bgx - pace
            IF csd4 = 4 THEN LET bgx = bgx + pace
            LET direction = csd4
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd4 = 666 THEN GOSUB endbeta
    IF csd4 = 10 THEN GOSUB spacetravel
    IF csd4 = 9 THEN GOSUB moveon
    IF csd4 = 0 THEN RETURN
    IF csd4 = 5 THEN
        OPEN csloc$ + txtdata4$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd4 = 6 THEN
        LET oldselect$ = selectitem$
        IF csm4 = 1 THEN LET selectitem$ = "WARP1"
        IF csm4 = 2 THEN LET selectitem$ = "WARP2"
        IF csm4 = 3 THEN LET selectitem$ = "WARP3"
        IF csm4 = 4 THEN LET selectitem$ = "WARP4"
        GOSUB warp
        LET selectitem$ = oldselect$
    END IF
    IF csd5 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata5$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        GOTO freshcutscene
    END IF
    IF csd5 >= 1 AND csd5 <= 4 THEN
        FOR move = 1 TO csm5
            LET ctime = (TIMER - itime): REM time keeper
            IF csd5 = 1 THEN LET bgy = bgy + pace
            IF csd5 = 2 THEN LET bgy = bgy - pace
            IF csd5 = 3 THEN LET bgx = bgx - pace
            IF csd5 = 4 THEN LET bgx = bgx + pace
            LET direction = csd5
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd5 = 666 THEN GOSUB endbeta
    IF csd5 = 10 THEN GOSUB spacetravel
    IF csd5 = 9 THEN GOSUB moveon
    IF csd5 = 0 THEN RETURN
    IF csd5 = 5 THEN
        OPEN csloc$ + txtdata5$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd5 = 6 THEN
        LET oldselect$ = selectitem$
        IF csm5 = 1 THEN LET selectitem$ = "WARP1"
        IF csm5 = 2 THEN LET selectitem$ = "WARP2"
        IF csm5 = 3 THEN LET selectitem$ = "WARP3"
        IF csm5 = 4 THEN LET selectitem$ = "WARP4"
        GOSUB warp
        LET selectitem$ = oldselect$
    END IF
    IF csd6 = 7 THEN
        REM   new cutscene
        LET freshcutscene$ = txtdata6$
        OPEN csloc$ + freshcutscene$ + "-CS.ddf" FOR INPUT AS #1
        INPUT #1, csperson$, csd1, csm1, txtdata1$, csd2, csm2, txtdata2$, csd3, csm3, txtdata3$, csd4, csm4, txtdata4$, csd5, csm5, txtdata5$, csd6, csm6, txtdata6$, csx, csy
        CLOSE #1
        GOTO freshcutscene
    END IF
    IF csd6 >= 1 AND csd6 <= 4 THEN
        FOR move = 1 TO csm6
            LET ctime = (TIMER - itime): REM time keeper
            IF csd6 = 1 THEN LET bgy = bgy + pace
            IF csd6 = 2 THEN LET bgy = bgy - pace
            IF csd6 = 3 THEN LET bgx = bgx - pace
            IF csd6 = 4 THEN LET bgx = bgx + pace
            LET direction = csd6
            GOSUB redraw
            _DELAY adelay
        NEXT move
    END IF
    IF csd6 = 666 THEN GOSUB endbeta
    IF csd6 = 10 THEN GOSUB spacetravel
    IF csd6 = 9 THEN GOSUB moveon
    IF csd6 = 0 THEN RETURN
    IF csd6 = 5 THEN
        OPEN csloc$ + txtdata6$ + ".ddf" FOR INPUT AS #2
        INPUT #2, talker$, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$
        CLOSE #2
        GOSUB talkscreen
    END IF
    IF csd6 = 6 THEN
        LET oldselect$ = selectitem$
        IF csm6 = 1 THEN LET selectitem$ = "WARP1"
        IF csm6 = 2 THEN LET selectitem$ = "WARP2"
        IF csm6 = 3 THEN LET selectitem$ = "WARP3"
        IF csm6 = 4 THEN LET selectitem$ = "WARP4"
        GOSUB warp
        LET selectitem$ = oldselect$
    END IF
END IF
RETURN

endbeta:
REM ends test or beta version once complete
SCREEN 0
CLS
PRINT "The Mystery of Robot Planet!"
PRINT: PRINT "Thank you for testing! You have reached the end of this game."
PRINT: PRINT "The game will now clear saved data and close."
PRINT "Relaunch the game to play again!"
PRINT: PRINT "Press space to clear data and end game."
DO: LOOP UNTIL INKEY$ = " "
OPEN dloc$ + "bloat.fuu" FOR OUTPUT AS #5
PRINT #5, 0
CLOSE #5
LET betaend = 1
GOSUB cleardata
SYSTEM

cutwarpup:
REM warp spin in cutscene (up)
REM spin
LET direction = 1
LET aniloop = 0
DO
    GOSUB redraw
    _DELAY adelay
    LET direction = direction + 1
    IF direction > 4 THEN LET direction = 1
    LET aniloop = aniloop + 1
LOOP UNTIL aniloop >= 5
LET soundfile$ = "warpup": GOSUB audio
REM spin and up
LET adelay = 0.01
LET aniloop = 0
DO
    GOSUB redraw
    _DELAY adelay
    LET bgy = bgy + pace
    LET direction = direction + 1
    IF direction > 4 THEN LET direction = 1
    LET aniloop = aniloop + 1
    CLS
LOOP UNTIL aniloop = 10 + bgresy
RETURN

object:
REM object
REM load data
LET obmap$ = oloc$
OPEN obmap$ + mapdir$ + "\" + object$ + ".ddf" FOR INPUT AS #1
INPUT #1, objecttype, objectdescript1$, objectdescript2$, objectdescript3$, objectdescript4$, objectdescript5$, objectdescript6$, containitem$, aobjectdescript1$, aobjectdescript2$, aobjectdescript3$, aobjectdescript4$, aobjectdescript5$, aobjectdescript6$, cutscenetype, mapcd
CLOSE #1
IF cutscenetype = 1 THEN GOSUB cutscene
LET containitem$ = LCASE$(containitem$)
IF inventoryopen = 1 THEN RETURN
REM descriptive object
IF objecttype = 1 OR objecttype = 2 OR objecttype = 7 OR objecttype = 8 THEN LET talker$ = "you"
IF objecttype = 3 OR objecttype = 4 OR objecttype = 5 OR objecttype = 6 THEN LET talker$ = LCASE$(object$)
IF objecttype = 5 OR objecttype = 6 OR objecttype = 7 OR objecttype = 8 THEN GOSUB object5: RETURN
IF objecttype = 1 OR objecttype = 3 THEN
    LET talkline1$ = objectdescript1$
    LET talkline2$ = objectdescript2$
    LET talkline3$ = objectdescript3$
    LET talkline4$ = objectdescript4$
    LET talkline5$ = objectdescript5$
    LET talkline6$ = objectdescript6$
    GOSUB talkscreen
END IF
REM contain object
IF objecttype = 2 OR objecttype = 4 THEN
    OPEN iloc$ + containitem$ + ".ddf" FOR INPUT AS #1
    INPUT #1, contain
    CLOSE #1
    LET grabbed = _LOADIMAGE(iloc$ + containitem$ + ".png")
    REM not picked up
    IF contain = 0 THEN
        LET talkline1$ = objectdescript1$
        LET talkline2$ = objectdescript2$
        LET talkline3$ = objectdescript3$
        LET talkline4$ = objectdescript4$
        LET talkline5$ = objectdescript5$
        LET talkline6$ = objectdescript6$
        GOSUB talkscreen
        LET talkscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
        CLS
        _PUTIMAGE (-resx, -resy)-(resx, resy), talkscreen
        REM aprostraphie searcher ;)
        LET afinder = 0
        LET afinder% = INSTR(afinder% + 1, containitem$, "'")
        IF afinder% THEN LET afinder = 1
        IF afinder = 0 THEN PRINT "You got the "; containitem$
        IF afinder = 1 THEN PRINT "You got "; containitem$
        PRINT: PRINT "..."
        IF gamepad = 1 THEN PRINT "(press back)"
        _PUTIMAGE (resx - 35, resy - 41), grabbed
        LET soundfile$ = "pickup": GOSUB audio
        IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
        IF gamepad = 1 THEN
            DO: LOOP UNTIL GetButton("BACK", 0)
            DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
        END IF
        OPEN iloc$ + containitem$ + ".ddf" FOR OUTPUT AS #2
        PRINT #2, 1
        CLOSE #2
        LET pocketnos = pocketnos + 1
        _FREEIMAGE grabbed: _FREEIMAGE talkscreen
        CLS: GOSUB redraw
    END IF
    REM picked up
    IF contain = 1 OR contain = 2 THEN
        LET talkline1$ = aobjectdescript1$
        LET talkline2$ = aobjectdescript2$
        LET talkline3$ = aobjectdescript3$
        LET talkline4$ = aobjectdescript4$
        LET talkline5$ = aobjectdescript5$
        LET talkline6$ = aobjectdescript6$
        GOSUB talkscreen
    END IF
END IF
REM map c technology
IF mapcd = 1 THEN
    _FREEIMAGE map: _FREEIMAGE mapb
    LET map = _LOADIMAGE(mloc$ + mapfile$ + "c.png")
    LET mapb = _LOADIMAGE(mloc$ + mapfile$ + "bc.png")
    LET itemno = itemno - 1
    LET mapc = 1
    OPEN mloc$ + "c" + mapdir$ + ".ddf" FOR OUTPUT AS #3
    PRINT #3, mapc
    CLOSE #3
    GOSUB mapload
    LET mapcd = 0
END IF
IF cutscenetype = 2 THEN GOSUB cutscene
RETURN

object5:
REM object type 5
OPEN obmap$ + mapdir$ + "\" + "object5\" + object$ + "5.ddf" FOR INPUT AS #3
INPUT #3, obj5stat
REM nothing given or picked up
IF obj5stat = 0 THEN
    LET talkline1$ = objectdescript1$
    LET talkline2$ = objectdescript2$
    LET talkline3$ = objectdescript3$
    LET talkline4$ = objectdescript4$
    LET talkline5$ = objectdescript5$
    LET talkline6$ = objectdescript6$
    GOSUB talkscreen
END IF
REM given or picked up
IF obj5stat = 1 THEN
    LET talkline1$ = aobjectdescript1$
    LET talkline2$ = aobjectdescript2$
    LET talkline3$ = aobjectdescript3$
    LET talkline4$ = aobjectdescript4$
    LET talkline5$ = aobjectdescript5$
    LET talkline6$ = aobjectdescript6$
    GOSUB talkscreen
END IF
CLOSE #3
RETURN

numberremover:
REM removes number from selectitem$
LET nfinder = 0
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "1")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "2")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "3")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "4")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "5")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "6")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "7")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "8")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "9")
IF nfinder% THEN LET nfinder = 1
LET nfinder% = INSTR(nfinder% + 1, selectitem$, "10")
IF nfinder% THEN LET nfinder = 1
IF nfinder = 1 THEN
    IF selectitem$ = "DESK1" OR selectitem$ = "DESK2" OR selectitem$ = "DESK3" OR selectitem$ = "DESK4" THEN LET oselectitem$ = selectitem$: LET selectitem$ = "DESK"
    IF selectitem$ = "BIN1" OR selectitem$ = "BIN2" OR selectitem$ = "BIN3" OR selectitem$ = "BIN4" THEN LET oselectitem$ = selectitem$: LET selectitem$ = "BIN"
    IF selectitem$ = "WARP1" OR selectitem$ = "WARP2" OR selectitem$ = "WARP3" OR selectitem$ = "WARP4" THEN LET oselectitem$ = selectitem$: LET selectitem$ = "WARP"
    IF selectitem$ = "SIGN1" OR selectitem$ = "SIGN2" OR selectitem$ = "SIGN3" OR selectitem$ = "SIGN4" OR selectitem$ = "SIGN5" OR selectitem$ = "SIGN6" THEN LET oselectitem$ = selectitem$: LET selectitem$ = "SIGN"
    IF selectitem$ = "BUNKBED1" OR selectitem$ = "BUNKBED2" THEN LET oselectitem$ = selectitem$: LET selectitem$ = "BUNKBED"
    IF selectitem$ = "ENGINE1" OR selectitem$ = "ENGINE2" OR selectitem$ = "ENGINE3" THEN LET oselectitem$ = selectitem$: LET selectitem$ = "ENGINE"
    IF selectitem$ = "COGS1" OR selectitem$ = "COGS2" OR selectitem$ = "COGS3" THEN LET oselectitem$ = selectitem$: LET selectitem$ = "COGS"
END IF
RETURN

numberadder:
REM adds number to selectitem$
IF nfinder = 1 THEN
    LET selectitem$ = oselectitem$
    LET nfinder = 0
END IF
RETURN

noline:
REM randomises "no" lines
OPEN iloc$ + "nolines.ddf" FOR INPUT AS #486
INPUT #486, noline1$, noline2$, noline3$, noline4$, noline5$, noline6$, noline7$, noline8$, noline9$, noline10$
CLOSE #486
LET nolineno = INT(RND * 10)
IF nolineno = 1 THEN LET defnoline$ = noline1$
IF nolineno = 2 THEN LET defnoline$ = noline2$
IF nolineno = 3 THEN LET defnoline$ = noline3$
IF nolineno = 4 THEN LET defnoline$ = noline4$
IF nolineno = 5 THEN LET defnoline$ = noline5$
IF nolineno = 6 THEN LET defnoline$ = noline6$
IF nolineno = 7 THEN LET defnoline$ = noline7$
IF nolineno = 8 THEN LET defnoline$ = noline8$
IF nolineno = 9 THEN LET defnoline$ = noline9$
IF nolineno = 10 THEN LET defnoline$ = noline10$
RETURN

inventory:
REM inventory sub
LET invscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
CLS
_PUTIMAGE (-resx, -resy)-(resx, resy), invscreen
REM loading loop
OPEN iloc$ + "inventory.ddf" FOR INPUT AS #1
INPUT #1, iitem1$, iitem2$, iitem3$, iitem4$, iitem5$, iitem6$, iitem7$, iitem8$, iitem9$, iitem10$, iitem11$, iitem12$, iitem13$, iitem14$, iitem15$, iitem16$, iitem17$, iitem18$, iitem19$, iitem20$, iitem21$, iitem22$, iitem23$, iitem24$, iitem25$, iitem26$, iitem27$, iitem28$, iitem29$, iitem30$, iitem31$, iitem32$, iitem33$, iitem34$, iitem35$, iitem36$, iitem37$, iitem38$, iitem39$
CLOSE #1
IF selectitem$ <> "" THEN
    LET object$ = selectitem$
    LET inventoryopen = 1
    GOSUB object
    LET inventoryopen = 0
END IF
LET iloopd = 2
LET iloop = 1
LET iloopmin = 1
LET iloopmax = 39
LET escapeinv = 0
DO
    IF iloop = 1 THEN LET ditem$ = iitem1$
    IF iloop = 2 THEN LET ditem$ = iitem2$
    IF iloop = 3 THEN LET ditem$ = iitem3$
    IF iloop = 4 THEN LET ditem$ = iitem4$
    IF iloop = 5 THEN LET ditem$ = iitem5$
    IF iloop = 6 THEN LET ditem$ = iitem6$
    IF iloop = 7 THEN LET ditem$ = iitem7$
    IF iloop = 8 THEN LET ditem$ = iitem8$
    IF iloop = 9 THEN LET ditem$ = iitem9$
    IF iloop = 10 THEN LET ditem$ = iitem10$
    IF iloop = 11 THEN LET ditem$ = iitem11$
    IF iloop = 12 THEN LET ditem$ = iitem12$
    IF iloop = 13 THEN LET ditem$ = iitem13$
    IF iloop = 14 THEN LET ditem$ = iitem14$
    IF iloop = 15 THEN LET ditem$ = iitem15$
    IF iloop = 16 THEN LET ditem$ = iitem16$
    IF iloop = 17 THEN LET ditem$ = iitem17$
    IF iloop = 18 THEN LET ditem$ = iitem18$
    IF iloop = 19 THEN LET ditem$ = iitem19$
    IF iloop = 20 THEN LET ditem$ = iitem20$
    IF iloop = 21 THEN LET ditem$ = iitem21$
    IF iloop = 22 THEN LET ditem$ = iitem22$
    IF iloop = 23 THEN LET ditem$ = iitem23$
    IF iloop = 24 THEN LET ditem$ = iitem24$
    IF iloop = 25 THEN LET ditem$ = iitem25$
    IF iloop = 26 THEN LET ditem$ = iitem26$
    IF iloop = 27 THEN LET ditem$ = iitem27$
    IF iloop = 28 THEN LET ditem$ = iitem28$
    IF iloop = 29 THEN LET ditem$ = iitem29$
    IF iloop = 30 THEN LET ditem$ = iitem30$
    IF iloop = 31 THEN LET ditem$ = iitem31$
    IF iloop = 32 THEN LET ditem$ = iitem32$
    IF iloop = 33 THEN LET ditem$ = iitem33$
    IF iloop = 34 THEN LET ditem$ = iitem34$
    IF iloop = 35 THEN LET ditem$ = iitem35$
    IF iloop = 36 THEN LET ditem$ = iitem36$
    IF iloop = 37 THEN LET ditem$ = iitem37$
    IF iloop = 38 THEN LET ditem$ = iitem38$
    IF iloop = 39 THEN LET ditem$ = iitem39$
    REM PRINT iloop: PRINT ditem$: SLEEP 1: REM Inventory Debug Tool
    GOSUB loadinv
    IF iloopd = 2 THEN LET iloop = iloop + 1
    IF iloopd = 1 THEN LET iloop = iloop - 1
    IF iloopd = 0 THEN GOSUB redraw: RETURN
    IF iloop <= (iloopmin - 1) THEN LET iloopd = 2: LET iloop = iloopmin
    IF iloop >= (iloopmax + 1) THEN LET iloopd = 1: LET iloop = iloopmax
LOOP
loadinv:
REM inventory file loading
OPEN iloc$ + ditem$ + ".ddf" FOR INPUT AS #2
INPUT #2, iavailable
CLOSE #2
REM number remover selectitem$
GOSUB numberremover
REM PRINT iavailable
IF iavailable = 1 THEN GOSUB showinv
LET iavailable = 0
RETURN
showinv:
REM inventory file displaying
PRINT "Inventory"
IF ditem$ <> "credits" THEN PRINT ditem$
IF ditem$ = "credits" THEN PRINT ditem$; " - "; credits
PRINT: PRINT: PRINT: PRINT: PRINT: PRINT: PRINT
COLOR &HFF545454
IF selectitem$ = "" THEN PRINT "Look at "; ditem$: GOTO yetanotherdirtycheatlol
IF objecttype = 1 OR objecttype = 2 OR objecttype = 7 OR objecttype = 8 THEN PRINT "Use "; ditem$; " with "; selectitem$: GOTO yetanotherdirtycheatlol
IF objecttype = 3 OR objecttype = 4 OR objecttype = 5 OR objecttype = 6 THEN PRINT "Give "; ditem$; " to "; selectitem$
yetanotherdirtycheatlol:
PRINT "Combine "; ditem$
COLOR &HFFFCFCFC
LET invimg = _LOADIMAGE(iloc$ + ditem$ + ".png")
LET arrowr = _LOADIMAGE(iloc$ + "arrowr.png")
LET arrowl = _LOADIMAGE(iloc$ + "arrowl.png")
LET arrowrs = _LOADIMAGE(iloc$ + "arrowrs.png")
LET arrowls = _LOADIMAGE(iloc$ + "arrowls.png")
_PUTIMAGE ((resx / 2) - (35 / 2), ((resy / 2) - (41 / 2) - 10)), invimg
_PUTIMAGE ((resx / 2) + (35 / 2), ((resy / 2) - (15 / 2) - 10)), arrowr
_PUTIMAGE ((resx / 2) - 35, ((resy / 2) - (15 / 2) - 10)), arrowl
IF gamepad = 0 THEN
    DO
        LET i$ = UCASE$(INKEY$): REM user input
        IF i$ = CHR$(0) + CHR$(77) THEN LET iloopd = 2: _PUTIMAGE ((resx / 2) + (35 / 2), ((resy / 2) - (15 / 2) - 10)), arrowrs: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF i$ = CHR$(0) + CHR$(75) THEN LET iloopd = 1: _PUTIMAGE ((resx / 2) - 35, ((resy / 2) - (15 / 2) - 10)), arrowls: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF i$ = "Q" THEN LET iloopd = 0: CLS: _FREEIMAGE invscreen: _FREEIMAGE arrowr: _FREEIMAGE arrowl: _FREEIMAGE arrowrs: _FREEIMAGE arrowls: _FREEIMAGE invimg: RETURN
        IF i$ = " " THEN LET iselect = 1: GOSUB useinv: GOTO loadinv
        IF escapeinv = 1 THEN LET iloopd = 0: CLS: _FREEIMAGE invscreen: _FREEIMAGE arrowr: _FREEIMAGE arrowl: _FREEIMAGE arrowrs: _FREEIMAGE arrowls: _FREEIMAGE invimg: RETURN
    LOOP
END IF
IF gamepad = 1 THEN
    DO
        IF GetButton("RIGHT", 0) THEN DO: LOOP UNTIL GetButton("RIGHT", 0) = GetButton.NotFound: LET iloopd = 2: _PUTIMAGE ((resx / 2) + (35 / 2), ((resy / 2) - (15 / 2) - 10)), arrowrs: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF GetButton("LEFT", 0) THEN DO: LOOP UNTIL GetButton("LEFT", 0) = GetButton.NotFound: LET iloopd = 1: _PUTIMAGE ((resx / 2) - 35, ((resy / 2) - (15 / 2) - 10)), arrowls: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF GetButton("BACK", 0) THEN DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound: LET iloopd = 0: CLS: _FREEIMAGE invscreen: _FREEIMAGE arrowr: _FREEIMAGE arrowl: _FREEIMAGE arrowrs: _FREEIMAGE arrowls: _FREEIMAGE invimg: RETURN
        IF GetButton("USE", 0) THEN DO: LOOP UNTIL GetButton("USE", 0) = GetButton.NotFound: LET iselect = 1: GOSUB useinv: GOTO loadinv
        IF escapeinv = 1 THEN LET iloopd = 0: CLS: _FREEIMAGE invscreen: _FREEIMAGE arrowr: _FREEIMAGE arrowl: _FREEIMAGE arrowrs: _FREEIMAGE arrowls: _FREEIMAGE invimg: RETURN
    LOOP
END IF
useinv:
REM use item in inventory
CLS
_PUTIMAGE (-resx, -resy)-(resx, resy), invscreen
PRINT "Inventory"
IF ditem$ <> "credits" THEN PRINT ditem$
IF ditem$ = "credits" THEN PRINT ditem$; " - "; credits
PRINT: PRINT: PRINT: PRINT: PRINT: PRINT: PRINT
_PUTIMAGE ((resx / 2) - (35 / 2), ((resy / 2) - (41 / 2) - 10)), invimg
IF iselect = 1 THEN
    COLOR &HFFA80000
    IF selectitem$ = "" THEN PRINT "Look at "; ditem$: GOTO dirtyinvcheat1
    IF objecttype = 1 OR objecttype = 2 OR objecttype = 7 OR objecttype = 8 THEN PRINT "Use "; ditem$; " with "; selectitem$: GOTO dirtyinvcheat1
    IF objecttype = 3 OR objecttype = 4 OR objecttype = 5 OR objecttype = 6 THEN PRINT "Give "; ditem$; " to "; selectitem$
    dirtyinvcheat1:
    COLOR &HFFFCFCFC: PRINT "Combine "; ditem$
END IF
IF iselect = 2 THEN
    COLOR &HFFFCFCFC
    IF selectitem$ = "" THEN PRINT "Look at "; ditem$: GOTO dirtyinvcheat2
    IF objecttype = 1 OR objecttype = 2 OR objecttype = 7 OR objecttype = 8 THEN PRINT "Use "; ditem$; " with "; selectitem$: GOTO dirtyinvcheat2
    IF objecttype = 3 OR objecttype = 4 OR objecttype = 5 OR objecttype = 6 THEN PRINT "Give "; ditem$; " to "; selectitem$
    dirtyinvcheat2:
    COLOR &HFFA80000: PRINT "Combine "; ditem$: COLOR &HFFFCFCFC
END IF
IF gamepad = 0 THEN
    DO
        LET ii$ = UCASE$(INKEY$): REM user input
        IF ii$ = CHR$(0) + CHR$(72) THEN LET iselect = 1: GOTO useinv
        IF ii$ = CHR$(0) + CHR$(80) THEN LET iselect = 2: GOTO useinv
        IF ii$ = "Q" THEN CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF ii$ = " " THEN
            OPEN iloc$ + ditem$ + "-p.ddf" FOR INPUT AS #3
            INPUT #3, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$, citem1$, citem2$, citem3$
            CLOSE #3
            IF iselect = 1 THEN GOSUB numberadder: GOSUB useinvworld: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
            IF iselect = 2 THEN GOSUB useinvinv: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        END IF
        IF escapeinv = 1 THEN CLS: RETURN
    LOOP
END IF
IF gamepad = 1 THEN
    DO
        IF GetButton("UP", 0) THEN DO: LOOP UNTIL GetButton("UP", 0) = GetButton.NotFound: LET iselect = 1: GOTO useinv
        IF GetButton("DOWN", 0) THEN DO: LOOP UNTIL GetButton("DOWN", 0) = GetButton.NotFound: LET iselect = 2: GOTO useinv
        IF GetButton("BACK", 0) THEN DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF GetButton("USE", 0) THEN
            DO: LOOP UNTIL GetButton("USE", 0) = GetButton.NotFound
            OPEN iloc$ + ditem$ + "-p.ddf" FOR INPUT AS #3
            INPUT #3, talkline1$, talkline2$, talkline3$, talkline4$, talkline5$, talkline6$, citem1$, citem2$, citem3$
            CLOSE #3
            IF iselect = 1 THEN GOSUB numberadder: GOSUB useinvworld: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
            IF iselect = 2 THEN GOSUB useinvinv: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        END IF
    LOOP
END IF
useinvworld:
REM use inventory item with world
IF selectitem$ = "" THEN
    IF objecttype <> 7 THEN LET objecttype = 1
    LET talker$ = "YOU"
    GOSUB talkscreen
    LET escapeinv = 1
    RETURN
END IF
IF ditem$ = "credits" THEN
    GOSUB usecredits
    IF except = 1 THEN LET except = 0: RETURN
    IF rejectcredit = 0 THEN IF cutscenetype = 3 THEN GOSUB cutscene
    IF rejectcredit = 1 THEN LET rejectcredit = 0
    RETURN
END IF
IF selectitem$ = citem1$ THEN
    GOSUB useinvworlds
    IF except = 1 THEN LET except = 0: RETURN
    IF cutscenetype = 3 THEN GOSUB cutscene
    RETURN
END IF
IF selectitem$ = citem2$ THEN
    GOSUB useinvworlds
    IF except = 1 THEN LET except = 0: RETURN
    IF cutscenetype = 3 THEN GOSUB cutscene
    RETURN
END IF
IF selectitem$ = citem3$ THEN
    GOSUB useinvworlds
    IF except = 1 THEN LET except = 0: RETURN
    IF cutscenetype = 3 THEN GOSUB cutscene
    RETURN
END IF
REM giving object to character (FAILURE)
IF objecttype = 3 OR objecttype = 4 OR objecttype = 5 OR objecttype = 6 THEN
    OPEN oloc$ + mapdir$ + "\" + selectitem$ + "-p.ddf" FOR INPUT AS #10
    INPUT #10, nochat1$, nochat2$, nochat3$, nochat4$, nochat5$, nochat6$
    CLOSE #10
    LET talker$ = selectitem$
    LET talkline1$ = nochat1$
    LET talkline2$ = nochat2$
    LET talkline3$ = nochat3$
    LET talkline4$ = nochat4$
    LET talkline5$ = nochat5$
    LET talkline6$ = nochat6$
    GOSUB talkscreen
    LET escapeinv = 1
    RETURN
END IF
REM using object with object (FAILURE)
GOSUB numberremover
GOSUB noline
LET objecttype = 1
LET talker$ = "YOU"
LET talkline1$ = "I can't use the " + ditem$
LET talkline2$ = "with the " + selectitem$
LET talkline3$ = ""
LET talkline4$ = defnoline$
LET talkline5$ = ""
LET talkline6$ = ""
GOSUB talkscreen
GOSUB numberadder
LET escapeinv = 1
RETURN
useinvworlds:
REM use invenory item success
LET escapeinv = 1
OPEN iloc$ + "comb.ddf" FOR INPUT AS #4
INPUT #4, terminalcom$, passcom$, uncoolcom$, coolcom$, guncom$, unicom$, leafcom$, lambtcardcom$, coffeecom$, clothcom$, tshirtcom$, refundcom$, accidentcom$, microcom$, shippasscom$, crewpasscom$, acrewpasscom$, kcrewpasscom$, rcrewpasscom$, bookcom$, mapcom$, keycom$, oldkeycom$, startermotorcom$, crackedbarcom$, kernelmapcom$, amypasscom$
CLOSE #4
REM t-card with terminal
IF selectitem$ = terminalcom$ THEN GOSUB terminal
REM pass with lamb
IF selectitem$ = passcom$ THEN GOSUB giveitem
REM uncool doll with gareth
IF selectitem$ = uncoolcom$ THEN GOSUB giveitem
REM cool doll with gun man
IF selectitem$ = coolcom$ THEN GOSUB giveitem
REM gun with voodoo
IF selectitem$ = guncom$ THEN GOSUB giveitem
REM uniform with marine
IF selectitem$ = unicom$ THEN GOSUB giveitem
REM leaflet with bouncer
IF selectitem$ = leafcom$ THEN GOSUB giveitem
REM lambs t-card with marine
IF selectitem$ = lambtcardcom$ THEN GOSUB giveitem
REM coffee with gareth
IF selectitem$ = coffeecom$ THEN GOSUB giveitem
REM cloth with coffee machine
IF selectitem$ = clothcom$ THEN GOSUB giveitem
REM tshirt with princess
IF selectitem$ = tshirtcom$ THEN GOSUB giveitem
REM refund with jerry
IF selectitem$ = refundcom$ THEN GOSUB giveitem
REM accident form with marine
IF selectitem$ = accidentcom$ THEN GOSUB giveitem
REM microphone with voodoo
IF selectitem$ = microcom$ THEN GOSUB giveitem
REM ship pass with reece
IF selectitem$ = shippasscom$ THEN GOSUB giveitem
REM crew pass with reece
IF selectitem$ = crewpasscom$ THEN GOSUB giveitem
REM amys crew pass with reece
IF selectitem$ = acrewpasscom$ THEN GOSUB giveitem
REM kristoffs crew pass with reece
IF selectitem$ = kcrewpasscom$ THEN GOSUB giveitem
REM reeces crew pass with reece
IF selectitem$ = rcrewpasscom$ THEN GOSUB giveitem
REM book with kristoff
IF selectitem$ = bookcom$ THEN GOSUB giveitem
REM map with machine
IF selectitem$ = mapcom$ THEN GOSUB giveitem
REM key with rocketbus
IF selectitem$ = keycom$ THEN GOSUB moveon
REM old key with chest/cabinet
IF selectitem$ = oldkeycom$ THEN GOSUB giveitem
REM starter motor with machine
IF selectitem$ = startermotorcom$ THEN GOSUB giveitem
REM chisel with cracked bar
IF selectitem$ = crackedbarcom$ THEN GOSUB giveitem
REM map with kernel
IF selectitem$ = kernelmapcom$ THEN GOSUB giveitem
REM pass with amy (map2)
IF selectitem$ = amypasscom$ THEN GOSUB giveitem
RETURN
useinvinv:
REM use inventory item with inventory
REM loading loop
REM return for less than two items
IF pocketnos = 1 THEN CLS: LET tselect$ = "noitem.txt": GOSUB readtxt: LET escapeinv = 1: RETURN
LET iloopd = 2
LET iloop = 1
LET escapeinvinv = 0
DO
    IF iloop = 1 THEN LET cditem$ = iitem1$
    IF iloop = 2 THEN LET cditem$ = iitem2$
    IF iloop = 3 THEN LET cditem$ = iitem3$
    IF iloop = 4 THEN LET cditem$ = iitem4$
    IF iloop = 5 THEN LET cditem$ = iitem5$
    IF iloop = 6 THEN LET cditem$ = iitem6$
    IF iloop = 7 THEN LET cditem$ = iitem7$
    IF iloop = 8 THEN LET cditem$ = iitem8$
    IF iloop = 9 THEN LET cditem$ = iitem9$
    IF iloop = 10 THEN LET cditem$ = iitem10$
    IF iloop = 11 THEN LET cditem$ = iitem11$
    IF iloop = 12 THEN LET cditem$ = iitem12$
    IF iloop = 13 THEN LET cditem$ = iitem13$
    IF iloop = 14 THEN LET cditem$ = iitem14$
    IF iloop = 15 THEN LET cditem$ = iitem15$
    IF iloop = 16 THEN LET cditem$ = iitem16$
    IF iloop = 17 THEN LET cditem$ = iitem17$
    IF iloop = 18 THEN LET cditem$ = iitem18$
    IF iloop = 19 THEN LET cditem$ = iitem19$
    IF iloop = 20 THEN LET cditem$ = iitem20$
    IF iloop = 21 THEN LET cditem$ = iitem21$
    IF iloop = 22 THEN LET cditem$ = iitem22$
    IF iloop = 23 THEN LET cditem$ = iitem23$
    IF iloop = 24 THEN LET cditem$ = iitem24$
    IF iloop = 25 THEN LET cditem$ = iitem25$
    IF iloop = 26 THEN LET cditem$ = iitem26$
    IF iloop = 27 THEN LET cditem$ = iitem27$
    IF iloop = 28 THEN LET cditem$ = iitem28$
    IF iloop = 29 THEN LET cditem$ = iitem29$
    IF iloop = 30 THEN LET cditem$ = iitem30$
    IF iloop = 31 THEN LET cditem$ = iitem31$
    IF iloop = 32 THEN LET cditem$ = iitem32$
    IF iloop = 33 THEN LET cditem$ = iitem33$
    IF iloop = 34 THEN LET cditem$ = iitem34$
    IF iloop = 35 THEN LET cditem$ = iitem35$
    IF iloop = 36 THEN LET cditem$ = iitem36$
    IF iloop = 37 THEN LET cditem$ = iitem37$
    IF iloop = 38 THEN LET cditem$ = iitem38$
    IF iloop = 39 THEN LET cditem$ = iitem39$
    GOSUB loadinv2
    IF iloopd = 2 THEN LET iloop = iloop + 1
    IF iloopd = 1 THEN LET iloop = iloop - 1
    IF iloopd = 0 THEN RETURN
    IF iloop <= (iloopmin - 1) THEN LET iloopd = 2: LET iloop = iloopmin
    IF iloop >= (iloopmax + 1) THEN LET iloopd = 1: LET iloop = iloopmax
LOOP
loadinv2:
IF cditem$ = ditem$ THEN RETURN
REM inventory file loading
LET invimg2 = _LOADIMAGE(iloc$ + cditem$ + ".png")
OPEN iloc$ + cditem$ + ".ddf" FOR INPUT AS #2
INPUT #2, iavailable
CLOSE #2
IF iavailable = 1 THEN GOSUB showinv2
LET iavailable = 0
RETURN
showinv2:
REM inventory file displaying
CLS
_PUTIMAGE (-resx, -resy)-(resx, resy), invscreen
PRINT "Inventory"
PRINT "Combine "; ditem$
PRINT "with "; cditem$
PRINT: PRINT: PRINT: PRINT: PRINT: PRINT: PRINT
_PUTIMAGE ((resx / 2) - (35 / 2), ((resy / 2) - (41 / 2) - 10)), invimg
_PUTIMAGE ((resx / 2) - (35 / 2), (resy / 2) - (41 / 2) + 31), invimg2
_PUTIMAGE ((resx / 2) + (35 / 2), (resy / 2) - (15 / 2) + 31), arrowr
_PUTIMAGE ((resx / 2) - 35, (resy / 2) - (15 / 2) + 31), arrowl
IF gamepad = 0 THEN
    DO
        LET i$ = UCASE$(INKEY$): REM user input
        IF i$ = CHR$(0) + CHR$(77) THEN LET iloopd = 2: _PUTIMAGE ((resx / 2) + (35 / 2), (resy / 2) - (15 / 2) + 31), arrowrs: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF i$ = CHR$(0) + CHR$(75) THEN LET iloopd = 1: _PUTIMAGE ((resx / 2) - 35, (resy / 2) - (15 / 2) + 31), arrowls: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF i$ = "Q" THEN LET iloopd = 0: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF i$ = " " THEN LET iselect = 1: GOSUB combineattempt: CLS: GOTO game
        IF escapeinvinv = 1 THEN LET iloopd = 0: CLS: RETURN
    LOOP
END IF
IF gamepad = 1 THEN
    DO
        IF GetButton("RIGHT", 0) THEN DO: LOOP UNTIL GetButton("RIGHT", 0) = GetButton.NotFound: LET iloopd = 2: _PUTIMAGE ((resx / 2) + (35 / 2), (resy / 2) - (15 / 2) + 31), arrowrs: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF GetButton("LEFT", 0) THEN DO: LOOP UNTIL GetButton("LEFT", 0) = GetButton.NotFound: LET iloopd = 1: _PUTIMAGE ((resx / 2) - 35, (resy / 2) - (15 / 2) + 31), arrowls: _DELAY 0.1: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF GetButton("BACK", 0) THEN DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound: LET iloopd = 0: CLS: _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen: RETURN
        IF GetButton("USE", 0) THEN
            DO: LOOP UNTIL GetButton("USE", 0) = GetButton.NotFound
            LET iselect = 1: GOSUB combineattempt: CLS: GOTO game
        END IF
    LOOP
END IF
combineattempt:
REM attempts to combine items
OPEN iloc$ + cditem$ + "-p.ddf" FOR INPUT AS #3
INPUT #3, ctalkline1$, ctalkline2$, ctalkline3$, ctalkline4$, ctalkline5$, ctalkline6$, ccitem1$, ccitem2$, ccitem3$
CLOSE #3
IF ccitem1$ = ditem$ THEN GOSUB combineinv: LET escapeinvinv = 1: RETURN
IF ccitem2$ = ditem$ THEN GOSUB combineinv: LET escapeinvinv = 1: RETURN
IF ccitem3$ = ditem$ THEN GOSUB combineinv: LET escapeinvinv = 1: RETURN
REM using item with item (FAILURE)
REM aprostraphie searcher ;)
LET afinder1 = 0
LET afinder1% = INSTR(afinder1% + 1, ditem$, "'")
IF afinder1% THEN LET afinder1 = 1
LET afinder2 = 0
LET afinder2% = INSTR(afinder2% + 1, cditem$, "'")
IF afinder2% THEN LET afinder2 = 1
LET objecttype = 1
GOSUB noline
LET talker$ = "YOU"
IF afinder1 = 0 THEN LET talkline1$ = "I can't use the " + ditem$
IF afinder1 = 1 THEN LET talkline1$ = "I can't use " + ditem$
IF afinder2 = 0 THEN LET talkline2$ = "with the " + cditem$
IF afinder2 = 1 THEN LET talkline2$ = "with " + cditem$
LET talkline3$ = ""
LET talkline4$ = defnoline$
LET talkline5$ = ""
LET talkline6$ = ""
GOSUB talkscreen
CLS
_PUTIMAGE (-resx, -resy)-(resx, resy), invscreen
LET escapeinvinv = 1
RETURN
combineinv:
REM inventory item combination sucess
OPEN iloc$ + cditem$ + ".ddf" FOR OUTPUT AS #4
PRINT #4, 2
CLOSE #4
OPEN iloc$ + ditem$ + ".ddf" FOR OUTPUT AS #5
PRINT #5, 2
CLOSE #5
OPEN iloc$ + "combinv.ddf" FOR INPUT AS #6
INPUT #6, comb1$, combr1$, comb2$, combr2$, comb3$, combr3$, comb4$, combr4$, comb5$, combr5$, comb6$, combr6$, comb7$, combr7$, comb8$, combr8$, comb9$, combr9$, comb10$, combr10$, comb11$, combr11$, comb12$, combr12$, comb13$, combr13$
CLOSE #6
IF cditem$ + ditem$ = comb1$ THEN LET givenitem$ = combr1$
IF cditem$ + ditem$ = comb2$ THEN LET givenitem$ = combr2$
IF cditem$ + ditem$ = comb3$ THEN LET givenitem$ = combr3$
IF cditem$ + ditem$ = comb4$ THEN LET givenitem$ = combr4$
IF cditem$ + ditem$ = comb5$ THEN LET givenitem$ = combr5$
IF cditem$ + ditem$ = comb6$ THEN LET givenitem$ = combr6$
IF cditem$ + ditem$ = comb7$ THEN LET givenitem$ = combr7$
IF cditem$ + ditem$ = comb8$ THEN LET givenitem$ = combr8$
IF cditem$ + ditem$ = comb9$ THEN LET givenitem$ = combr9$
IF cditem$ + ditem$ = comb10$ THEN LET givenitem$ = combr10$
IF cditem$ + ditem$ = comb11$ THEN LET givenitem$ = combr11$
IF cditem$ + ditem$ = comb12$ THEN LET givenitem$ = combr12$
IF cditem$ + ditem$ = comb13$ THEN LET givenitem$ = combr13$
LET grabbed = _LOADIMAGE(iloc$ + givenitem$ + ".png")
OPEN iloc$ + givenitem$ + ".ddf" FOR OUTPUT AS #6
PRINT #6, 1
CLOSE #6
CLS
_PUTIMAGE (-resx, -resy)-(resx, resy), invscreen
REM aprostraphie searcher ;)
LET afinder = 0
LET afinder% = INSTR(afinder% + 1, givenitem$, "'")
IF afinder% THEN LET afinder = 1
IF afinder = 0 THEN PRINT "You got the "; givenitem$
IF afinder = 1 THEN PRINT "You got "; givenitem$
PRINT: PRINT "..."
IF gamepad = 1 THEN PRINT "(press back)"
_PUTIMAGE (resx - 35, resy - 41), grabbed
LET pocketnos = pocketnos - 1
LET soundfile$ = "pickup": GOSUB audio
IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
IF gamepad = 1 THEN
    DO: LOOP UNTIL GetButton("BACK", 0)
    DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
END IF
_FREEIMAGE grabbed
CLS
RETURN

usecredits:
REM gives credits to character (attempt)
REM usechecker?
ON ERROR GOTO resume1
IF objecttype = 4 OR objecttype = 5 OR objecttype = 6 OR objecttype = 7 THEN
    OPEN oloc$ + mapdir$ + "\object5\" + selectitem$ + "5.ddf" FOR INPUT AS #666
    INPUT #666, ob555
    CLOSE #666
    IF ob555 = 1 THEN
        IF objecttype = 1 OR objecttype = 2 OR objecttype = 7 THEN GOTO rejectcheat1
        IF objecttype = 3 OR objecttype = 4 OR objecttype = 5 OR objecttype = 6 THEN
            OPEN oloc$ + mapdir$ + "\" + selectitem$ + ".ddf" FOR INPUT AS #11
            INPUT #11, throwaway1, throwaway1$, throwaway2$, throwaway3$, throwaway4$, throwaway5$, throwaway6$, throwaway7$, nochat1$, nochat2$, nochat3$, nochat4$, nochat5$, nochat6$, throwaway2, throwaway3
            CLOSE #11
            LET talker$ = selectitem$
            LET talkline1$ = nochat1$
            LET talkline2$ = nochat2$
            LET talkline3$ = nochat3$
            LET talkline4$ = nochat4$
            LET talkline5$ = nochat5$
            LET talkline6$ = nochat6$
            GOSUB talkscreen
            LET escapeinv = 1
            RETURN
        END IF
    END IF
END IF
resume1:
OPEN oloc$ + mapdir$ + "\creditcomb.ddf" FOR INPUT AS #10
INPUT #10, ccomb1$, ccomb2$, ccomb3$, am1, am2, am3
CLOSE #10
IF selectitem$ = ccomb1$ THEN LET am = am1: GOSUB useusecredits: LET escapeinv = 1: RETURN
IF selectitem$ = ccomb2$ THEN LET am = am2: GOSUB useusecredits: LET escapeinv = 1: RETURN
IF selectitem$ = ccomb3$ THEN LET am = am3: GOSUB useusecredits: LET escapeinv = 1: RETURN
IF objecttype = 3 OR objecttype = 4 OR objecttype = 5 OR objecttype = 6 THEN
    OPEN oloc$ + mapdir$ + "\" + selectitem$ + "-p.ddf" FOR INPUT AS #11
    INPUT #11, nochat1$, nochat2$, nochat3$, nochat4$, nochat5$, nochat6$
    CLOSE #11
    LET talker$ = selectitem$
    LET talkline1$ = nochat1$
    LET talkline2$ = nochat2$
    LET talkline3$ = nochat3$
    LET talkline4$ = nochat4$
    LET talkline5$ = nochat5$
    LET talkline6$ = nochat6$
    GOSUB talkscreen
    LET rejectcredit = 1
    LET escapeinv = 1
    RETURN
END IF
rejectcheat1:
REM _PUTIMAGE (-resx, -resy)-(resx, resy), invscreen
GOSUB numberremover
REM aprostraphie searcher ;)
LET afinder = 0
LET afinder% = INSTR(afinder% + 1, ditem$, "'")
IF afinder% THEN LET afinder = 1
LET objecttype = 1
GOSUB noline
LET talker$ = "YOU"
IF afinder = 0 THEN LET talkline1$ = "I can't use the " + ditem$
IF afinder = 1 THEN LET talkline1$ = "I can't use " + ditem$
LET talkline2$ = "with the " + selectitem$
LET talkline3$ = ""
LET talkline4$ = defnoline$
LET talkline5$ = ""
LET talkline6$ = ""
GOSUB talkscreen
GOSUB numberadder
LET rejectcredit = 1
LET escapeinv = 1
RETURN

nocredit:
REM not enough credits
LET objecttype = 1
LET talker$ = "YOU"
LET talkline1$ = "I don't have enough"
LET talkline2$ = "credits."
LET talkline3$ = ""
LET talkline4$ = ":("
LET talkline5$ = ""
LET talkline6$ = ""
GOSUB talkscreen
CLS
RETURN

alreadyusedcredits:
REM already used credits to purchase item (prevents purchase of duplicate items)
LET obmap$ = oloc$
OPEN obmap$ + mapdir$ + "\" + object$ + ".ddf" FOR INPUT AS #1
INPUT #1, objecttype, objectdescript1$, objectdescript2$, objectdescript3$, objectdescript4$, objectdescript5$, objectdescript6$, containitem$, aobjectdescript1$, aobjectdescript2$, aobjectdescript3$, aobjectdescript4$, aobjectdescript5$, aobjectdescript6$
CLOSE #1
LET talker$ = selectitem$
LET talkline1$ = aobjectdescript1$
LET talkline2$ = aobjectdescript2$
LET talkline3$ = aobjectdescript3$
LET talkline4$ = aobjectdescript4$
LET talkline5$ = aobjectdescript5$
LET talkline6$ = aobjectdescript6$
GOSUB talkscreen
RETURN

useusecredits:
REM give credits to character (sucess(ish))
IF credits - am < 0 THEN GOSUB nocredit: RETURN
LET credits = credits - am
REM SCRIPT ITEMS
LET noterminal = 1
LET tselect$ = selectitem$ + ditem$: GOSUB script
LET noterminal = 0
OPEN oloc$ + mapdir$ + "\object5\" + selectitem$ + "5.ddf" FOR INPUT AS #5
INPUT #5, obj5stat
CLOSE #5
IF obj5stat = 1 THEN GOSUB alreadyusedcredits: RETURN
LET obj5stat = 1
OPEN oloc$ + mapdir$ + "\object5\" + selectitem$ + "5.ddf" FOR OUTPUT AS #6
PRINT #6, obj5stat
CLOSE #6
OPEN oloc$ + mapdir$ + "\" + selectitem$ + "5.ddf" FOR INPUT AS #7
INPUT #7, ob5talk1$, ob5talk2$, ob5talk3$, ob5talk4$, ob5talk5$, ob5talk6$
CLOSE #7
LET talkline1$ = ob5talk1$
LET talkline2$ = ob5talk2$
LET talkline3$ = ob5talk3$
LET talkline4$ = ob5talk4$
LET talkline5$ = ob5talk5$
LET talkline6$ = ob5talk6$
LET talker$ = selectitem$
IF objecttype = 7 THEN LET talker$ = "YOU"
GOSUB talkscreen
REM item gain screen
IF scripttype = 2 THEN
    LET scrscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
    CLS
    _PUTIMAGE (-resx, -resy)-(resx, resy), scrscreen
    REM aprostraphie searcher ;)
    LET afinder = 0
    LET afinder% = INSTR(afinder% + 1, scriptitem$, "'")
    IF afinder% THEN LET afinder = 1
    IF afinder = 0 THEN PRINT "You got the "; scriptitem$
    IF afinder = 1 THEN PRINT "You got "; scriptitem$
    PRINT: PRINT "..."
    IF gamepad = 1 THEN PRINT "(press back)"
    _PUTIMAGE (resx - 35, resy - 41), grabbed
    LET pocketnos = pocketnos + 1
    LET soundfile$ = "pickup": GOSUB audio
    IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
    IF gamepad = 1 THEN
        DO: LOOP UNTIL GetButton("BACK", 0)
        DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
    END IF
    _FREEIMAGE grabbed: _FREEIMAGE scrscreen
END IF
REM removes credit inventory item if credits at zero
IF credits <= 0 THEN
    OPEN iloc$ + "credits.ddf" FOR OUTPUT AS #8
    PRINT #8, 0
    CLOSE #8
    LET pocketnos = pocketnos - 1
END IF
RETURN

giveexceptions:
REM giveitem exceptions
IF selectitem$ = "REECE" THEN
    IF mapno = 31 THEN IF ditem$ <> "ship pass" THEN LET except = 1
    IF mapno = 32 THEN IF ditem$ <> "fake crew pass" THEN LET except = 1
END IF
IF selectitem$ = "MARINE" THEN
    IF mapno = 6 THEN IF ditem$ = "lamb's t-card" THEN LET except = 1
    IF mapno = 13 THEN IF ditem$ = "uniform" THEN LET except = 1
END IF
IF selectitem$ = "VOODOO" THEN
    IF mapno = 29 THEN IF ditem$ = "gun" THEN LET except = 1
END IF
IF except = 1 THEN
    OPEN oloc$ + mapdir$ + "\" + selectitem$ + "-p.ddf" FOR INPUT AS #10
    INPUT #10, nochat1$, nochat2$, nochat3$, nochat4$, nochat5$, nochat6$
    CLOSE #10
    LET talker$ = selectitem$
    LET talkline1$ = nochat1$
    LET talkline2$ = nochat2$
    LET talkline3$ = nochat3$
    LET talkline4$ = nochat4$
    LET talkline5$ = nochat5$
    LET talkline6$ = nochat6$
    GOSUB talkscreen
    LET escapeinv = 1
END IF
RETURN

giveitem:
REM gives invenory item to character
GOSUB giveexceptions: REM exceptions
IF except = 1 THEN RETURN
OPEN oloc$ + mapdir$ + "\object5\" + selectitem$ + "5.ddf" FOR INPUT AS #5
INPUT #5, obj5stat
CLOSE #5
IF obj5stat = 1 THEN GOSUB alreadyusedcredits: RETURN
LET obj5stat = 1
OPEN oloc$ + mapdir$ + "\object5\" + selectitem$ + "5.ddf" FOR OUTPUT AS #6
PRINT #6, obj5stat
CLOSE #6
OPEN oloc$ + mapdir$ + "\" + selectitem$ + "5.ddf" FOR INPUT AS #7
INPUT #7, ob5talk1$, ob5talk2$, ob5talk3$, ob5talk4$, ob5talk5$, ob5talk6$
CLOSE #7
IF objecttype = 5 OR objecttype = 7 OR objecttype = 8 THEN
    OPEN iloc$ + ditem$ + ".ddf" FOR OUTPUT AS #8
    PRINT #8, 2
    CLOSE #8
    LET pocketnos = pocketnos - 1
END IF
REM SCRIPT ITEMS
LET noterminal = 1
LET tselect$ = selectitem$ + ditem$: GOSUB script
LET noterminal = 0
LET talkline1$ = ob5talk1$
LET talkline2$ = ob5talk2$
LET talkline3$ = ob5talk3$
LET talkline4$ = ob5talk4$
LET talkline5$ = ob5talk5$
LET talkline6$ = ob5talk6$
LET talker$ = selectitem$
IF objecttype = 7 THEN LET talker$ = "YOU"
GOSUB talkscreen
REM item gain screen
IF scriptitem$ <> "" THEN
    IF scripttype = 2 OR scripttype = 4 THEN
        LET talkscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
        CLS
        _PUTIMAGE (-resx, -resy)-(resx, resy), talkscreen
        IF scripttype = 2 THEN
            REM aprostraphie searcher ;)
            LET afinder = 0
            LET afinder% = INSTR(afinder% + 1, scriptitem$, "'")
            IF afinder% THEN LET afinder = 1
            IF afinder = 0 THEN PRINT "You got the "; scriptitem$
            IF afinder = 1 THEN PRINT "You got "; scriptitem$
        END IF
        IF scripttype = 4 THEN PRINT "You got "; spara; " credits."
        PRINT: PRINT "..."
        IF gamepad = 1 THEN PRINT "(press back)"
        _PUTIMAGE (resx - 35, resy - 41), grabbed
        LET pocketnos = pocketnos + 1
        LET soundfile$ = "pickup": GOSUB audio
        IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
        IF gamepad = 1 THEN
            DO: LOOP UNTIL GetButton("BACK", 0)
            DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
        END IF
        _FREEIMAGE grabbed
        _FREEIMAGE talkscreen
        CLS
    END IF
END IF
REM map changer
IF scripttype = 7 THEN
    GOSUB mapload
    GOSUB redraw
END IF
REM map c technology
IF mapcd = 1 THEN
    _FREEIMAGE map: _FREEIMAGE mapb
    LET map = _LOADIMAGE(mloc$ + mapfile$ + "c.png")
    LET mapb = _LOADIMAGE(mloc$ + mapfile$ + "bc.png")
    LET itemno = itemno - 1
    LET mapc = 1
    OPEN mloc$ + "c" + mapdir$ + ".ddf" FOR OUTPUT AS #3
    PRINT #3, mapc
    CLOSE #3
    LET mapcd = 0
END IF
RETURN

terminal:
REM terminal sub
REM image + variable loading
LET tani1 = _LOADIMAGE(tloc$ + "tani1.png")
LET tani2 = _LOADIMAGE(tloc$ + "tani2.png")
LET tani3 = _LOADIMAGE(tloc$ + "tani3.png")
LET tani4 = _LOADIMAGE(tloc$ + "tani4.png")
LET tani5 = _LOADIMAGE(tloc$ + "tani5.png")
LET tfile = _LOADIMAGE(tloc$ + "file.png")
LET tdir = _LOADIMAGE(tloc$ + "dir.png")
LET tno = _LOADIMAGE(tloc$ + "nodata.png")
LET tscript = _LOADIMAGE(tloc$ + "script.png")
LET tselectn = _LOADIMAGE(tloc$ + "selectn.png")
LET tselectd = _LOADIMAGE(tloc$ + "selectd.png")
LET tselectf = _LOADIMAGE(tloc$ + "selectf.png")
LET sysok = _LOADIMAGE(tloc$ + "sysok.png")
LET sysbusy = _LOADIMAGE(tloc$ + "sysbusy.png")
LET syserr = _LOADIMAGE(tloc$ + "syserr.png")
LET mmplay = _LOADIMAGE(tloc$ + "play.png")
LET mmmusic = _LOADIMAGE(tloc$ + "music.png")
LET mmtoggle = _LOADIMAGE(tloc$ + "toggle.png")
LET mmclear = _LOADIMAGE(tloc$ + "clear.png")
LET mmquit = _LOADIMAGE(tloc$ + "quit.png")
LET mmpad = _LOADIMAGE(tloc$ + "pad.png")
OPEN tloc$ + "terminal.ddf" FOR INPUT AS #1
INPUT #1, tos$
CLOSE #1
IF mapno = 0 THEN LET mapdir$ = "mainmenu"
IF mapdir$ = "mainmenu" THEN LET tos$ = "game menu": LET musicfile$ = "menu": GOSUB playmusic
OPEN tloc$ + mapdir$ + ".ddf" FOR INPUT AS #2
INPUT #2, ct1, cn1$, ct2, cn2$, ct3, cn3$, ct4, cn4$, ct5, cn5$, ct6, cn6$
CLOSE #2
LET tdelay = .5
LET stposx = 30: LET stposy = 50
REM opening animation loop
IF mapdir$ = "mainmenu" THEN GOTO taniskip1
CLS
LET soundfile$ = "t-on": GOSUB audio
FOR tloop = 1 TO 5
    IF tloop = 1 THEN _PUTIMAGE (30, 10)-(resx - 30, resy - 10), tani1
    IF tloop = 2 THEN _PUTIMAGE (30, 10)-(resx - 30, resy - 10), tani2
    IF tloop = 3 THEN _PUTIMAGE (30, 10)-(resx - 30, resy - 10), tani3
    IF tloop = 4 THEN _PUTIMAGE (30, 10)-(resx - 30, resy - 10), tani4
    _DELAY 0.2
NEXT tloop
taniskip1:
REM free animation images
_FREEIMAGE tani1: _FREEIMAGE tani2: _FREEIMAGE tani3: _FREEIMAGE tani4
REM terminal menu loop
termloop:
CLS
IF mapdir$ <> "mainmenu" THEN _PUTIMAGE (70, 120), sysbusy
PRINT tos$
IF mapdir$ <> "mainmenu" THEN
    IF ct1 = 0 THEN _PUTIMAGE (30, 50), tno
    IF ct1 = 1 THEN _PUTIMAGE (30, 50), tfile
    IF ct1 = 2 THEN _PUTIMAGE (30, 50), tdir
    IF ct1 = 3 THEN _PUTIMAGE (30, 50), tscript
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct2 = 0 THEN _PUTIMAGE (70, 50), tno
    IF ct2 = 1 THEN _PUTIMAGE (70, 50), tfile
    IF ct2 = 2 THEN _PUTIMAGE (70, 50), tdir
    IF ct2 = 3 THEN _PUTIMAGE (70, 50), tscript
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct3 = 0 THEN _PUTIMAGE (110, 50), tno
    IF ct3 = 1 THEN _PUTIMAGE (110, 50), tfile
    IF ct3 = 2 THEN _PUTIMAGE (110, 50), tdir
    IF ct3 = 3 THEN _PUTIMAGE (110, 50), tscript
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct4 = 0 THEN _PUTIMAGE (30, 90), tno
    IF ct4 = 1 THEN _PUTIMAGE (30, 90), tfile
    IF ct4 = 2 THEN _PUTIMAGE (30, 90), tdir
    IF ct4 = 3 THEN _PUTIMAGE (30, 90), tscript
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct5 = 0 THEN _PUTIMAGE (70, 90), tno
    IF ct5 = 1 THEN _PUTIMAGE (70, 90), tfile
    IF ct5 = 2 THEN _PUTIMAGE (70, 90), tdir
    IF ct5 = 3 THEN _PUTIMAGE (70, 90), tscript
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct6 = 0 THEN _PUTIMAGE (110, 90), tno
    IF ct6 = 1 THEN _PUTIMAGE (110, 90), tfile
    IF ct6 = 2 THEN _PUTIMAGE (110, 90), tdir
    IF ct6 = 3 THEN _PUTIMAGE (110, 90), tscript
    _DELAY tdelay
END IF
IF mapdir$ = "mainmenu" THEN
    IF screenmode = 1 THEN
        REM fullscreen (displays 'window')
        IF cn1$ = "FULLSCREEN" THEN LET cn1$ = "WINDOW"
        IF cn2$ = "FULLSCREEN" THEN LET cn2$ = "WINDOW"
        IF cn3$ = "FULLSCREEN" THEN LET cn3$ = "WINDOW"
        IF cn4$ = "FULLSCREEN" THEN LET cn4$ = "WINDOW"
        IF cn5$ = "FULLSCREEN" THEN LET cn5$ = "WINDOW"
    END IF
    IF musicon = 1 THEN
        REM music (displays 'music + SFX')
        IF cn1$ = "MUSIC" THEN LET cn1$ = "MUSIC + SFX"
        IF cn2$ = "MUSIC" THEN LET cn2$ = "MUSIC + SFX"
        IF cn3$ = "MUSIC" THEN LET cn3$ = "MUSIC + SFX"
        IF cn4$ = "MUSIC" THEN LET cn4$ = "MUSIC + SFX"
        IF cn5$ = "MUSIC" THEN LET cn5$ = "MUSIC + SFX"
    END IF
    IF musicon = 2 THEN
        REM music (displays 'sfx')
        IF cn1$ = "MUSIC" THEN LET cn1$ = "SFX ONLY"
        IF cn2$ = "MUSIC" THEN LET cn2$ = "SFX ONLY"
        IF cn3$ = "MUSIC" THEN LET cn3$ = "SFX ONLY"
        IF cn4$ = "MUSIC" THEN LET cn4$ = "SFX ONLY"
        IF cn5$ = "MUSIC" THEN LET cn5$ = "SFX ONLY"
    END IF
    IF musicon = 3 THEN
        REM music (displays 'mute')
        IF cn1$ = "MUSIC" THEN LET cn1$ = "MUTE"
        IF cn2$ = "MUSIC" THEN LET cn2$ = "MUTE"
        IF cn3$ = "MUSIC" THEN LET cn3$ = "MUTE"
        IF cn4$ = "MUSIC" THEN LET cn4$ = "MUTE"
        IF cn5$ = "MUSIC" THEN LET cn5$ = "MUTE"
    END IF
    IF musicon = 0 THEN
        REM music (displays 'music')
        IF cn1$ = "MUSIC" THEN LET cn1$ = "MUSIC ONLY"
        IF cn2$ = "MUSIC" THEN LET cn2$ = "MUSIC ONLY"
        IF cn3$ = "MUSIC" THEN LET cn3$ = "MUSIC ONLY"
        IF cn4$ = "MUSIC" THEN LET cn4$ = "MUSIC ONLY"
        IF cn5$ = "MUSIC" THEN LET cn5$ = "MUSIC ONLY"
    END IF
    IF ct1 = 0 THEN _PUTIMAGE (30, 50), tno
    IF ct1 = 1 THEN _PUTIMAGE (30, 50), mmplay
    IF ct1 = 2 THEN _PUTIMAGE (30, 50), mmtoggle
    IF ct1 = 3 THEN _PUTIMAGE (30, 50), mmclear
    IF ct1 = 4 THEN _PUTIMAGE (30, 50), mmquit
    IF ct1 = 5 THEN _PUTIMAGE (30, 50), mmpad
    IF ct1 = 6 THEN _PUTIMAGE (30, 50), mmmusic
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct2 = 0 THEN _PUTIMAGE (70, 50), tno
    IF ct2 = 1 THEN _PUTIMAGE (70, 50), mmplay
    IF ct2 = 2 THEN _PUTIMAGE (70, 50), mmtoggle
    IF ct2 = 3 THEN _PUTIMAGE (70, 50), mmclear
    IF ct2 = 4 THEN _PUTIMAGE (70, 50), mmquit
    IF ct2 = 5 THEN _PUTIMAGE (70, 50), mmpad
    IF ct2 = 6 THEN _PUTIMAGE (70, 50), mmmusic
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct3 = 0 THEN _PUTIMAGE (110, 50), tno
    IF ct3 = 1 THEN _PUTIMAGE (110, 50), mmplay
    IF ct3 = 2 THEN _PUTIMAGE (110, 50), mmtoggle
    IF ct3 = 3 THEN _PUTIMAGE (110, 50), mmclear
    IF ct3 = 4 THEN _PUTIMAGE (110, 50), mmquit
    IF ct3 = 5 THEN _PUTIMAGE (110, 50), mmpad
    IF ct3 = 6 THEN _PUTIMAGE (110, 50), mmmusic
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct4 = 0 THEN _PUTIMAGE (30, 90), tno
    IF ct4 = 1 THEN _PUTIMAGE (30, 90), mmplay
    IF ct4 = 2 THEN _PUTIMAGE (30, 90), mmtoggle
    IF ct4 = 3 THEN _PUTIMAGE (30, 90), mmclear
    IF ct4 = 4 THEN _PUTIMAGE (30, 90), mmquit
    IF ct4 = 5 THEN _PUTIMAGE (30, 90), mmpad
    IF ct4 = 6 THEN _PUTIMAGE (30, 90), mmmusic
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct5 = 0 THEN _PUTIMAGE (70, 90), tno
    IF ct5 = 1 THEN _PUTIMAGE (70, 90), mmplay
    IF ct5 = 2 THEN _PUTIMAGE (70, 90), mmtoggle
    IF ct5 = 3 THEN _PUTIMAGE (70, 90), mmclear
    IF ct5 = 4 THEN _PUTIMAGE (70, 90), mmquit
    IF ct5 = 5 THEN _PUTIMAGE (70, 90), mmpad
    IF ct5 = 6 THEN _PUTIMAGE (70, 90), mmmusic
    _DELAY tdelay: LET tdelay = tdelay / 2
    IF ct6 = 0 THEN _PUTIMAGE (110, 90), tno
    IF ct6 = 1 THEN _PUTIMAGE (110, 90), mmplay
    IF ct6 = 2 THEN _PUTIMAGE (110, 90), mmtoggle
    IF ct6 = 3 THEN _PUTIMAGE (110, 90), mmclear
    IF ct6 = 4 THEN _PUTIMAGE (110, 90), mmquit
    IF ct6 = 5 THEN _PUTIMAGE (110, 90), mmpad
    IF ct6 = 6 THEN _PUTIMAGE (110, 90), mmmusic
    _DELAY tdelay
END IF
IF stposx = 30 AND stposy = 50 THEN LET ttype = ct1: LET tselect$ = cn1$
IF stposx = 70 AND stposy = 50 THEN LET ttype = ct2: LET tselect$ = cn2$
IF stposx = 110 AND stposy = 50 THEN LET ttype = ct3: LET tselect$ = cn3$
IF stposx = 30 AND stposy = 90 THEN LET ttype = ct4: LET tselect$ = cn4$
IF stposx = 70 AND stposy = 90 THEN LET ttype = ct5: LET tselect$ = cn5$
IF stposx = 110 AND stposy = 90 THEN LET ttype = ct6: LET tselect$ = cn6$
LET tdelay = 0
IF mapdir$ <> "mainmenu" THEN
    IF ttype = 1 THEN PRINT "file - "; tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectf
    IF ttype = 2 THEN PRINT "folder - "; tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectd
    IF ttype = 3 THEN PRINT "script - "; tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectf
    IF ttype = 0 THEN PRINT "no data": _PUTIMAGE (stposx - 1, stposy - 1), tselectn
END IF
IF mapdir$ = "mainmenu" THEN
    IF tselect$ = "PLAY" THEN
        IF charmodel$ = "none" THEN LET tselect$ = "NEW GAME"
        IF charmodel$ <> "none" THEN LET tselect$ = "RESUME"
    END IF
    IF ttype = 1 THEN PRINT tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectf
    IF ttype = 2 THEN PRINT tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectn
    IF ttype = 3 THEN PRINT tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectn
    IF ttype = 4 THEN PRINT tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectn
    IF ttype = 5 THEN PRINT tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectf
    IF ttype = 6 THEN PRINT tselect$: _PUTIMAGE (stposx - 1, stposy - 1), tselectf
END IF
IF mapdir$ <> "mainmenu" THEN _PUTIMAGE (70, 120), sysok
REM input loop
DO
    LET t$ = UCASE$(INKEY$): REM terminal user input
    IF t$ = CHR$(0) + CHR$(72) THEN LET stposy = 50: GOTO termloop: REM up
    IF t$ = CHR$(0) + CHR$(80) THEN LET stposy = 90: GOTO termloop: REM down
    IF gamepad = 1 THEN
        IF GetButton("UP", 0) THEN LET stposy = 50: DO: LOOP UNTIL GetButton("UP", 0) = GetButton.NotFound: GOTO termloop: REM gamepad up
        IF GetButton("DOWN", 0) THEN LET stposy = 90: DO: LOOP UNTIL GetButton("DOWN", 0) = GetButton.NotFound: GOTO termloop: REM gamepad down
    END IF
    REM left
    IF gamepad = 1 THEN
        IF GetButton("LEFT", 0) THEN
            DO: LOOP UNTIL GetButton("LEFT", 0) = GetButton.NotFound:
            IF stposx = 30 THEN LET stposx = 30: GOTO termloop
            IF stposx = 70 THEN LET stposx = 30: GOTO termloop
            IF stposx = 110 THEN LET stposx = 70: GOTO termloop
        END IF
    END IF
    IF t$ = CHR$(0) + CHR$(75) THEN
        IF stposx = 30 THEN LET stposx = 30: GOTO termloop
        IF stposx = 70 THEN LET stposx = 30: GOTO termloop
        IF stposx = 110 THEN LET stposx = 70: GOTO termloop
    END IF
    REM right
    IF gamepad = 1 THEN
        IF GetButton("RIGHT", 0) THEN
            DO: LOOP UNTIL GetButton("RIGHT", 0) = GetButton.NotFound:
            IF stposx = 30 THEN LET stposx = 70: GOTO termloop
            IF stposx = 70 THEN LET stposx = 110: GOTO termloop
            IF stposx = 110 THEN LET stposx = 110: GOTO termloop
        END IF
    END IF
    IF t$ = CHR$(0) + CHR$(77) THEN
        IF stposx = 30 THEN LET stposx = 70: GOTO termloop
        IF stposx = 70 THEN LET stposx = 110: GOTO termloop
        IF stposx = 110 THEN LET stposx = 110: GOTO termloop
    END IF
    REM use
    IF gamepad = 1 THEN IF GetButton("USE", 0) THEN DO: LOOP UNTIL GetButton("USE", 0) = GetButton.NotFound: GOTO termpaduse
    IF t$ = " " THEN
        REM main menu
        termpaduse:
        IF tselect$ = "PLAY" OR tselect$ = "RESUME" OR tselect$ = "NEW GAME" THEN CLS: RETURN
        IF tselect$ = "CLEAR SAVE" THEN
            GOSUB cleardata
            CLEAR
            GOTO setup
        END IF
        IF tselect$ = "MUSIC ONLY" OR tselect$ = "MUTE" OR tselect$ = "MUSIC + SFX" OR tselect$ = "SFX ONLY" THEN
            IF musicon = 1 THEN
                LET musicon = 2: GOSUB musictoggle: GOTO termloop
            END IF
            IF musicon = 2 THEN
                LET musicon = 3: _SNDSTOP musix: _SNDCLOSE musix: GOSUB musictoggle: GOTO termloop
            END IF
            IF musicon = 3 THEN
                LET musicon = 0: GOSUB musictoggle: GOTO termloop
            END IF
            IF musicon = 0 THEN
                LET musicon = 1: LET cmusicfile$ = "": GOSUB playmusic: GOSUB musictoggle: GOTO termloop
            END IF
        END IF
        IF tselect$ = "FULLSCREEN" OR tselect$ = "WINDOW" THEN GOSUB toggle: GOTO termloop
        REM THE REST
        IF tselect$ = "QUIT" THEN GOTO endgame
        IF tselect$ = "PAD SETUP" THEN LET dev = 3: GOSUB padsetup: GOTO termloop
        REM file type
        IF ttype = 1 THEN
            LET findtxt = 0: findtxt = INSTR(findtxt + 1, tselect$, ".TXT"): IF findtxt THEN GOSUB readtxt
            GOTO termloop
        END IF
        REM directory type
        IF ttype = 2 THEN GOSUB directory: GOTO termloop
        REM script type
        IF ttype = 3 THEN
            IF tselect$ = "EXIT.H" THEN GOTO endterm
            LET tselect$ = LCASE$(tselect$)
            GOSUB script
            GOTO termloop
        END IF
    END IF
LOOP
endterm:
CLS
_FREEIMAGE mmmusic: _FREEIMAGE mmplay: _FREEIMAGE mmtoggle: _FREEIMAGE mmclear: _FREEIMAGE mmquit: _FREEIMAGE sysok: _FREEIMAGE sysbusy: _FREEIMAGE syserr: _FREEIMAGE tfile: _FREEIMAGE tdir: _FREEIMAGE tno: _FREEIMAGE tscript: _FREEIMAGE tselectd: _FREEIMAGE tselectf: _FREEIMAGE tselectn
LET soundfile$ = "t-off": GOSUB audio
GOSUB redraw
RETURN

cleardata:
REM clears save data (overrites data with master data)
REM clear screen
CLS
PRINT "Wait..."
REM stop music
IF musicon = 1 OR musicon = 2 THEN _SNDSTOP musix: _SNDCLOSE musix
IF betaend <> 1 THEN
    REM bloat.fuu
    OPEN dloc$ + "bloat.fuu" FOR OUTPUT AS #1
    PRINT #1, 1
    CLOSE #1
END IF
REM overwrite data
IF ros$ = "win" THEN
    SHELL _HIDE "copy data\i\master\*.* data\i\ /y"
    SHELL _HIDE "copy data\w\master\*.* data\w\ /y"
    SHELL _HIDE "copy data\master\*.* data\ /y"
    SHELL _HIDE "copy data\m\master\*.* data\m\ /y"
END IF
IF ros$ = "lnx" OR ros$ = "mac" THEN
    SHELL _HIDE "cp data/i/master/*.* data/i/"
    SHELL _HIDE "cp data/w/master/*.* data/w/"
    SHELL _HIDE "cp data/master/*.* data/"
    SHELL _HIDE "cp data/m/master/*.* data/m/"
END IF
LET levelno = 1
DO
    IF levelno = 1 THEN LET levelno$ = "m1"
    IF levelno = 2 THEN LET levelno$ = "m2"
    IF levelno = 3 THEN LET levelno$ = "m3"
    IF levelno = 4 THEN LET levelno$ = "m4"
    IF levelno = 5 THEN LET levelno$ = "m5"
    IF levelno = 6 THEN LET levelno$ = "m6"
    IF levelno = 7 THEN LET levelno$ = "m7"
    IF levelno = 8 THEN LET levelno$ = "m8"
    IF levelno = 9 THEN LET levelno$ = "m9"
    IF levelno = 10 THEN LET levelno$ = "m10"
    IF levelno = 11 THEN LET levelno$ = "m11"
    IF levelno = 12 THEN LET levelno$ = "m12"
    IF levelno = 13 THEN LET levelno$ = "m13"
    IF levelno = 14 THEN LET levelno$ = "m14"
    IF levelno = 15 THEN LET levelno$ = "m15"
    IF levelno = 16 THEN LET levelno$ = "m16"
    IF levelno = 17 THEN LET levelno$ = "m17"
    IF levelno = 18 THEN LET levelno$ = "m18"
    IF levelno = 19 THEN LET levelno$ = "m19"
    IF levelno = 20 THEN LET levelno$ = "m20"
    IF levelno = 21 THEN LET levelno$ = "m21"
    IF levelno = 22 THEN LET levelno$ = "m22"
    IF levelno = 23 THEN LET levelno$ = "m23"
    IF levelno = 24 THEN LET levelno$ = "m24"
    IF levelno = 25 THEN LET levelno$ = "m25"
    IF levelno = 26 THEN LET levelno$ = "m26"
    IF levelno = 27 THEN LET levelno$ = "m27"
    IF levelno = 28 THEN LET levelno$ = "m28"
    IF levelno = 29 THEN LET levelno$ = "m29"
    IF levelno = 30 THEN LET levelno$ = "m30"
    IF levelno = 31 THEN LET levelno$ = "m31"
    IF levelno = 32 THEN LET levelno$ = "m32"
    IF levelno = 33 THEN LET levelno$ = "m33"
    IF levelno = 34 THEN LET levelno$ = "m34"
    IF levelno = 35 THEN LET levelno$ = "m35"
    IF levelno = 36 THEN LET levelno$ = "m36"
    IF levelno = 37 THEN LET levelno$ = "m37"
    IF levelno = 38 THEN LET levelno$ = "m38"
    IF levelno = 39 THEN LET levelno$ = "m39"
    IF levelno = 40 THEN LET levelno$ = "m40"
    IF levelno = 41 THEN LET levelno$ = "m41"
    IF levelno = 42 THEN LET levelno$ = "m42"
    IF levelno = 43 THEN LET levelno$ = "m43"
    IF levelno = 44 THEN LET levelno$ = "m44"
    IF levelno = 45 THEN LET levelno$ = "m45"
    IF levelno = 46 THEN LET levelno$ = "m46"
    IF levelno = 47 THEN LET levelno$ = "m47"
    IF levelno = 48 THEN LET levelno$ = "m48"
    IF levelno = 49 THEN LET levelno$ = "m49"
    IF levelno = 50 THEN LET levelno$ = "m50"
    IF levelno = 51 THEN LET levelno$ = "m51"
    IF levelno = 52 THEN LET levelno$ = "m52"
    IF levelno = 53 THEN LET levelno$ = "m53"
    IF levelno = 54 THEN LET levelno$ = "m54"
    REM IF levelno = 55 THEN LET levelno$ = "m55"
    REM IF levelno = 56 THEN LET levelno$ = "m56"
    REM IF levelno = 57 THEN LET levelno$ = "m57"
    REM IF levelno = 58 THEN LET levelno$ = "m58"
    REM IF levelno = 59 THEN LET levelno$ = "m59"
    REM IF levelno = 60 THEN LET levelno$ = "m60"
    REM IF levelno = 61 THEN LET levelno$ = "m61"
    REM IF levelno = 62 THEN LET levelno$ = "m62"
    REM IF levelno = 63 THEN LET levelno$ = "m63"
    REM IF levelno = 64 THEN LET levelno$ = "m64"
    IF ros$ = "win" THEN SHELL _HIDE "copy data\o\" + levelno$ + "\object5\master\*.* data\o\" + levelno$ + "\object5\ /y"
    IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "cp data/o/" + levelno$ + "/object5/master/*.* data/o/" + levelno$ + "/object5/"
    LET levelno = levelno + 1
LOOP UNTIL levelno > 54
ON ERROR GOTO gamepadskip
IF betaend <> 1 THEN KILL "data\gamepad.ddf"
gamepadskip:
LET tselect$ = "cleardata.txt"
GOSUB keycatcher
IF betaend <> 1 THEN GOSUB readtxt
RETURN

playmusic:
REM music management sub
IF musicon = 1 OR musicon = 2 THEN
    IF musicfile$ <> cmusicfile$ THEN
        CLS
        PRINT "wait..."
        IF cmusicfile$ <> "" THEN _SNDSTOP musix: _SNDCLOSE musix
        LET musix = _SNDOPEN(aloc$ + musicfile$ + ".ogg", "vol")
        _SNDVOL musix, 0.5
        _SNDLOOP musix
        LET cmusicfile$ = musicfile$
        CLS
    END IF
END IF
IF musicon = 0 THEN LET cmusicfile$ = ""
RETURN

script:
REM Script sub
LET scriptname$ = LCASE$(tselect$)
OPEN tloc$ + "script\" + scriptname$ + ".ddf" FOR INPUT AS #2
INPUT #2, scripttype, spara, scriptitem$, mapcd
CLOSE #2
REM activate warp
IF scripttype = 1 THEN
    OPEN wloc$ + mapdir$ + ".ddf" FOR INPUT AS #3
    INPUT #3, warpnos, warpon1, warpdest1, warpdx1, warpdy1, warpdd1, warpon2, warpdest2, warpdx2, warpdy2, warpdd2, warpon3, warpdest3, warpdx3, warpdy3, warpdd3, warpon4, warpdest4, warpdx4, warpdy4, warpdd4
    CLOSE #3
    IF warpon1 = 1 THEN LET tselect$ = "warpon.txt": GOSUB readtxt: RETURN
    LET warpon1 = 1
    OPEN wloc$ + mapdir$ + ".ddf" FOR OUTPUT AS #4
    PRINT #4, warpnos, warpon1, warpdest1, warpdx1, warpdy1, warpdd1, warpon2, warpdest2, warpdx2, warpdy2, warpdd2, warpon3, warpdest3, warpdx3, warpdy3, warpdd3, warpon4, warpdest4, warpdx4, warpdy4, warpdd4
    CLOSE #4
    IF noterminal = 1 THEN RETURN
    LET tselect$ = "warpoff.txt"
    GOSUB readtxt
END IF
REM give item
IF scripttype = 2 THEN
    LET grabbed = _LOADIMAGE(iloc$ + scriptitem$ + ".png")
    OPEN iloc$ + scriptitem$ + ".ddf" FOR OUTPUT AS #3
    PRINT #3, 1
    CLOSE #3
    IF noterminal = 1 THEN RETURN
    CLS
    LET scrscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
    _PUTIMAGE (-resx, -resy)-(resx, resy), scrscreen
    REM aprostraphie searcher ;)
    LET afinder = 0
    LET afinder% = INSTR(afinder% + 1, scriptitem$, "'")
    IF afinder% THEN LET afinder = 1
    IF afinder = 0 THEN PRINT "You got the "; scriptitem$
    IF afinder = 1 THEN PRINT "You got "; scriptitem$
    IF gamepad = 1 THEN PRINT "(press back)"
    _PUTIMAGE (resx - 35, resy - 41), grabbed
    LET pocketnos = pocketnos + 1
    LET soundfile$ = "pickup": GOSUB audio
    IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
    IF gamepad = 1 THEN
        DO: LOOP UNTIL GetButton("BACK", 0)
        DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
    END IF
    _FREEIMAGE grabbed: _FREEIMAGE scrscreen
END IF
REM credit drop (LAMBs TCARD)
IF scripttype = 3 THEN
    IF ditem$ <> "lamb's t-card" THEN LET tselect$ = "wrongcard.txt": GOSUB readtxt
    IF ditem$ = "lamb's t-card" THEN
        OPEN oloc$ + mapdir$ + "\object5\C-DROP.ddf" FOR INPUT AS #4
        INPUT #4, cdrop
        CLOSE #4
        IF cdrop = 1 THEN LET tselect$ = "nocredit.txt": GOSUB readtxt: RETURN
        LET grabbed = _LOADIMAGE(iloc$ + "credits.png")
        OPEN iloc$ + "credits.ddf" FOR INPUT AS #3
        INPUT #3, meh
        CLOSE #3
        LET credits = credits + spara
        OPEN iloc$ + "credits.ddf" FOR INPUT AS #3
        INPUT #3, creds
        CLOSE #3
        IF creds = 0 THEN
            OPEN iloc$ + "credits.ddf" FOR OUTPUT AS #3
            PRINT #3, 1
            CLOSE #3
            LET pocketnos = pocketnos + 1
        END IF
        OPEN oloc$ + mapdir$ + "\object5\C-DROP.ddf" FOR OUTPUT AS #5
        PRINT #5, 1
        CLOSE #5
        CLS
        LET scrscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
        _PUTIMAGE (-resx, -resy)-(resx, resy), scrscreen
        PRINT "You got "; spara; " credits"
        PRINT: PRINT "..."
        IF gamepad = 1 THEN PRINT "(press back)"
        _PUTIMAGE (resx - 35, resy - 41), grabbed
        LET pocketnos = pocketnos + 1
        LET soundfile$ = "pickup": GOSUB audio
        IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
        IF gamepad = 1 THEN
            DO: LOOP UNTIL GetButton("BACK", 0)
            DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
        END IF
    END IF
END IF
REM credit drop (CHARACTER)
IF scripttype = 4 THEN
    LET grabbed = _LOADIMAGE(iloc$ + "credits.png")
    OPEN iloc$ + "credits.ddf" FOR INPUT AS #3
    INPUT #3, creds
    CLOSE #3
    IF creds = 0 THEN
        OPEN iloc$ + "credits.ddf" FOR OUTPUT AS #3
        PRINT #3, 1
        CLOSE #3
        LET pocketnos = pocketnos + 1
    END IF
    LET credits = credits + spara
END IF
REM give item (TERMINAL)
IF scripttype = 6 THEN
    IF ditem$ <> "princess t-card" THEN LET tselect$ = "wrongcard.txt": GOSUB readtxt
    IF ditem$ = "princess t-card" THEN
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR INPUT AS #4
        INPUT #4, cdrop
        CLOSE #4
        IF cdrop = 1 THEN LET tselect$ = "nodrop.txt": GOSUB readtxt: RETURN
        LET grabbed = _LOADIMAGE(iloc$ + scriptitem$ + ".png")
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR OUTPUT AS #5
        PRINT #5, 1
        CLOSE #5
        OPEN iloc$ + scriptitem$ + ".ddf" FOR OUTPUT AS #3
        PRINT #3, 1
        CLOSE #3
        CLS
        LET scrscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
        _PUTIMAGE (-resx, -resy)-(resx, resy), scrscreen
        REM aprostraphie searcher ;)
        LET afinder = 0
        LET afinder% = INSTR(afinder% + 1, scriptitem$, "'")
        IF afinder% THEN LET afinder = 1
        IF afinder = 0 THEN PRINT "You got the "; scriptitem$
        IF afinder = 1 THEN PRINT "You got "; scriptitem$
        PRINT: PRINT "..."
        IF gamepad = 1 THEN PRINT "(press back)"
        _PUTIMAGE (resx - 35, resy - 41), grabbed
        LET pocketnos = pocketnos + 1
        LET soundfile$ = "pickup": GOSUB audio
        IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
        IF gamepad = 1 THEN
            DO: LOOP UNTIL GetButton("BACK", 0)
            DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
        END IF
        _FREEIMAGE grabbed: _FREEIMAGE scrscreen
        CLS
    END IF
END IF
REM change map
IF scripttype = 7 THEN
    LET mapno = spara
END IF
REM nothing?
IF scripttype = 8 THEN RETURN
REM display message
IF scripttype = 9 THEN
    LET tselect$ = scriptitem$
    GOSUB readtxt
    RETURN
END IF
REM map c!
IF scripttype = 10 THEN
    IF ditem$ = "t-card" THEN LET tselect$ = "wrongcard.txt": GOSUB readtxt
    IF ditem$ = "lamb's t-card" THEN LET tselect$ = "wronglambcard.txt": GOSUB readtxt
    IF ditem$ = "voodoo's t-card" THEN
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR INPUT AS #4
        INPUT #4, cdrop
        CLOSE #4
        IF cdrop = 1 THEN LET tselect$ = "tankempty.txt": GOSUB readtxt: RETURN
        LET grabbed = _LOADIMAGE(iloc$ + scriptitem$ + ".png")
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR OUTPUT AS #5
        PRINT #5, 1
        CLOSE #5
        OPEN mloc$ + "c" + mapdir$ + ".ddf" FOR OUTPUT AS #3
        PRINT #3, 1
        CLOSE #3
        LET tselect$ = "tankopen.txt": GOSUB readtxt
        LET object$ = "SUIT"
        GOSUB cutscene
        LET soundfile$ = "pickup"
        GOSUB audio
        IF charmodel$ = "ivan" THEN LET charmodel$ = "ivanarmour"
        IF charmodel$ = "eliza" THEN LET charmodel$ = "elizaarmour"
        GOSUB charload
        GOSUB mapload
        OPEN iloc$ + "uniform.ddf" FOR OUTPUT AS #4
        PRINT #4, 1
        CLOSE #4
        LET object$ = "SUIT2"
        GOSUB cutscene
        LET object$ = "TERMINAL"
    END IF
    RETURN
END IF
REM lambs card to open warp
IF scripttype = 11 THEN
    IF ditem$ = "t-card" OR ditem$ = "voodoo's t-card" THEN LET tselect$ = "wrongcard.txt": GOSUB readtxt
    IF ditem$ = "lamb's t-card" THEN
        OPEN wloc$ + mapdir$ + ".ddf" FOR INPUT AS #3
        INPUT #3, warpnos, warpon1, warpdest1, warpdx1, warpdy1, warpdd1, warpon2, warpdest2, warpdx2, warpdy2, warpdd2, warpon3, warpdest3, warpdx3, warpdy3, warpdd3, warpon4, warpdest4, warpdx4, warpdy4, warpdd4
        CLOSE #3
        IF warpon1 = 1 THEN LET tselect$ = "warpon.txt": GOSUB readtxt: RETURN
        LET warpon1 = 1
        OPEN wloc$ + mapdir$ + ".ddf" FOR OUTPUT AS #4
        PRINT #4, warpnos, warpon1, warpdest1, warpdx1, warpdy1, warpdd1, warpon2, warpdest2, warpdx2, warpdy2, warpdd2, warpon3, warpdest3, warpdx3, warpdy3, warpdd3, warpon4, warpdest4, warpdx4, warpdy4, warpdd4
        CLOSE #4
        IF noterminal = 1 THEN RETURN
        LET tselect$ = "warpoff.txt"
        GOSUB readtxt
    END IF
END IF
REM give item (TERMINAL)
IF scripttype = 12 THEN
    IF ditem$ <> "lamb's t-card" THEN LET tselect$ = "wrongcard.txt": GOSUB readtxt
    IF ditem$ = "lamb's t-card" THEN
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR INPUT AS #4
        INPUT #4, cdrop
        CLOSE #4
        IF cdrop = 1 THEN LET tselect$ = "nodrop.txt": GOSUB readtxt: RETURN
        LET grabbed = _LOADIMAGE(iloc$ + scriptitem$ + ".png")
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR OUTPUT AS #5
        PRINT #5, 1
        CLOSE #5
        OPEN iloc$ + scriptitem$ + ".ddf" FOR OUTPUT AS #3
        PRINT #3, 1
        CLOSE #3
        CLS
        LET scrscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
        _PUTIMAGE (-resx, -resy)-(resx, resy), scrscreen
        REM aprostraphie searcher ;)
        LET afinder = 0
        LET afinder% = INSTR(afinder% + 1, scriptitem$, "'")
        IF afinder% THEN LET afinder = 1
        IF afinder = 0 THEN PRINT "You got the "; scriptitem$
        IF afinder = 1 THEN PRINT "You got "; scriptitem$
        PRINT: PRINT "..."
        IF gamepad = 1 THEN PRINT "(press back)"
        _PUTIMAGE (resx - 35, resy - 41), grabbed
        LET pocketnos = pocketnos + 1
        LET soundfile$ = "pickup": GOSUB audio
        IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
        IF gamepad = 1 THEN
            DO: LOOP UNTIL GetButton("BACK", 0)
            DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
        END IF
        _FREEIMAGE grabbed: _FREEIMAGE scrscreen
        CLS
    END IF
END IF
IF scripttype = 13 THEN
    IF ditem$ <> "voodoo's t-card" THEN LET tselect$ = "wrongcard.txt": GOSUB readtxt
    IF ditem$ = "voodoo's t-card" THEN
        OPEN iloc$ + "full refund.ddf" FOR INPUT AS #666
        INPUT #666, temprefund
        CLOSE #666
        IF temprefund > 0 THEN LET tselect$ = "nodrop.txt": GOSUB readtxt: RETURN
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR INPUT AS #4
        INPUT #4, cdrop
        CLOSE #4
        IF cdrop = 1 THEN LET tselect$ = "nodrop.txt": GOSUB readtxt: RETURN
        LET grabbed = _LOADIMAGE(iloc$ + scriptitem$ + ".png")
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR OUTPUT AS #5
        PRINT #5, 1
        CLOSE #5
        OPEN iloc$ + scriptitem$ + ".ddf" FOR OUTPUT AS #3
        PRINT #3, 1
        CLOSE #3
        CLS
        LET scrscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
        _PUTIMAGE (-resx, -resy)-(resx, resy), scrscreen
        REM aprostraphie searcher ;)
        LET afinder = 0
        LET afinder% = INSTR(afinder% + 1, scriptitem$, "'")
        IF afinder% THEN LET afinder = 1
        IF afinder = 0 THEN PRINT "You got the "; scriptitem$
        IF afinder = 1 THEN PRINT "You got "; scriptitem$
        PRINT: PRINT "..."
        IF gamepad = 1 THEN PRINT "(press back)"
        _PUTIMAGE (resx - 35, resy - 41), grabbed
        LET pocketnos = pocketnos + 1
        LET soundfile$ = "pickup": GOSUB audio
        IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
        IF gamepad = 1 THEN
            DO: LOOP UNTIL GetButton("BACK", 0)
            DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
        END IF
        _FREEIMAGE grabbed: _FREEIMAGE scrscreen
        CLS
    END IF
END IF
IF scripttype = 14 THEN
    IF ditem$ <> "voodoo's t-card" THEN LET tselect$ = "wrongcard.txt": GOSUB readtxt
    IF ditem$ = "voodoo's t-card" THEN
        OPEN iloc$ + "map.ddf" FOR INPUT AS #666
        INPUT #666, temprefund
        CLOSE #666
        IF temprefund > 0 THEN LET tselect$ = "nodrop.txt": GOSUB readtxt: RETURN
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR INPUT AS #4
        INPUT #4, cdrop
        CLOSE #4
        IF cdrop = 1 THEN LET tselect$ = "nodrop.txt": GOSUB readtxt: RETURN
        LET grabbed = _LOADIMAGE(iloc$ + scriptitem$ + ".png")
        OPEN oloc$ + mapdir$ + "\object5\" + scriptitem$ + ".ddf" FOR OUTPUT AS #5
        PRINT #5, 1
        CLOSE #5
        OPEN iloc$ + scriptitem$ + ".ddf" FOR OUTPUT AS #3
        PRINT #3, 1
        CLOSE #3
        CLS
        LET scrscreen = _LOADIMAGE(tloc$ + "talkscreen.png")
        _PUTIMAGE (-resx, -resy)-(resx, resy), scrscreen
        REM aprostraphie searcher ;)
        LET afinder = 0
        LET afinder% = INSTR(afinder% + 1, scriptitem$, "'")
        IF afinder% THEN LET afinder = 1
        IF afinder = 0 THEN PRINT "You got the "; scriptitem$
        IF afinder = 1 THEN PRINT "You got "; scriptitem$
        PRINT: PRINT "..."
        IF gamepad = 1 THEN PRINT "(press back)"
        _PUTIMAGE (resx - 35, resy - 41), grabbed
        LET pocketnos = pocketnos + 1
        LET soundfile$ = "pickup": GOSUB audio
        IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
        IF gamepad = 1 THEN
            DO: LOOP UNTIL GetButton("BACK", 0)
            DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
        END IF
        _FREEIMAGE grabbed: _FREEIMAGE scrscreen
        CLS
    END IF
END IF
RETURN

directory:
REM directory code
CLS
LET dirname$ = tselect$
OPEN tloc$ + "dir\" + dirname$ + ".ddf" FOR INPUT AS #1
INPUT #1, dct1, dcn1$, dct2, dcn2$, dct3, dcn3$, dct4, dcn4$, dct5, dcn5$, dct6, dcn6$
CLOSE #1
LET dstposx = 30: LET dstposy = 50
LET tdelay = .5
dtermloop:
CLS
_PUTIMAGE (70, 120), sysbusy
PRINT tos$; " / "; dirname$
IF dct1 = 0 THEN _PUTIMAGE (30, 50), tno
IF dct1 = 1 THEN _PUTIMAGE (30, 50), tfile
IF dct1 = 3 THEN _PUTIMAGE (30, 50), tscript
_DELAY tdelay: LET tdelay = tdelay / 2
IF dct2 = 0 THEN _PUTIMAGE (70, 50), tno
IF dct2 = 1 THEN _PUTIMAGE (70, 50), tfile
IF dct2 = 3 THEN _PUTIMAGE (70, 50), tscript
_DELAY tdelay: LET tdelay = tdelay / 2
IF dct3 = 0 THEN _PUTIMAGE (110, 50), tno
IF dct3 = 1 THEN _PUTIMAGE (110, 50), tfile
IF dct3 = 3 THEN _PUTIMAGE (110, 50), tscript
_DELAY tdelay: LET tdelay = tdelay / 2
IF dct4 = 0 THEN _PUTIMAGE (30, 90), tno
IF dct4 = 1 THEN _PUTIMAGE (30, 90), tfile
IF dct4 = 3 THEN _PUTIMAGE (30, 90), tscript
_DELAY tdelay: LET tdelay = tdelay / 2
IF dct5 = 0 THEN _PUTIMAGE (70, 90), tno
IF dct5 = 1 THEN _PUTIMAGE (70, 90), tfile
IF dct5 = 3 THEN _PUTIMAGE (70, 90), tscript
_DELAY tdelay: LET tdelay = tdelay / 2
IF dct6 = 0 THEN _PUTIMAGE (110, 90), tno
IF dct6 = 1 THEN _PUTIMAGE (110, 90), tfile
IF dct6 = 3 THEN _PUTIMAGE (110, 90), tscript
_DELAY tdelay
IF dstposx = 30 AND dstposy = 50 THEN LET dttype = dct1: LET dtselect$ = dcn1$
IF dstposx = 70 AND dstposy = 50 THEN LET dttype = dct2: LET dtselect$ = dcn2$
IF dstposx = 110 AND dstposy = 50 THEN LET dttype = dct3: LET dtselect$ = dcn3$
IF dstposx = 30 AND dstposy = 90 THEN LET dttype = dct4: LET dtselect$ = dcn4$
IF dstposx = 70 AND dstposy = 90 THEN LET dttype = dct5: LET dtselect$ = dcn5$
IF dstposx = 110 AND dstposy = 90 THEN LET dttype = dct6: LET dtselect$ = dcn6$
LET tdelay = 0
IF dttype = 1 THEN PRINT "file - "; dtselect$: _PUTIMAGE (dstposx - 1, dstposy - 1), tselectf
IF dttype = 3 THEN PRINT "script - "; dtselect$: _PUTIMAGE (dstposx - 1, dstposy - 1), tselectf
IF dttype = 0 THEN PRINT "no data": _PUTIMAGE (dstposx - 1, dstposy - 1), tselectn
_PUTIMAGE (70, 120), sysok
REM input loop
DO
    LET dt$ = UCASE$(INKEY$): REM terminal user input
    IF dt$ = CHR$(0) + CHR$(72) THEN LET dstposy = 50: GOTO dtermloop: REM up
    IF dt$ = CHR$(0) + CHR$(80) THEN LET dstposy = 90: GOTO dtermloop: REM down
    IF gamepad = 1 THEN
        IF GetButton("UP", 0) THEN LET dstposy = 50: DO: LOOP UNTIL GetButton("UP", 0) = GetButton.NotFound: GOTO dtermloop: REM gamepad up
        IF GetButton("DOWN", 0) THEN LET dstposy = 90: DO: LOOP UNTIL GetButton("DOWN", 0) = GetButton.NotFound: GOTO dtermloop: REM gamepad down
    END IF
    REM left
    IF gamepad = 1 THEN
        IF GetButton("LEFT", 0) THEN
            DO: LOOP UNTIL GetButton("LEFT", 0) = GetButton.NotFound:
            IF dstposx = 30 THEN LET dstposx = 30: GOTO dtermloop
            IF dstposx = 70 THEN LET dstposx = 30: GOTO dtermloop
            IF dstposx = 110 THEN LET dstposx = 70: GOTO dtermloop
        END IF
    END IF
    IF dt$ = CHR$(0) + CHR$(75) THEN
        IF dstposx = 30 THEN LET dstposx = 30: GOTO dtermloop
        IF dstposx = 70 THEN LET dstposx = 30: GOTO dtermloop
        IF dstposx = 110 THEN LET dstposx = 70: GOTO dtermloop
    END IF
    REM right
    IF gamepad = 1 THEN
        IF GetButton("RIGHT", 0) THEN
            DO: LOOP UNTIL GetButton("RIGHT", 0) = GetButton.NotFound
            IF dstposx = 30 THEN LET dstposx = 70: GOTO dtermloop
            IF dstposx = 70 THEN LET dstposx = 110: GOTO dtermloop
            IF dstposx = 110 THEN LET dstposx = 110: GOTO dtermloop
        END IF
    END IF
    IF dt$ = CHR$(0) + CHR$(77) THEN
        IF dstposx = 30 THEN LET dstposx = 70: GOTO dtermloop
        IF dstposx = 70 THEN LET dstposx = 110: GOTO dtermloop
        IF dstposx = 110 THEN LET dstposx = 110: GOTO dtermloop
    END IF
    REM use
    IF gamepad = 1 THEN IF GetButton("USE", 0) THEN DO: LOOP UNTIL GetButton("USE", 0) = GetButton.NotFound: GOTO dtermpaduse
    IF dt$ = " " THEN
        dtermpaduse:
        REM file type
        IF dttype = 1 THEN
            LET findtxt = 0: findtxt = INSTR(findtxt + 1, dtselect$, ".TXT"): IF findtxt THEN LET tselect$ = dtselect$: GOSUB readtxt
            GOTO dtermloop
        END IF
        REM script type
        IF dttype = 3 THEN
            IF dtselect$ = "BACK.H" THEN LET tselect$ = "": LET tdelay = .5: CLS: RETURN
            LET tselect$ = LCASE$(dtselect$): GOSUB script
            GOTO dtermloop
        END IF
    END IF
LOOP

paderror:
REM pad error
CLS
PRINT "NO MORE GAMEPADS DETECTED."
_DELAY 2
RETURN

paderror2:
REM 2nd pad error
CLS
PRINT "PLEASE RESTART GAME TO"
PRINT "RECONFIGURE PADS"
_DELAY 2
RETURN

padsetup:
IF booting = 0 THEN
    SCREEN 0
    IF screenmode = 2 THEN _FULLSCREEN _OFF
    IF screenmode = 1 THEN _FULLSCREEN _SQUAREPIXELS
END IF
CLS
PRINT "Detecting your gamepad."
PRINT "Press any button..."
StartTime# = TIMER
DO
    x& = _DEVICEINPUT
    IF x& > 2 THEN
        'Keyboard is 1, Mouse is 2. Anything after that could be a controller.
        Found = -1
        EXIT DO
    END IF
LOOP UNTIL TIMER - StartTime# > 10
IF Found = 0 THEN
    PRINT "No gamepad detected."
    LET gamepad = 0
    _DELAY 2
    IF booting = 0 THEN
        SCREEN _NEWIMAGE(resx, resy, 32)
        IF screenmode = 2 THEN _FULLSCREEN _OFF
        IF screenmode = 1 THEN _FULLSCREEN _SQUAREPIXELS
        COLOR &HFFFCFCFC, 0
        _FONT f&
    END IF
    RETURN
END IF
FOR padi = 3 TO _DEVICES
    gamepad$ = _DEVICE$(padi)
    IF INSTR(gamepad$, "CONTROLLER") THEN
        TotalControllers = TotalControllers + 1
        REDIM _PRESERVE SHARED MyDevices(1 TO TotalControllers) AS DevType
        MyDevices(TotalControllers).ID = padi
        MyDevices(TotalControllers).Name = gamepad$
    END IF
NEXT padi
IF TotalControllers > 1 THEN
    'More than one controller found, user can choose which will be used
    '(though I highly suspect this bit will never be run)
    PRINT "Controllers found:"
    FOR padi = 1 TO TotalControllers
        PRINT padi, MyDevices(padi).Name
    NEXT padi
    DO
        INPUT "Your choice (0 to quit): ", ChosenController
        IF ChosenController = 0 THEN END
    LOOP UNTIL ChosenController <= TotalControllers
ELSE
    ChosenController = 1
END IF
AssignKeys:
IF booting = 0 THEN
    CLS
    PRINT "Using "; RTRIM$(MyDevices(ChosenController).Name)
    PRINT
    PRINT "Button assignments:"
END IF
IF _FILEEXISTS(dloc$ + "gamepad.ddf") = 0 THEN
    LET padi = 0
    'Wait until all buttons in the deviced are released:
    DO
    LOOP UNTIL GetButton("", MyDevices(ChosenController).ID) = GetButton.NotFound
    'Start assignment
    DO
        LET padi = padi + 1
        IF padi > UBOUND(ButtonMap) THEN EXIT DO
        Redo:
        PRINT "PRESS BUTTON FOR '" + RTRIM$(ButtonMap(padi).Name) + "'...";
        'Read a button
        LET ReturnedButton$ = ""
        DO
        LOOP UNTIL GetButton(ReturnedButton$, 0) = GetButton.Found
        'Wait until all buttons in the deviced are released:
        DO
        LOOP UNTIL GetButton("", 0) = GetButton.NotFound
        ButtonMap(padi).ID = CVI(ReturnedButton$)
        PRINT
    LOOP
    OPEN dloc$ + "gamepad.ddf" FOR BINARY AS #1
    PUT #1, 1, ButtonMap()
    CLOSE #1
ELSE
    OPEN dloc$ + "gamepad.ddf" FOR BINARY AS #1
    GET #1, 1, ButtonMap()
    CLOSE #1
    FOR i = 1 TO UBOUND(Buttonmap)
        PRINT ButtonMap(padi).Name; "="; ButtonMap(padi).ID
    NEXT
END IF
LET gamepad = 1
IF booting = 0 THEN
    PRINT
    PRINT "Gamepad Setup complete!"
    PRINT
    PRINT "Gamepad Setup data is stored with game save data!"
    PRINT "Clearing save data with also clear Gamepad Setup data!"
    PRINT "Run Gamepad Setup at any time to reassign keys!"
    PRINT
    PRINT "Push START to continue."
    PRINT "(DELETE to reassign keys)"
END IF
IF booting = 1 THEN PRINT: PRINT "Push START to continue."
DO
    IF _KEYHIT = 21248 THEN
        ON ERROR GOTO padfileerror
        KILL "data\gamepad.ddf"
        ON ERROR GOTO padsetup
        GOTO AssignKeys
    END IF
LOOP UNTIL GetButton("START", MyDevices(ChosenController).ID)
IF booting = 0 THEN
    SCREEN _NEWIMAGE(resx, resy, 32)
    IF screenmode = 2 THEN _FULLSCREEN _OFF
    IF screenmode = 1 THEN _FULLSCREEN _SQUAREPIXELS
    COLOR &HFFFCFCFC, 0
    _FONT f&
END IF
RETURN

padfileerror:
PRINT
PRINT "== Metadata Error =="
RESUME NEXT

readtxt:
REM read txt files
CLS
LET tselect$ = UCASE$(tselect$)
LET tdelay = .5
_PUTIMAGE (70, 120), sysbusy
OPEN tloc$ + "txt\" + tselect$ FOR INPUT AS #1
INPUT #1, txtfile1$, txtfile2$, txtfile3$, txtfile4$, txtfile5$, txtfile6$, sysstat
CLOSE #1
PRINT tos$
PRINT
PRINT txtfile1$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT txtfile2$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT txtfile3$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT txtfile4$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT txtfile5$
_DELAY tdelay: LET tdelay = tdelay / 2
PRINT txtfile6$
PRINT: PRINT
PRINT "..."
IF gamepad = 1 THEN PRINT "(press back)"
IF sysstat = 1 THEN _PUTIMAGE (70, 120), sysok: LET soundfile$ = "sysok"
IF sysstat = 2 THEN _PUTIMAGE (70, 120), sysbusy
IF sysstat = 3 THEN _PUTIMAGE (70, 120), syserr: LET soundfile$ = "syserr"
GOSUB audio
IF gamepad = 0 THEN DO: LOOP WHILE INKEY$ = ""
IF gamepad = 1 THEN
    DO: LOOP UNTIL GetButton("BACK", 0)
    DO: LOOP UNTIL GetButton("BACK", 0) = GetButton.NotFound
END IF
LET tselect$ = ""
LET tdelay = .5
CLS
GOSUB keycatcher
RETURN

powersaveblock:
REM blocks power saving features
LET cursorx = _MOUSEX
LET cursory = _MOUSEY
_MOUSEMOVE (cursorx + 1), cursory
_MOUSEMOVE cursorx, cursory
LET ctime = 0
LET itime = TIMER
RETURN

game:
REM Game Engine
DO
    LET xxit = _EXIT
    _LIMIT hertz
    IF refresh = 1 THEN GOSUB redraw: REM refresh enabler
    LET a$ = UCASE$(INKEY$): REM user input
    GOSUB inputter: REM user input switches
    GOSUB stillfoot: REM stillfoot
    GOSUB border: REM border control
    GOSUB item: REM item control
    REM GOSUB printitem: REM variable value displayer
    LET ctime = TIMER - itime: REM timer function
    IF stillfoot = 1 THEN GOSUB redraw2: REM animation
    IF _EXIT THEN GOTO endgame
    LET ctime = (TIMER - itime): REM time keeper
    IF ctime > 200 THEN GOSUB powersaveblock: REM blocks power saving features
LOOP

printitem:
REM prints value of selected variable (dev use)
COLOR &HFFFCFCFC, &HFFA80000
LOCATE 1, 1: PRINT bgx
LOCATE 2, 1: PRINT bgy
REM LOCATE 3, 1: PRINT pocketnos
COLOR &HFFFCFCFC, 0
RETURN

endgame:
REM quits game
IF musicon = 1 THEN _SNDSTOP musix: _SNDCLOSE musix
IF mapno <> 0 THEN
    OPEN dloc$ + "savedata.ddf" FOR OUTPUT AS #1
    PRINT #1, mapno, bgx, bgy, direction, credits, pocketnos, musicon, screenmode, gamepad, charmodel$
    CLOSE #1
END IF
SCREEN 0
PRINT "bgx: "; bgx
PRINT "bgy: "; bgy
PRINT "bgresx: "; bgresx
PRINT "bgresy: "; bgresy
PRINT "cbgx: "; cbgx
PRINT "cbgy: "; cbgy
PRINT
PRINT "mapno: "; mapno
PRINT "map c:"; mapc
PRINT "credits: "; credits
PRINT "items: "; pocketnos
PRINT "direction: "; direction
PRINT "selectitem$: "; selectitem$
PRINT "screenmode: "; screenmode
PRINT "musicon:"; musicon
PRINT "charmodel: "; charmodel$
PRINT "part: "; part
PRINT
PRINT "gamepad: "; gamepad
PRINT "OS: "; ros$
PRINT "itime: "; itime
PRINT "ctime: "; ctime
SYSTEM

stillfoot:
REM Still Foot Loop
IF stillfoot = 0 THEN IF sps >= spsloop THEN LET refresh = 1: LET stillfoot = 1
RETURN

redraw2:
REM Redraw Utility (version 2.0 !!!) :O
REM position worker
LET posx = (resx / 2) - (13 / 2)
LET posy = (resy / 2) - (16 / 2)
REM background
IF INT(ctime) MOD 2 THEN
    _PUTIMAGE (bgx, bgy), map
ELSE
    _PUTIMAGE (bgx, bgy), mapb
END IF
REM still foot
IF direction = 1 THEN _PUTIMAGE (posx, posy), pb
IF direction = 2 THEN _PUTIMAGE (posx, posy), pf
IF direction = 3 THEN _PUTIMAGE (posx, posy), pr
IF direction = 4 THEN _PUTIMAGE (posx, posy), pl
LET stillfoot = 0
LET refresh = 0
LET rps = rps + 1
LET sps = 0
RETURN

moveon:
REM move-on sub (advances plot)
IF mapno = 29 OR mapno = 39 THEN
    REM enter rocketbus
    CLS
    GOSUB redraw
    GOSUB fadeout
    LET bgx = -69: LET bgy = 1
    LET direction = 2
    GOSUB fadein
    GOSUB cutscene
    GOSUB fadeout
    LET bgx = -1: LET bgy = 29
    LET mapno = 42
    GOSUB mapload
    GOSUB fadein
END IF
IF mapno = 54 THEN
    CLS
    GOSUB redraw
    GOSUB fadeout
    LET bgx = -63: LET bgy = 25
    LET direction = 1
    GOSUB fadein
END IF
IF mapno = 53 THEN
    REM escorted to prison
    CLS
    GOSUB redraw
    GOSUB fadeout
    LET mapno = 54
    LET bgx = -18: LET bgy = 0
    LET direction = 1
    GOSUB mapload
    FOR mol = 1 TO 6
        IF mol = 1 THEN LET moitem$ = "voodoo's t-card"
        IF mol = 2 THEN LET moitem$ = "princess t-card"
        IF mol = 3 THEN LET moitem$ = "gun"
        IF mol = 4 THEN LET moitem$ = "rocketbus key"
        IF mol = 5 THEN LET moitem$ = "note"
        IF mol = 6 THEN LET moitem$ = "accident form"
        OPEN iloc$ + moitem$ + ".ddf" FOR OUTPUT AS #888
        PRINT #888, 2
        CLOSE #888
    NEXT mol
    OPEN iloc$ + "credits.ddf" FOR OUTPUT AS #999
    PRINT #999, 0
    CLOSE #999
    LET pocketnos = 1
    GOSUB fadein
END IF
RETURN

fadein:
REM fade in utility
FOR i% = 255 TO 0 STEP -5
    _LIMIT 50
    IF INT(ctime) MOD 2 THEN
        _PUTIMAGE (bgx, bgy), map
    ELSE
        _PUTIMAGE (bgx, bgy), mapb
    END IF
    LET ctime = TIMER - itime: REM timer function
    IF direction = 1 THEN _PUTIMAGE (posx, posy), pb
    IF direction = 2 THEN _PUTIMAGE (posx, posy), pf
    IF direction = 3 THEN _PUTIMAGE (posx, posy), pr
    IF direction = 4 THEN _PUTIMAGE (posx, posy), pl
    LINE (0, 0)-(160, 144), _RGBA(0, 0, 0, i%), BF
    _DISPLAY
NEXT
_AUTODISPLAY
RETURN

fadeout:
REM fade out utility
FOR i% = 0 TO 255 STEP 5
    _LIMIT 50
    IF INT(ctime) MOD 2 THEN
        _PUTIMAGE (bgx, bgy), map
    ELSE
        _PUTIMAGE (bgx, bgy), mapb
    END IF
    LET ctime = TIMER - itime: REM timer function
    IF direction = 1 THEN _PUTIMAGE (posx, posy), pb
    IF direction = 2 THEN _PUTIMAGE (posx, posy), pf
    IF direction = 3 THEN _PUTIMAGE (posx, posy), pr
    IF direction = 4 THEN _PUTIMAGE (posx, posy), pl
    LINE (0, 0)-(160, 144), _RGBA(0, 0, 0, i%), BF
    _DISPLAY
NEXT
_AUTODISPLAY
RETURN

redraw:
REM Redraw Utility
REM CLS
REM flush variables
LET selectitem$ = ""
REM position worker
LET posx = (resx / 2) - (13 / 2)
LET posy = (resy / 2) - (16 / 2)
REM foot changer
IF rps >= footpace THEN
    IF foot = 1 THEN LET foot = 2: LET rps = 0: GOTO 10
    IF foot = 2 THEN LET foot = 1: LET rps = 0: GOTO 10
END IF
IF gameon = 0 THEN GOSUB fadein: LET gameon = 1: REM fade in function
10 REM background
IF INT(ctime) MOD 2 THEN
    _PUTIMAGE (bgx, bgy), map
ELSE
    _PUTIMAGE (bgx, bgy), mapb
END IF
REM still foot
IF stillfoot = 1 THEN IF sps >= spsloop THEN
        IF direction = 1 THEN _PUTIMAGE (posx, posy), pb
        IF direction = 2 THEN _PUTIMAGE (posx, posy), pf
        IF direction = 3 THEN _PUTIMAGE (posx, posy), pr
        IF direction = 4 THEN _PUTIMAGE (posx, posy), pl
        GOTO 20
    END IF
END IF
REM if non-player cutscene occuring
IF notyoucutscene = 1 THEN
    IF direction = 1 THEN _PUTIMAGE (posx, posy), pb
    IF direction = 2 THEN _PUTIMAGE (posx, posy), pf
    IF direction = 3 THEN _PUTIMAGE (posx, posy), pr
    IF direction = 4 THEN _PUTIMAGE (posx, posy), pl
    GOTO 30
END IF
REM moving foot
IF direction = 1 THEN
    IF foot = 1 THEN _PUTIMAGE (posx, posy), pbl
    IF foot = 2 THEN _PUTIMAGE (posx, posy), pbr
END IF
IF direction = 2 THEN
    IF foot = 1 THEN _PUTIMAGE (posx, posy), pfl
    IF foot = 2 THEN _PUTIMAGE (posx, posy), pfr
END IF
IF direction = 3 THEN
    IF foot = 1 THEN _PUTIMAGE (posx, posy), prr
    IF foot = 2 THEN _PUTIMAGE (posx, posy), prl
END IF
IF direction = 4 THEN
    IF foot = 1 THEN _PUTIMAGE (posx, posy), pll
    IF foot = 2 THEN _PUTIMAGE (posx, posy), plr
END IF
30 REM draw extra characters for cutscene
IF notyoucutscene = 1 THEN
    LET ctime = TIMER - itime: REM timer function
    IF csdirection = 1 THEN
        IF foot = 1 THEN _PUTIMAGE (csx, csy), cspbl
        IF foot = 2 THEN _PUTIMAGE (csx, csy), cspbr
    END IF
    IF csdirection = 2 THEN
        IF foot = 1 THEN _PUTIMAGE (csx, csy), cspfl
        IF foot = 2 THEN _PUTIMAGE (csx, csy), cspfr
    END IF
    IF csdirection = 3 THEN
        IF foot = 1 THEN _PUTIMAGE (csx, csy), csprr
        IF foot = 2 THEN _PUTIMAGE (csx, csy), csprl
    END IF
    IF csdirection = 4 THEN
        IF foot = 1 THEN _PUTIMAGE (csx, csy), cspll
        IF foot = 2 THEN _PUTIMAGE (csx, csy), csplr
    END IF
END IF
LET stillfoot = 0
20 LET refresh = 0
LET rps = rps + 1
LET sps = 0
RETURN

audio:
REM sound
IF musicon = 2 OR musicon = 3 THEN
    OPEN aloc$ + soundfile$ + ".ddf" FOR INPUT AS #1
    INPUT #1, s1, d1, s2, d2, s3, d3, s4, d4, s5, d5, s6, d6
    CLOSE #1
    LET sloop = 1
    DO
        IF sloop = 1 THEN SOUND s1, d1
        IF sloop = 2 THEN SOUND s2, d2
        IF sloop = 3 THEN SOUND s3, d3
        IF sloop = 4 THEN SOUND s4, d4
        IF sloop = 5 THEN SOUND s5, d5
        IF sloop = 6 THEN SOUND s6, d6
        LET sloop = sloop + 1
        IF sloop = 7 THEN RETURN
    LOOP
END IF
RETURN

keycatcher:
REM catches key presses
DO
    Kh = _KEYHIT
    Ink$ = INKEY$
LOOP UNTIL Kh = 0 AND Ink$ = ""
RETURN

partdisplay:
REM introduction / part display sub
LET tslider = 1
LET cmusicfile$ = musicfile$
LET musicfile$ = "menu"
GOSUB playmusic
LET cmusicfile$ = musicfile$
OPEN ploc$ + partname$ + ".ddf" FOR INPUT AS #69
INPUT #69, pn1$, pn1, pn2$, pn2, pn3$, pn3
CLOSE #69
DO
    LET kh$ = INKEY$
    CLS
    COLOR &HFFA80000
    LOCATE tslider, pn1: PRINT pn1$
    _DELAY 1
    LET tslider = tslider + 1
    IF gamepad = 1 THEN IF GetButton("START", 0) THEN COLOR &HFFFCFCFC: GOSUB keycatcher: RETURN
    IF gamepad = 0 THEN IF kh$ <> "" THEN COLOR &HFFFCFCFC: GOSUB keycatcher: RETURN
LOOP UNTIL tslider = 6
LET tslider = 12
LET ttslider = 1
DO
    LET kh$ = INKEY$
    CLS
    COLOR &HFFA80000: LOCATE 6, (pn1 + ttslider): PRINT pn1$
    COLOR &HFFFCFCFC: LOCATE tslider, pn2: PRINT pn2$
    IF tslider < 12 THEN LOCATE (tslider + 1), pn3: PRINT pn3$
    LET tslider = tslider - 1
    IF ttslider = 1 THEN LET ttslider = -1: GOTO introlooper
    IF ttslider = -1 THEN LET ttslider = 1: GOTO introlooper
    introlooper:
    _DELAY 1
    IF gamepad = 1 THEN IF GetButton("START", 0) THEN GOSUB keycatcher: RETURN
    IF gamepad = 0 THEN IF kh$ <> "" THEN GOSUB keycatcher: RETURN
LOOP UNTIL tslider = 7
LET tslider = 1
LET partcounter = 0
DO
    LET kh$ = INKEY$
    CLS
    COLOR &HFFA80000: LOCATE 6, (pn1 + ttslider): PRINT pn1$
    COLOR &HFFFCFCFC: LOCATE 7, (pn2 + tslider): PRINT pn2$
    IF tslider < 12 THEN LOCATE 8, (pn3 + tslider): PRINT pn3$
    IF tslider = 1 THEN LET tslider = -1: GOTO introlooper2
    IF tslider = -1 THEN LET tslider = 1: GOTO introlooper2
    introlooper2:
    IF ttslider = 1 THEN LET ttslider = -1: GOTO introlooper3
    IF ttslider = -1 THEN LET ttslider = 1: GOTO introlooper3
    introlooper3:
    LET partcounter = partcounter + 1
    IF partcounter > 10 THEN COLOR &HFF545454: LOCATE 12, 1: PRINT "press space": COLOR &HFFFCFCFC: IF partcounter > 15 THEN LET partcounter = 0
    _DELAY 1
    IF gamepad = 1 THEN IF GetButton("START", 0) THEN GOSUB keycatcher: RETURN
    IF gamepad = 0 THEN IF kh$ <> "" THEN GOSUB keycatcher: RETURN
LOOP WHILE INKEY$ = ""
GOSUB keycatcher
RETURN

REM Pad Function 1
FUNCTION GetButton (Name$, DeviceID AS INTEGER)
SHARED GetButton.Found, GetButton.NotFound, GetButton.Multiple
STATIC LastDevice AS INTEGER
REM Initialize SHARED variables used for return codes
GetButton.NotFound = 0
GetButton.Found = -1
GetButton.Multiple = -2
REM DeviceID must always be passed in case there are multiple
REM devices to query; If only one, 0 can be passed in subsequent
REM calls to this function.
IF DeviceID THEN
    LastDevice = DeviceID
ELSE
    IF LastDevice = 0 THEN
        CLS
        PRINT "GAMEPAD ERROR - (no value)"
        PRINT "SWITCHING TO KEYBOARD"
        _DELAY 2
        LET gamepad = 0
    END IF
END IF
REM Read the device's buffer:
DO WHILE _DEVICEINPUT(LastDevice): LOOP
IF LEN(Name$) THEN
    REM if button Name$ is passed, we look for that specific ID.
    REM If pressed, we return -1
    FOR padi = 1 TO UBOUND(ButtonMap)
        IF UCASE$(RTRIM$(ButtonMap(padi).Name)) = UCASE$(Name$) THEN
            'Found the requested button's ID.
            'Time to query the controller:
            GetButton = _BUTTON(ButtonMap(padi).ID) 'Return result maps to .NotFound = 0 or .Found = -1
            EXIT FUNCTION
        END IF
    NEXT padi
ELSE
    REM Otherwise we return every button whose state is -1
    REM Return is passed by changing Name$ and GetButton then returns -2
    FOR padi = 1 TO _LASTBUTTON(LastDevice)
        IF _BUTTON(padi) THEN Name$ = Name$ + MKI$(padi)
    NEXT padi
    IF LEN(Name$) = 0 THEN EXIT FUNCTION
    IF LEN(Name$) = 2 THEN GetButton = GetButton.Found ELSE GetButton = GetButton.Multiple
END IF
END FUNCTION
