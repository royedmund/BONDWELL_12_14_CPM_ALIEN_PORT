;==============================================================================
; ALIENS_DOCUMENTED.ASM
;
; Documented, byte-exact Z80 reconstruction of the current Bondwell ALIENS.COM
; derived from the original Kaypro/Yahoo Software ALIENS.COM binary.
;
; CP/M load address : 0100H
; Original image    : 3800H bytes (14,336)
; Current image     : 4077H bytes (16,503)
; Current end       : 4177H
;
; The original symbolic source was not present in the executable.
; The original Kaypro area is emitted as exact DB directives. Recognised
; modifications and all appended MC1408 routines are labelled and explained.
;
; Runtime address = COM file offset + 0100H
;==============================================================================

BDOS            EQU     0005H
DAC_PORT        EQU     050H       ; MC1408 decoded at 50H-5FH

;------------------------------------------------------------------------------
; Patch map relative to the original Kaypro executable
;------------------------------------------------------------------------------
; File    Runtime  Change                         Purpose
; 138BH   148BH    31H -> FFH                     Disable original level-1 key
; 1397H   1497H    32H -> 31H                     Start game with key 1
; 13A3H   14A3H    33H -> FFH                     Disable original level-3 key
; 13AFH   14AFH    34H -> FFH                     Disable original level-4 key
; 13BBH   14BBH    35H -> FFH                     Disable original level-5 key
; 13C7H   14C7H    36H -> FFH                     Disable original level-6 key
; 1432H   1532H    2A 15 01 -> CD 32 41           Player firing sound hook
; 1476H   1576H    02H -> 03H                     Alien return-fire variation
; 1985H   1A85H    21 77 1B -> CD 51 41           Turret-hit explosion hook
; 218CH   228CH    2A 15 01 -> CD 00 41           Alien movement sound hook
; 296EH   2A6EH    20H -> 00H                     Hide original level-1 menu
; 299CH   2A9CH    menu text replaced             <1> Start Game
; 29D1H   2AD1H    20H -> 00H                     Hide original level-3 menu
; 2A0CH   2B0CH    20H -> 00H                     Hide original level-4 menu
; 2A48H   2B48H    20H -> 00H                     Hide original level-5 menu
; 2A74H   2B74H    20H -> 00H                     Hide original level-6 menu
; 2C5FH   2D5FH    OXO -> 4F D8 4F                Alien frame
; 2C65H   2D65H    XOX -> 58 CF 58                Alien frame
; 2C6BH   2D6BH    "\o/" -> 2F CF 5C              Alien frame
; 2C71H   2D71H    "/o\\" -> 5C 4F 2F             Alien frame
; 2C77H   2D77H    '"M"' -> 83 80 83              Alien frame
; 2C7DH   2D7DH    wMw -> 88 83 84                Alien frame
; 2C89H   2D89H    xx|xx -> 8B 83 80 83 87        Player turret
; 2C91H   2D91H    23H -> 80H                     Barrier character

; Appended sound routines:
;   4100H SND_ALIEN_MOVE
;   4132H SND_FIRE
;   4151H SND_PLAYER_HIT

                ORG     0100H

                DB      2AH,06H,00H,0F9H,00H,00H,00H,00H,00H,00H,00H,00H,0CDH,4BH,03H,0CDH ; 0100: *............K..
                DB      9EH,07H,0C3H,2BH,04H,1DH,38H,9EH,06H,1DH,38H,88H,3FH,0C3H,27H,04H ; 0110: ...+..8...8.?.'.
                DB      0C3H,2BH,04H,0C3H,46H,04H,0C3H,8EH,04H,0C3H,72H,04H,0C3H,1AH,05H,0C3H ; 0120: .+..F.....r.....
                DB      0FBH,0CH,0CDH,96H,0DH,0FEH,38H,0CAH,7BH,0CH,0E6H,08H,0C4H,82H,11H,77H ; 0130: ......8.{......w
                DB      23H,77H,23H,77H,0D1H,0C1H,0C9H,0CDH,0C6H,04H,0C3H,0DEH,04H,0E1H,5EH,23H ; 0140: #w#w..........^#
                DB      56H,23H,0E5H,2AH,15H,01H,19H,7EH,23H,66H,6FH,0C9H,0E1H,5EH,23H,0E5H ; 0150: V#.*...~#fo..^#.
                DB      16H,00H,2AH,15H,01H,19H,7EH,23H,66H,6FH,0C9H,0E1H,5EH,23H,56H,23H ; 0160: ..*...~#fo..^#V#
                DB      0E5H,2AH,15H,01H,19H,6EH,0C9H,0E1H,5EH,23H,0E5H,16H,00H,2AH,15H,01H ; 0170: .*...n..^#...*..
                DB      19H,6EH,0C9H,0E1H,5EH,23H,56H,23H,0E5H,0EBH,09H,7EH,23H,66H,6FH,0C9H ; 0180: .n..^#V#...~#fo.
                DB      0E1H,5EH,23H,0E5H,0EBH,26H,00H,09H,7EH,23H,66H,6FH,0C9H,21H,01H,00H ; 0190: .^#..&..~#fo.!..
                DB      0C8H,2BH,0C9H,21H,00H,00H,0C8H,23H,0C9H,21H,01H,00H,0D8H,2BH,0C9H,21H ; 01A0: .+.!...#.!...+.!
                DB      00H,00H,0D8H,23H,0C9H,21H,01H,00H,0F0H,2BH,0C9H,21H,01H,00H,0F8H,2BH ; 01B0: ...#.!...+.!...+
                DB      0C9H,11H,01H,00H,0C8H,1BH,0C9H,11H,00H,00H,0C8H,13H,0C9H,11H,01H,00H ; 01C0: ................
                DB      0D8H,1BH,0C9H,11H,00H,00H,0D8H,13H,0C9H,11H,01H,00H,0F0H,1BH,0C9H,11H ; 01D0: ................
                DB      01H,00H,0F8H,1BH,0C9H,7DH,0BBH,0C0H,7CH,0BAH,0C9H,0EBH,7AH,0BCH,0C0H,7BH ; 01E0: .....}..|...z..{
                DB      0BDH,0C9H,0EBH,7CH,0BAH,0C0H,7DH,0BBH,0C9H,0EBH,7CH,0AAH,0F2H,0ECH,01H,7AH ; 01F0: ...|..}...|....z
                DB      0B7H,0F0H,37H,0C9H,0EBH,7CH,0AAH,0F2H,0F3H,01H,7CH,0B7H,0F0H,37H,0C9H,7AH ; 0200: ..7..|....|..7.z
                DB      0F5H,0CDH,5AH,02H,0EBH,0CDH,5AH,02H,0EBH,0CDH,29H,02H,0F1H,0B7H,0F0H,7CH ; 0210: ..Z...Z...)....|
                DB      2FH,67H,7DH,2FH,6FH,23H,0C9H,00H,00H,7CH,0B5H,0C8H,0D5H,0E5H,0CDH,89H ; 0220: /g}/o#...|......
                DB      02H,0D1H,0CDH,6BH,02H,7CH,2FH,67H,7DH,2FH,6FH,23H,0D1H,19H,0C9H,0AFH ; 0230: ...k.|/g}/o#....
                DB      32H,71H,05H,0CDH,5AH,02H,0EBH,0CDH,5AH,02H,0CDH,6BH,02H,3AH,71H,05H ; 0240: 2q..Z...Z..k.:q.
                DB      1FH,0D0H,7CH,2FH,67H,7DH,2FH,6FH,23H,0C9H,7CH,0B7H,0F0H,2FH,67H,7DH ; 0250: ..|/g}/o#.|../g}
                DB      2FH,6FH,23H,3AH,71H,05H,3CH,32H,71H,05H,0C9H,0C5H,0CDH,71H,02H,0C1H ; 0260: /o#:q.<2q....q..
                DB      0C9H,44H,4DH,21H,00H,00H,78H,0B1H,0C8H,78H,1FH,47H,79H,1FH,4FH,0D2H ; 0270: .DM!..x..x.Gy.O.
                DB      83H,02H,19H,0EBH,29H,0EBH,0C3H,76H,02H,7CH,0B5H,0C8H,0C5H,0CDH,94H,02H ; 0280: ....)..v.|......
                DB      60H,69H,0C1H,0C9H,06H,01H,7CH,0B7H,0FAH,0A0H,02H,29H,04H,0C3H,96H,02H ; 0290: `i....|....)....
                DB      0EBH,78H,01H,00H,00H,0F5H,0CDH,0DDH,02H,0DAH,0B7H,02H,03H,0D5H,7AH,2FH ; 02A0: .x............z/
                DB      57H,7BH,2FH,5FH,13H,19H,0D1H,0AFH,7AH,1FH,57H,7BH,1FH,5FH,0F1H,3DH ; 02B0: W{/_....z.W{._.=
                DB      0C8H,0F5H,79H,17H,4FH,78H,17H,47H,0C3H,0A6H,02H,0AFH,32H,71H,05H,0CDH ; 02C0: ..y.Ox.G....2q..
                DB      5AH,02H,0EBH,0CDH,5AH,02H,0EBH,0CDH,89H,02H,0C3H,4DH,02H,7CH,0BAH,0D8H ; 02D0: Z...Z......M.|..
                DB      0C0H,7DH,0BBH,0C9H,0EBH,1CH,1DH,0C8H,0AFH,7CH,1FH,67H,7DH,1FH,6FH,0C3H ; 02E0: .}.......|.g}.o.
                DB      0E6H,02H,0EBH,1CH,1DH,0C8H,29H,0C3H,0F4H,02H,7CH,2FH,67H,7DH,2FH,6FH ; 02F0: ......)...|/g}/o
                DB      23H,0C9H,7AH,2FH,57H,7BH,2FH,5FH,13H,0C9H,21H,04H,00H,39H,7EH,23H ; 0300: #.z/W{/_..!..9~#
                DB      66H,6FH,0C9H,21H,06H,00H,0C3H,0DH,03H,21H,08H,00H,0C3H,0DH,03H,21H ; 0310: fo.!.....!.....!
                DB      0AH,00H,0C3H,0DH,03H,21H,0CH,00H,0C3H,0DH,03H,21H,0EH,00H,0C3H,0DH ; 0320: .....!.....!....
                DB      03H,21H,10H,00H,0C3H,0DH,03H,11H,9FH,05H,21H,04H,00H,39H,0C5H,06H ; 0330: .!........!..9..
                DB      0EH,7EH,12H,23H,13H,05H,0C2H,41H,03H,0C1H,0C9H,0E1H,22H,73H,05H,21H ; 0340: .~.#...A...."s.!
                DB      60H,07H,0E5H,2AH,1BH,01H,22H,0B3H,05H,21H,0E8H,03H,22H,0B5H,05H,21H ; 0350: `..*.."..!.."..!
                DB      0DCH,59H,22H,97H,05H,3EH,0DBH,32H,0ADH,05H,3EH,0D3H,32H,0B0H,05H,3EH ; 0360: .Y"..>.2..>.2..>
                DB      0C9H,32H,0AFH,05H,32H,0B2H,05H,21H,00H,0CCH,22H,8FH,05H,21H,10H,00H ; 0370: .2..2..!.."..!..
                DB      22H,93H,05H,21H,40H,00H,22H,91H,05H,21H,00H,04H,22H,95H,05H,0EH ; 0380: "..!@."..!.."...
                DB      0BH,0CDH,05H,00H,0E6H,01H,0CAH,9EH,03H,0EH,01H,0CDH,05H,00H,21H,80H ; 0390: ..............!.
                DB      00H,11H,0DFH,06H,46H,23H,78H,0B7H,0C2H,0B1H,03H,11H,01H,00H,0C3H,0FH ; 03A0: ....F#x.........
                DB      04H,7EH,12H,23H,13H,05H,0C2H,0B1H,03H,0AFH,12H,21H,0DFH,06H,11H,01H ; 03B0: .~.#.......!....
                DB      00H,01H,62H,07H,0AFH,32H,72H,05H,7EH,23H,0FEH,20H,0CAH,0C8H,03H,0B7H ; 03C0: ..b..2r.~#. ....
                DB      0CAH,0FH,04H,0FEH,22H,0C2H,0DEH,03H,32H,72H,05H,0C3H,0DFH,03H,2BH,7DH ; 03D0: ...."...2r....+}
                DB      02H,03H,7CH,02H,03H,13H,7EH,23H,0B7H,0CAH,0FH,04H,0C5H,47H,3AH,72H ; 03E0: ..|...~#.....G:r
                DB      05H,0B7H,78H,0C1H,0CAH,03H,04H,0FEH,22H,0C2H,0E6H,03H,0AFH,32H,72H,05H ; 03F0: ..x....."....2r.
                DB      2BH,77H,23H,0FEH,20H,0C2H,0E6H,03H,2BH,36H,00H,23H,0C3H,0C8H,03H,0D5H ; 0400: +w#. ...+6.#....
                DB      06H,08H,21H,0D7H,06H,36H,00H,23H,05H,0C2H,15H,04H,0AFH,32H,77H,05H ; 0410: ..!..6.#.....2w.
                DB      32H,78H,05H,2AH,73H,05H,0E9H,21H,0FFH,0FFH,0C9H,3EH,0FH,0F5H,0CDH,72H ; 0420: 2x.*s..!...>...r
                DB      04H,0DAH,3CH,04H,6FH,26H,00H,0E5H,0CDH,46H,04H,0E1H,0F1H,3DH,0FEH,07H ; 0430: ..<.o&...F...=..
                DB      0C2H,2DH,04H,0C3H,00H,00H,0CDH,60H,05H,0CDH,0AH,03H,0CDH,72H,04H,0DAH ; 0440: .-.....`.....r..
                DB      27H,04H,7EH,0E6H,04H,0CAH,68H,04H,0E5H,0CDH,13H,03H,0C5H,0CDH,1AH,05H ; 0450: '.~...h.........
                DB      0EBH,0EH,10H,0CDH,05H,00H,0C1H,0E1H,36H,00H,0FEH,0FFH,21H,00H,00H,0C0H ; 0460: ........6...!...
                DB      2BH,0C9H,0CDH,60H,05H,57H,0D6H,08H,0D8H,0FEH,08H,3FH,0D8H,0D5H,5FH,16H ; 0470: +..`.W.....?.._.
                DB      00H,21H,0D7H,06H,19H,7EH,0E6H,01H,37H,0D1H,7AH,0C8H,3FH,0C9H,0CDH,60H ; 0480: .!...~..7.z.?..`
                DB      05H,0C5H,0CDH,0CH,05H,06H,08H,0E5H,13H,1AH,1BH,0FEH,3AH,3EH,00H,0C2H ; 0490: ............:>..
                DB      0AAH,04H,1AH,0CDH,03H,05H,0D6H,40H,13H,13H,77H,23H,0CDH,47H,01H,1AH ; 04A0: .......@..w#.G..
                DB      0FEH,2EH,0C2H,0B6H,04H,13H,06H,03H,0CDH,0C6H,04H,0AFH,77H,11H,14H,00H ; 04B0: ............w...
                DB      19H,77H,23H,0C3H,3FH,01H,0C5H,1AH,0FEH,2AH,3EH,3FH,0CAH,0E9H,04H,1AH ; 04C0: .w#.?....*>?....
                DB      0CDH,0F1H,04H,0DAH,0E7H,04H,77H,23H,13H,05H,0C2H,0C7H,04H,0C1H,1AH,0CDH ; 04D0: ......w#........
                DB      0F1H,04H,0D8H,13H,0C3H,0DEH,04H,3EH,20H,77H,23H,05H,0C2H,0E9H,04H,0C1H ; 04E0: .......> w#.....
                DB      0C9H,0CDH,03H,05H,0FEH,2EH,37H,0C8H,0FEH,3AH,37H,0C8H,0FEH,7FH,37H,0C8H ; 04F0: ......7..:7...7.
                DB      0FEH,21H,0C9H,0FEH,61H,0D8H,0FEH,7BH,0D0H,0D6H,20H,0C9H,1BH,13H,1AH,0FEH ; 0500: .!..a..{.. .....
                DB      20H,0CAH,0DH,05H,0FEH,09H,0CAH,0DH,05H,0C9H,0C5H,0CDH,60H,05H,0B7H,4FH ; 0510:  ...........`..O
                DB      0C2H,45H,05H,06H,08H,11H,0D7H,06H,21H,0B7H,05H,0EH,08H,1AH,0E6H,01H ; 0520: .E......!.......
                DB      79H,0C2H,36H,05H,0C1H,0C9H,0D5H,11H,24H,00H,19H,0D1H,13H,0CH,05H,0C2H ; 0530: y.6.....$.......
                DB      2DH,05H,37H,0C1H,0C9H,0CDH,72H,04H,0DAH,42H,05H,0D6H,08H,6FH,26H,00H ; 0540: -.7...r..B...o&.
                DB      29H,29H,54H,5DH,29H,29H,29H,19H,0EBH,21H,0B7H,05H,19H,79H,0C1H,0C9H ; 0550: ))T])))..!...y..
                DB      0D5H,0C5H,0F5H,0E5H,0EH,1AH,11H,80H,00H,0CDH,05H,00H,0E1H,0F1H,0C1H,0D1H ; 0560: ................
                DB      0C9H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H ; 0570: ................
                DB      56H,35H,0F1H,0C9H,0E5H,3AH,19H,3DH,0E6H,11H,0C2H,62H,23H,3AH,19H,3DH ; 0580: V5...:.=...b#:.=
                DB      0E6H,02H,0C2H,0F9H,23H,3AH,24H,3DH,0E6H,01H,0CAH,32H,23H,0CDH,76H,2BH ; 0590: ....#:$=...2#.v+
                DB      3AH,0E0H,3CH,0B7H,0C2H,0F2H,22H,0CDH,0EAH,28H,0C2H,0C3H,22H,3EH,36H,0CDH ; 05A0: :.<..."..(..">6.
                DB      8BH,35H,3AH,26H,3DH,0CDH,8BH,35H,0C3H,1FH,23H,2AH,26H,3DH,7CH,0B5H ; 05B0: .5:&=..5..#*&=|.
                DB      0C2H,0D4H,22H,11H,4DH,31H,0CDH,0BFH,35H,0C3H,1FH,23H,3EH,36H,0CDH,8BH ; 05C0: ..".M1..5..#>6..
                DB      35H,3AH,26H,3DH,0CDH,8BH,35H,3EH,23H,0CDH,8BH,35H,3EH,36H,0CDH,8BH ; 05D0: 5:&=..5>#..5>6..
                DB      35H,3AH,27H,3DH,0CDH,8BH,35H,0C3H,1FH,23H,2AH,26H,3DH,22H,0FCH,3CH ; 05E0: 5:'=..5..#*&=".<
                DB      0CDH,0EAH,28H,0C2H,16H,23H,3EH,1EH,0CDH,8BH,35H,3AH,26H,3DH,0CDH,8BH ; 05F0: ..(..#>...5:&=..
                DB      35H,3EH,73H,0CDH,8BH,35H,3EH,40H,32H,19H,3DH,0C3H,1FH,23H,11H,52H ; 0600: 5>s..5>@2.=..#.R
                DB      31H,0CDH,0BFH,35H,0C3H,0EH,23H,0CDH,0D1H,28H,0C2H,2CH,23H,3AH,1DH,3DH ; 0610: 1..5..#..(.,#:.=
                DB      3DH,32H,1DH,3DH,0E1H,0F1H,0CDH,01H,29H,0C9H,0CDH,0EAH,28H,0C2H,40H,23H ; 0620: =2.=....)...(.@#
                DB      3EH,73H,0CDH,8BH,35H,0C3H,0EH,23H,0CDH,98H,28H,0C2H,59H,23H,11H,58H ; 0630: >s..5..#..(.Y#.X
                DB      31H,3AH,0E0H,3CH,0B7H,0CAH,53H,23H,11H,5DH,31H,0CDH,0BFH,35H,0C3H,0EH ; 0640: 1:.<..S#.]1..5..
                DB      23H,11H,88H,32H,0CDH,0BFH,35H,0C3H,0EH,23H,2AH,1BH,3DH,22H,0FCH,3CH ; 0650: #..2..5..#*.=".<
                DB      2AH,26H,3DH,22H,0FEH,3CH,3AH,24H,3DH,0E6H,01H,0CAH,0C3H,23H,3AH,0E0H ; 0660: *&=".<:$=....#:.
                DB      3CH,0B7H,0C2H,0A4H,23H,0CDH,0EAH,28H,0C2H,97H,23H,3EH,3EH,0CDH,8BH,35H ; 0670: <...#..(..#>>..5
                DB      3AH,26H,3DH,0CDH,8BH,35H,11H,63H,31H,0CDH,0BFH,35H,0C3H,1FH,23H,11H ; 0680: :&=..5.c1..5..#.
                DB      66H,31H,0CDH,0BFH,35H,0AFH,32H,19H,3DH,0C3H,1FH,23H,0CDH,0EAH,28H,0C2H ; 0690: f1..5.2.=..#..(.
                DB      97H,23H,3EH,1EH,0CDH,8BH,35H,3AH,26H,3DH,0CDH,8BH,35H,3EH,7BH,0CDH ; 06A0: .#>...5:&=..5>{.
                DB      8BH,35H,11H,63H,31H,0CDH,0BFH,35H,0C3H,0EH,23H,0CDH,0EAH,28H,0C2H,0DCH ; 06B0: .5.c1..5..#..(..
                DB      23H,3AH,24H,3DH,0E6H,0C0H,0C2H,0B5H,23H,3EH,7DH,0CDH,8BH,35H,11H,63H ; 06C0: #:$=....#>}..5.c
                DB      31H,0C3H,9AH,23H,3AH,24H,3DH,0E6H,0C0H,0C4H,3BH,2DH,0CDH,98H,28H,0C2H ; 06D0: 1..#:$=....-..(.
                DB      0F3H,23H,3EH,26H,0CDH,8BH,35H,0AFH,0CDH,8BH,35H,11H,66H,32H,0C3H,9AH ; 06E0: .#>&..5...5.f2..
                DB      23H,3AH,24H,3DH,0E6H,01H,0CAH,07H,24H,0CDH,76H,2BH,0C3H,0A8H,22H,3AH ; 06F0: #:$=....$.v+..":
                DB      19H,3DH,0E6H,08H,0C2H,18H,24H,0CDH,7FH,2CH,0CDH,76H,2BH,0C3H,32H,23H ; 0700: .=....$..,.v+.2#
                DB      3AH,24H,3DH,0E6H,0C0H,3EH,0E5H,0CAH,24H,24H,3EH,0D5H,0CDH,8BH,35H,0CDH ; 0710: :$=..>..$$>...5.
                DB      76H,2BH,3EH,0D1H,0CDH,8BH,35H,3EH,40H,32H,24H,3DH,0C3H,32H,23H,0E5H ; 0720: v+>...5>@2$=.2#.
                DB      2AH,1BH,3DH,22H,0FCH,3CH,0E1H,11H,0E4H,31H,0CDH,0BFH,35H,3AH,19H,3DH ; 0730: *.=".<...1..5:.=
                DB      0E6H,0FEH,0F6H,10H,32H,19H,3DH,0C9H,22H,0FCH,3CH,7CH,0B7H,0C2H,73H,24H ; 0740: ....2.=.".<|..s$
                DB      7DH,0B7H,0C2H,64H,24H,11H,5BH,32H,0CDH,0BFH,35H,0C9H,06H,06H,0F5H,0F1H ; 0750: }..d$.[2..5.....
                DB      1FH,0F5H,0B7H,0CAH,7AH,24H,05H,0C2H,67H,24H,0F1H,11H,5BH,33H,0CDH,0BFH ; 0760: ....z$..g$..[3..
                DB      35H,0C9H,0F1H,3EH,07H,90H,47H,05H,0C8H,3EH,29H,0CDH,8BH,35H,0C3H,7FH ; 0770: 5..>..G..>)..5..
                DB      24H,23H,0CDH,9EH,2AH,0CDH,44H,29H,0F1H,0F5H,0CDH,8FH,2CH,0CDH,0B6H,04H ; 0780: $#..*.D)....,...
                DB      0CDH,0CFH,2CH,0CDH,76H,2BH,0CDH,2BH,34H,0FEH,0CAH,0CAH,0B1H,24H,0C3H,0AAH ; 0790: ..,.v+.+4....$..
                DB      07H,0C3H,47H,30H,0C3H,0EH,08H,0C3H,0B1H,08H,0C5H,21H,00H,00H,39H,0F9H ; 07A0: ..G0.......!..9.
                DB      44H,4DH,2AH,15H,01H,11H,4FH,00H,19H,0AFH,77H,23H,77H,0CDH,90H,01H ; 07B0: DM*...O...w#w...
                DB      04H,11H,01H,00H,0CDH,04H,02H,0D2H,09H,08H,21H,06H,00H,09H,7EH,23H ; 07C0: ..........!...~#
                DB      66H,6FH,23H,23H,7EH,23H,66H,6FH,6EH,26H,00H,0E5H,0CDH,0A1H,07H,0D1H ; 07D0: fo##~#fon&......
                DB      7CH,0B5H,0C2H,0E8H,07H,0CDH,0A4H,07H,21H,06H,00H,09H,7EH,23H,66H,6FH ; 07E0: |.......!...~#fo
                DB      23H,23H,7EH,23H,66H,6FH,6EH,26H,00H,11H,0D0H,0FFH,19H,0E5H,2AH,15H ; 07F0: ##~#fon&......*.
                DB      01H,11H,4FH,00H,19H,0D1H,73H,23H,72H,0CDH,0A7H,07H,0C1H,0C9H,0C3H,17H ; 0800: ..O...s#r.......
                DB      08H,0C3H,37H,09H,0C3H,34H,37H,0C5H,21H,3AH,08H,0E5H,0CDH,11H,08H,0D1H ; 0810: ..7..47.!:......
                DB      21H,52H,08H,0E5H,0CDH,11H,08H,0D1H,21H,84H,08H,0E5H,0CDH,11H,08H,0D1H ; 0820: !R......!.......
                DB      21H,01H,00H,0E5H,0CDH,14H,08H,0D1H,0C1H,0C9H,55H,73H,61H,67H,65H,3AH ; 0830: !.........Usage:
                DB      20H,61H,6CH,69H,65H,6EH,73H,20H,3CH,64H,69H,67H,69H,74H,3EH,0DH ; 0840:  aliens <digit>.
                DB      0AH,00H,09H,3CH,64H,69H,67H,69H,74H,3EH,20H,69H,73H,20H,74H,68H ; 0850: ...<digit> is th
                DB      65H,20H,6CH,65H,76H,65H,6CH,20H,6FH,66H,20H,64H,69H,66H,66H,69H ; 0860: e level of diffi
                DB      63H,75H,6CH,74H,79H,20H,66H,72H,6FH,6DH,20H,30H,20H,74H,6FH,20H ; 0870: culty from 0 to 
                DB      39H,0DH,0AH,00H,09H,6CH,65H,76H,65H,6CH,20H,30H,20H,69H,73H,20H ; 0880: 9....level 0 is 
                DB      74H,68H,65H,20H,65H,61H,73H,69H,65H,73H,74H,20H,61H,6EH,64H,20H ; 0890: the easiest and 
                DB      69H,73H,20H,74H,68H,65H,20H,64H,65H,66H,61H,75H,6CH,74H,0DH,0AH ; 08A0: is the default..
                DB      00H,0C3H,0D2H,08H,0C3H,37H,37H,0C3H,8CH,09H,0C3H,0CCH,0DH,0C3H,8AH,13H ; 08B0: .....77.........
                DB      0C3H,0EBH,15H,0C3H,91H,1BH,0C3H,35H,1CH,0C3H,98H,20H,0C3H,15H,22H,0C3H ; 08C0: .......5... ..".
                DB      86H,26H,0C5H,21H,00H,00H,0E5H,0CDH,0B4H,08H,0D1H,0CDH,0B7H,08H,0CDH,0BAH ; 08D0: .&.!............
                DB      08H,0CDH,0BDH,08H,0CDH,0C0H,08H,0CDH,0C0H,08H,0CDH,0C0H,08H,0CDH,0C3H,08H ; 08E0: ................
                DB      0CDH,0C6H,08H,0CDH,0C9H,08H,0CDH,5CH,01H,31H,2BH,2BH,2BH,2BH,7CH,0B5H ; 08F0: .......\.1++++|.
                DB      0CAH,06H,09H,0CDH,0CCH,08H,0CDH,5CH,01H,31H,2BH,2BH,7CH,0B5H,0C2H,14H ; 0900: .......\.1++|...
                DB      09H,0CDH,0CCH,08H,0CDH,0CCH,08H,0CDH,5CH,01H,45H,7CH,0B5H,0C2H,2CH,09H ; 0910: ........\.E|..,.
                DB      0CDH,5CH,01H,47H,7CH,0B5H,0C2H,2CH,09H,0C3H,2FH,09H,0C3H,0E1H,08H,0CDH ; 0920: .\.G|..,../.....
                DB      0CFH,08H,0C3H,0DEH,08H,0C1H,0C9H,0C3H,3DH,09H,0C3H,0B5H,27H,0C5H,21H,0FEH ; 0930: ........=...'.!.
                DB      0FFH,39H,0F9H,44H,4DH,60H,69H,0AFH,77H,23H,77H,21H,06H,00H,09H,7EH ; 0940: .9.DM`i.w#w!...~
                DB      23H,66H,6FH,0E5H,0CDH,90H,01H,00H,0D1H,19H,6EH,7DH,0B7H,0CAH,83H,09H ; 0950: #fo.......n}....
                DB      21H,06H,00H,09H,7EH,23H,66H,6FH,0E5H,0CDH,90H,01H,00H,0D1H,19H,6EH ; 0960: !...~#fo.......n
                DB      26H,00H,0E5H,0CDH,3AH,09H,0D1H,60H,69H,5EH,23H,56H,13H,72H,2BH,73H ; 0970: &...:..`i^#V.r+s
                DB      0C3H,4BH,09H,0EBH,21H,02H,00H,39H,0F9H,0EBH,0C1H,0C9H,0C3H,0A1H,09H,0C3H ; 0980: .K..!..9........
                DB      76H,30H,0C3H,0C0H,30H,0C3H,0D5H,27H,0C3H,37H,09H,0C3H,63H,28H,0C3H,8AH ; 0990: v0..0..'.7..c(..
                DB      13H,0C5H,2AH,15H,01H,11H,2DH,00H,19H,0AFH,77H,23H,77H,2AH,15H,01H ; 09A0: ..*...-...w#w*..
                DB      11H,47H,00H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,4DH,00H,19H,0AFH ; 09B0: .G...w#w*...M...
                DB      77H,23H,77H,21H,0F3H,0AH,0E5H,2AH,15H,01H,11H,51H,00H,19H,0E5H,0CDH ; 09C0: w#w!...*...Q....
                DB      8FH,09H,0D1H,0D1H,21H,93H,0BH,0E5H,2AH,15H,01H,11H,0F3H,00H,19H,0E5H ; 09D0: ....!...*.......
                DB      0CDH,8FH,09H,0D1H,0D1H,21H,33H,0CH,0E5H,2AH,15H,01H,11H,95H,01H,19H ; 09E0: .....!3..*......
                DB      0E5H,0CDH,8FH,09H,0D1H,0D1H,21H,0D3H,0CH,0E5H,2AH,15H,01H,11H,37H,02H ; 09F0: ......!...*...7.
                DB      19H,0E5H,0CDH,8FH,09H,0D1H,0D1H,21H,73H,0DH,0E5H,2AH,15H,01H,11H,62H ; 0A00: .......!s..*...b
                DB      05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H,7AH,0DH,0E5H,2AH,15H,01H,11H ; 0A10: ........!z..*...
                DB      71H,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H,84H,0DH,0E5H,2AH,15H,01H ; 0A20: q........!...*..
                DB      11H,80H,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H,90H,0DH,0E5H,2AH,15H ; 0A30: ..........!...*.
                DB      01H,11H,8FH,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H,97H,0DH,0E5H,2AH ; 0A40: ...........!...*
                DB      15H,01H,11H,9EH,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H,0A2H,0DH,0E5H ; 0A50: ............!...
                DB      2AH,15H,01H,11H,0ADH,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H,0ACH,0DH ; 0A60: *............!..
                DB      0E5H,2AH,15H,01H,11H,0BCH,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H,0B4H ; 0A70: .*............!.
                DB      0DH,0E5H,2AH,15H,01H,11H,0CBH,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H,21H ; 0A80: ..*............!
                DB      0BCH,0DH,0E5H,2AH,15H,01H,11H,0DAH,05H,19H,0E5H,0CDH,92H,09H,0D1H,0D1H ; 0A90: ...*............
                DB      0CDH,95H,09H,2AH,15H,01H,11H,14H,00H,19H,0E5H,0CDH,98H,09H,0D1H,2AH ; 0AA0: ...*...........*
                DB      15H,01H,11H,31H,00H,19H,0AFH,77H,23H,77H,0CDH,9BH,09H,0CDH,5CH,01H ; 0AB0: ...1...w#w....\.
                DB      31H,7CH,0B5H,0C2H,0CCH,0AH,0CDH,9EH,09H,0C3H,0BDH,0AH,2AH,15H,01H,11H ; 0AC0: 1|..........*...
                DB      2DH,00H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,2FH,00H,19H,36H,03H ; 0AD0: -...w#w*.../..6.
                DB      23H,36H,00H,2AH,15H,01H,11H,39H,00H,19H,36H,16H,23H,36H,00H,0C1H ; 0AE0: #6.*...9..6.#6..
                DB      0C9H,0C1H,0C9H,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0AF0: ...0,0,0,0,0,0,0
                DB      2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H ; 0B00: ,0,0,1,1,1,1,1,1
                DB      2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0B10: ,1,1,0,0,0,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,31H ; 0B20: ,0,0,0,0,1,1,1,1
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0B30: ,1,1,1,1,0,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H ; 0B40: ,0,0,0,0,0,0,1,1
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H ; 0B50: ,1,1,1,1,1,1,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0B60: ,0,0,0,0,0,0,0,0
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H ; 0B70: ,1,1,1,1,1,1,1,1
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0B80: ,0,0,0,0,0,0,0,0
                DB      2CH,30H,00H,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0B90: ,0.0,0,0,0,0,0,0
                DB      2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H ; 0BA0: ,0,1,1,1,1,1,1,1
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0BB0: ,1,1,1,0,0,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H ; 0BC0: ,0,0,0,1,1,1,1,1
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H ; 0BD0: ,1,1,1,1,1,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H ; 0BE0: ,0,0,0,0,0,1,1,1
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,30H ; 0BF0: ,1,1,1,1,1,1,1,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H ; 0C00: ,0,0,0,0,0,0,0,1
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H,2CH,31H ; 0C10: ,1,1,1,1,1,1,1,1
                DB      2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0C20: ,1,0,0,0,0,0,0,0
                DB      2CH,30H,00H,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0C30: ,0.0,0,0,0,0,0,0
                DB      2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0C40: ,0,1,1,1,0,0,0,0
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0C50: ,1,1,1,0,0,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H ; 0C60: ,0,0,0,1,1,1,0,0
                DB      2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H ; 0C70: ,0,0,1,1,1,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H ; 0C80: ,0,0,0,0,0,1,1,1
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H ; 0C90: ,0,0,0,0,1,1,1,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H ; 0CA0: ,0,0,0,0,0,0,0,1
                DB      2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H ; 0CB0: ,1,1,0,0,0,0,1,1
                DB      2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0CC0: ,1,0,0,0,0,0,0,0
                DB      2CH,30H,00H,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0CD0: ,0.0,0,0,0,0,0,0
                DB      2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0CE0: ,0,1,1,1,0,0,0,0
                DB      2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0CF0: ,1,1,1,0,0,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H ; 0D00: ,0,0,0,1,1,1,0,0
                DB      2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H ; 0D10: ,0,0,1,1,1,0,0,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H ; 0D20: ,0,0,0,0,0,1,1,1
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H,2CH,31H,2CH,30H ; 0D30: ,0,0,0,0,1,1,1,0
                DB      2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H ; 0D40: ,0,0,0,0,0,0,0,1
                DB      2CH,31H,2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,31H,2CH,31H ; 0D50: ,1,1,0,0,0,0,1,1
                DB      2CH,31H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H,2CH,30H ; 0D60: ,1,0,0,0,0,0,0,0
                DB      2CH,30H,00H,72H,6FH,6FH,6BH,69H,65H,00H,65H,61H,72H,74H,68H,6CH ; 0D70: ,0.rookie.earthl
                DB      69H,6EH,67H,00H,73H,70H,61H,63H,65H,20H,63H,61H,64H,65H,74H,00H ; 0D80: ing.space cadet.
                DB      79H,65H,6FH,6DH,61H,6EH,00H,6CH,69H,65H,75H,74H,65H,6EH,61H,6EH ; 0D90: yeoman.lieutenan
                DB      74H,00H,63H,6FH,6DH,6DH,61H,6EH,64H,65H,72H,00H,63H,61H,70H,74H ; 0DA0: t.commander.capt
                DB      61H,69H,6EH,00H,61H,64H,6DH,69H,72H,61H,6CH,00H,6DH,61H,73H,74H ; 0DB0: ain.admiral.mast
                DB      65H,72H,20H,61H,73H,73H,61H,73H,73H,69H,6EH,00H,0C3H,0E1H,0DH,0C3H ; 0DC0: er assassin.....
                DB      0CAH,2BH,0C3H,0DFH,2BH,0C3H,08H,31H,0C3H,37H,09H,0C3H,3DH,2CH,0C3H,0A0H ; 0DD0: .+..+..1.7..=,..
                DB      37H,0C5H,0CDH,0CFH,0DH,21H,00H,00H,0E5H,21H,00H,00H,0E5H,0CDH,0D2H,0DH ; 0DE0: 7....!...!......
                DB      0D1H,0D1H,0CDH,5CH,01H,4FH,0E5H,21H,51H,12H,0E5H,2AH,15H,01H,11H,0F3H ; 0DF0: ...\.O.!Q..*....
                DB      05H,19H,0E5H,0CDH,0D5H,0DH,0D1H,0D1H,0D1H,2AH,15H,01H,11H,0F3H,05H,19H ; 0E00: .........*......
                DB      0E5H,0CDH,0D8H,0DH,0D1H,0CDH,5CH,01H,2DH,0E5H,21H,5CH,12H,0E5H,2AH,15H ; 0E10: ......\.-.!\..*.
                DB      01H,11H,0F3H,05H,19H,0E5H,0CDH,0D5H,0DH,0D1H,0D1H,0D1H,2AH,15H,01H,11H ; 0E20: ............*...
                DB      0F3H,05H,19H,0E5H,0CDH,0D8H,0DH,0D1H,0CDH,5CH,01H,31H,3EH,01H,0BDH,0C2H ; 0E30: .........\.1>...
                DB      48H,0EH,3EH,00H,0BCH,0CAH,87H,0EH,3EH,02H,0BDH,0C2H,54H,0EH,3EH,00H ; 0E40: H.>.....>...T.>.
                DB      0BCH,0CAH,92H,0EH,3EH,03H,0BDH,0C2H,60H,0EH,3EH,00H,0BCH,0CAH,9DH,0EH ; 0E50: ....>...`.>.....
                DB      3EH,04H,0BDH,0C2H,6CH,0EH,3EH,00H,0BCH,0CAH,0A8H,0EH,3EH,05H,0BDH,0C2H ; 0E60: >...l.>.....>...
                DB      78H,0EH,3EH,00H,0BCH,0CAH,0B3H,0EH,3EH,06H,0BDH,0C2H,84H,0EH,3EH,00H ; 0E70: x.>.....>.....>.
                DB      0BCH,0CAH,0BEH,0EH,0C3H,0C9H,0EH,21H,69H,12H,0E5H,0CDH,0D8H,0DH,0D1H,0C3H ; 0E80: .......!i.......
                DB      0C9H,0EH,21H,97H,12H,0E5H,0CDH,0D8H,0DH,0D1H,0C3H,0C9H,0EH,21H,0C5H,12H ; 0E90: ..!..........!..
                DB      0E5H,0CDH,0D8H,0DH,0D1H,0C3H,0C9H,0EH,21H,0F3H,12H,0E5H,0CDH,0D8H,0DH,0D1H ; 0EA0: ........!.......
                DB      0C3H,0C9H,0EH,21H,21H,13H,0E5H,0CDH,0D8H,0DH,0D1H,0C3H,0C9H,0EH,21H,4FH ; 0EB0: ...!!.........!O
                DB      13H,0E5H,0CDH,0D8H,0DH,0D1H,0C3H,0C9H,0EH,21H,46H,00H,0E5H,21H,00H,00H ; 0EC0: .........!F..!..
                DB      0E5H,0CDH,0D2H,0DH,0D1H,0D1H,0CDH,5CH,01H,31H,11H,03H,00H,0CDH,0F9H,01H ; 0ED0: .......\.1......
                DB      0DAH,0FAH,0EH,0CDH,5CH,01H,2FH,0E5H,21H,7CH,13H,0E5H,2AH,15H,01H,11H ; 0EE0: ....\./.!|..*...
                DB      0F3H,05H,19H,0E5H,0CDH,0D5H,0DH,0D1H,0D1H,0D1H,2AH,15H,01H,11H,0F3H,05H ; 0EF0: ..........*.....
                DB      19H,0E5H,0CDH,0D8H,0DH,0D1H,2AH,15H,01H,11H,45H,00H,19H,36H,37H,23H ; 0F00: ......*...E..67#
                DB      36H,00H,0CDH,5CH,01H,4FH,11H,0BH,00H,19H,0E5H,2AH,15H,01H,11H,37H ; 0F10: 6..\.O.....*...7
                DB      00H,19H,0D1H,73H,23H,72H,0CDH,5CH,01H,37H,0E5H,0CDH,5CH,01H,39H,0D1H ; 0F20: ...s#r.\.7..\.9.
                DB      0CDH,05H,02H,0D2H,46H,0FH,0CDH,5CH,01H,39H,0E5H,2AH,15H,01H,11H,37H ; 0F30: ....F..\.9.*...7
                DB      00H,19H,0D1H,73H,23H,72H,0CDH,5CH,01H,4FH,11H,05H,00H,19H,0E5H,2AH ; 0F40: ...s#r.\.O.....*
                DB      15H,01H,11H,49H,00H,19H,0D1H,73H,23H,72H,0CDH,5CH,01H,49H,11H,0AH ; 0F50: ...I...s#r.\.I..
                DB      00H,0CDH,04H,02H,0D2H,73H,0FH,2AH,15H,01H,11H,49H,00H,19H,36H,0AH ; 0F60: .....s.*...I..6.
                DB      23H,36H,00H,0CDH,5CH,01H,4FH,11H,02H,00H,0EBH,0CDH,0CBH,02H,0E5H,2AH ; 0F70: #6..\.O........*
                DB      15H,01H,11H,4BH,00H,19H,0D1H,73H,23H,72H,2AH,15H,01H,11H,35H,00H ; 0F80: ...K...s#r*...5.
                DB      19H,0AFH,77H,23H,77H,0CDH,5CH,01H,35H,11H,04H,00H,0CDH,04H,02H,0DAH ; 0F90: ..w#w.\.5.......
                DB      95H,10H,21H,00H,00H,0E5H,0CDH,5CH,01H,37H,0E5H,0CDH,5CH,01H,35H,11H ; 0FA0: ..!....\.7..\.5.
                DB      02H,00H,0CDH,3FH,02H,0D1H,0CDH,0FAH,02H,19H,0E5H,0CDH,0D2H,0DH,0D1H,0D1H ; 0FB0: ...?............
                DB      2AH,15H,01H,11H,33H,00H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H,33H,11H ; 0FC0: *...3...w#w.\.3.
                DB      0AH,00H,0CDH,04H,02H,0DAH,84H,10H,0CDH,5CH,01H,33H,0E5H,0CDH,5CH,01H ; 0FD0: .........\.3..\.
                DB      35H,0D1H,19H,11H,01H,00H,7CH,0A2H,67H,7DH,0A3H,6FH,0E5H,0CDH,5CH,01H ; 0FE0: 5.....|.g}.o..\.
                DB      35H,11H,02H,00H,0EBH,0CDH,0CBH,02H,11H,02H,00H,0CDH,3FH,02H,0D1H,19H ; 0FF0: 5...........?...
                DB      0E5H,0CDH,0DBH,0DH,0D1H,21H,86H,13H,0E5H,0CDH,0D8H,0DH,0D1H,0CDH,5CH,01H ; 1000: .....!........\.
                DB      35H,11H,0BH,00H,0CDH,3FH,02H,0E5H,0CDH,5CH,01H,33H,0D1H,19H,29H,29H ; 1010: 5....?...\.3..))
                DB      0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,0E5H,0CDH,5CH,01H,37H,0E5H ; 1020: .*...W......\.7.
                DB      0CDH,5CH,01H,35H,11H,02H,00H,0CDH,3FH,02H,0D1H,0CDH,0FAH,02H,19H,0EBH ; 1030: .\.5....?.......
                DB      0E1H,73H,23H,72H,0CDH,5CH,01H,35H,11H,0BH,00H,0CDH,3FH,02H,0E5H,0CDH ; 1040: .s#r.\.5....?...
                DB      5CH,01H,33H,0D1H,19H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H ; 1050: \.3..)).*...W...
                DB      19H,23H,23H,0E5H,0CDH,5CH,01H,33H,11H,06H,00H,0CDH,3FH,02H,0EBH,0E1H ; 1060: .##..\.3....?...
                DB      73H,23H,72H,2AH,15H,01H,11H,33H,00H,19H,5EH,23H,56H,13H,72H,2BH ; 1070: s#r*...3..^#V.r+
                DB      73H,0C3H,0CBH,0FH,2AH,15H,01H,11H,35H,00H,19H,5EH,23H,56H,13H,72H ; 1080: s...*...5..^#V.r
                DB      2BH,73H,0C3H,95H,0FH,2AH,15H,01H,11H,41H,00H,19H,36H,36H,23H,36H ; 1090: +s...*...A..66#6
                DB      00H,2AH,15H,01H,11H,3BH,00H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H ; 10A0: .*.......w#w*...
                DB      3DH,00H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,3FH,00H,19H,0AFH,77H ; 10B0: =...w#w*...?...w
                DB      23H,77H,2AH,15H,01H,11H,33H,07H,19H,36H,17H,23H,36H,00H,2AH,15H ; 10C0: #w*...3..6.#6.*.
                DB      01H,11H,35H,07H,19H,36H,48H,23H,36H,00H,0CDH,0DEH,0DH,11H,10H,27H ; 10D0: ..5..6H#6......'
                DB      0CDH,0F9H,01H,0D2H,0F2H,10H,2AH,15H,01H,11H,35H,07H,19H,36H,01H,23H ; 10E0: ......*...5..6.#
                DB      36H,00H,2AH,15H,01H,11H,37H,07H,19H,0AFH,77H,23H,77H,2AH,15H,01H ; 10F0: 6.*...7...w#w*..
                DB      11H,39H,07H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H,31H,11H,06H,00H,0CDH ; 1100: .9...w#w.\.1....
                DB      0F9H,01H,0D2H,2EH,11H,0CDH,4DH,01H,35H,07H,0E5H,0CDH,4DH,01H,33H,07H ; 1110: ......M.5...M.3.
                DB      0E5H,0CDH,0D2H,0DH,0D1H,0D1H,21H,07H,00H,0E5H,0CDH,0DBH,0DH,0D1H,2AH,15H ; 1120: ......!.......*.
                DB      01H,11H,33H,00H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H,33H,0E5H,0CDH,5CH ; 1130: ..3...w#w.\.3..\
                DB      01H,49H,0D1H,0CDH,0FAH,01H,0D2H,6EH,11H,0CDH,5CH,01H,33H,29H,29H,0E5H ; 1140: .I.....n..\.3)).
                DB      2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,0AFH,77H,23H,77H,2AH,15H,01H ; 1150: *...=.....w#w*..
                DB      11H,33H,00H,19H,5EH,23H,56H,13H,72H,2BH,73H,0C3H,39H,11H,2AH,15H ; 1160: .3..^#V.r+s.9.*.
                DB      01H,11H,43H,00H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,47H,00H,19H ; 1170: ..C...w#w*...G..
                DB      0AFH,77H,23H,77H,2AH,15H,01H,11H,33H,00H,19H,0AFH,77H,23H,77H,0CDH ; 1180: .w#w*...3...w#w.
                DB      5CH,01H,33H,11H,03H,00H,0CDH,04H,02H,0DAH,42H,12H,21H,00H,00H,0E5H ; 1190: \.3.......B.!...
                DB      0CDH,5CH,01H,33H,11H,13H,00H,19H,0E5H,0CDH,0D2H,0DH,0D1H,0D1H,2AH,15H ; 11A0: .\.3..........*.
                DB      01H,11H,35H,00H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H,35H,11H,50H,00H ; 11B0: ..5...w#w.\.5.P.
                DB      0CDH,0F9H,01H,0D2H,31H,12H,0CDH,5CH,01H,33H,11H,0A2H,00H,0CDH,6BH,02H ; 11C0: ....1..\.3....k.
                DB      0E5H,2AH,15H,01H,11H,0D9H,02H,19H,0D1H,19H,0E5H,0CDH,5CH,01H,35H,29H ; 11D0: .*..........\.5)
                DB      0D1H,19H,0E5H,0CDH,5CH,01H,33H,11H,0A2H,00H,0CDH,6BH,02H,0E5H,2AH,15H ; 11E0: ....\.3....k..*.
                DB      01H,11H,51H,00H,19H,0D1H,19H,0E5H,0CDH,5CH,01H,35H,29H,0D1H,19H,7EH ; 11F0: ..Q......\.5)..~
                DB      23H,66H,6FH,0EBH,0E1H,73H,23H,72H,7AH,0B3H,0CAH,18H,12H,21H,08H,00H ; 1200: #fo..s#rz....!..
                DB      0E5H,0CDH,0DBH,0DH,0D1H,0C3H,20H,12H,21H,88H,13H,0E5H,0CDH,0D8H,0DH,0D1H ; 1210: ...... .!.......
                DB      2AH,15H,01H,11H,35H,00H,19H,5EH,23H,56H,13H,72H,2BH,73H,0C3H,0B9H ; 1220: *...5..^#V.r+s..
                DB      11H,2AH,15H,01H,11H,33H,00H,19H,5EH,23H,56H,13H,72H,2BH,73H,0C3H ; 1230: .*...3..^#V.r+s.
                DB      8FH,11H,2AH,15H,01H,11H,69H,07H,19H,0AFH,77H,23H,77H,0C1H,0C9H,0C1H ; 1240: ..*...i...w#w...
                DB      0C9H,4CH,65H,76H,65H,6CH,3AH,25H,32H,64H,20H,00H,53H,63H,6FH,72H ; 1250: .Level:%2d .Scor
                DB      65H,3AH,20H,25H,2DH,35H,64H,20H,00H,20H,20H,20H,20H,20H,20H,20H ; 1260: e: %-5d .       
                DB      20H,20H,20H,20H,20H,20H,20H,20H,42H,20H,4CH,20H,4FH,20H,4FH,20H ; 1270:         B L O O 
                DB      44H,20H,42H,20H,41H,20H,54H,20H,48H,20H,20H,20H,20H,20H,20H,20H ; 1280: D B A T H       
                DB      20H,20H,20H,20H,20H,20H,00H,20H,20H,20H,20H,20H,20H,20H,20H,57H ; 1290:       .        W
                DB      20H,45H,20H,20H,43H,20H,4FH,20H,4DH,20H,45H,20H,20H,49H,20H,4EH ; 12A0:  E  C O M E  I N
                DB      20H,20H,50H,20H,45H,20H,41H,20H,43H,20H,45H,20H,21H,20H,20H,20H ; 12B0:   P E A C E !   
                DB      20H,20H,20H,20H,00H,54H,20H,48H,20H,45H,20H,20H,20H,41H,20H,4CH ; 12C0:     .T H E   A L
                DB      20H,49H,20H,45H,20H,4EH,20H,53H,20H,20H,20H,53H,20H,54H,20H,52H ; 12D0:  I E N S   S T R
                DB      20H,49H,20H,4BH,20H,45H,20H,20H,20H,42H,20H,41H,20H,43H,20H,4BH ; 12E0:  I K E   B A C K
                DB      20H,21H,00H,49H,20H,4EH,20H,56H,20H,49H,20H,53H,20H,49H,20H,42H ; 12F0:  !.I N V I S I B
                DB      20H,4CH,20H,45H,20H,20H,41H,20H,4CH,20H,49H,20H,45H,20H,4EH,20H ; 1300:  L E  A L I E N 
                DB      20H,57H,20H,45H,20H,41H,20H,53H,20H,45H,20H,4CH,20H,53H,20H,21H ; 1310:  W E A S E L S !
                DB      00H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,4BH ; 1320: .              K
                DB      20H,4CH,20H,49H,20H,4EH,20H,4BH,20H,45H,20H,52H,20H,20H,20H,20H ; 1330:  L I N K E R    
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,00H,20H ; 1340:               . 
                DB      20H,20H,20H,20H,54H,20H,48H,20H,45H,20H,20H,20H,42H,20H,4CH,20H ; 1350:     T H E   B L 
                DB      41H,20H,43H,20H,4BH,20H,20H,20H,48H,20H,4FH,20H,4CH,20H,45H,20H ; 1360: A C K   H O L E 
                DB      21H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,00H,42H,61H,73H,65H ; 1370: !          .Base
                DB      73H,3AH,20H,25H,64H,00H,20H,00H,20H,00H,0C3H,96H,13H,0C3H,93H,2DH ; 1380: s: %d. . ......-
                DB      0C3H,0C5H,2DH,0C3H,0D0H,2DH,0C5H,0CDH,5CH,01H,31H,2BH,7CH,0B5H,0C2H,0DFH ; 1390: ..-..-..\.1+|...
                DB      13H,0CDH,4DH,01H,35H,07H,0E5H,0CDH,5CH,01H,4FH,11H,48H,00H,0CDH,0FAH ; 13A0: ..M.5...\.O.H...
                DB      02H,19H,0D1H,0CDH,0FAH,01H,0DAH,0C5H,13H,2AH,15H,01H,11H,37H,07H,19H ; 13B0: .........*...7..
                DB      36H,0FFH,23H,36H,0FFH,0CDH,4DH,01H,35H,07H,11H,01H,00H,0CDH,04H,02H ; 13C0: 6.#6..M.5.......
                DB      0DAH,0DFH,13H,2AH,15H,01H,11H,37H,07H,19H,36H,01H,23H,36H,00H,0CDH ; 13D0: ...*...7..6.#6..
                DB      8DH,13H,7CH,0B5H,0C2H,0E9H,13H,0C1H,0C9H,0CDH,90H,13H,0E5H,2AH,15H,01H ; 13E0: ..|..........*..
                DB      11H,61H,05H,19H,0D1H,73H,0CDH,6BH,01H,61H,05H,26H,00H,11H,7FH,00H ; 13F0: .a...s.k.a.&....
                DB      7CH,0A2H,67H,7DH,0A3H,6FH,3EH,7AH,0BDH,0C2H,12H,14H,3EH,00H,0BCH,0CAH ; 1400: |.g}.o>z....>...
                DB      0D5H,14H,3EH,2CH,0BDH,0C2H,1EH,14H,3EH,00H,0BCH,0CAH,0D5H,14H,3EH,63H ; 1410: ..>,....>.....>c
                DB      0BDH,0C2H,2AH,14H,3EH,00H,0BCH,0CAH,0F1H,14H,3EH,2FH,0BDH,0C2H,36H,14H ; 1420: ..*.>.....>/..6.
                DB      3EH,00H,0BCH,0CAH,0F1H,14H,3EH,78H,0BDH,0C2H,42H,14H,3EH,00H,0BCH,0CAH ; 1430: >.....>x..B.>...
                DB      0DH,15H,3EH,2EH,0BDH,0C2H,4EH,14H,3EH,00H,0BCH,0CAH,0DH,15H,3EH,20H ; 1440: ..>...N.>.....> 
                DB      0BDH,0C2H,5AH,14H,3EH,00H,0BCH,0CAH,28H,15H,3EH,7FH,0BDH,0C2H,66H,14H ; 1450: ..Z.>...(.>...f.
                DB      3EH,00H,0BCH,0CAH,41H,15H,3EH,1CH,0BDH,0C2H,72H,14H,3EH,00H,0BCH,0CAH ; 1460: >...A.>...r.>...
                DB      41H,15H,3EH,71H,0BDH,0C2H,7EH,14H,3EH,00H,0BCH,0CAH,41H,15H,3EH,03H ; 1470: A.>q..~.>...A.>.
                DB      0BDH,0C2H,8AH,14H,3EH,00H,0BCH,0CAH,41H,15H,3EH                 ; 1480: ....>...A.>

KEY_LEVEL1_DISABLED:
; File 138BH / runtime 148BH
; FFH disables original level-1 comparison
                DB      0FFH                                                            ; 148B: .
                DB      0BDH,0C2H,96H,14H,3EH,00H,0BCH,0CAH,47H,15H,3EH                 ; 148C: ....>...G.>

KEY_START_GAME:
; File 1397H / runtime 1497H
; ASCII '1' starts the game
                DB      31H                                                             ; 1497: 1
                DB      0BDH,0C2H,0A2H,14H,3EH,00H,0BCH,0CAH,62H,15H,3EH                ; 1498: ....>...b.>

KEY_LEVEL3_DISABLED:
; File 13A3H / runtime 14A3H
; FFH disables original level-3 comparison
                DB      0FFH                                                            ; 14A3: .
                DB      0BDH,0C2H,0AEH,14H,3EH,00H,0BCH,0CAH,7DH,15H,3EH                ; 14A4: ....>...}.>

KEY_LEVEL4_DISABLED:
; File 13AFH / runtime 14AFH
; FFH disables original level-4 comparison
                DB      0FFH                                                            ; 14AF: .
                DB      0BDH,0C2H,0BAH,14H,3EH,00H,0BCH,0CAH,98H,15H,3EH                ; 14B0: ....>.....>

KEY_LEVEL5_DISABLED:
; File 13BBH / runtime 14BBH
; FFH disables original level-5 comparison
                DB      0FFH                                                            ; 14BB: .
                DB      0BDH,0C2H,0C6H,14H,3EH,00H,0BCH,0CAH,0B3H,15H,3EH               ; 14BC: ....>.....>

KEY_LEVEL6_DISABLED:
; File 13C7H / runtime 14C7H
; FFH disables original level-6 comparison
                DB      0FFH                                                            ; 14C7: .
                DB      0BDH,0C2H,0D2H,14H,3EH,00H,0BCH,0CAH,0CEH,15H,0C3H,0E9H,15H,0CDH,5CH,01H ; 14C8: ....>.........\.
                DB      31H,2BH,7CH,0B5H,0C2H,0E2H,14H,0C3H,0E9H,15H,2AH,15H,01H,11H,37H,07H ; 14D8: 1+|.......*...7.
                DB      19H,36H,0FFH,23H,36H,0FFH,0C3H,0E9H,15H,0CDH,5CH,01H,31H,2BH,7CH,0B5H ; 14E8: .6.#6.....\.1+|.
                DB      0C2H,0FEH,14H,0C3H,0E9H,15H,2AH,15H,01H,11H,37H,07H,19H,36H,01H,23H ; 14F8: ......*...7..6.#
                DB      36H,00H,0C3H,0E9H,15H,0CDH,5CH,01H,31H,2BH,7CH,0B5H,0C2H,1AH,15H,0C3H ; 1508: 6.....\.1+|.....
                DB      0E9H,15H,2AH,15H,01H,11H,37H,07H,19H,0AFH,77H,23H,77H,0C3H,0E9H,15H ; 1518: ..*...7...w#w...
                DB      0CDH,4DH,01H,39H,07H,7CH,0B5H,0C2H,3EH,15H                      ; 1528: .M.9.|..>.

PLAYER_FIRE_SOUND_HOOK:
; File 1432H / runtime 1532H
; CALL 4132H; replaces LD HL,(0115H)
                DB      0CDH,32H,41H                                                    ; 1532: .2A
                DB      11H,39H,07H,19H,36H,16H,23H,36H,00H,0C3H,0E9H,15H,0CDH,93H,13H,0C3H ; 1535: .9..6.#6........
                DB      0E9H,15H,0CDH,5CH,01H,31H,7CH,0B5H,0CAH,53H,15H,0C3H,0E9H,15H,2AH,15H ; 1545: ...\.1|..S....*.
                DB      01H,11H,31H,00H,19H,36H,01H,23H,36H,00H,0C3H,0E9H,15H,0CDH,5CH,01H ; 1555: ..1..6.#6.....\.
                DB      31H,7CH,0B5H,0CAH,6EH,15H,0C3H,0E9H,15H,2AH,15H,01H,11H,31H,00H,19H ; 1565: 1|..n....*...1..
                DB      36H                                                             ; 1575: 6

ACTIVE_GAME_VARIATION:
; File 1476H / runtime 1576H
; 03H enables alien return fire
                DB      03H                                                             ; 1576: .
                DB      23H,36H,00H,0C3H,0E9H,15H,0CDH,5CH,01H,31H,7CH,0B5H,0CAH,89H,15H,0C3H ; 1577: #6.....\.1|.....
                DB      0E9H,15H,2AH,15H,01H,11H,31H,00H,19H,36H,03H,23H,36H,00H,0C3H,0E9H ; 1587: ..*...1..6.#6...
                DB      15H,0CDH,5CH,01H,31H,7CH,0B5H,0CAH,0A4H,15H,0C3H,0E9H,15H,2AH,15H,01H ; 1597: ..\.1|.......*..
                DB      11H,31H,00H,19H,36H,04H,23H,36H,00H,0C3H,0E9H,15H,0CDH,5CH,01H,31H ; 15A7: .1..6.#6.....\.1
                DB      7CH,0B5H,0CAH,0BFH,15H,0C3H,0E9H,15H,2AH,15H,01H,11H,31H,00H,19H,36H ; 15B7: |.......*...1..6
                DB      05H,23H,36H,00H,0C3H,0E9H,15H,0CDH,5CH,01H,31H,7CH,0B5H,0CAH,0DAH,15H ; 15C7: .#6.....\.1|....
                DB      0C3H,0E9H,15H,2AH,15H,01H,11H,31H,00H,19H,36H,06H,23H,36H,00H,0C3H ; 15D7: ...*...1..6.#6..
                DB      0E9H,15H,0C1H,0C9H,0C3H,0FAH,15H,0C3H,0DFH,2BH,0C3H,37H,09H,0C3H,0E5H,2FH ; 15E7: .........+.7.../
                DB      0C3H,3DH,2CH,0C5H,21H,0FEH,0FFH,39H,0F9H,44H,4DH,0CDH,4DH,01H,39H,07H ; 15F7: .=,.!..9.DM.M.9.
                DB      3EH,17H,0BDH,0C2H,13H,16H,3EH,00H,0BCH,0CAH,2EH,16H,3EH,00H,0BDH,0C2H ; 1607: >.....>.....>...
                DB      1FH,16H,3EH,00H,0BCH,0CAH,2EH,16H,3EH,16H,0BDH,0C2H,2BH,16H,3EH,00H ; 1617: ..>.....>...+.>.
                DB      0BCH,0CAH,76H,16H,0C3H,0A4H,16H,0CDH,4DH,01H,3BH,07H,0E5H,21H,15H,00H ; 1627: ..v.....M....!..
                DB      0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,62H,1BH,0E5H,0CDH,0F1H,15H,0D1H,0CDH,4DH ; 1637: ......!b.......M
                DB      01H,3BH,07H,0E5H,21H,15H,00H,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,63H,1BH ; 1647: ....!........!c.
                DB      0E5H,0CDH,0F1H,15H,0D1H,0CDH,4DH,01H,3BH,07H,0E5H,21H,15H,00H,0E5H,0CDH ; 1657: ......M....!....
                DB      0EEH,15H,0D1H,0D1H,21H,64H,1BH,0E5H,0CDH,0F1H,15H,0D1H,0C3H,59H,1BH,0CDH ; 1667: ....!d.......Y..
                DB      4DH,01H,35H,07H,23H,23H,23H,0E5H,2AH,15H,01H,11H,3BH,07H,19H,0D1H ; 1677: M.5.###.*.......
                DB      73H,23H,72H,0CDH,4DH,01H,3BH,07H,0E5H,21H,16H,00H,0E5H,0CDH,0EEH,15H ; 1687: s#r.M....!......
                DB      0D1H,0D1H,21H,65H,1BH,0E5H,0CDH,0F1H,15H,0D1H,0C3H,0DAH,16H,0CDH,4DH,01H ; 1697: ..!e..........M.
                DB      3BH,07H,0E5H,0CDH,4DH,01H,39H,07H,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,67H ; 16A7: ....M.9.......!g
                DB      1BH,0E5H,0CDH,0F1H,15H,0D1H,0CDH,4DH,01H,3BH,07H,0E5H,0CDH,4DH,01H,39H ; 16B7: .......M.....M.9
                DB      07H,23H,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,69H,1BH,0E5H,0CDH,0F1H,15H,0D1H ; 16C7: .#......!i......
                DB      0C3H,0DAH,16H,2AH,15H,01H,11H,33H,00H,19H,0AFH,77H,23H,77H,0CDH,5CH ; 16D7: ...*...3...w#w.\
                DB      01H,33H,11H,37H,00H,0CDH,0F9H,01H,0D2H,7FH,18H,0CDH,5CH,01H,33H,29H ; 16E7: .3.7........\.3)
                DB      29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,7EH,23H,66H,6FH,0E5H ; 16F7: ).*...W....~#fo.
                DB      0CDH,4DH,01H,39H,07H,0D1H,0CDH,0E5H,01H,0C2H,6EH,18H,0CDH,5CH,01H,33H ; 1707: .M.9......n..\.3
                DB      29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H,7EH,23H ; 1717: )).*...W....##~#
                DB      66H,6FH,23H,0E5H,0CDH,4DH,01H,3BH,07H,0D1H,0CDH,05H,02H,0DAH,6EH,18H ; 1727: fo#..M........n.
                DB      0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H ; 1737: .\.3)).*...W....
                DB      23H,23H,7EH,23H,66H,6FH,23H,23H,23H,0E5H,0CDH,4DH,01H,3BH,07H,0D1H ; 1747: ##~#fo###..M....
                DB      0CDH,0FAH,01H,0DAH,6EH,18H,0CDH,5CH,01H,33H,11H,16H,00H,0EBH,0CDH,0CBH ; 1757: ....n..\.3......
                DB      02H,11H,01H,00H,19H,0E5H,0CDH,5CH,01H,4FH,0E5H,0CDH,5CH,01H,33H,11H ; 1767: .......\.O..\.3.
                DB      0BH,00H,0EBH,0CDH,0CBH,02H,0D1H,0CDH,3FH,02H,0D1H,19H,0EBH,60H,69H,73H ; 1777: ........?....`is
                DB      23H,72H,0CDH,5CH,01H,31H,2BH,7CH,0B5H,0CAH,0A7H,17H,0CDH,90H,01H,00H ; 1787: #r.\.1+|........
                DB      0E5H,0CDH,5CH,01H,4DH,0D1H,0CDH,0FAH,02H,19H,0EBH,60H,69H,73H,23H,72H ; 1797: ..\.M......`is#r
                DB      0CDH,90H,01H,00H,11H,01H,00H,0CDH,04H,02H,0DAH,0BBH,17H,60H,69H,36H ; 17A7: .............`i6
                DB      01H,23H,36H,00H,2AH,15H,01H,11H,2DH,00H,19H,0E5H,7EH,23H,66H,6FH ; 17B7: .#6.*...-...~#fo
                DB      0E5H,0CDH,90H,01H,00H,0D1H,19H,0EBH,0E1H,73H,23H,72H,0CDH,0F4H,15H,0CDH ; 17C7: .........s#r....
                DB      4DH,01H,3BH,07H,0E5H,0CDH,4DH,01H,39H,07H,23H,0E5H,0CDH,0EEH,15H,0D1H ; 17D7: M.....M.9.#.....
                DB      0D1H,21H,6BH,1BH,0E5H,0CDH,0F1H,15H,0D1H,0CDH,5CH,01H,31H,11H,04H,00H ; 17E7: .!k.......\.1...
                DB      0CDH,0F9H,01H,0DAH,05H,18H,21H,6DH,1BH,0E5H,0CDH,0F1H,15H,0D1H,0CDH,5CH ; 17F7: ......!m.......\
                DB      01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H ; 1807: .3)).*...W....##
                DB      7EH,23H,66H,6FH,0E5H,0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H ; 1817: ~#fo..\.3)).*...
                DB      57H,06H,19H,0D1H,19H,7EH,23H,66H,6FH,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H ; 1827: W....~#fo......!
                DB      06H,00H,0E5H,0CDH,0F7H,15H,0D1H,2AH,15H,01H,11H,39H,07H,19H,0AFH,77H ; 1837: .......*...9...w
                DB      23H,77H,0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H ; 1847: #w.\.3)).*...W..
                DB      0D1H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,45H,00H,19H,5EH,23H,56H ; 1857: ...w#w*...E..^#V
                DB      1BH,72H,2BH,73H,0C3H,59H,1BH,2AH,15H,01H,11H,33H,00H,19H,5EH,23H ; 1867: .r+s.Y.*...3..^#
                DB      56H,13H,72H,2BH,73H,0C3H,0E5H,16H,2AH,15H,01H,11H,33H,00H,19H,0AFH ; 1877: V.r+s...*...3...
                DB      77H,23H,77H,0CDH,5CH,01H,33H,0E5H,0CDH,5CH,01H,49H,0D1H,0CDH,0FAH,01H ; 1887: w#w.\.3..\.I....
                DB      0D2H,52H,19H,0CDH,4DH,01H,39H,07H,0E5H,0CDH,5CH,01H,33H,29H,29H,0E5H ; 1897: .R..M.9...\.3)).
                DB      2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,7EH,23H,66H,6FH,0D1H,0CDH,0E5H ; 18A7: *...=....~#fo...
                DB      01H,0C2H,41H,19H,0CDH,4DH,01H,3BH,07H,0E5H,0CDH,5CH,01H,33H,29H,29H ; 18B7: ..A..M.....\.3))
                DB      0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H,7EH,23H,66H,6FH ; 18C7: .*...=....##~#fo
                DB      0D1H,0CDH,0E5H,01H,0C2H,41H,19H,0CDH,4DH,01H,3BH,07H,0E5H,0CDH,4DH,01H ; 18D7: .....A..M.....M.
                DB      39H,07H,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,6FH,1BH,0E5H,0CDH,0F1H,15H,0D1H ; 18E7: 9.......!o......
                DB      0CDH,4DH,01H,3BH,07H,0E5H,0CDH,4DH,01H,39H,07H,23H,0E5H,0CDH,0EEH,15H ; 18F7: .M.....M.9.#....
                DB      0D1H,0D1H,21H,71H,1BH,0E5H,0CDH,0F1H,15H,0D1H,2AH,15H,01H,11H,39H,07H ; 1907: ..!q......*...9.
                DB      19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,47H,00H,19H,5EH,23H,56H,1BH ; 1917: ..w#w*...G..^#V.
                DB      72H,2BH,73H,0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H ; 1927: r+s.\.3)).*...=.
                DB      19H,0D1H,19H,0AFH,77H,23H,77H,0C3H,59H,1BH,2AH,15H,01H,11H,33H,00H ; 1937: ....w#w.Y.*...3.
                DB      19H,5EH,23H,56H,13H,72H,2BH,73H,0C3H,8AH,18H,0CDH,4DH,01H,39H,07H ; 1947: .^#V.r+s....M.9.
                DB      11H,13H,00H,0CDH,0F9H,01H,0DAH,24H,1AH,0CDH,4DH,01H,39H,07H,11H,16H ; 1957: .......$..M.9...
                DB      00H,0CDH,04H,02H,0DAH,24H,1AH,0CDH,4DH,01H,39H,07H,11H,0EDH,0FFH,19H ; 1967: .....$..M.9.....
                DB      11H,0A2H,00H,0CDH,6BH,02H,0E5H,2AH,15H,01H,11H,0D9H,02H,19H,0D1H,19H ; 1977: ....k..*........
                DB      0E5H,0CDH,4DH,01H,3BH,07H,29H,0D1H,19H,7EH,23H,66H,6FH,7CH,0B5H,0CAH ; 1987: ..M...)..~#fo|..
                DB      24H,1AH,0CDH,4DH,01H,3BH,07H,0E5H,0CDH,4DH,01H,39H,07H,0E5H,0CDH,0EEH ; 1997: $..M.....M.9....
                DB      15H,0D1H,0D1H,0CDH,5CH,01H,31H,2BH,2BH,7CH,0B5H,0C2H,0C0H,19H,21H,08H ; 19A7: ....\.1++|....!.
                DB      00H,0E5H,0CDH,0F7H,15H,0D1H,0C3H,0EEH,19H,0CDH,4DH,01H,39H,07H,11H,0EDH ; 19B7: ..........M.9...
                DB      0FFH,19H,11H,0A2H,00H,0CDH,6BH,02H,0E5H,2AH,15H,01H,11H,0D9H,02H,19H ; 19C7: ......k..*......
                DB      0D1H,19H,0E5H,0CDH,4DH,01H,3BH,07H,29H,0D1H,19H,0AFH,77H,23H,77H,21H ; 19D7: ....M...)...w#w!
                DB      73H,1BH,0E5H,0CDH,0F1H,15H,0D1H,0CDH,4DH,01H,39H,07H,11H,16H,00H,0CDH ; 19E7: s.......M.9.....
                DB      0E5H,01H,0CAH,0EH,1AH,0CDH,4DH,01H,3BH,07H,0E5H,0CDH,4DH,01H,39H,07H ; 19F7: ......M.....M.9.
                DB      23H,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,75H,1BH,0E5H,0CDH,0F1H,15H,0D1H,2AH ; 1A07: #......!u......*
                DB      15H,01H,11H,39H,07H,19H,0AFH,77H,23H,77H,0C3H,59H,1BH,0CDH,4DH,01H ; 1A17: ...9...w#w.Y..M.
                DB      69H,07H,7CH,0B5H,0CAH,0F6H,1AH,0CDH,4DH,01H,39H,07H,2BH,7CH,0B5H,0C2H ; 1A27: i.|.....M.9.+|..
                DB      0F6H,1AH,0CDH,4DH,01H,3BH,07H,0E5H,0CDH,4DH,01H,67H,07H,0E5H,0CDH,4DH ; 1A37: ...M.....M.g...M
                DB      01H,69H,07H,0D1H,0CDH,0FAH,02H,19H,0E5H,2AH,15H,01H,11H,33H,00H,19H ; 1A47: .i.......*...3..
                DB      0D1H,73H,23H,72H,0E1H,0CDH,04H,02H,0D2H,0F6H,1AH,0CDH,4DH,01H,3BH,07H ; 1A57: .s#r........M...
                DB      0E5H,0CDH,5CH,01H,33H,11H,07H,00H,19H,0D1H,0CDH,0FAH,01H,0D2H,0F6H,1AH ; 1A67: ..\.3...........
                DB      0CDH,5CH,01H,33H,0E5H,21H,01H,00H,0E5H,0CDH,0EEH,15H,0D1H,0D1H  ; 1A77: .\.3.!........

PLAYER_HIT_SOUND_HOOK:
; File 1985H / runtime 1A85H
; CALL 4151H; replaces LD HL,1B77H before the existing <BOOM!> display
                DB      0CDH,51H,41H                                                    ; 1A85: .QA
                DB      0E5H,0CDH,0F1H,15H,0D1H,0CDH,5CH,01H,33H,0E5H,21H,01H,00H,0E5H,0CDH,0EEH ; 1A88: ......\.3.!.....
                DB      15H,0D1H,0D1H,21H,82H,1BH,0E5H,0CDH,0F1H,15H,0D1H,2AH,15H,01H,11H,69H ; 1A98: ...!.......*...i
                DB      07H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,2DH,00H,19H,0E5H,7EH,23H ; 1AA8: ...w#w*...-...~#
                DB      66H,6FH,0E5H,0CDH,4DH,01H,65H,07H,11H,03H,00H,0EBH,0CDH,0CBH,02H,0D1H ; 1AB8: fo..M.e.........
                DB      19H,0EBH,0E1H,73H,23H,72H,0CDH,0F4H,15H,0CDH,4DH,01H,3BH,07H,0E5H,21H ; 1AC8: ...s#r....M....!
                DB      02H,00H,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,8BH,1BH,0E5H,0CDH,0F1H,15H,0D1H ; 1AD8: ........!.......
                DB      2AH,15H,01H,11H,39H,07H,19H,0AFH,77H,23H,77H,0C3H,59H,1BH,2AH,15H ; 1AE8: *...9...w#w.Y.*.
                DB      01H,11H,39H,07H,19H,5EH,23H,56H,1BH,72H,2BH,73H,7AH,0B3H,0C2H,56H ; 1AF8: ..9..^#V.r+sz..V
                DB      1BH,0CDH,4DH,01H,3BH,07H,0E5H,21H,01H,00H,0E5H,0CDH,0EEH,15H,0D1H,0D1H ; 1B08: ..M....!........
                DB      21H,8DH,1BH,0E5H,0CDH,0F1H,15H,0D1H,0CDH,4DH,01H,3BH,07H,0E5H,21H,02H ; 1B18: !........M....!.
                DB      00H,0E5H,0CDH,0EEH,15H,0D1H,0D1H,21H,8FH,1BH,0E5H,0CDH,0F1H,15H,0D1H,2AH ; 1B28: .......!.......*
                DB      15H,01H,11H,2DH,00H,19H,0E5H,7EH,23H,66H,6FH,0E5H,0CDH,5CH,01H,4FH ; 1B38: ...-...~#fo..\.O
                DB      23H,0D1H,0CDH,0FAH,02H,19H,0EBH,0E1H,73H,23H,72H,0CDH,0F4H,15H,0C3H,59H ; 1B48: #.......s#r....Y
                DB      1BH,0EBH,21H,02H,00H,39H,0F9H,0EBH,0C1H,0C9H,00H,00H,00H,7CH,00H,7CH ; 1B58: ..!..9.......|.|
                DB      00H,20H,00H,20H,00H,07H,00H,20H,00H,20H,00H,20H,00H,20H,00H,20H ; 1B68: . . ... . . . . 
                DB      3CH,42H,4FH,4FH,4DH,21H,3EH,20H,07H,00H,20H,20H,20H,20H,20H,20H ; 1B78: <BOOM!> ..      
                DB      20H,20H,00H,20H,00H,20H,00H,20H,00H,0C3H,9AH,1BH,0C3H,0DFH,2BH,0C3H ; 1B88:   . . . ......+.
                DB      3DH,2CH,0C5H,0CDH,4DH,01H,37H,07H,7CH,0B5H,0C2H,0A7H,1BH,0C1H,0C9H,2AH ; 1B98: =,..M.7.|......*
                DB      15H,01H,11H,35H,07H,19H,0E5H,7EH,23H,66H,6FH,0E5H,0CDH,4DH,01H,37H ; 1BA8: ...5...~#fo..M.7
                DB      07H,0D1H,19H,0EBH,0E1H,73H,23H,72H,0CDH,4DH,01H,35H,07H,11H,01H,00H ; 1BB8: .....s#r.M.5....
                DB      0CDH,0F9H,01H,0D2H,0E8H,1BH,2AH,15H,01H,11H,35H,07H,19H,36H,01H,23H ; 1BC8: ......*...5..6.#
                DB      36H,00H,2AH,15H,01H,11H,37H,07H,19H,0AFH,77H,23H,77H,0C3H,0DH,1CH ; 1BD8: 6.*...7...w#w...
                DB      0CDH,4DH,01H,35H,07H,11H,48H,00H,0CDH,04H,02H,0D2H,0DH,1CH,2AH,15H ; 1BE8: .M.5..H.......*.
                DB      01H,11H,35H,07H,19H,36H,48H,23H,36H,00H,2AH,15H,01H,11H,37H,07H ; 1BF8: ..5..6H#6.*...7.
                DB      19H,0AFH,77H,23H,77H,0CDH,5CH,01H,31H,11H,06H,00H,0CDH,0F9H,01H,0D2H ; 1C08: ..w#w.\.1.......
                DB      33H,1CH,0CDH,4DH,01H,35H,07H,0E5H,0CDH,4DH,01H,33H,07H,0E5H,0CDH,94H ; 1C18: 3..M.5...M.3....
                DB      1BH,0D1H,0D1H,21H,07H,00H,0E5H,0CDH,97H,1BH,0D1H,0C1H,0C9H,0C3H,50H,1CH ; 1C28: ...!..........P.
                DB      0C3H,0DFH,2BH,0C3H,37H,09H,0C3H,3DH,2CH,0C3H,08H,31H,0C3H,0E5H,2FH,0C3H ; 1C38: ..+.7..=,..1../.
                DB      2BH,30H,0C3H,0C8H,37H,0C3H,0A0H,37H,0C5H,2AH,15H,01H,11H,43H,00H,19H ; 1C48: +0..7..7.*...C..
                DB      0AFH,77H,23H,77H,0CDH,5CH,01H,43H,0E5H,0CDH,5CH,01H,49H,0D1H,0CDH,0FAH ; 1C58: .w#w.\.C..\.I...
                DB      01H,0D2H,7AH,20H,0CDH,5CH,01H,47H,7CH,0B5H,0C2H,77H,1CH,0C1H,0C9H,0CDH ; 1C68: ..z .\.G|..w....
                DB      5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,7EH ; 1C78: \.C)).*...=....~
                DB      23H,66H,6FH,7CH,0B5H,0C2H,93H,1CH,0C3H,69H,20H,0CDH,5CH,01H,43H,29H ; 1C88: #fo|.....i .\.C)
                DB      29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,5EH,23H,56H,13H,72H ; 1C98: ).*...=....^#V.r
                DB      2BH,73H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H ; 1CA8: +s.\.C)).*...=..
                DB      0D1H,19H,7EH,23H,66H,6FH,11H,17H,00H,0CDH,0E5H,01H,0C2H,51H,1EH,0CDH ; 1CB8: ..~#fo.......Q..
                DB      5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,23H ; 1CC8: \.C)).*...=....#
                DB      23H,7EH,23H,66H,6FH,0E5H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H ; 1CD8: #~#fo..\.C)).*..
                DB      11H,3DH,07H,19H,0D1H,19H,7EH,23H,66H,6FH,2BH,0E5H,0CDH,38H,1CH,0D1H ; 1CE8: .=....~#fo+..8..
                DB      0D1H,21H,7CH,20H,0E5H,0CDH,3BH,1CH,0D1H,0CDH,5CH,01H,43H,29H,29H,0E5H ; 1CF8: .!| ......\.C)).
                DB      2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H ; 1D08: *...=.....w#w.\.
                DB      43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H,7EH ; 1D18: C)).*...=....##~
                DB      23H,66H,6FH,0E5H,0CDH,4DH,01H,35H,07H,0D1H,0CDH,05H,02H,0D2H,4EH,1EH ; 1D28: #fo..M.5......N.
                DB      0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H ; 1D38: .\.C)).*...=....
                DB      23H,23H,7EH,23H,66H,6FH,0E5H,0CDH,4DH,01H,35H,07H,11H,05H,00H,19H ; 1D48: ##~#fo..M.5.....
                DB      0D1H,0CDH,05H,02H,0DAH,4EH,1EH,0CDH,5CH,01H,31H,11H,05H,00H,0CDH,04H ; 1D58: .....N..\.1.....
                DB      02H,0D2H,85H,1DH,0CDH,4DH,01H,35H,07H,0E5H,0CDH,4DH,01H,33H,07H,0E5H ; 1D68: .....M.5...M.3..
                DB      0CDH,38H,1CH,0D1H,0D1H,21H,07H,00H,0E5H,0CDH,3EH,1CH,0D1H,2AH,15H,01H ; 1D78: .8...!....>..*..
                DB      11H,2FH,00H,19H,5EH,23H,56H,1BH,72H,2BH,73H,21H,46H,00H,0E5H,21H ; 1D88: ./..^#V.r+s!F..!
                DB      00H,00H,0E5H,0CDH,38H,1CH,0D1H,0D1H,0CDH,5CH,01H,2FH,0E5H,21H,7EH,20H ; 1D98: ....8....\./.!~ 
                DB      0E5H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,41H,1CH,0D1H,0D1H,0D1H,2AH ; 1DA8: .*........A....*
                DB      15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,3BH,1CH,0D1H,2AH,15H,01H,11H,2DH ; 1DB8: ...........*...-
                DB      00H,19H,0E5H,7EH,23H,66H,6FH,11H,0E7H,0FFH,19H,0EBH,0E1H,73H,23H,72H ; 1DC8: ...~#fo......s#r
                DB      0CDH,44H,1CH,0CDH,5CH,01H,2FH,7CH,0B5H,0C2H,0E7H,1DH,0CDH,47H,1CH,21H ; 1DD8: .D..\./|.....G.!
                DB      14H,00H,0E5H,0CDH,4AH,1CH,0D1H,0CDH,4DH,01H,35H,07H,0E5H,21H,17H,00H ; 1DE8: ....J...M.5..!..
                DB      0E5H,0CDH,38H,1CH,0D1H,0D1H,21H,88H,20H,0E5H,0CDH,3BH,1CH,0D1H,2AH,15H ; 1DF8: ..8...!. .....*.
                DB      01H,11H,35H,07H,19H,36H,48H,23H,36H,00H,0CDH,4DH,1CH,11H,0C8H,32H ; 1E08: ..5..6H#6..M...2
                DB      0CDH,0F9H,01H,0D2H,2AH,1EH,2AH,15H,01H,11H,35H,07H,19H,36H,01H,23H ; 1E18: ....*.*...5..6.#
                DB      36H,00H,0CDH,5CH,01H,31H,11H,06H,00H,0CDH,0F9H,01H,0D2H,4EH,1EH,0CDH ; 1E28: 6..\.1.......N..
                DB      4DH,01H,35H,07H,0E5H,21H,17H,00H,0E5H,0CDH,38H,1CH,0D1H,0D1H,21H,07H ; 1E38: M.5..!....8...!.
                DB      00H,0E5H,0CDH,3EH,1CH,0D1H,0C3H,69H,20H,0CDH,5CH,01H,43H,29H,29H,0E5H ; 1E48: ...>...i .\.C)).
                DB      2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,7EH,23H,66H,6FH,11H,13H,00H ; 1E58: *...=....~#fo...
                DB      0CDH,0F9H,01H,0DAH,0B4H,1FH,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H ; 1E68: .......\.C)).*..
                DB      11H,3DH,07H,19H,0D1H,19H,7EH,23H,66H,6FH,11H,17H,00H,0CDH,0F9H,01H ; 1E78: .=....~#fo......
                DB      0D2H,0B4H,1FH,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H ; 1E88: ....\.C)).*...=.
                DB      19H,0D1H,19H,7EH,23H,66H,6FH,11H,0EDH,0FFH,19H,11H,0A2H,00H,0CDH,6BH ; 1E98: ...~#fo........k
                DB      02H,0E5H,2AH,15H,01H,11H,0D9H,02H,19H,0D1H,19H,0E5H,0CDH,5CH,01H,43H ; 1EA8: ..*..........\.C
                DB      29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H,7EH,23H ; 1EB8: )).*...=....##~#
                DB      66H,6FH,29H,0D1H,19H,7EH,23H,66H,6FH,7CH,0B5H,0CAH,0B4H,1FH,0CDH,5CH ; 1EC8: fo)..~#fo|.....\
                DB      01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H ; 1ED8: .C)).*...=....##
                DB      7EH,23H,66H,6FH,0E5H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H ; 1EE8: ~#fo..\.C)).*...
                DB      3DH,07H,19H,0D1H,19H,7EH,23H,66H,6FH,2BH,0E5H,0CDH,38H,1CH,0D1H,0D1H ; 1EF8: =....~#fo+..8...
                DB      21H,90H,20H,0E5H,0CDH,3BH,1CH,0D1H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH ; 1F08: !. ......\.C)).*
                DB      15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H,7EH,23H,66H,6FH,0E5H,0CDH ; 1F18: ...=....##~#fo..
                DB      5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,7EH ; 1F28: \.C)).*...=....~
                DB      23H,66H,6FH,0E5H,0CDH,38H,1CH,0D1H,0D1H,21H,92H,20H,0E5H,0CDH,3BH,1CH ; 1F38: #fo..8...!. ....
                DB      0D1H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H ; 1F48: ..\.C)).*...=...
                DB      19H,7EH,23H,66H,6FH,11H,0EDH,0FFH,19H,11H,0A2H,00H,0CDH,6BH,02H,0E5H ; 1F58: .~#fo........k..
                DB      2AH,15H,01H,11H,0D9H,02H,19H,0D1H,19H,0E5H,0CDH,5CH,01H,43H,29H,29H ; 1F68: *..........\.C))
                DB      0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H,7EH,23H,66H,6FH ; 1F78: .*...=....##~#fo
                DB      29H,0D1H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H ; 1F88: )...w#w.\.C)).*.
                DB      01H,11H,3DH,07H,19H,0D1H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,47H ; 1F98: ..=.....w#w*...G
                DB      00H,19H,5EH,23H,56H,1BH,72H,2BH,73H,0C3H,69H,20H,0CDH,5CH,01H,43H ; 1FA8: ..^#V.r+s.i .\.C
                DB      29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H,7EH,23H ; 1FB8: )).*...=....##~#
                DB      66H,6FH,0E5H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H ; 1FC8: fo..\.C)).*...=.
                DB      19H,0D1H,19H,7EH,23H,66H,6FH,2BH,0E5H,0CDH,38H,1CH,0D1H,0D1H,21H,94H ; 1FD8: ...~#fo+..8...!.
                DB      20H,0E5H,0CDH,3BH,1CH,0D1H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H ; 1FE8:  ......\.C)).*..
                DB      11H,3DH,07H,19H,0D1H,19H,7EH,23H,66H,6FH,11H,17H,00H,0CDH,0E5H,01H ; 1FF8: .=....~#fo......
                DB      0C2H,30H,20H,2AH,15H,01H,11H,47H,00H,19H,5EH,23H,56H,1BH,72H,2BH ; 2008: .0 *...G..^#V.r+
                DB      73H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H ; 2018: s.\.C)).*...=...
                DB      19H,0AFH,77H,23H,77H,0C3H,61H,20H,0CDH,5CH,01H,43H,29H,29H,0E5H,2AH ; 2028: ..w#w.a .\.C)).*
                DB      15H,01H,11H,3DH,07H,19H,0D1H,19H,23H,23H,7EH,23H,66H,6FH,0E5H,0CDH ; 2038: ...=....##~#fo..
                DB      5CH,01H,43H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,7EH ; 2048: \.C)).*...=....~
                DB      23H,66H,6FH,0E5H,0CDH,38H,1CH,0D1H,0D1H,21H,96H,20H,0E5H,0CDH,3BH,1CH ; 2058: #fo..8...!. ....
                DB      0D1H,2AH,15H,01H,11H,43H,00H,19H,5EH,23H,56H,13H,72H,2BH,73H,0C3H ; 2068: .*...C..^#V.r+s.
                DB      5CH,1CH,0C1H,0C9H,20H,00H,42H,61H,73H,65H,73H,3AH,20H,25H,64H,00H ; 2078: \... .Bases: %d.
                DB      20H,20H,20H,20H,20H,20H,20H,00H,20H,00H,20H,00H,20H,00H,2AH,00H ; 2088:        . . . .*.
                DB      0C3H,0A7H,20H,0C3H,0A0H,37H,0C3H,0DFH,2BH,0C3H,08H,31H,0C3H,37H,09H,0C5H ; 2098: .. ..7..+..1.7..
                DB      21H,0FEH,0FFH,39H,0F9H,44H,4DH,60H,69H,36H,50H,23H,36H,00H,0CDH,4DH ; 20A8: !..9.DM`i6P#6..M
                DB      01H,69H,07H,7CH,0B5H,0C2H,2FH,21H,0CDH,9BH,20H,0E5H,2AH,15H,01H,11H ; 20B8: .i.|../!.. .*...
                DB      33H,00H,19H,0D1H,73H,23H,72H,21H,60H,00H,0CDH,0FAH,01H,0D2H,2CH,21H ; 20C8: 3...s#r!`.....,!
                DB      0CDH,5CH,01H,33H,11H,30H,00H,0CDH,0F9H,01H,0D2H,00H,21H,2AH,15H,01H ; 20D8: .\.3.0......!*..
                DB      11H,69H,07H,19H,36H,01H,23H,36H,00H,2AH,15H,01H,11H,67H,07H,19H ; 20E8: .i..6.#6.*...g..
                DB      36H,01H,23H,36H,00H,0C3H,20H,21H,2AH,15H,01H,11H,69H,07H,19H,36H ; 20F8: 6.#6.. !*...i..6
                DB      0FFH,23H,36H,0FFH,0CDH,90H,01H,00H,11H,0F8H,0FFH,19H,0E5H,2AH,15H,01H ; 2108: .#6..........*..
                DB      11H,67H,07H,19H,0D1H,73H,23H,72H,2AH,15H,01H,11H,65H,07H,19H,36H ; 2118: .g...s#r*...e..6
                DB      5AH,23H,36H,00H,0C3H,0F8H,21H,0CDH,4DH,01H,67H,07H,0E5H,21H,01H,00H ; 2128: Z#6...!.M.g..!..
                DB      0E5H,0CDH,9EH,20H,0D1H,0D1H,0CDH,5CH,01H,31H,11H,03H,00H,0CDH,04H,02H ; 2138: ... ...\.1......
                DB      0DAH,6AH,21H,0CDH,4DH,01H,65H,07H,11H,03H,00H,0EBH,0CDH,0CBH,02H,0E5H ; 2148: .j!.M.e.........
                DB      21H,01H,22H,0E5H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,0A1H,20H,0D1H ; 2158: !.".*......... .
                DB      0D1H,0D1H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,0A4H,20H,0D1H,2AH,15H ; 2168: ..*......... .*.
                DB      01H,11H,65H,07H,19H,5EH,23H,56H,1BH,72H,2BH,73H,2AH,15H,01H,11H ; 2178: ..e..^#V.r+s*...
                DB      67H,07H,19H,0E5H,7EH,23H,66H,6FH,0E5H,0CDH,4DH,01H,69H,07H,0D1H,19H ; 2188: g...~#fo..M.i...
                DB      0EBH,0E1H,73H,23H,72H,0CDH,4DH,01H,67H,07H,0E5H,2AH,15H,01H,11H,33H ; 2198: ..s#r.M.g..*...3
                DB      00H,19H,0D1H,73H,23H,72H,0D5H,0CDH,90H,01H,00H,11H,0F8H,0FFH,19H,0D1H ; 21A8: ...s#r..........
                DB      0CDH,05H,02H,0DAH,0CBH,21H,0CDH,5CH,01H,33H,11H,01H,00H,0CDH,0F9H,01H ; 21B8: .....!.\.3......
                DB      0D2H,0F8H,21H,0CDH,4DH,01H,67H,07H,0E5H,0CDH,4DH,01H,69H,07H,0D1H,0CDH ; 21C8: ..!.M.g...M.i...
                DB      0FAH,02H,19H,0E5H,21H,01H,00H,0E5H,0CDH,9EH,20H,0D1H,0D1H,21H,0CH,22H ; 21D8: ....!..... ..!."
                DB      0E5H,0CDH,0A4H,20H,0D1H,2AH,15H,01H,11H,69H,07H,19H,0AFH,77H,23H,77H ; 21E8: ... .*...i...w#w
                DB      0EBH,21H,02H,00H,39H,0F9H,0EBH,0C1H,0C9H,20H,20H,3CH,3DH,25H,64H,3DH ; 21F8: .!..9....  <=%d=
                DB      3EH,20H,20H,00H,20H,20H,20H,20H,20H,20H,20H,20H,00H,0C3H,24H,22H ; 2208: >  .        ..$"
                DB      0C3H,0E5H,2FH,0C3H,2BH,30H,0C3H,0DFH,2BH,0C3H,3DH,2CH,0C5H,0CDH,5CH,01H ; 2218: ../.+0..+.=,..\.
                DB      41H,23H,0E5H,2AH,15H,01H,11H,41H,00H,19H,0D1H,73H,23H,72H,21H,37H ; 2228: A#.*...A...s#r!7
                DB      00H,0CDH,0FAH,01H,0DAH,97H,22H,0CDH,5CH,01H,45H,7CH,0B5H,0C2H,4AH,22H ; 2238: ......".\.E|..J"
                DB      0C1H,0C9H,2AH,15H,01H,11H,3DH,00H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H ; 2248: ..*...=...w#w.\.
                DB      3BH,7CH,0B5H,0CAH,8CH,22H,0CDH,5CH,01H,3FH,11H,01H,00H,0CDH,0FAH,02H ; 2258: .|...".\.?......
                DB      19H,0E5H,2AH,15H,01H,11H,3FH,00H,19H,0D1H,73H,23H,72H,2AH,15H,01H ; 2268: ..*...?...s#r*..
                DB      11H,3DH,00H,19H,36H,01H,23H,36H,00H,2AH,15H,01H,11H,3BH,00H,19H ; 2278: .=..6.#6.*......
                DB      0AFH,77H,23H,77H                                                ; 2288: .w#w

ALIEN_MOVE_SOUND_HOOK:
; File 218CH / runtime 228CH
; CALL 4100H; replaces LD HL,(0115H)
                DB      0CDH,00H,41H                                                    ; 228C: ..A
                DB      11H,41H,00H,19H,0AFH,77H,23H,77H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH ; 228F: .A...w#w.\.A)).*
                DB      15H,01H,11H,57H,06H,19H,0D1H,19H,7EH,23H,66H,6FH,0E5H,2AH,15H,01H ; 229F: ...W....~#fo.*..
                DB      11H,33H,00H,19H,0D1H,73H,23H,72H,21H,00H,00H,0CDH,05H,02H,0D2H,0C3H ; 22AF: .3...s#r!.......
                DB      22H,0C3H,0C6H,22H,0C3H,25H,22H,0CDH,5CH,01H,33H,11H,17H,00H,0CDH,0F9H ; 22BF: "..".%".\.3.....
                DB      01H,0DAH,0EEH,22H,2AH,15H,01H,11H,2DH,00H,19H,0E5H,7EH,23H,66H,6FH ; 22CF: ..."*...-...~#fo
                DB      11H,0F6H,0FFH,19H,0EBH,0E1H,73H,23H,72H,0CDH,18H,22H,0CDH,1BH,22H,0CDH ; 22DF: ......s#r.."..".
                DB      5CH,01H,3FH,7CH,0B5H,0CAH,13H,23H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH ; 22EF: \.?|...#.\.A)).*
                DB      15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H,5EH,23H,56H,1BH,72H,2BH ; 22FF: ...W....##^#V.r+
                DB      73H,0C3H,2CH,23H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH,15H,01H,11H,57H ; 230F: s.,#.\.A)).*...W
                DB      06H,19H,0D1H,19H,23H,23H,5EH,23H,56H,13H,72H,2BH,73H,0CDH,5CH,01H ; 231F: ....##^#V.r+s.\.
                DB      41H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H,7EH ; 232F: A)).*...W....##~
                DB      23H,66H,6FH,0E5H,2AH,15H,01H,11H,35H,00H,19H,0D1H,73H,23H,72H,7AH ; 233F: #fo.*...5...s#rz
                DB      0B3H,0CAH,81H,23H,0CDH,5CH,01H,35H,0E5H,0CDH,5CH,01H,4DH,11H,4BH,00H ; 234F: ...#.\.5..\.M.K.
                DB      0CDH,0FAH,02H,19H,0E5H,0CDH,5CH,01H,4FH,11H,03H,00H,0CDH,3FH,02H,11H ; 235F: ......\.O....?..
                DB      02H,00H,0EBH,0CDH,0CBH,02H,0D1H,0CDH,0FAH,02H,19H,0D1H,0CDH,0FAH,01H,0DAH ; 236F: ................
                DB      8DH,23H,2AH,15H,01H,11H,3BH,00H,19H,36H,01H,23H,36H,00H,0CDH,5CH ; 237F: .#*......6.#6..\
                DB      01H,35H,0E5H,0CDH,5CH,01H,33H,0E5H,0CDH,1EH,22H,0D1H,0D1H,0CDH,5CH,01H ; 238F: .5..\.3..."...\.
                DB      3DH,7CH,0B5H,0CAH,0DFH,23H,21H,06H,00H,0E5H,0CDH,21H,22H,0D1H,0CDH,5CH ; 239F: =|...#!....!"..\
                DB      01H,41H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,5EH,23H ; 23AF: .A)).*...W....^#
                DB      56H,13H,72H,2BH,73H,0D5H,2AH,15H,01H,11H,33H,00H,19H,0D1H,73H,23H ; 23BF: V.r+s.*...3...s#
                DB      72H,0CDH,5CH,01H,35H,0E5H,0CDH,5CH,01H,33H,0E5H,0CDH,1EH,22H,0D1H,0D1H ; 23CF: r.\.5..\.3..."..
                DB      0CDH,5CH,01H,35H,0E5H,0CDH,5CH,01H,33H,11H,02H,00H,0EBH,0CDH,0CBH,02H ; 23DF: .\.5..\.3.......
                DB      0D1H,19H,11H,01H,00H,7CH,0A2H,67H,7DH,0A3H,6FH,0E5H,0CDH,5CH,01H,41H ; 23EF: .....|.g}.o..\.A
                DB      11H,16H,00H,0EBH,0CDH,0CBH,02H,11H,02H,00H,0CDH,3FH,02H,0D1H,19H,0E5H ; 23FF: ...........?....
                DB      0CDH,21H,22H,0D1H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH,15H,01H,11H,57H ; 240F: .!"..\.A)).*...W
                DB      06H,19H,0D1H,19H,7EH,23H,66H,6FH,11H,13H,00H,0CDH,0F9H,01H,0DAH,0F6H ; 241F: ....~#fo........
                DB      24H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H ; 242F: $.\.A)).*...W...
                DB      19H,7EH,23H,66H,6FH,11H,17H,00H,0CDH,0F9H,01H,0D2H,0F6H,24H,0CDH,5CH ; 243F: .~#fo........$.\
                DB      01H,41H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H ; 244F: .A)).*...W....##
                DB      7EH,23H,66H,6FH,0E5H,2AH,15H,01H,11H,35H,00H,19H,0D1H,73H,23H,72H ; 245F: ~#fo.*...5...s#r
                DB      2AH,15H,01H,11H,33H,00H,19H,36H,03H,23H,36H,00H,0CDH,5CH,01H,33H ; 246F: *...3..6.#6..\.3
                DB      11H,0FFH,0FFH,0CDH,0F9H,01H,0DAH,0F6H,24H,0CDH,5CH,01H,35H,0E5H,0CDH,5CH ; 247F: ........$.\.5..\
                DB      01H,33H,0D1H,19H,7CH,0B7H,0FAH,0F6H,24H,0CDH,5CH,01H,41H,29H,29H,0E5H ; 248F: .3..|...$.\.A)).
                DB      2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,7EH,23H,66H,6FH,11H,0EDH,0FFH ; 249F: *...W....~#fo...
                DB      19H,11H,0A2H,00H,0CDH,6BH,02H,0E5H,2AH,15H,01H,11H,0D9H,02H,19H,0D1H ; 24AF: .....k..*.......
                DB      19H,0E5H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H ; 24BF: ...\.A)).*...W..
                DB      0D1H,19H,23H,23H,7EH,23H,66H,6FH,0E5H,0CDH,5CH,01H,33H,0D1H,19H,29H ; 24CF: ..##~#fo..\.3..)
                DB      0D1H,19H,0AFH,77H,23H,77H,2AH,15H,01H,11H,33H,00H,19H,5EH,23H,56H ; 24DF: ...w#w*...3..^#V
                DB      1BH,72H,2BH,73H,0C3H,7BH,24H,0CDH,5CH,01H,31H,2BH,7CH,0B5H,0CAH,0BH ; 24EF: .r+s.{$.\.1+|...
                DB      25H,0CDH,5CH,01H,31H,2BH,2BH,7CH,0B5H,0C2H,0DH,25H,0C1H,0C9H,0CDH,5CH ; 24FF: %.\.1++|...%...\
                DB      01H,41H,11H,0F5H,0FFH,19H,0E5H,2AH,15H,01H,11H,33H,00H,19H,0D1H,73H ; 250F: .A.....*...3...s
                DB      23H,72H,0CDH,5CH,01H,33H,7CH,0B7H,0FAH,5DH,25H,0CDH,5CH,01H,33H,29H ; 251F: #r.\.3|..]%.\.3)
                DB      29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,7EH,23H,66H,6FH,7CH ; 252F: ).*...W....~#fo|
                DB      0B5H,0CAH,45H,25H,0C1H,0C9H,2AH,15H,01H,11H,33H,00H,19H,0E5H,7EH,23H ; 253F: ..E%..*...3...~#
                DB      66H,6FH,11H,0F5H,0FFH,19H,0EBH,0E1H,73H,23H,72H,0C3H,21H,25H,0CDH,5CH ; 254F: fo......s#r.!%.\
                DB      01H,41H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H ; 255F: .A)).*...W....##
                DB      7EH,23H,66H,6FH,0E5H,0CDH,4DH,01H,35H,07H,0E5H,0CDH,5CH,01H,4BH,0D1H ; 256F: ~#fo..M.5...\.K.
                DB      0CDH,0FAH,02H,19H,0D1H,0CDH,0FAH,01H,0DAH,84H,26H,0CDH,5CH,01H,41H,29H ; 257F: ..........&.\.A)
                DB      29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H,7EH,23H,66H ; 258F: ).*...W....##~#f
                DB      6FH,0E5H,0CDH,4DH,01H,35H,07H,23H,23H,23H,0E5H,0CDH,5CH,01H,4BH,0D1H ; 259F: o..M.5.###..\.K.
                DB      19H,0D1H,0CDH,0FAH,01H,0D2H,84H,26H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH ; 25AF: .......&.\.A)).*
                DB      15H,01H,11H,57H,06H,19H,0D1H,19H,7EH,23H,66H,6FH,11H,14H,00H,0CDH ; 25BF: ...W....~#fo....
                DB      04H,02H,0DAH,84H,26H,2AH,15H,01H,11H,33H,00H,19H,0AFH,77H,23H,77H ; 25CF: ....&*...3...w#w
                DB      0CDH,5CH,01H,33H,0E5H,0CDH,5CH,01H,49H,0D1H,0CDH,0FAH,01H,0D2H,84H,26H ; 25DF: .\.3..\.I......&
                DB      0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H ; 25EF: .\.3)).*...=....
                DB      7EH,23H,66H,6FH,7CH,0B5H,0C2H,73H,26H,0CDH,5CH,01H,33H,29H,29H,0E5H ; 25FF: ~#fo|..s&.\.3)).
                DB      2AH,15H,01H,11H,3DH,07H,19H,0D1H,19H,0E5H,0CDH,5CH,01H,41H,29H,29H ; 260F: *...=......\.A))
                DB      0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,7EH,23H,66H,6FH,0EBH,0E1H ; 261F: .*...W....~#fo..
                DB      73H,23H,72H,0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,3DH,07H ; 262F: s#r.\.3)).*...=.
                DB      19H,0D1H,19H,23H,23H,0E5H,0CDH,5CH,01H,41H,29H,29H,0E5H,2AH,15H,01H ; 263F: ...##..\.A)).*..
                DB      11H,57H,06H,19H,0D1H,19H,23H,23H,7EH,23H,66H,6FH,23H,23H,0EBH,0E1H ; 264F: .W....##~#fo##..
                DB      73H,23H,72H,2AH,15H,01H,11H,47H,00H,19H,5EH,23H,56H,13H,72H,2BH ; 265F: s#r*...G..^#V.r+
                DB      73H,0C3H,84H,26H,2AH,15H,01H,11H,33H,00H,19H,5EH,23H,56H,13H,72H ; 266F: s..&*...3..^#V.r
                DB      2BH,73H,0C3H,0DFH,25H,0C1H,0C9H,0C3H,98H,26H,0C3H,0CAH,2BH,0C3H,0DFH,2BH ; 267F: +s..%....&..+..+
                DB      0C3H,08H,31H,0C3H,37H,09H,0C3H,0C8H,37H,0C5H,0CDH,89H,26H,21H,0AH,00H ; 268F: ..1.7...7...&!..
                DB      0E5H,21H,0AH,00H,0E5H,0CDH,8CH,26H,0D1H,0D1H,0CDH,5CH,01H,4FH,11H,08H ; 269F: .!.....&...\.O..
                DB      00H,0CDH,04H,02H,0D2H,0C0H,26H,2AH,15H,01H,11H,0DAH,05H,19H,0C3H,0D4H ; 26AF: ......&*........
                DB      26H,0CDH,5CH,01H,4FH,11H,0FH,00H,0CDH,6BH,02H,0E5H,2AH,15H,01H,11H ; 26BF: &.\.O....k..*...
                DB      62H,05H,19H,0D1H,19H,0E5H,21H,5BH,27H,0E5H,2AH,15H,01H,11H,0F3H,05H ; 26CF: b.....!['.*.....
                DB      19H,0E5H,0CDH,8FH,26H,0D1H,0D1H,0D1H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H ; 26DF: ....&...*.......
                DB      0CDH,92H,26H,0D1H,2AH,15H,01H,11H,4FH,00H,19H,5EH,23H,56H,13H,72H ; 26EF: ..&.*...O..^#V.r
                DB      2BH,73H,1BH,0D5H,21H,6FH,27H,0E5H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H ; 26FF: +s..!o'.*.......
                DB      0CDH,8FH,26H,0D1H,0D1H,0D1H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,92H ; 270F: ..&...*.........
                DB      26H,0D1H,21H,0AH,00H,0E5H,21H,0CH,00H,0E5H,0CDH,8CH,26H,0D1H,0D1H,0CDH ; 271F: &.!...!.....&...
                DB      5CH,01H,4FH,0E5H,21H,8AH,27H,0E5H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H ; 272F: \.O.!.'.*.......
                DB      0CDH,8FH,26H,0D1H,0D1H,0D1H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,92H ; 273F: ..&...*.........
                DB      26H,0D1H,21H,32H,00H,0E5H,0CDH,95H,26H,0D1H,0C1H,0C9H,43H,6FH,6EH,67H ; 274F: &.!2....&...Cong
                DB      72H,61H,74H,75H,6CH,61H,74H,69H,6FH,6EH,73H,20H,25H,73H,20H,00H ; 275F: ratulations %s .
                DB      2DH,20H,79H,6FH,75H,20H,68H,61H,76H,65H,20H,77H,6FH,6EH,20H,61H ; 276F: - you have won a
                DB      74H,20H,6CH,65H,76H,65H,6CH,20H,25H,64H,00H,4EH,6FH,77H,20H,6CH ; 277F: t level %d.Now l
                DB      65H,74H,27H,73H,20H,73H,65H,65H,20H,68H,6FH,77H,20H,67H,6FH,6FH ; 278F: et's see how goo
                DB      64H,20H,79H,6FH,75H,20H,61H,72H,65H,20H,61H,74H,20H,6CH,65H,76H ; 279F: d you are at lev
                DB      65H,6CH,20H,25H,64H,00H,0C3H,0BBH,27H,0C3H,0F9H,37H,0C5H,21H,00H,00H ; 27AF: el %d...'..7.!..
                DB      39H,0F9H,44H,4DH,0CDH,90H,01H,04H,0E5H,21H,04H,00H,0E5H,0CDH,0B8H,27H ; 27BF: 9.DM.....!.....'
                DB      0D1H,0D1H,0C1H,0C9H,0C1H,0C9H,0C5H,2AH,15H,01H,11H,33H,00H,19H,0AFH,77H ; 27CF: .......*...3...w
                DB      23H,77H,0CDH,5CH,01H,33H,11H,0AH,00H,0CDH,0F9H,01H,0D2H,61H,28H,0CDH ; 27DF: #w.\.3.......a(.
                DB      5CH,01H,33H,0E5H,2AH,15H,01H,11H,0E9H,05H,19H,0D1H,19H,0E5H,0CDH,5CH ; 27EF: \.3.*..........\
                DB      01H,33H,0EBH,2AH,15H,01H,19H,6EH,0EBH,0E1H,73H,0CDH,5CH,01H,33H,0E5H ; 27FF: .3.*...n..s.\.3.
                DB      2AH,15H,01H,11H,0E9H,05H,19H,0D1H,19H,6EH,7DH,0FEH,0FFH,0C2H,2DH,28H ; 280F: *........n}...-(
                DB      0CDH,5CH,01H,33H,0E5H,2AH,15H,01H,11H,2AH,00H,19H,0D1H,73H,0CDH,5CH ; 281F: .\.3.*...*...s.\
                DB      01H,33H,0E5H,2AH,15H,01H,11H,0E9H,05H,19H,0D1H,19H,6EH,7DH,0FEH,0FEH ; 282F: .3.*........n}..
                DB      0C2H,50H,28H,0CDH,5CH,01H,33H,0E5H,2AH,15H,01H,11H,2BH,00H,19H,0D1H ; 283F: .P(.\.3.*...+...
                DB      73H,2AH,15H,01H,11H,33H,00H,19H,5EH,23H,56H,13H,72H,2BH,73H,0C3H ; 284F: s*...3..^#V.r+s.
                DB      0E1H,27H,0C1H,0C9H,0C3H,6FH,28H,0C3H,0CAH,2BH,0C3H,0DFH,2BH,0C3H,37H,09H ; 285F: .'...o(..+..+.7.
                DB      0C5H,0CDH,66H,28H,21H,00H,00H,0E5H,21H,00H,00H,0E5H,0CDH,69H,28H,0D1H ; 286F: ..f(!...!....i(.
                DB      0D1H,21H,0FAH,28H,0E5H,0CDH,6CH,28H,0D1H,21H,24H,29H,0E5H,0CDH,6CH,28H ; 287F: .!.(..l(.!$)..l(
                DB      0D1H,21H,5AH,29H,0E5H,0CDH,6CH,28H,0D1H,21H,8AH,29H,0E5H,0CDH,6CH,28H ; 288F: .!Z)..l(.!.)..l(
                DB      0D1H,21H,0BBH,29H,0E5H,0CDH,6CH,28H,0D1H,21H,0E1H,29H,0E5H,0CDH,6CH,28H ; 289F: .!.)..l(.!.)..l(
                DB      0D1H,21H,18H,2AH,0E5H,0CDH,6CH,28H,0D1H,21H,3EH,2AH,0E5H,0CDH,6CH,28H ; 28AF: .!.*..l(.!>*..l(
                DB      0D1H,21H,6EH,2AH,0E5H,0CDH,6CH,28H,0D1H,21H,9CH,2AH,0E5H,0CDH,6CH,28H ; 28BF: .!n*..l(.!.*..l(
                DB      0D1H,21H,0D1H,2AH,0E5H,0CDH,6CH,28H,0D1H,21H,0CH,2BH,0E5H,0CDH,6CH,28H ; 28CF: .!.*..l(.!.+..l(
                DB      0D1H,21H,48H,2BH,0E5H,0CDH,6CH,28H,0D1H,21H,74H,2BH,0E5H,0CDH,6CH,28H ; 28DF: .!H+..l(.!t+..l(
                DB      0D1H,21H,0A7H,2BH,0E5H,0CDH,6CH,28H,0D1H,0C1H,0C9H,41H,74H,74H,65H,6EH ; 28EF: .!.+..l(...Atten
                DB      74H,69H,6FH,6EH,3AH,20H,41H,6CH,69H,65H,6EH,20H,69H,6EH,76H,61H ; 28FF: tion: Alien inva
                DB      73H,69H,6FH,6EH,20H,69H,6EH,20H,70H,72H,6FH,67H,72H,65H,73H,73H ; 290F: sion in progress
                DB      21H,0DH,0AH,0AH,00H,20H,20H,20H,20H,20H,20H,20H,20H,54H,79H,70H ; 291F: !....        Typ
                DB      65H,3AH,20H,20H,20H,3CH,2CH,3EH,20H,20H,20H,20H,20H,74H,6FH,20H ; 292F: e:   <,>     to 
                DB      6DH,6FH,76H,65H,20H,74H,68H,65H,20H,6CH,61H,73H,65H,72H,20H,62H ; 293F: move the laser b
                DB      61H,73H,65H,20H,6CH,65H,66H,74H,0DH,0AH,00H,20H,20H,20H,20H,20H ; 294F: ase left...     
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH,7AH,3EH,20H,20H ; 295F:            <z>  
                DB      20H,20H,20H,61H,73H,20H,61H,62H,6FH,76H,65H,2CH,20H,66H,6FH,72H ; 296F:    as above, for
                DB      20H,6CH,65H,66H,74H,69H,65H,73H,0DH,0AH,00H,20H,20H,20H,20H,20H ; 297F:  lefties...     
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH,2EH,3EH,20H,20H ; 298F:            <.>  
                DB      20H,20H,20H,74H,6FH,20H,68H,61H,6CH,74H,20H,74H,68H,65H,20H,6CH ; 299F:    to halt the l
                DB      61H,73H,65H,72H,20H,62H,61H,73H,65H,0DH,0AH,00H,20H,20H,20H,20H ; 29AF: aser base...    
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH,78H,3EH,20H ; 29BF:             <x> 
                DB      20H,20H,20H,20H,66H,6FH,72H,20H,6CH,65H,66H,74H,69H,65H,73H,0DH ; 29CF:     for lefties.
                DB      0AH,00H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H ; 29DF: ..              
                DB      20H,20H,3CH,2FH,3EH,20H,20H,20H,20H,20H,74H,6FH,20H,6DH,6FH,76H ; 29EF:   </>     to mov
                DB      65H,20H,74H,68H,65H,20H,6CH,61H,73H,65H,72H,20H,62H,61H,73H,65H ; 29FF: e the laser base
                DB      20H,72H,69H,67H,68H,74H,0DH,0AH,00H,20H,20H,20H,20H,20H,20H,20H ; 2A0F:  right...       
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH,63H,3EH,20H,20H,20H,20H ; 2A1F:          <c>    
                DB      20H,66H,6FH,72H,20H,6CH,65H,66H,74H,69H,65H,73H,0DH,0AH,00H,20H ; 2A2F:  for lefties... 
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH ; 2A3F:                <
                DB      73H,70H,61H,63H,65H,3EH,20H,74H,6FH,20H,66H,69H,72H,65H,20H,61H ; 2A4F: space> to fire a
                DB      20H,6CH,61H,73H,65H,72H,20H,62H,65H,61H,6DH,0DH,0AH,0AH,00H     ; 2A5F:  laser beam....

MENU_LEVEL1_HIDDEN:
; File 296EH / runtime 2A6EH
; NUL-prefix hides original level-1 text
                DB      00H                                                             ; 2A6E: .
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH ; 2A6F:                <
                DB      31H,3EH,20H,20H,20H,20H,20H,74H,6FH,20H,70H,6CH,61H,79H,20H,22H ; 2A7F: 1>     to play "
                DB      42H,6CH,6FH,6FH,64H,62H,61H,74H,68H,22H,0DH,0AH,00H             ; 2A8F: Bloodbath"...

MENU_START_GAME:
; File 299CH / runtime 2A9CH
; Fixed menu region containing "<1> Start Game"
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H ; 2A9C:                 
                DB      3CH,31H,3EH,20H,20H,20H,20H,20H,53H,74H,61H,72H,74H,20H,47H,61H ; 2AAC: <1>     Start Ga
                DB      6DH,65H,0DH,0AH,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H ; 2ABC: me..............
                DB      00H,00H,00H,00H,00H                                             ; 2ACC: .....

MENU_LEVEL3_HIDDEN:
; File 29D1H / runtime 2AD1H
; NUL-prefix hides original level-3 text
                DB      00H                                                             ; 2AD1: .
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH ; 2AD2:                <
                DB      33H,3EH,20H,20H,20H,20H,20H,74H,6FH,20H,70H,6CH,61H,79H,20H,22H ; 2AE2: 3>     to play "
                DB      54H,68H,65H,20H,41H,6CH,69H,65H,6EH,73H,20H,73H,74H,72H,69H,6BH ; 2AF2: The Aliens strik
                DB      65H,20H,62H,61H,63H,6BH,22H,0DH,0AH,00H                         ; 2B02: e back"...

MENU_LEVEL4_HIDDEN:
; File 2A0CH / runtime 2B0CH
; NUL-prefix hides original level-4 text
                DB      00H                                                             ; 2B0C: .
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH ; 2B0D:                <
                DB      34H,3EH,20H,20H,20H,20H,20H,74H,6FH,20H,70H,6CH,61H,79H,20H,22H ; 2B1D: 4>     to play "
                DB      49H,6EH,76H,69H,73H,69H,62H,6CH,65H,20H,41H,6CH,69H,65H,6EH,20H ; 2B2D: Invisible Alien 
                DB      57H,65H,61H,73H,65H,6CH,73H,22H,0DH,0AH,00H                     ; 2B3D: Weasels"...

MENU_LEVEL5_HIDDEN:
; File 2A48H / runtime 2B48H
; NUL-prefix hides original level-5 text
                DB      00H                                                             ; 2B48: .
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH ; 2B49:                <
                DB      35H,3EH,20H,20H,20H,20H,20H,74H,6FH,20H,70H,6CH,61H,79H,20H,22H ; 2B59: 5>     to play "
                DB      4BH,6CH,69H,6EH,6BH,65H,72H,22H,0DH,0AH,00H                     ; 2B69: Klinker"...

MENU_LEVEL6_HIDDEN:
; File 2A74H / runtime 2B74H
; NUL-prefix hides original level-6 text
                DB      00H                                                             ; 2B74: .
                DB      20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,3CH ; 2B75:                <
                DB      36H,3EH,20H,20H,20H,20H,20H,74H,6FH,20H,70H,6CH,61H,79H,20H,22H ; 2B85: 6>     to play "
                DB      54H,68H,65H,20H,42H,6CH,61H,63H,6BH,20H,48H,6FH,6CH,65H,22H,0DH ; 2B95: The Black Hole".
                DB      0AH,00H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H ; 2BA5: ..              
                DB      20H,20H,3CH,71H,3EH,20H,20H,20H,20H,20H,74H,6FH,20H,71H,75H,69H ; 2BB5:   <q>     to qui
                DB      74H,0DH,0AH,0AH,00H,0C3H,0D0H,2BH,0C3H,37H,09H,0C5H,2AH,15H,01H,11H ; 2BC5: t......+.7..*...
                DB      1EH,00H,19H,0E5H,0CDH,0CDH,2BH,0D1H,0C1H,0C9H,0C3H,0E5H,2BH,0C3H,37H,09H ; 2BD5: ......+.....+.7.
                DB      0C5H,21H,00H,00H,39H,0F9H,44H,4DH,0CDH,77H,01H,2AH,26H,00H,0E5H,2AH ; 2BE5: .!..9.DM.w.*&..*
                DB      15H,01H,11H,0E9H,05H,19H,0D1H,19H,0E5H,0CDH,90H,01H,04H,0E5H,0CDH,77H ; 2BF5: ...............w
                DB      01H,28H,0D1H,0AFH,67H,19H,0EBH,0E1H,73H,0CDH,77H,01H,2BH,26H,00H,0E5H ; 2C05: .(..g...s.w.+&..
                DB      2AH,15H,01H,11H,0E9H,05H,19H,0D1H,19H,0E5H,0CDH,90H,01H,06H,0E5H,0CDH ; 2C15: *...............
                DB      77H,01H,29H,0D1H,0AFH,67H,19H,0EBH,0E1H,73H,2AH,15H,01H,11H,0E9H,05H ; 2C25: w.)..g...s*.....
                DB      19H,0E5H,0CDH,0E2H,2BH,0D1H,0C1H,0C9H,0C3H,43H,2CH,0C3H,37H,09H,0C5H,21H ; 2C35: ....+....C,.7..!
                DB      00H,00H,39H,0F9H,44H,4DH,0CDH,5CH,01H,31H,11H,04H,00H,0CDH,0F9H,01H ; 2C45: ..9.DM.\.1......
                DB      0DAH,77H,2CH,0CDH,90H,01H,04H,7CH,0B7H,0FAH,77H,2CH,0CDH,90H,01H,04H ; 2C55: .w,....|..w,....
                DB      11H,05H,00H,0CDH,04H,02H,0DAH,77H,2CH,21H,04H,00H,09H,36H,06H,23H ; 2C65: .......w,!...6.#
                DB      36H,00H,0CDH,90H,01H,04H,3EH,00H,0BDH,0C2H,87H,2CH,3EH,00H,0BCH,0CAH ; 2C75: 6.....>....,>...
                DB      0EAH,2CH,3EH,01H,0BDH,0C2H,93H,2CH,3EH,00H,0BCH,0CAH,0F5H,2CH,3EH,02H ; 2C85: .,>....,>....,>.
                DB      0BDH,0C2H,9FH,2CH,3EH,00H,0BCH,0CAH,00H,2DH,3EH,03H,0BDH,0C2H,0ABH,2CH ; 2C95: ...,>....->....,
                DB      3EH,00H,0BCH,0CAH,0BH,2DH,3EH,04H,0BDH,0C2H,0B7H,2CH,3EH,00H,0BCH,0CAH ; 2CA5: >....->....,>...
                DB      16H,2DH,3EH,05H,0BDH,0C2H,0C3H,2CH,3EH,00H,0BCH,0CAH,21H,2DH,3EH,06H ; 2CB5: .->....,>...!->.
                DB      0BDH,0C2H,0CFH,2CH,3EH,00H,0BCH,0CAH,2CH,2DH,3EH,07H,0BDH,0C2H,0DBH,2CH ; 2CC5: ...,>...,->....,
                DB      3EH,00H,0BCH,0CAH,37H,2DH,3EH,08H,0BDH,0C2H,0E7H,2CH,3EH,00H,0BCH,0CAH ; 2CD5: >...7->....,>...
                DB      42H,2DH,0C3H,5DH,2DH,21H,5FH,2DH,0E5H,0CDH,40H,2CH,0D1H,0C3H,5DH,2DH ; 2CE5: B-.]-!_-..@,..]-
                DB      21H,65H,2DH,0E5H,0CDH,40H,2CH,0D1H,0C3H,5DH,2DH,21H,6BH,2DH,0E5H,0CDH ; 2CF5: !e-..@,..]-!k-..
                DB      40H,2CH,0D1H,0C3H,5DH,2DH,21H,71H,2DH,0E5H,0CDH,40H,2CH,0D1H,0C3H,5DH ; 2D05: @,..]-!q-..@,..]
                DB      2DH,21H,77H,2DH,0E5H,0CDH,40H,2CH,0D1H,0C3H,5DH,2DH,21H,7DH,2DH,0E5H ; 2D15: -!w-..@,..]-!}-.
                DB      0CDH,40H,2CH,0D1H,0C3H,5DH,2DH,21H,83H,2DH,0E5H,0CDH,40H,2CH,0D1H,0C3H ; 2D25: .@,..]-!.-..@,..
                DB      5DH,2DH,21H,89H,2DH,0E5H,0CDH,40H,2CH,0D1H,0C3H,5DH,2DH,0CDH,5CH,01H ; 2D35: ]-!.-..@,..]-.\.
                DB      31H,11H,05H,00H,0CDH,0F9H,01H,0DAH,52H,2DH,0C3H,5DH,2DH,21H,91H,2DH ; 2D45: 1.......R-.]-!.-
                DB      0E5H,0CDH,40H,2CH,0D1H,0C3H,5DH,2DH,0C1H,0C9H                   ; 2D55: ..@,..]-..

ALIEN_FRAME_OXO:
; File 2C5FH / runtime 2D5FH
; Custom frame: 4F D8 4F
                DB      20H,4FH,0D8H,4FH,20H,00H                                        ; 2D5F:  O.O .

ALIEN_FRAME_XOX:
; File 2C65H / runtime 2D65H
; Custom frame: 58 CF 58
                DB      20H,58H,0CFH,58H,20H,00H                                        ; 2D65:  X.X .

ALIEN_FRAME_SLASH_A:
; File 2C6BH / runtime 2D6BH
; Custom frame: 2F CF 5C
                DB      20H,2FH,0CFH,5CH,20H,00H                                        ; 2D6B:  /.\ .

ALIEN_FRAME_SLASH_B:
; File 2C71H / runtime 2D71H
; Custom frame: 5C 4F 2F
                DB      20H,5CH,4FH,2FH,20H,00H                                         ; 2D71:  \O/ .

ALIEN_FRAME_M_A:
; File 2C77H / runtime 2D77H
; Custom frame: 83 80 83
                DB      20H,83H,80H,83H,20H,00H                                         ; 2D77:  ... .

ALIEN_FRAME_M_B:
; File 2C7DH / runtime 2D7DH
; Custom frame: 88 83 84
                DB      20H,88H,83H,84H,20H,00H                                         ; 2D7D:  ... .

ALIEN_FRAME_RESERVED:
; File 2C83H / runtime 2D83H
; Original six-byte entry retained
                DB      20H,20H,20H,20H,20H,00H                                         ; 2D83:      .

PLAYER_TURRET:
; File 2C89H / runtime 2D89H
; Custom turret: 8B 83 80 83 87
                DB      20H,8BH,83H,80H,83H,87H,20H,00H                                 ; 2D89:  ..... .

BARRIER_CHARACTER:
; File 2C91H / runtime 2D91H
; Character 80H followed by NUL
                DB      80H,00H                                                         ; 2D91: ..
                DB      0C3H,99H,2DH,0C3H,0F9H,37H,0C5H,21H,02H,00H,0E5H,0CDH,96H,2DH,0D1H,7CH ; 2D93: ..-..7.!.....-.|
                DB      0B5H,0CAH,0BEH,2DH,21H,03H,00H,0E5H,0CDH,96H,2DH,0D1H,0E5H,2AH,15H,01H ; 2DA3: ...-!.....-..*..
                DB      11H,2CH,00H,19H,0D1H,73H,21H,01H,00H,0C1H,0C9H,21H,00H,00H,0C1H,0C9H ; 2DB3: .,...s!....!....
                DB      0C1H,0C9H,0C5H,0CDH,77H,01H,2CH,26H,00H,0C1H,0C9H,0C1H,0C9H,0C3H,0E2H,2DH ; 2DC3: ....w.,&.......-
                DB      0C3H,0DFH,2BH,0C3H,3DH,2CH,0C3H,37H,09H,0C3H,0C8H,37H,0C3H,34H,37H,0C5H ; 2DD3: ..+.=,.7...7.47.
                DB      21H,0FEH,0FFH,39H,0F9H,44H,4DH,0CDH,5CH,01H,31H,11H,05H,00H,0CDH,0F9H ; 2DE3: !..9.DM.\.1.....
                DB      01H,0DAH,0BAH,2EH,0CDH,5CH,01H,31H,0EBH,60H,69H,73H,23H,72H,2AH,15H ; 2DF3: .....\.1.`is#r*.
                DB      01H,11H,31H,00H,19H,36H,03H,23H,36H,00H,2AH,15H,01H,11H,33H,00H ; 2E03: ..1..6.#6.*...3.
                DB      19H,0AFH,77H,23H,77H,0CDH,5CH,01H,33H,11H,03H,00H,0CDH,04H,02H,0DAH ; 2E13: ..w#w.\.3.......
                DB      0AAH,2EH,21H,00H,00H,0E5H,0CDH,5CH,01H,33H,11H,13H,00H,19H,0E5H,0CDH ; 2E23: ..!....\.3......
                DB      0D3H,2DH,0D1H,0D1H,2AH,15H,01H,11H,35H,00H,19H,0AFH,77H,23H,77H,0CDH ; 2E33: .-..*...5...w#w.
                DB      5CH,01H,35H,11H,50H,00H,0CDH,0F9H,01H,0D2H,99H,2EH,0CDH,5CH,01H,33H ; 2E43: \.5.P........\.3
                DB      11H,0A2H,00H,0CDH,6BH,02H,0E5H,2AH,15H,01H,11H,0D9H,02H,19H,0D1H,19H ; 2E53: ....k..*........
                DB      0E5H,0CDH,5CH,01H,35H,29H,0D1H,19H,7EH,23H,66H,6FH,2BH,7CH,0B5H,0C2H ; 2E63: ..\.5)..~#fo+|..
                DB      80H,2EH,21H,08H,00H,0E5H,0CDH,0D6H,2DH,0D1H,0C3H,88H,2EH,21H,0E3H,2FH ; 2E73: ..!.....-....!./
                DB      0E5H,0CDH,0D9H,2DH,0D1H,2AH,15H,01H,11H,35H,00H,19H,5EH,23H,56H,13H ; 2E83: ...-.*...5..^#V.
                DB      72H,2BH,73H,0C3H,42H,2EH,2AH,15H,01H,11H,33H,00H,19H,5EH,23H,56H ; 2E93: r+s.B.*...3..^#V
                DB      13H,72H,2BH,73H,0C3H,18H,2EH,0CDH,90H,01H,00H,0E5H,2AH,15H,01H,11H ; 2EA3: .r+s........*...
                DB      31H,00H,19H,0D1H,73H,23H,72H,0CDH,5CH,01H,31H,11H,04H,00H,0CDH,0F9H ; 2EB3: 1...s#r.\.1.....
                DB      01H,0DAH,0BEH,2FH,0CDH,5CH,01H,31H,0EBH,60H,69H,73H,23H,72H,2AH,15H ; 2EC3: .../.\.1.`is#r*.
                DB      01H,11H,31H,00H,19H,36H,03H,23H,36H,00H,2AH,15H,01H,11H,33H,00H ; 2ED3: ..1..6.#6.*...3.
                DB      19H,0AFH,77H,23H,77H,0CDH,5CH,01H,33H,11H,37H,00H,0CDH,0F9H,01H,0D2H ; 2EE3: ..w#w.\.3.7.....
                DB      0A6H,2FH,0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H ; 2EF3: ./.\.3)).*...W..
                DB      0D1H,19H,7EH,23H,66H,6FH,7CH,0B5H,0CAH,95H,2FH,0CDH,5CH,01H,33H,29H ; 2F03: ..~#fo|.../.\.3)
                DB      29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H,7EH,23H,66H ; 2F13: ).*...W....##~#f
                DB      6FH,0E5H,0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H ; 2F23: o..\.3)).*...W..
                DB      0D1H,19H,7EH,23H,66H,6FH,0E5H,0CDH,0D3H,2DH,0D1H,0D1H,0CDH,5CH,01H,33H ; 2F33: ..~#fo...-...\.3
                DB      29H,29H,0E5H,2AH,15H,01H,11H,57H,06H,19H,0D1H,19H,23H,23H,7EH,23H ; 2F43: )).*...W....##~#
                DB      66H,6FH,0E5H,0CDH,5CH,01H,33H,29H,29H,0E5H,2AH,15H,01H,11H,57H,06H ; 2F53: fo..\.3)).*...W.
                DB      19H,0D1H,19H,7EH,23H,66H,6FH,11H,02H,00H,0EBH,0CDH,0CBH,02H,0D1H,19H ; 2F63: ...~#fo.........
                DB      11H,01H,00H,7CH,0A2H,67H,7DH,0A3H,6FH,0E5H,0CDH,5CH,01H,33H,11H,16H ; 2F73: ...|.g}.o..\.3..
                DB      00H,0EBH,0CDH,0CBH,02H,11H,02H,00H,0CDH,3FH,02H,0D1H,19H,0E5H,0CDH,0D6H ; 2F83: .........?......
                DB      2DH,0D1H,2AH,15H,01H,11H,33H,00H,19H,5EH,23H,56H,13H,72H,2BH,73H ; 2F93: -.*...3..^#V.r+s
                DB      0C3H,0E8H,2EH,0CDH,90H,01H,00H,0E5H,2AH,15H,01H,11H,31H,00H,19H,0D1H ; 2FA3: ........*...1...
                DB      73H,23H,72H,21H,32H,00H,0E5H,0CDH,0DCH,2DH,0D1H,21H,00H,00H,0E5H,21H ; 2FB3: s#r!2....-.!...!
                DB      16H,00H,0E5H,0CDH,0D3H,2DH,0D1H,0D1H,2AH,15H,01H,11H,0AH,00H,19H,0E5H ; 2FC3: .....-..*.......
                DB      0CDH,0D9H,2DH,0D1H,0CDH,0DFH,2DH,0EBH,21H,02H,00H,39H,0F9H,0EBH,0C1H,0C9H ; 2FD3: ..-...-.!..9....
                DB      20H,00H,0C3H,0F1H,2FH,0C3H,0DFH,2BH,0C3H,08H,31H,0C3H,37H,09H,0C5H,21H ; 2FE3:  .../..+..1.7..!
                DB      10H,00H,0E5H,21H,00H,00H,0E5H,0CDH,0E8H,2FH,0D1H,0D1H,0CDH,5CH,01H,2DH ; 2FF3: ...!...../...\.-
                DB      0E5H,21H,26H,30H,0E5H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,0EBH,2FH ; 3003: .!&0.*........./
                DB      0D1H,0D1H,0D1H,2AH,15H,01H,11H,0F3H,05H,19H,0E5H,0CDH,0EEH,2FH,0D1H,0C1H ; 3013: ...*........./..
                DB      0C9H,0C1H,0C9H,25H,64H,20H,20H,00H,0C3H,34H,30H,0C3H,0DFH,2BH,0C3H,0B1H ; 3023: ...%d  ..40..+..
                DB      08H,0C5H,21H,00H,00H,0E5H,21H,17H,00H,0E5H,0CDH,2EH,30H,0D1H,0D1H,0CDH ; 3033: ..!...!.....0...
                DB      31H,30H,0C1H,0C9H,0C5H,21H,00H,00H,39H,0F9H,44H,4DH,21H,04H,00H,09H ; 3043: 10...!..9.DM!...
                DB      6EH,26H,00H,11H,30H,00H,0CDH,0F9H,01H,0CDH,0AFH,01H,0DAH,72H,30H,21H ; 3053: n&..0........r0!
                DB      04H,00H,09H,6EH,26H,00H,11H,39H,00H,0CDH,04H,02H,0CDH,0AFH,01H,0C1H ; 3063: ...n&..9........
                DB      0C9H,0C1H,0C9H,0C3H,7CH,30H,0C3H,27H,31H,0C5H,21H,0FEH,0FFH,39H,0F9H,44H ; 3073: ....|0.'1.!..9.D
                DB      4DH,21H,08H,00H,09H,0E5H,0CDH,79H,30H,0D1H,0EBH,60H,69H,73H,23H,72H ; 3083: M!.....y0..`is#r
                DB      21H,08H,80H,0CDH,0E5H,01H,0CAH,0B7H,30H,21H,06H,00H,09H,5EH,23H,56H ; 3093: !.......0!...^#V
                DB      13H,13H,72H,2BH,73H,1BH,1BH,0D5H,0CDH,90H,01H,00H,0EBH,0E1H,73H,23H ; 30A3: ..r+s.........s#
                DB      72H,0C3H,84H,30H,0EBH,21H,02H,00H,39H,0F9H,0EBH,0C1H,0C9H,0C5H,21H,0FEH ; 30B3: r..0.!..9.....!.
                DB      0FFH,39H,0F9H,44H,4DH,0CDH,90H,01H,06H,0EBH,60H,69H,73H,23H,72H,21H ; 30C3: .9.DM.....`is#r!
                DB      06H,00H,09H,5EH,23H,56H,13H,72H,2BH,73H,1BH,0D5H,21H,08H,00H,09H ; 30D3: ...^#V.r+s..!...
                DB      5EH,23H,56H,13H,72H,2BH,73H,1BH,0EBH,6EH,0EBH,0E1H,73H,7BH,0B7H,0CAH ; 30E3: ^#V.r+s..n..s{..
                DB      0F8H,30H,0C3H,0D2H,30H,0CDH,90H,01H,00H,0C3H,0FFH,30H,0EBH,21H,02H,00H ; 30F3: .0..0......0.!..
                DB      39H,0F9H,0EBH,0C1H,0C9H,0C3H,0EH,31H,0C3H,91H,31H,0C5H,21H,00H,00H,39H ; 3103: 9......1..1.!..9
                DB      0F9H,44H,4DH,21H,06H,00H,09H,0E5H,0CDH,90H,01H,04H,0E5H,0CDH,0BH,31H ; 3113: .DM!...........1
                DB      0D1H,0D1H,0C1H,0C9H,0C3H,2DH,31H,0C3H,00H,35H,0C5H,21H,0FEH,0FFH,39H,0F9H ; 3123: .....-1..5.!..9.
                DB      44H,4DH,0CDH,90H,01H,06H,7EH,23H,66H,6FH,6EH,7DH,0B7H,0C2H,49H,31H ; 3133: DM....~#fon}..I1
                DB      21H,08H,80H,0C3H,88H,31H,0CDH,90H,01H,06H,7EH,23H,66H,6FH,0E5H,0CDH ; 3143: !....1....~#fo..
                DB      2AH,31H,0D1H,0EBH,60H,69H,73H,23H,72H,0CDH,90H,01H,06H,7EH,23H,66H ; 3153: *1..`is#r....~#f
                DB      6FH,6EH,7DH,0B7H,0CAH,81H,31H,0CDH,90H,01H,06H,5EH,23H,56H,13H,72H ; 3163: on}...1....^#V.r
                DB      2BH,73H,1BH,0EBH,6EH,7DH,0FEH,2CH,0CAH,81H,31H,0C3H,5CH,31H,0CDH,90H ; 3173: +s..n}.,..1.\1..
                DB      01H,00H,0C3H,88H,31H,0EBH,21H,02H,00H,39H,0F9H,0EBH,0C1H,0C9H,0C3H,0A0H ; 3183: ....1.!..9......
                DB      31H,0C3H,0C0H,35H,0C3H,47H,30H,0C3H,6AH,36H,0C3H,0CDH,36H,0C5H,21H,68H ; 3193: 1..5.G0.j6..6.!h
                DB      0FFH,39H,0F9H,44H,4DH,21H,9EH,00H,09H,5EH,23H,56H,13H,13H,72H,2BH ; 31A3: .9.DM!...^#V..r+
                DB      73H,1BH,1BH,0EBH,7EH,23H,66H,6FH,0EBH,21H,04H,00H,09H,73H,23H,72H ; 31B3: s...~#fo.!...s#r
                DB      0CDH,90H,01H,9EH,0EBH,21H,96H,00H,09H,73H,23H,72H,21H,04H,00H,09H ; 31C3: .....!...s#r!...
                DB      5EH,23H,56H,13H,72H,2BH,73H,1BH,0EBH,6EH,0EBH,60H,69H,73H,7BH,0B7H ; 31D3: ^#V.r+s..n.`is{.
                DB      0CAH,0F1H,34H,60H,69H,6EH,7DH,0FEH,25H,0C2H,0DBH,34H,21H,06H,00H,09H ; 31E3: ..4`in}.%..4!...
                DB      0EBH,21H,8DH,00H,09H,73H,23H,72H,21H,94H,00H,09H,36H,06H,23H,36H ; 31F3: .!...s#r!...6.#6
                DB      00H,21H,91H,00H,09H,1EH,00H,73H,21H,8FH,00H,09H,73H,21H,90H,00H ; 3203: .!.....s!...s!..
                DB      09H,73H,0CDH,90H,01H,04H,6EH,7DH,0FEH,2DH,0C2H,30H,32H,21H,04H,00H ; 3213: .s....n}.-.02!..
                DB      09H,5EH,23H,56H,13H,72H,2BH,73H,21H,90H,00H,09H,34H,0CDH,90H,01H ; 3223: .^#V.r+s!...4...
                DB      04H,6EH,7DH,0FEH,30H,0C2H,40H,32H,21H,91H,00H,09H,34H,0CDH,90H,01H ; 3233: .n}.0.@2!...4...
                DB      04H,6EH,26H,00H,0E5H,0CDH,97H,31H,0D1H,7DH,0B7H,0CAH,5DH,32H,21H,04H ; 3243: .n&....1.}..]2!.
                DB      00H,09H,0E5H,0CDH,9AH,31H,0D1H,0C3H,60H,32H,21H,01H,00H,0EBH,21H,92H ; 3253: .....1..`2!...!.
                DB      00H,09H,73H,23H,72H,21H,04H,00H,09H,5EH,23H,56H,13H,72H,2BH,73H ; 3263: ..s#r!...^#V.r+s
                DB      1BH,0EBH,6EH,0EBH,60H,69H,73H,7BH,0FEH,2EH,0C2H,0A8H,32H,21H,04H,00H ; 3273: ..n.`is{....2!..
                DB      09H,0E5H,0CDH,9AH,31H,0D1H,0EBH,21H,94H,00H,09H,73H,23H,72H,21H,8FH ; 3283: ....1..!...s#r!.
                DB      00H,09H,34H,21H,04H,00H,09H,5EH,23H,56H,13H,72H,2BH,73H,1BH,0EBH ; 3293: ..4!...^#V.r+s..
                DB      6EH,0EBH,60H,69H,73H,60H,69H,6EH,26H,00H,0E5H,0CDH,9DH,31H,0D1H,7DH ; 32A3: n.`is`in&....1.}
                DB      0FEH,44H,0CAH,0D4H,32H,0FEH,55H,0CAH,10H,33H,0FEH,58H,0CAH,19H,33H,0FEH ; 32B3: .D..2.U..3.X..3.
                DB      4FH,0CAH,22H,33H,0FEH,43H,0CAH,68H,33H,0FEH,53H,0CAH,99H,33H,0C3H,0C5H ; 32C3: O."3.C.h3.S..3..
                DB      34H,0CDH,90H,01H,96H,7EH,23H,66H,6FH,7CH,0B7H,0F2H,10H,33H,21H,8DH ; 32D3: 4....~#fo|...3!.
                DB      00H,09H,5EH,23H,56H,13H,72H,2BH,73H,1BH,0EBH,36H,2DH,0CDH,90H,01H ; 32E3: ..^#V.r+s..6-...
                DB      96H,0E5H,0CDH,90H,01H,96H,7EH,23H,66H,6FH,0CDH,0FAH,02H,0EBH,0E1H,73H ; 32F3: ......~#fo.....s
                DB      23H,72H,21H,92H,00H,09H,5EH,23H,56H,1BH,72H,2BH,73H,21H,01H,00H ; 3303: #r!...^#V.r+s!..
                DB      09H,36H,0AH,0C3H,28H,33H,21H,01H,00H,09H,36H,10H,0C3H,28H,33H,21H ; 3313: .6..(3!...6..(3!
                DB      01H,00H,09H,36H,08H,21H,92H,00H,09H,0E5H,7EH,23H,66H,6FH,0E5H,21H ; 3323: ...6.!....~#fo.!
                DB      01H,00H,09H,6EH,26H,00H,0E5H,21H,96H,00H,09H,5EH,23H,56H,13H,13H ; 3333: ...n&..!...^#V..
                DB      72H,2BH,73H,1BH,1BH,0EBH,7EH,23H,66H,6FH,0E5H,21H,8DH,00H,09H,0E5H ; 3343: r+s...~#fo.!....
                DB      0CDH,94H,31H,0D1H,0D1H,0D1H,0D1H,0AFH,67H,0CDH,0FAH,02H,19H,0EBH,0E1H,73H ; 3353: ..1.....g......s
                DB      23H,72H,0C3H,11H,34H,21H,8DH,00H,09H,5EH,23H,56H,13H,72H,2BH,73H ; 3363: #r..4!...^#V.r+s
                DB      1BH,0D5H,21H,96H,00H,09H,5EH,23H,56H,13H,13H,72H,2BH,73H,1BH,1BH ; 3373: ..!...^#V..r+s..
                DB      0EBH,7EH,23H,66H,6FH,0EBH,0E1H,73H,21H,92H,00H,09H,5EH,23H,56H,1BH ; 3383: .~#fo..s!...^#V.
                DB      72H,2BH,73H,0C3H,11H,34H,21H,8FH,00H,09H,6EH,7DH,0B7H,0C2H,0ACH,33H ; 3393: r+s..4!...n}...3
                DB      21H,94H,00H,09H,36H,0C8H,23H,36H,00H,21H,96H,00H,09H,5EH,23H,56H ; 33A3: !...6.#6.!...^#V
                DB      13H,13H,72H,2BH,73H,1BH,1BH,0EBH,7EH,23H,66H,6FH,0EBH,21H,02H,00H ; 33B3: ..r+s...~#fo.!..
                DB      09H,73H,23H,72H,0CDH,90H,01H,02H,6EH,7DH,0B7H,0CAH,11H,34H,0CDH,90H ; 33C3: .s#r....n}...4..
                DB      01H,94H,7CH,0B5H,0CAH,11H,34H,21H,8DH,00H,09H,5EH,23H,56H,13H,72H ; 33D3: ..|...4!...^#V.r
                DB      2BH,73H,1BH,0D5H,21H,02H,00H,09H,5EH,23H,56H,13H,72H,2BH,73H,1BH ; 33E3: +s..!...^#V.r+s.
                DB      0EBH,6EH,0EBH,0E1H,73H,21H,94H,00H,09H,5EH,23H,56H,1BH,72H,2BH,73H ; 33F3: .n..s!...^#V.r+s
                DB      21H,92H,00H,09H,5EH,23H,56H,1BH,72H,2BH,73H,0C3H,0C7H,33H,0CDH,90H ; 3403: !...^#V.r+s..3..
                DB      01H,8DH,36H,00H,21H,06H,00H,09H,0EBH,21H,8DH,00H,09H,73H,23H,72H ; 3413: ..6.!....!...s#r
                DB      21H,90H,00H,09H,6EH,7DH,0B7H,0C2H,68H,34H,21H,92H,00H,09H,5EH,23H ; 3423: !...n}..h4!...^#
                DB      56H,1BH,72H,2BH,73H,13H,21H,00H,00H,0CDH,05H,02H,0D2H,68H,34H,21H ; 3433: V.r+s.!......h4!
                DB      9CH,00H,09H,5EH,23H,56H,13H,72H,2BH,73H,1BH,0D5H,21H,91H,00H,09H ; 3443: ...^#V.r+s..!...
                DB      6EH,7DH,0B7H,0CAH,5FH,34H,21H,30H,00H,0C3H,62H,34H,21H,20H,00H,0EBH ; 3453: n}.._4!0..b4! ..
                DB      0E1H,73H,0C3H,2DH,34H,0CDH,90H,01H,9CH,0E5H,21H,8DH,00H,09H,5EH,23H ; 3463: .s.-4.....!...^#
                DB      56H,13H,72H,2BH,73H,1BH,0EBH,6EH,0EBH,0E1H,73H,7BH,0B7H,0CAH,91H,34H ; 3473: V.r+s..n..s{...4
                DB      21H,9CH,00H,09H,5EH,23H,56H,13H,72H,2BH,73H,0C3H,68H,34H,21H,90H ; 3483: !...^#V.r+s.h4!.
                DB      00H,09H,6EH,7DH,0B7H,0CAH,0C2H,34H,21H,92H,00H,09H,5EH,23H,56H,1BH ; 3493: ..n}...4!...^#V.
                DB      72H,2BH,73H,13H,21H,00H,00H,0CDH,05H,02H,0D2H,0C2H,34H,21H,9CH,00H ; 34A3: r+s.!.......4!..
                DB      09H,5EH,23H,56H,13H,72H,2BH,73H,1BH,0EBH,36H,20H,0C3H,9BH,34H,0C3H ; 34B3: .^#V.r+s..6 ..4.
                DB      0D8H,34H,21H,9CH,00H,09H,5EH,23H,56H,13H,72H,2BH,73H,1BH,0D5H,60H ; 34C3: .4!...^#V.r+s..`
                DB      69H,6EH,0EBH,0E1H,73H,0C3H,0EEH,34H,21H,9CH,00H,09H,5EH,23H,56H,13H ; 34D3: in..s..4!...^#V.
                DB      72H,2BH,73H,1BH,0D5H,60H,69H,6EH,0EBH,0E1H,73H,0C3H,0CFH,31H,0CDH,90H ; 34E3: r+s..`in..s..1..
                DB      01H,9CH,36H,00H,0EBH,21H,98H,00H,39H,0F9H,0EBH,0C1H,0C9H,0C3H,06H,35H ; 34F3: ..6..!..9......5
                DB      0C3H,47H,30H,0C5H,21H,0FBH,0FFH,39H,0F9H,44H,4DH,60H,69H,0AFH,77H,23H ; 3503: .G0.!..9.DM`i.w#
                DB      77H,21H,03H,00H,09H,36H,01H,23H,36H,00H,0CDH,90H,01H,09H,6EH,0EBH ; 3513: w!...6.#6.....n.
                DB      21H,02H,00H,09H,73H,7BH,0FEH,09H,0CAH,39H,35H,21H,02H,00H,09H,6EH ; 3523: !...s{...95!...n
                DB      7DH,0FEH,20H,0C2H,47H,35H,21H,09H,00H,09H,5EH,23H,56H,13H,72H,2BH ; 3533: }. .G5!...^#V.r+
                DB      73H,0C3H,1DH,35H,21H,02H,00H,09H,6EH,7DH,0FEH,2DH,0C2H,66H,35H,21H ; 3543: s..5!...n}.-.f5!
                DB      03H,00H,09H,36H,0FFH,23H,36H,0FFH,21H,09H,00H,09H,5EH,23H,56H,13H ; 3553: ...6.#6.!...^#V.
                DB      72H,2BH,73H,21H,09H,00H,09H,5EH,23H,56H,13H,72H,2BH,73H,1BH,0EBH ; 3563: r+s!...^#V.r+s..
                DB      6EH,0EBH,21H,02H,00H,09H,73H,16H,00H,0D5H,0CDH,03H,35H,0D1H,7CH,0B5H ; 3573: n.!...s.....5.|.
                DB      0CAH,0A7H,35H,0CDH,90H,01H,00H,11H,0AH,00H,0CDH,3FH,02H,0E5H,21H,02H ; 3583: ..5........?..!.
                DB      00H,09H,6EH,0D1H,0AFH,67H,19H,11H,0D0H,0FFH,19H,0EBH,60H,69H,73H,23H ; 3593: ..n..g......`is#
                DB      72H,0C3H,66H,35H,0CDH,90H,01H,03H,0E5H,0CDH,90H,01H,00H,0D1H,0CDH,3FH ; 35A3: r.f5...........?
                DB      02H,0C3H,0B7H,35H,0EBH,21H,05H,00H,39H,0F9H,0EBH,0C1H,0C9H,0C3H,0C6H,35H ; 35B3: ...5.!..9......5
                DB      0C3H,0C0H,35H,0C5H,21H,0FFH,0FFH,39H,0F9H,44H,4DH,0CDH,90H,01H,07H,0E5H ; 35C3: ..5.!..9.DM.....
                DB      0CDH,90H,01H,09H,0D1H,0CDH,0ECH,01H,0D2H,16H,36H,0CDH,90H,01H,05H,5EH ; 35D3: ..........6....^
                DB      23H,56H,13H,72H,2BH,73H,1BH,0D5H,0CDH,90H,01H,07H,11H,0AH,00H,0CDH ; 35E3: #V.r+s..........
                DB      0EBH,01H,0D2H,03H,36H,0CDH,90H,01H,07H,11H,30H,00H,19H,0C3H,0BH,36H ; 35F3: ....6.....0....6
                DB      0CDH,90H,01H,07H,11H,37H,00H,19H,0EBH,0E1H,73H,21H,01H,00H,26H,00H ; 3603: .....7....s!..&.
                DB      0C3H,61H,36H,0CDH,90H,01H,09H,0E5H,0CDH,90H,01H,07H,0E5H,0CDH,90H,01H ; 3613: .a6.............
                DB      09H,0D1H,0CDH,89H,02H,0E5H,0CDH,90H,01H,05H,0E5H,0CDH,0C3H,35H,0D1H,0D1H ; 3623: .............5..
                DB      0D1H,0EBH,60H,69H,73H,0CDH,90H,01H,09H,0E5H,0CDH,90H,01H,07H,0E5H,0CDH ; 3633: ..`is...........
                DB      90H,01H,09H,0D1H,0CDH,29H,02H,0E5H,0CDH,90H,01H,05H,0E5H,0CDH,0C3H,35H ; 3643: .....).........5
                DB      0D1H,0D1H,0D1H,60H,69H,6EH,26H,00H,23H,26H,00H,0C3H,61H,36H,0EBH,21H ; 3653: ...`in&.#&..a6.!
                DB      01H,00H,39H,0F9H,0EBH,0C1H,0C9H,0C3H,70H,36H,0C3H,47H,30H,0C5H,21H,0FEH ; 3663: ..9.....p6.G0.!.
                DB      0FFH,39H,0F9H,44H,4DH,60H,69H,0AFH,77H,23H,77H,0CDH,90H,01H,06H,7EH ; 3673: .9.DM`i.w#w....~
                DB      23H,66H,6FH,6EH,26H,00H,0E5H,0CDH,6DH,36H,0D1H,7DH,0B7H,0CAH,0BDH,36H ; 3683: #fon&...m6.}...6
                DB      0CDH,90H,01H,00H,11H,0AH,00H,0CDH,3FH,02H,0E5H,0CDH,90H,01H,06H,5EH ; 3693: ........?......^
                DB      23H,56H,13H,72H,2BH,73H,1BH,0EBH,6EH,0D1H,0AFH,67H,19H,11H,0D0H,0FFH ; 36A3: #V.r+s..n..g....
                DB      19H,0EBH,60H,69H,73H,23H,72H,0C3H,7EH,36H,0CDH,90H,01H,00H,0C3H,0C4H ; 36B3: ..`is#r.~6......
                DB      36H,0EBH,21H,02H,00H,39H,0F9H,0EBH,0C1H,0C9H,0C3H,0D3H,36H,0C3H,05H,37H ; 36C3: 6.!..9......6..7
                DB      0C5H,21H,00H,00H,39H,0F9H,44H,4DH,21H,04H,00H,09H,6EH,26H,00H,0E5H ; 36D3: .!..9.DM!...n&..
                DB      0CDH,0D0H,36H,0D1H,7CH,0B5H,0CAH,0FAH,36H,21H,04H,00H,09H,6EH,26H,00H ; 36E3: ..6.|...6!...n&.
                DB      11H,0E0H,0FFH,19H,0C3H,0FFH,36H,21H,04H,00H,09H,6EH,26H,00H,0C1H,0C9H ; 36F3: ......6!...n&...
                DB      0C1H,0C9H,0C5H,21H,00H,00H,39H,0F9H,44H,4DH,21H,04H,00H,09H,6EH,26H ; 3703: ...!..9.DM!...n&
                DB      00H,11H,61H,00H,0CDH,0F9H,01H,0CDH,0AFH,01H,0DAH,30H,37H,21H,04H,00H ; 3713: ..a........07!..
                DB      09H,6EH,26H,00H,11H,7AH,00H,0CDH,04H,02H,0CDH,0AFH,01H,0C1H,0C9H,0C1H ; 3723: .n&..z..........
                DB      0C9H,0C3H,20H,01H,0CDH,0AH,03H,7CH,0B5H,0CAH,46H,37H,22H,97H,05H,22H ; 3733: .. ....|..F7".."
                DB      99H,05H,0C9H,11H,7CH,37H,0C5H,0EH,09H,0CDH,05H,00H,21H,0BDH,0BDH,0E5H ; 3743: ....|7......!...
                DB      0EH,0BH,0CDH,05H,00H,0E1H,23H,23H,23H,0E6H,01H,0CAH,52H,37H,22H,97H ; 3753: ......###...R7".
                DB      05H,22H,99H,05H,0EH,02H,1EH,0DH,0CDH,05H,00H,0EH,02H,1EH,0AH,0CDH ; 3763: ."..............
                DB      05H,00H,0EH,01H,0CDH,05H,00H,0C1H,0C9H,57H,61H,69H,74H,20H,61H,20H ; 3773: .........Wait a 
                DB      66H,65H,77H,20H,73H,65H,63H,6FH,6EH,64H,73H,2CH,20H,61H,6EH,64H ; 3783: few seconds, and
                DB      20H,74H,79H,70H,65H,20H,61H,20H,43H,52H,3AH,20H,24H,2AH,97H,05H ; 3793:  type a CR: $*..
                DB      0EBH,3EH,48H,0A3H,0CAH,0AEH,37H,0EAH,0AEH,37H,37H,2AH,99H,05H,7CH,17H ; 37A3: .>H...7..77*..|.
                DB      67H,7DH,17H,6FH,22H,99H,05H,7AH,17H,67H,7BH,17H,6FH,22H,97H,05H ; 37B3: g}.o"..z.g{.o"..
                DB      7CH,0E6H,7FH,67H,0C9H,0CDH,0AH,03H,0C5H,23H,2BH,7CH,0B5H,0C2H,0D5H,37H ; 37C3: |..g.....#+|...7
                DB      0C1H,0C9H,11H,10H,27H,1BH,7AH,0B3H,0C2H,0D8H,37H,0E5H,0EH,0BH,0CDH,05H ; 37D3: ....'.z...7.....
                DB      00H,0E6H,01H,0E1H,0CAH,0CDH,37H,0E5H,0EH,01H,0CDH,05H,00H,0FEH,03H,0CAH ; 37E3: ......7.........
                DB      00H,00H,0E1H,0C3H,0CDH,37H,0CDH,37H,03H,0C5H,2AH,01H,00H,2BH,2BH,2BH ; 37F3: .....7.7..*..+++
                DB      3AH,9FH,05H,47H,87H,80H,5FH,16H,00H,19H,0E5H,2AH,0A1H,05H,44H,4DH ; 3803: :..G.._....*..DM
                DB      21H,18H,38H,0E3H,0E9H,6FH,26H,00H,0C1H,0C9H,1BH,3DH,0FFH,0FEH,00H,00H ; 3813: !.8..o&....=....
                DB      00H,00H,00H,00H,00H,79H,35H,00H,00H,00H,00H,00H,00H,00H,00H,78H ; 3823: .....y5........x
                DB      35H,00H,00H,00H,00H,00H,00H,00H,1AH,00H,00H,00H,00H,00H,00H,00H ; 3833: 5...............
                DB      00H,00H,20H,20H,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH ; 3843: ..  ............
                DB      1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH ; 3853: ................
                DB      1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH ; 3863: ................
                DB      1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,1AH,00H,3CH,42H,4FH ; 3873: .............<BO
                DB      4FH,4DH,21H,3EH,20H,07H,00H,20H,20H,20H,20H,20H,20H,20H,20H,00H ; 3883: OM!> ..        .
                DB      20H,00H,20H,00H,20H,00H,0C3H,9AH,1BH,0C3H,0DFH,2BH,0C3H,3DH,2CH,0C5H ; 3893:  . . ......+.=,.
                DB      0CDH,4DH,01H,37H,07H,7CH,0B5H,0C2H,0A7H,1BH,0C1H,0C9H,2AH,15H,01H,11H ; 38A3: .M.7.|......*...
                DB      35H,07H,19H,0E5H,7EH,23H,66H,6FH,0E5H,0CDH,4DH,01H,37H,07H,0D1H,19H ; 38B3: 5...~#fo..M.7...
                DB      0EBH,0E1H,73H,23H,72H,0CDH,4DH,01H,35H,07H,11H,01H,00H,0CDH,0F9H,01H ; 38C3: ..s#r.M.5.......
                DB      0D2H,0E8H,1BH,2AH,15H,01H,11H,35H,07H,19H,36H,01H,23H,36H,00H,2AH ; 38D3: ...*...5..6.#6.*
                DB      15H,01H,11H,37H,07H,19H,0AFH,77H,23H,77H,0C3H,0DH,1CH,0CDH,4DH,01H ; 38E3: ...7...w#w....M.
                DB      35H,07H,11H,48H,00H,0CDH,04H,02H,0D2H,0DH,1CH,2AH,15H           ; 38F3: 5..H.......*.

ORIGINAL_KAYPRO_IMAGE_END:
; File 3800H / runtime 3900H

; Padding places the first sound routine at runtime 4100H.
SOUND_PADDING:
                DEFS    0800H,00H

;------------------------------------------------------------------------------
; MC1408 sound routines
;------------------------------------------------------------------------------

SND_ALIEN_MOVE:
                DB      0F5H                            ; PUSH AF -- Preserve caller registers
                DB      0C5H                            ; PUSH BC
                DB      0D5H                            ; PUSH DE
                DB      3AH,2DH,41H                     ; LD A,(MOVE_PHASE) -- Load cadence phase
                DB      3CH                             ; INC A
                DB      0E6H,03H                        ; AND 03H -- Four movement tones
                DB      32H,2DH,41H                     ; LD (MOVE_PHASE),A
                DB      5FH                             ; LD E,A
                DB      16H,00H                         ; LD D,00H
                DB      21H,2EH,41H                     ; LD HL,MOVE_DELAYS
                DB      19H                             ; ADD HL,DE
                DB      5EH                             ; LD E,(HL) -- Selected delay
                DB      06H,08H                         ; LD B,08H -- Eight half-cycles
                DB      3EH,64H                         ; LD A,64H

MOVE_WAVE:
                DB      0D3H,50H                        ; OUT (DAC_PORT),A
                DB      4BH                             ; LD C,E

MOVE_DELAY:
                DB      0DH                             ; DEC C
                DB      20H,0FDH                        ; JR NZ,MOVE_DELAY
                DB      0EEH,0FEH                       ; XOR FEH -- Toggle 64H/9AH
                DB      10H,0F6H                        ; DJNZ MOVE_WAVE
                DB      3EH,80H                         ; LD A,80H
                DB      0D3H,50H                        ; OUT (DAC_PORT),A -- DAC midpoint
                DB      0D1H                            ; POP DE
                DB      0C1H                            ; POP BC
                DB      0F1H                            ; POP AF
                DB      2AH,15H,01H                     ; LD HL,(0115H) -- Replaced instruction
                DB      0C9H                            ; RET

MOVE_PHASE:
                DB      0FFH                            ; DB FFH -- Initial phase

MOVE_DELAYS:
                DB      48H,58H,68H,78H                 ; DB 48H,58H,68H,78H

SND_FIRE:
                DB      0F5H                            ; PUSH AF -- Preserve caller registers
                DB      0C5H                            ; PUSH BC
                DB      0D5H                            ; PUSH DE
                DB      06H,50H                         ; LD B,50H
                DB      1EH,30H                         ; LD E,30H
                DB      3EH,40H                         ; LD A,40H

FIRE_WAVE:
                DB      0D3H,50H                        ; OUT (DAC_PORT),A
                DB      4BH                             ; LD C,E

FIRE_DELAY:
                DB      0DH                             ; DEC C
                DB      20H,0FDH                        ; JR NZ,FIRE_DELAY
                DB      0EEH,80H                        ; XOR 80H -- Toggle 40H/C0H
                DB      1CH                             ; INC E -- Descending chirp
                DB      10H,0F5H                        ; DJNZ FIRE_WAVE
                DB      3EH,80H                         ; LD A,80H
                DB      0D3H,50H                        ; OUT (DAC_PORT),A -- DAC midpoint
                DB      0D1H                            ; POP DE
                DB      0C1H                            ; POP BC
                DB      0F1H                            ; POP AF
                DB      2AH,15H,01H                     ; LD HL,(0115H) -- Replaced instruction
                DB      0C9H                            ; RET

SND_PLAYER_HIT:
                DB      0F5H                            ; PUSH AF -- Short turret-hit explosion
                DB      0C5H                            ; PUSH BC
                DB      0D5H                            ; PUSH DE
                DB      06H,60H                         ; LD B,60H -- 96 noise samples
                DB      16H,0A5H                        ; LD D,A5H -- Noise seed
                DB      1EH,30H                         ; LD E,30H -- Initial sample delay

HIT_NOISE:
                DB      7AH                             ; LD A,D
                DB      0FH                             ; RRCA
                DB      30H,02H                         ; JR NC,HIT_NO_TAP
                DB      0EEH,0B8H                       ; XOR B8H -- Feedback tap

HIT_NO_TAP:
                DB      57H                             ; LD D,A
                DB      0EEH,80H                        ; XOR 80H -- Centre waveform
                DB      0D3H,50H                        ; OUT (DAC_PORT),A
                DB      4BH                             ; LD C,E

HIT_DELAY:
                DB      0DH                             ; DEC C
                DB      20H,0FDH                        ; JR NZ,HIT_DELAY
                DB      1CH                             ; INC E -- Rough descending tail
                DB      10H,0EEH                        ; DJNZ HIT_NOISE
                DB      3EH,80H                         ; LD A,80H
                DB      0D3H,50H                        ; OUT (DAC_PORT),A -- DAC midpoint
                DB      0D1H                            ; POP DE
                DB      0C1H                            ; POP BC
                DB      0F1H                            ; POP AF
                DB      21H,77H,1BH                     ; LD HL,1B77H -- Replaced BOOM pointer
                DB      0C9H                            ; RET

PROGRAM_END:
; PROGRAM_END - 0100H = 4077H bytes
                END     0100H
