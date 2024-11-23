
;  Copyright 2023, David S. Madole <david@madole.net>
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>.


          ; Definition files

          #include include/bios.inc
          #include include/kernel.inc


          ; Unpublished kernel vector points

d_ideread:  equ   0447h
d_idewrite: equ   044ah


          ; Executable header block

            org   1ffah
            dw    start
            dw    end-start
            dw    start

start:      br    skipini

            db    11+80h                ; month
            db    23                    ; day
            dw    2024                  ; year
            dw    1                     ; build

            db    'See github/dmadole/MiniDOS-rename for more information',0


skipini:    lda   ra                    ; skip spaces, if end then error
            lbz   dousage
            sdi   ' '
            lbdf  skipini

            ghi   ra                    ; point rf to first pathname
            phi   rf
            glo   ra
            plo   rf

            dec   rf                    ; back up to first character

skipsrc:    lda   ra                    ; skip pathname, if none then error
            lbz   dousage
            sdi   ' '
            lbnf  skipsrc

            dec   ra                    ; zero terminate name
            ldi   0
            str   ra
            inc   ra

skipspc:    lda   ra                    ; skip spaces, if end then error
            lbz   dousage
            sdi   ' '
            lbdf  skipspc

            ghi   ra                    ; point rc to second paathname
            phi   rc
            glo   ra
            plo   rc

            dec   rc                    ; back up to first character

skipdst:    lda   ra                    ; skip pathname, if end then rename
            lbz   endargs
            sdi   ' '
            lbnf  skipdst

            dec   ra                    ; terminate at first space
            ldi   0
            str   ra

skipend:    lda   ra                    ; skip any trailing spaces
            lbz   endargs
            sdi   ' '
            lbdf  skipend

dousage:    sep   scall                 ; more than two arguments is error
            dw    o_inmsg
            db    'USAGE: rename source dest',13,10,0

            ldi   1                     ; return with failure
            sep   sret


          ; ------------------------------------------------------------------
          ; We now have all the arguments and options, proceed with rename.

endargs:    sep   scall                 ; rename the source to target
            dw    o_rename
            lbdf  failure

            ldi   0                     ; return with success
            sep   sret

failure:    sep   scall                 ; say that something went wrong
            dw    o_inmsg
            db    'ERROR: not found or name not valid',13,10,0

            ldi   1                     ; return with failure
            sep   sret

end:        end    start                ; end of the program

