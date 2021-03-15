(* FoxHunt game by Saveliy Ivankov (Yprit), 2020 *)
(* https://vk.com/64kilobytes *)

MODULE FoxHunt; (*$866*)
IMPORT b := Basic, GrFonts, g := GrTiles, c := Console, s := SYSTEM, KMouse;

TYPE
  NumbersTileSet = ARRAY 10 * 32 OF CHAR;

CONST
  Xm = 11; Ym = 11; (* Field size [width, height] *)
  FoxNum = 9; (* Number of foxes *)

  Numbers = NumbersTileSet( (* 0..9 *)
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0F2X, 04FX, 0F2X, 04CX, 072X, 04CX, 0F2X, 04DX, 0F2X,
    04FX, 0B2X, 04FX, 032X, 04EX, 032X, 04FX, 0F2X, 04FX, 0F2X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 040X, 0C2X, 041X, 0C2X, 043X, 0C2X, 043X, 0C2X, 040X, 0C2X,
    040X, 0C2X, 040X, 0C2X, 040X, 0C2X, 040X, 0C2X, 040X, 0C2X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0F2X, 04FX, 0F2X, 040X, 032X, 040X, 032X, 04FX, 0F2X,
    04FX, 0F2X, 04CX, 002X, 04CX, 002X, 04FX, 0F2X, 04FX, 0F2X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0F2X, 04FX, 0F2X, 040X, 032X, 040X, 032X, 043X, 0F2X,
    043X, 0F2X, 040X, 032X, 040X, 032X, 04FX, 0F2X, 04FX, 0F2X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04CX, 032X, 04CX, 032X, 04CX, 032X, 04CX, 032X, 04FX, 0F2X,
    04FX, 0F2X, 040X, 032X, 040X, 032X, 040X, 032X, 040X, 032X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0F2X, 04FX, 0F2X, 04CX, 002X, 04CX, 002X, 04FX, 0F2X,
    04FX, 0F2X, 040X, 032X, 040X, 032X, 04FX, 0F2X, 04FX, 0F2X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0F2X, 04FX, 0F2X, 04CX, 002X, 04CX, 002X, 04FX, 0F2X,
    04FX, 0F2X, 04CX, 032X, 04CX, 032X, 04FX, 0F2X, 04FX, 0F2X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0FAX, 04FX, 0FAX, 040X, 01AX, 040X, 01AX, 040X, 01AX,
    040X, 01AX, 040X, 01AX, 040X, 01AX, 040X, 01AX, 040X, 01AX, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0F2X, 04FX, 0F2X, 04CX, 032X, 04CX, 032X, 04FX, 0F2X,
    04FX, 0F2X, 04CX, 032X, 04CX, 032X, 04FX, 0F2X, 04FX, 0F2X, 040X, 002X, 07FX, 0FEX, 000X, 000X,
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04FX, 0F2X, 04FX, 0F2X, 04CX, 032X, 04CX, 032X, 04FX, 0F2X, 
    04FX, 0F2X, 040X, 032X, 040X, 032X, 04FX, 0F2X, 04FX, 0F2X, 040X, 002X, 07FX, 0FEX, 000X, 000X);
  Empty = g.MonoTile16x16(
    000X, 000X, 07FX, 0FEX, 040X, 002X, 040X, 002X, 040X, 002X, 040X, 002X, 040X, 002X, 040X, 002X,
    040X, 002X, 040X, 002X, 040X, 002X, 040X, 002X, 040X, 002X, 040X, 002X, 07FX, 0FEX, 000X, 000X);
  Flag = g.MonoTile16x16(
    000X, 000X, 07FX, 0FEX, 040X, 002X, 04BX, 002X, 04FX, 0C2X, 04FX, 0F2X, 04CX, 0C2X, 048X, 002X,
    048X, 002X, 048X, 002X, 048X, 002X, 048X, 002X, 048X, 002X, 040X, 002X, 07FX, 0FEX, 000X,000X);
  Fox = g.MonoTile16x16(
    004X, 020X, 03BX, 0DCX, 02DX, 0B4X, 06EX, 076X, 04FX, 0F2X, 050X, 00AX, 060X, 006X, 040X, 012X,
    09CX, 029X, 083X, 0C1X, 041X, 082X, 020X, 004X, 050X, 02AX, 069X, 0D6X, 074X, 02EX, 003X, 0C0X);

VAR
  cur_x, cur_y, fox_found, turn: INT8;
  field, number: ARRAY Xm, Ym OF INT8;
  opened, marked: ARRAY Xm, Ym OF BOOLEAN;
  is_fire, is_mark, is_end: BOOLEAN;
  is_only1, is_axes, is_sounds, is_line, is_auto, is_mouse: BOOLEAN;

PROCEDURE PrintField;
  VAR x, y: INT8;
BEGIN
  b.COLOR(b.Paper*b.LightGray); b.BORDER(b.LightGray); b.CLS;
  FOR x := Xm-1 TO 0 BY -1 DO
    FOR y := Ym-1 TO 0 BY -1 DO
      g.DrawNoAtrTile16x16(x*2+1, y*2+1, Empty);
    END;
  END;
  c.At(25, 1); b.INK(2); c.WriteStr("Найти");
  c.At(25, 2); c.WriteStr("лис");
  c.At(25, 6); b.INK(1); c.WriteStr("Сделано");
  c.At(25, 7); c.WriteStr("ходов");
  c.At(25, 22); b.INK(3); c.WriteStr("E-Выйти");
  b.INK(0);
END PrintField;

PROCEDURE Settings;
  VAR key: CHAR;
BEGIN
  b.COLOR(b.Bright + b.Paper*b.Green); b.BORDER(b.Green); b.CLS;
  LOOP
    c.At(12,10); c.WriteStr("НАСТРОЙКИ");
    c.At(4, 12); c.WriteStr("1. НАЗАД В МЕНЮ");
    c.At(4, 13); c.WriteStr("2. Только 1 лиса в поле");
    c.At(4, 14); c.WriteStr("3. Показать направления");
    c.At(4, 15); c.WriteStr("4. Звуки");
    c.At(4, 16); c.WriteStr("5. Кемпстон-мышь");
    c.At(28, 13);
    IF is_only1 THEN c.WriteCh("Y") ELSE c.WriteCh("N") END;
    c.At(28, 14);
    IF is_axes THEN c.WriteCh("Y") ELSE c.WriteCh("N") END;
    c.At(28, 15);
    IF is_sounds THEN c.WriteCh("Y") ELSE c.WriteCh("N") END;
    c.At(28, 16);
    IF is_mouse THEN c.WriteCh("Y") ELSE c.WriteCh("N") END;
    c.At(4, 17); (* 6 !!! *)
    IF is_line THEN c.WriteStr("6. Передать привет моим Y");
      c.At(7, 18); c.WriteStr("друзьям!");
    END;
    REPEAT key := CHR(b.PEEK(23560)) UNTIL (key >= "1") & (key <= "6");
    IF is_sounds THEN b.BEEP(20, 20) END;
    b.POKE(23560, 0);
    CASE key OF
      | "1": EXIT
      | "2": is_only1 := ~is_only1;
      | "3": is_axes := ~is_axes;
      | "4": is_sounds := ~is_sounds;
      | "5": is_mouse := ~is_mouse;
    ELSE is_line := TRUE;
    END;
  END;
END Settings;

PROCEDURE Help;
  VAR y: INT8;
BEGIN
  b.COLOR(b.Bright + b.Paper*b.Yellow); b.BORDER(b.Olive); b.CLS;
  FOR y := 21 TO 2 BY -1 DO
    c.At(0, y); c.WriteCh("║"); c.At(31, y); c.WriteCh("║");
  END;
  c.At(0,  0); c.WriteStr("╔══════════════════════════════╗");
  c.At(0,  1); c.WriteStr("╠════════════ИСТОРИЯ═══════════╣");
  c.At(1,  3); c.WriteStr("Основано на игре для советских");
  c.At(1,  4); c.WriteStr("калькуляторов, известной как");
  c.At(1,  5); c.WriteStr('"Охота на лис". Оригинальная');
  c.At(1,  6); c.WriteStr("игра основана на спортивной");
  c.At(1,  7); c.WriteStr("радиопеленгации (СРП).");
  c.At(0,  9); c.WriteStr("╠══════════КАК ИГРАТЬ══════════╣");
  c.At(1, 11); c.WriteStr("Перемещайте курсор клавишами");
  c.At(1, 12); c.WriteStr("QAOP и ходите клавишей M. Если");
  c.At(1, 13); c.WriteStr("в выбранной позиции есть лиса,");
  c.At(1, 14); c.WriteStr("она считается пойманной, иначе");
  c.At(1, 15); c.WriteStr("Вы увидите число лис (пойман-");
  c.At(1, 16); c.WriteStr("ных и нет) по вертикали, гори-");
  c.At(1, 17); c.WriteStr("зонтали и диагоналях. Если Вы");
  c.At(1, 18); c.WriteStr("уверены, что в выбранном поле");
  c.At(1, 19); c.WriteStr("нет лис, его можно пометить");
  c.At(1, 20); c.WriteStr("клавишей X.");
  c.At(0, 22); c.WriteStr("╚══════════════════════════════╝");
  b.COLOR(b.Bright + b.Yellow);
  c.At(6, 22); c.WriteStr("НАЖМИ ЛЮБУЮ КЛАВИШУ");
  REPEAT UNTIL b.INKEY() # b.NoKey;
  IF is_sounds THEN b.BEEP(20, 20) END;
  b.PAUSE(3); b.POKE(23560, 0);
END Help;

PROCEDURE Menu;
  VAR key: CHAR;
BEGIN
  b.FONT(GrFonts.MsDosCgaRus8x8);
  REPEAT
    b.COLOR(b.Bright + b.Paper*b.LightCyan); b.BORDER(b.Cyan); b.CLS;
    c.At(12, 10); b.INK(b.LightRed); c.WriteStr("FOXHUNT!"); b.INK(b.Black);
    c.At(11, 12); c.WriteStr("1. ИГРАТЬ");
    c.At(11, 13); c.WriteStr("2. ПОМОЩЬ");
    c.At(11, 14); c.WriteStr("3. НАСТРОЙКИ");
    c.At(2, 22); c.WriteStr("Автор идеи А. Несчетный, 1985");
    c.At(2, 23); c.WriteStr("ZX-реализация by Yprit, 2020");
    REPEAT
      IF b.RND(0, 1) = 0 THEN END; (* RANDOMIZE *)
      key := CHR(b.PEEK(23560));
    UNTIL (key >= "1") & (key <= ("3"));
    IF is_sounds THEN b.BEEP(20, 20) END;
    b.OVER(b.On); b.PAPER(6); b.AT(SHORT(ORD(key) - 37), 11);
    b.PRSTR("            "); b.PAUSE(5); b.OVER(b.Off);
    CASE key OF
      | "2": Help;
      | "3": b.POKE(23560, 0); Settings;
    ELSE
    END;
    b.POKE(23560, 0);
  UNTIL key = "1";
END Menu;

PROCEDURE Control;
  VAR keys: SET; ticks: INT8;
BEGIN
  is_fire := FALSE; is_mark := FALSE;
  CASE CHR(b.PEEK(23560)) OF
    | "x", " ": is_mark := TRUE;
    | "m", 0DX, "0": is_fire := TRUE;
    | "q", "9": IF cur_y > 0 THEN DEC(cur_y) ELSE cur_y := Ym-1 END;
    | "a", "8": IF cur_y < Ym-1 THEN INC(cur_y) ELSE cur_y := 0 END;
    | "o", "6": IF cur_x > 0 THEN DEC(cur_x) ELSE cur_x := Xm-1 END;
    | "p", "7": IF cur_x < Xm-1 THEN INC(cur_x) ELSE cur_x := 0 END;
    | "e": is_end := TRUE;
  ELSE
    IF is_mouse THEN
      KMouse.SetXY(127, 95);
      ticks := 5; REPEAT
      b.PAUSE(1);
        keys := KMouse.Read();
        IF (keys # {}) THEN
          IF keys*{1} = {} THEN is_mark := TRUE END;
          IF keys*{0} = {} THEN is_fire := TRUE END;
        END;
      DEC(ticks) UNTIL ticks = 0;
      IF KMouse.Y > 159 THEN IF cur_y < Ym-1 THEN INC(cur_y) ELSE cur_y := 0 END END;
      IF KMouse.Y <  32 THEN IF cur_y > 0 THEN DEC(cur_y) ELSE cur_y := Ym-1 END END;
      IF KMouse.X <  64 THEN IF cur_x > 0 THEN DEC(cur_x) ELSE cur_x := Xm-1 END END;
      IF KMouse.X > 191 THEN IF cur_x < Xm-1 THEN INC(cur_x) ELSE cur_x := 0 END END;
    END;
  END;
  b.POKE(23560, 0);
END Control;

PROCEDURE CellColor (x, y, color: INT8);
  VAR adr: ADRINT;
BEGIN
  adr := y*64 + x*2 + 22561;
  b.POKE(adr, color); b.POKE(adr+1, color);
  b.POKE(adr+32, color); b.POKE(adr+33, color);
END CellColor;

PROCEDURE Cursor;
  VAR x,y: INT8;
BEGIN
  FOR x := Xm-1 TO 0 BY -1 DO
    FOR y := Ym-1 TO 0 BY -1 DO
      IF (x # cur_x) OR (y # cur_y) THEN
        IF (((ABS(cur_x-x)=ABS(cur_y-y))OR(x=cur_x)OR(y=cur_y))&((x#cur_x)OR(y#cur_y))) & is_axes THEN
          IF ~opened[x, y] THEN
            IF ~marked[x, y] THEN CellColor(x, y, c.BlackOnLGreen); (* an axe *)
            ELSE CellColor(x, y, c.LRedOnLGreen); (* a light flag *)
            END;
          ELSE 
            IF field[x, y] > 0 THEN CellColor(x, y, c.LRedOnYellow); (* a light fox *)
            ELSE CellColor(x, y, c.LBlueOnLWhite); (* a light number *)
            END;
          END;
        ELSE
          IF ~opened[x, y] THEN 
            IF ~marked[x, y] THEN CellColor(x, y, c.BlackOnGreen); (* an empty cell *)
            ELSE CellColor(x, y, c.RedOnGreen); (* a flag *)
            END;
          ELSE 
            IF field[x, y] > 0 THEN CellColor(x, y, c.RedOnOlive); (* fox *)
            ELSE CellColor(x, y, c.BlueOnGray); (* a number *)
            END;
          END;
        END;
      END;
    END;
  END;
  CellColor(cur_x, cur_y, c.BlackOnLCyan); (* cursor *)
END Cursor;

PROCEDURE Beep (x, t, f: INT8);
  VAR a: INT8;
BEGIN
  IF is_sounds THEN
    FOR a := x TO 1 BY -1 DO b.BEEP(t, f); b.PAUSE(2) END;
  END;
END Beep;

PROCEDURE Peleng;
  VAR foxes, x, y: INT8;
BEGIN
  IF ~opened[cur_x, cur_y] THEN
    opened[cur_x, cur_y] := TRUE; INC(turn); foxes := 0;
    IF field[cur_x, cur_y] = 0 THEN
      FOR x := Xm-1 TO 0 BY -1 DO
        FOR y := Ym-1 TO 0 BY -1 DO
          IF (ABS(cur_x-x) = ABS(cur_y-y)) OR (x = cur_x) OR (y = cur_y) (*ЭТИ И ПРОВЕРЯЕМ!*) THEN 
            IF field[x, y] # 0 THEN INC(foxes, field[x, y]); Beep(field[x, y],10,10) END;
          END;
        END;
      END;
      number[cur_x, cur_y] := foxes;
      g.DrawNoAtrTile16x16(2*cur_x+1, 2*cur_y+1, s.VAL(g.AnyTile, s.ADR(Numbers) + foxes*32));
    ELSE
      g.DrawNoAtrTile16x16(2*cur_x+1, 2*cur_y+1, Fox); (*добавить цифру?*)
      INC(fox_found, field[cur_x, cur_y]); Beep(field[cur_x, cur_y], 20, 20);
      IF field[cur_x, cur_y] # 1 THEN (* print a number of foxes *)
        b.AT(2*cur_y + 1, 2*cur_x + 1); b.PRWORD(field[cur_x, cur_y]);
        CellColor(cur_x, cur_y, 5*8+64);
      END;
    END;
  END;
END Peleng;

PROCEDURE PrintStat;
BEGIN
  b.AT(4, 25); b.PRWORD(FoxNum - fox_found);
  b.AT(9, 25); b.PRWORD(turn);
END PrintStat;

PROCEDURE EnderFox;
  VAR y: INT8;
BEGIN
  IF fox_found = FoxNum THEN
    c.At(25, 22); c.WriteStr("       ");
    b.COLOR(b.Bright + 5*b.Paper);
    FOR y := 5 TO 0 BY -1 DO c.At(6, y+9); c.WriteStr("│                │") END;
    c.At(6, 8); c.WriteStr("┌────────────────┐");
    c.At(9, 9); b.INK(2); c.WriteStr("ПОЗДРАВЛЯЕМ!"); b.INK(0);
    c.At(8, 10); c.WriteStr("Вы нашли N лис"); b.AT(10, 17); b.PRWORD(FoxNum);
    c.At(9, 11); c.WriteStr("за   ");
    IF CHR(turn) > CHR(99) THEN c.WriteCh(" ") END;
    IF CHR(turn) > CHR(9) THEN c.WriteCh(" ") END;
    b.AT(11, 12); b.PRWORD(turn); c.WriteStr("ходов");
    c.At(6, 15); c.WriteStr("└────────────────┘");
    b.INK(b.Magenta);
    c.At(7, 13); c.WriteStr("НАЖМИТЕ R, ЧТОБ");
    c.At(8, 14); c.WriteStr("ИГРАТЬ ЕЩЕ РАЗ");
    REPEAT UNTIL b.INKEY() = "r";
    b.PAUSE(3);
    is_end := TRUE;
  END;
END EnderFox;

PROCEDURE MarkCell;
  VAR x,y,openedfoxes: INT8;
BEGIN
  openedfoxes := 0;
  IF ~opened[cur_x, cur_y] THEN
    IF marked[cur_x, cur_y] THEN
      g.DrawNoAtrTile16x16(2*cur_x+1, 2*cur_y+1, Empty); marked[cur_x, cur_y] := FALSE;
    ELSIF ~marked[cur_x, cur_y] THEN
      g.DrawNoAtrTile16x16(2*cur_x+1, 2*cur_y+1, Flag); marked[cur_x, cur_y] := TRUE;
    END;
  ELSE (*если клетка открыта*)
    FOR x := Xm-1 TO 0 BY -1 DO
      FOR y := Ym-1 TO 0 BY -1 DO
        IF (ABS(cur_x-x) = ABS(cur_y-y)) OR (x=cur_x) OR (y=cur_y) THEN
          IF (field[x, y] # 0) & opened[x, y] THEN
            INC(openedfoxes, field[x, y]); Beep(field[x, y], 10, 10);
          END;
        END;
      END;
    END;
    IF number[cur_x, cur_y] = openedfoxes THEN
      FOR x := Xm-1 TO 0 BY -1 DO
        FOR y := Ym-1 TO 0 BY -1 DO
          IF (ABS(cur_x-x) = ABS(cur_y-y)) OR (x=cur_x) OR (y=cur_y) THEN
            IF ~opened[x, y] THEN g.DrawNoAtrTile16x16(x*2+1, y*2+1, Flag); marked[x, y] := TRUE END;
          END;
        END;
      END;
    END;
  END;
END MarkCell;

PROCEDURE Zero;
  VAR x, y: INT8;
BEGIN
  cur_x := 0; cur_y := 0; fox_found := 0; turn := 0;
  is_fire := FALSE; is_end := FALSE; is_line := FALSE;
  FOR x := Xm-1 TO 0 BY -1 DO
    FOR y := Ym-1 TO 0 BY -1 DO
      field[x, y] := 0; opened[x, y] := FALSE; marked[x, y] := FALSE;
    END;
  END;
END Zero;

PROCEDURE FoxPlot;
  VAR x, y, foxes: INT8;
BEGIN
  FOR foxes := FoxNum TO 1 BY -1 DO
    REPEAT
      x := SHORT(b.RND(0, Xm-1));
      y := SHORT(b.RND(0, Ym-1));
    UNTIL ~is_only1 OR (field[x, y] = 0);
    INC(field[x, y]);
  END;
END FoxPlot;

BEGIN (*$MAIN*)
  is_only1 := TRUE; is_axes := TRUE; is_sounds := TRUE; is_mouse := KMouse.Detect();
  LOOP
    Zero;
    Menu;
    cur_x := 0; cur_y := 0;
    FoxPlot;
    PrintField;
    REPEAT
      Control;
      Cursor;
      IF is_mark THEN MarkCell END;
      IF is_fire THEN Peleng END;
      PrintStat;
      EnderFox;
    UNTIL is_end;
  END;
END FoxHunt.
