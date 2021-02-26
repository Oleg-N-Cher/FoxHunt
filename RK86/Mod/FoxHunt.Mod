(* FoxHunt game by Saveliy Ivankov (Yprit), 2020 *)
(* https://vk.com/64kilobytes *)
(* Ported to Radio-86RK by Oleg N. Cher, 2021 *)
(* http://zx.oberon.org/foxhunt *)

MODULE FoxHunt; IMPORT m := RK86;

CONST
  Xm = 11; Ym = 11; (* Field size [width, height] *)
  FoxNum = 9; (* Number of foxes *)

  Flag = 1CX; (* 9X, 0BX, 1EX *)
  Fox = 1DX; (* 9X, 0EX, 1EX *)

VAR
  cur_x, cur_y, old_x, old_y, fox_found, turn: INT8;
  field, number: ARRAY Xm, Ym OF INT8;
  opened, marked: ARRAY Xm, Ym OF BOOLEAN;
  is_fire, is_mark, is_end: BOOLEAN; seed: INT16;
  is_only1, is_axes, is_sounds, is_line, is_auto: BOOLEAN;

PROCEDURE PrintField;
  VAR x, y: INT8;
BEGIN
  m.PUTCHAR(m.ClrScr);
  FOR x := Xm*4-2 TO 2 BY -4 DO
    FOR y := Ym TO 1 BY -1 DO
      m.CURSOR(x, y*2-1); m.PUTSTR("+---+"); (* 15X + 14X + 14X + 16X *)
      m.CURSOR(x, y*2); m.PUTSTR("!   !"); (* 13X + 3X + 20X + 6X *)
      m.CURSOR(x, y*2+1); m.PUTSTR("+---+"); (* 15X + 14X + 14X + 16X *)
    END;
  END;
  m.CURSOR(50, 2); m.PUTSTR("H A j T i");
  m.CURSOR(50, 3); m.PUTSTR("l i C");
  m.CURSOR(50, 7); m.PUTSTR("C d E l A H O");
  m.CURSOR(50, 8); m.PUTSTR("X O d O B");
  m.CURSOR(50, 22); m.PUTSTR("E - B y j T i");
END PrintField;

PROCEDURE Beep (x: INT8);
  VAR a: INT8;
BEGIN
  IF is_sounds THEN
    FOR a := x TO 1 BY -1 DO m.PUTCHAR(m.Bell); m.WAIT(3000) END;
  END;
END Beep;

PROCEDURE Settings;
  VAR key: CHAR;
BEGIN
  m.PUTCHAR(m.ClrScr);
  LOOP
    m.CURSOR(24, 10); m.PUTSTR("H A C T P O j K i");
    m.CURSOR(8, 12); m.PUTSTR("1 .   H A z A d   B   M E H `");
    m.CURSOR(8, 13); m.PUTSTR("2 .   T O l x K O   1   l i C A   B   p O l E");
    m.CURSOR(8, 14); m.PUTSTR("3 .   p O K A z A T x   H A p P A B l E H i q");
    m.CURSOR(8, 15); m.PUTSTR("4 .   z B u K i");
    m.CURSOR(56, 13);
  	IF is_only1 THEN m.PUTCHAR("Y") ELSE m.PUTCHAR("N") END;
    m.CURSOR(56, 14);
  	IF is_axes THEN m.PUTCHAR("Y") ELSE m.PUTCHAR("N") END;
    m.CURSOR(56, 15);
  	IF is_sounds THEN m.PUTCHAR("Y") ELSE m.PUTCHAR("N") END;
    m.CURSOR(8, 16); (* 5 !!! *)
    IF is_line THEN m.PUTSTR("5 .   p E P E d A T x   p P i B E T   M O i M   Y");
      m.CURSOR(14, 17); m.PUTSTR("d P u z x q M !");
    END;
    REPEAT key := m.GETKEY() UNTIL (key >= "1") & (key <= "5");
    Beep(1);
    m.WAIT(3000);
    CASE key OF
      | "1": EXIT
      | "2": is_only1 := ~is_only1;
      | "3": is_axes := ~is_axes;
      | "4": is_sounds := ~is_sounds;
    ELSE is_line := TRUE;
    END;
  END;
END Settings;

PROCEDURE Help;
  CONST
    Ramka = 3X+3X+3X+3X+3X+3X+3X+3X; Ramka2 = Ramka + Ramka + 3X+3X;
  VAR y: INT8;
BEGIN
  m.PUTCHAR(m.ClrScr);
  FOR y := 22 TO 2 BY -1 DO
    m.CURSOR(0, y); m.PUTSTR(6X + 6X); m.CURSOR(62, y); m.PUTSTR(11X + 11X);
  END;
  m.CURSOR(0, 1); m.PUTSTR(6X + Ramka2 + Ramka2 + Ramka2 + Ramka + 11X);
  m.CURSOR(2, 2);
  m.PUTSTR(Ramka2 + 3X+3X+3X + "  i C T O P i q  " + Ramka2 + 3X+3X+3X+3X);
  m.CURSOR(3, 4);
  m.PUTSTR("O C H O B A H O   H A   i g P E   d l q  C O B E T C K i X");
  m.CURSOR(3, 5);
  m.PUTSTR("K A l x K u l q T O P O B ,   i z B E C T H O j   K A K");
  m.CURSOR(3, 6);
  m.PUTSTR('" O X O T A   H A   l i C " .   O P i g i H A l x H A q');
  m.CURSOR(3, 7);
  m.PUTSTR("i g P A   O C H O B A H A   H A   C p O P T i B H O j");
  m.CURSOR(3, 8);
  m.PUTSTR("P A d i O p E l E H g A c i i   ( C P p ) .");
  m.CURSOR(2, 10);
  m.PUTSTR(Ramka2 + 3X + "  K A K   i g P A T x  " + Ramka2 + 11X);
  m.CURSOR(3, 12);
  m.PUTSTR("p E P E M E } A j T E   K u P C O P   C T P E l K A M i");
  m.CURSOR(3, 13);
  m.PUTSTR('i   X O d i T E   K l A B i { E j   ENTER .   E C l i   B');
  m.CURSOR(3, 14);
  m.PUTSTR("B y b P A H H O j   p O z i c i i   E C T x   l i C A ,");
  m.CURSOR(3, 15);
  m.PUTSTR("O H A   C ~ i T A E T C q   p O j M A H H O j ,  i H A ~ E");
  m.CURSOR(3, 16);
  m.PUTSTR("B y   u B i d i T E   ~ i C l O   l i C   ( p O j M A H -");
  m.CURSOR(3, 17);
  m.PUTSTR("H y X   i   H E T )   p O   B E P T i K A l i ,  g O P i -");
  m.CURSOR(3, 18);
  m.PUTSTR("z O H T A l i   i   d i A g O H A l q X.  E C l i   B y");
  m.CURSOR(3, 19);
  m.PUTSTR("u B E P E H y ,   ~ T O   B   B y b P A H H O M    p O l E");
  m.CURSOR(3, 20);
  m.PUTSTR("H E T   l i C ,   E g O   M O v H O   p O M E T i T x");
  m.CURSOR(3, 21);
  m.PUTSTR('K l A B i { E j   pPObEl .');
  m.CURSOR(0, 23);
  m.PUTSTR(6X + 16X + 14X+14X+14X+14X+14X+14X+14X+14X+14X
    + "  H A v M i   l ` b u `   K l A B i { u  "
    +14X+14X+14X+14X+14X+14X+14X+14X+14X+14X + 15X + 11X);
  REPEAT UNTIL m.GETKEY() # m.NoKey;
  Beep(1);
  m.WAIT(500);
END Help;

PROCEDURE Menu;
  VAR key: CHAR;
BEGIN
  REPEAT
    m.PUTCHAR(m.ClrScr); (* Clear screen *)
    m.CURSOR(24, 9); m.PUTSTR("F O X H U N T !");
    m.CURSOR(22, 11); m.PUTSTR("1 .   i g P A T x");
    m.CURSOR(22, 12); m.PUTSTR("2 .   p O M O } x");
    m.CURSOR(22, 13); m.PUTSTR("3 .   H A C T P O j K i");
    m.CURSOR(3, 22); m.PUTSTR("A B T O P   i d E i   "
      + "A .   H E C ~ E T H y j ,   1 9 8 5");
    m.CURSOR(4, 23); m.PUTSTR("Z X - P E A l i z A c i q   "
      + "B Y   Y P R I T ,   2 0 2 0");
    m.CURSOR(2, 24); m.PUTSTR("P K 8 6 - p O P T   "
      + "B Y   O L E G   N .  C H E R ,  2 0 2 1");
    REPEAT
      m.RANDOMIZE(seed); INC(seed); key := m.GETKEY();
    UNTIL (key >= "1") & (key <= ("3"));
    Beep(1);
    m.CURSOR(22, SHORT(ORD(key) - 38));
    m.PUTSTR(7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX
      +7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX+7FX);
    m.WAIT(1000); (* Delay *)
    CASE key OF
      | "2": Help;
      | "3": Settings;
    ELSE
    END;
  UNTIL key = "1";
END Menu;

PROCEDURE Control;
  VAR exit: BOOLEAN;
BEGIN
  m.CURSOR(4*(cur_x+1), 2*(cur_y+1));
  is_fire := FALSE; is_mark := FALSE;
  REPEAT
    exit := TRUE;
    CASE m.GETKEY() OF
      | " ": is_mark := TRUE; m.WAIT(5000);
      | 0DX, "0": is_fire := TRUE;
      | 19X, "9": IF cur_y > 0 THEN DEC(cur_y) ELSE cur_y := Ym-1 END;
      | 1AX, "8": IF cur_y < Ym-1 THEN INC(cur_y) ELSE cur_y := 0 END;
      | 8X, "6": IF cur_x > 0 THEN DEC(cur_x) ELSE cur_x := Xm-1 END;
      | 18X, "7": IF cur_x < Xm-1 THEN INC(cur_x) ELSE cur_x := 0 END;
      | "E": is_end := TRUE;
    ELSE
      exit := FALSE
    END;
  UNTIL exit;
END Control;

PROCEDURE CellColor (x, y: INT8; on: BOOLEAN);
BEGIN
  m.CURSOR(4*(x+1)-1, 2*(y+1));
  IF on THEN m.PUTSTR("/" + 18X + "/"); (* 11X + 18X + 6X *)
  ELSE m.PUTSTR(" " + 18X + " ");
  END;
  IF (opened[x, y]) & (CHR(field[x, y]) > 1X) THEN (* fix a number of foxes, if needs *)
    m.CURSOR(4*(x+1)-1, 2*(y+1)); m.PUTCHAR(CHR(field[x, y] + ORD("0")));
  END;
END CellColor;

PROCEDURE Cursor (cur_x, cur_y: INT8; on: BOOLEAN);
  VAR x,y: INT8;
BEGIN
  FOR x := Xm-1 TO 0 BY -1 DO
    FOR y := Ym-1 TO 0 BY -1 DO
      IF (ABS(cur_x-x) = ABS(cur_y-y)) OR (x=cur_x) OR (y=cur_y) THEN
        CellColor(x, y, on);
      END;
    END;
  END;
END Cursor;

PROCEDURE PRINT (x: INT8);
  VAR dig: INT8; zero: BOOLEAN;
BEGIN
  zero := (x < 100);
  IF ~zero THEN m.PUTSTR("1 "); DEC(x, 100) END;
  dig := x DIV0 10;
  IF ~zero OR (dig # 0) THEN m.PUTCHAR(CHR(dig + 30H)); m.PUTCHAR(" ") END;
  m.PUTCHAR(CHR(x REM0 10 + 30H)); m.PUTCHAR(" ");
END PRINT;

PROCEDURE Peleng;
  VAR foxes, x, y: INT8;
BEGIN
  IF ~opened[cur_x, cur_y] THEN
    opened[cur_x, cur_y] := TRUE; INC(turn); foxes := 0;
    IF field[cur_x, cur_y] = 0 THEN
      FOR x := Xm-1 TO 0 BY -1 DO
        FOR y := Ym-1 TO 0 BY -1 DO
          IF (ABS(cur_x-x) = ABS(cur_y-y)) OR (x = cur_x) OR (y = cur_y) (*ЭТИ И ПРОВЕРЯЕМ!*) THEN 
            IF field[x, y] # 0 THEN INC(foxes, field[x, y]); Beep(field[x, y]) END;
          END;
        END;
      END;
      number[cur_x, cur_y] := foxes;
      m.CURSOR(4*(cur_x+1), 2*(cur_y+1)); m.PUTCHAR(CHR(foxes + ORD("0")));
    ELSE
      m.CURSOR(4*(cur_x+1), 2*(cur_y+1)); m.PUTCHAR(Fox); (*добавить цифру?*)
      INC(fox_found, field[cur_x, cur_y]); Beep(field[cur_x, cur_y]);
      IF field[cur_x, cur_y] # 1 THEN
        m.CURSOR(4*(cur_x+1)-1, 2*(cur_y+1)); m.PUTCHAR(CHR(field[cur_x, cur_y] + ORD("0")));
      END; (* print a number of foxes *)
    END;
  END;
END Peleng;

PROCEDURE PrintStat;
BEGIN
  m.CURSOR(50, 5); PRINT(FoxNum - fox_found);
  m.CURSOR(50, 10); PRINT(turn);
END PrintStat;

PROCEDURE EnderFox;
  CONST
    Ramka1 = 3X+3X+3X+3X+3X+3X+3X+3X+3X+3X+3X+3X+3X+3X+3X+3X;
    Ramka2 = 14X+14X+14X+14X+14X+14X+14X+14X+14X+14X+14X+14X+14X+14X+14X+14X;
  VAR y: INT8;
BEGIN
  IF fox_found = FoxNum THEN
    m.CURSOR(50, 22); m.PUTSTR("             ");
    FOR y := 5 TO 0 BY -1 DO
      m.CURSOR(13, y+10); m.PUTSTR(6X + "                                 " + 11X);
    END;
    m.CURSOR(13, 9); m.PUTSTR(6X + Ramka1 + 3X + Ramka1 + 11X);
    m.CURSOR(19, 10); m.PUTSTR("p O z d P A B l q E M !");
    m.CURSOR(17, 11); m.PUTSTR("B y   H A { l i   "); PRINT(FoxNum); m.PUTSTR("  l i C");
    m.CURSOR(19, 12); m.PUTSTR("z A   "); PRINT(turn); m.PUTSTR("  X O d O B");
    m.CURSOR(13, 16); m.PUTSTR(6X + Ramka2 + 14X + Ramka2 + 11X);
    m.CURSOR(15, 14); m.PUTSTR("H A v M i T E   R ,   " + 7EX + " T O b");
    m.CURSOR(17, 15); m.PUTSTR("i g P A T x   E } E   P A z ");
    REPEAT UNTIL m.GETKEY() = "R";
    m.WAIT(3000);
    is_end := TRUE;
  END;
END EnderFox;

PROCEDURE MarkCell;
  VAR x,y,openedfoxes: INT8;
BEGIN
  openedfoxes := 0;
  IF ~opened[cur_x, cur_y] THEN
    IF marked[cur_x, cur_y] THEN
      m.CURSOR(4*(cur_x+1), 2*(cur_y+1)); m.PUTCHAR(" "); marked[cur_x, cur_y] := FALSE;
    ELSIF ~marked[cur_x, cur_y] THEN
      m.CURSOR(4*(cur_x+1), 2*(cur_y+1)); m.PUTCHAR(Flag); marked[cur_x, cur_y] := TRUE;
    END;
  ELSE (* если клетка открыта *)
    FOR x := Xm-1 TO 0 BY -1 DO
      FOR y := Ym-1 TO 0 BY -1 DO
        IF (ABS(cur_x-x) = ABS(cur_y-y)) OR (x=cur_x) OR (y=cur_y) THEN
          IF (field[x, y] # 0) & opened[x, y] THEN
            INC(openedfoxes, field[x, y]); Beep(field[x, y]);
          END;
        END;
      END;
    END;
    IF number[cur_x, cur_y] = openedfoxes THEN
      FOR x := Xm-1 TO 0 BY -1 DO
        FOR y := Ym-1 TO 0 BY -1 DO
          IF (ABS(cur_x-x) = ABS(cur_y-y)) OR (x=cur_x) OR (y=cur_y) THEN
            IF ~opened[x, y] THEN
              m.CURSOR(4*(x+1), 2*(y+1)); m.PUTCHAR(Flag); marked[x, y] := TRUE;
            END;
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
      x := ABS(m.RND8()) REM0 Xm;
      y := ABS(m.RND8()) REM0 Ym;
    UNTIL ~is_only1 OR (field[x, y] = 0);
    INC(field[x, y]);
  END;
END FoxPlot;

BEGIN (*$MAIN*)
  seed := 1;
  is_only1 := TRUE; is_axes := TRUE; is_sounds := TRUE;
  LOOP
    Zero;
    Menu;
    cur_x := 0; cur_y := 0;
    FoxPlot;
    PrintField;
    IF is_axes THEN Cursor(cur_x, cur_y, TRUE) END;
    REPEAT
      PrintStat;
      old_x := cur_x; old_y := cur_y;
      Control;
      IF (old_x # cur_x) OR (old_y # cur_y) THEN
        IF is_axes THEN
          Cursor(old_x, old_y, FALSE); Cursor(cur_x, cur_y, TRUE);
        ELSE
          m.WAIT(7500);
        END;
      END;
      IF is_mark THEN MarkCell END;
      IF is_fire THEN Peleng END;
      PrintStat;
      EnderFox;
    UNTIL is_end;
  END;
END FoxHunt.
