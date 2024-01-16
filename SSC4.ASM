CODE    segment
        assume  cs:CODE,ds:CODE
        org     100h
START:

AskConst equ    0A05Eh
AnsConst equ    03D15h

old88o  equ     100h
old88s  equ     102h

        jmp     INSTALL
        org     104h
Program dw      7
Version dw      100h


Search  proc    near
        cli
        cld
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
        push    es

        in      al,60h

        cmp     al,58h
        jz      Switch
        cmp     al,57h
        jnz     NotS
        mov     ax,0E6CDh
        mov     dx,04289h
        jmp     short Switch1
Switch:
        mov     ax,0CDE6h
        mov     dx,08942h

Switch1:
        xchg    ah,dl
        mov     bx,1000h
m1:
        mov     cx,0FFF0h
        mov     es,bx
        xor     di,di
m2:
        repnz   scasb
        jcxz    m3
        cmp     byte ptr es:[di],ah
        jnz     m2
        mov     word ptr es:[di-1],dx
        jmp     short m2
m3:
        add     bx,1000h
        cmp     bx,0A000h
        jne     m1
NotS:
        pop     es
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        jmp     dword ptr cs:100h
Search  endp

Int89:
        push    dx
        mov     dx,5FE0h
        out     dx,al
        mov     dl,0E2h
        out     dx,al
        pop     dx
        iret

ShortVar:

int10:
        pushf
        cmp     ax,AskConst
        jnz     NOT_CHECKING
        cmp     cx,ax
        jnz     NOT_CHECKING
        cmp     bx,ax
        jnz     NOT_CHECKING
        mov     ax,AnsConst
        mov     bx,ax
        mov     cx,ax
        popf
        iret
NOT_CHECKING:
        popf
        call    ReplaceI9
        db      0EAh
old10o  dw      0
old10s  dw      0


int88:
        iret

int9_0:
        int     88h
        pushf
        push    cs
        call    Search
        db      0EAh
old9o_0 dw      0
old9s_0 dw      0

int9_1:
        int     88h
        pushf
        push    cs
        call    Search
        db      0EAh
old9o_1 dw      0
old9s_1 dw      0


Int13:
        call    ReplaceI9
        db      0EAh
old13o  dw      0
old13s  dw      0

ReplaceI9:
        pushf
        push    ax
        push    bx
        push    cx
        push    es
        push    ds

        push    cs
        pop     ds

        xor     ax,ax
        mov     es,ax

        mov     bx,word ptr es:[9*4]
        mov     cx,word ptr es:[9*4+2]

        mov     ax,cs
        cmp     ax,cx

        jnz     SetNew9_
        cmp     bx,offset Int9_0
        jnz     SetNew9

GoodBye_:
        pop     ds
        pop     es
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

SetNew9:
        cmp     bx,offset Int9_1
        jz      GoodBye_
SetNew9_:
        mov     word ptr ds:old9o_1,bx
        mov     word ptr ds:old9s_1,cx

        mov     word ptr es:[9*4],offset Int9_1
        mov     word ptr es:[9*4+2],ds

        jmp     short GoodBye_

Install:
        push    cs
        pop     ds
        mov     dx,offset Mess
        mov     ah,9
        int     21h
        mov     es,word ptr cs:[2Ch]
        mov     ah,49h
        int     21h

        mov     ax,AskConst
        mov     bx,ax
        mov     cx,ax
        int     10h
        xor     di,di
        mov     ds,di
        push    cs
        pop     es
        cld
        cli
        mov     di,old88o

        cmp     ax,AnsConst
        jnz     InstWhole
        cmp     ax,bx
        jnz     InstWhole
        cmp     ax,cx
        jnz     InstWhole

        mov     si,88h*4
        movsw
        movsw
        mov     word ptr ds:[89h*4],offset int89
        mov     word ptr ds:[89h*4+2],cs
        mov     word ptr ds:[88h*4],offset Search
        mov     word ptr ds:[88h*4+2],cs
        mov     dx,offset ShortVar
        jmp     Resident

InstWhole:
        xor     ax,ax
        stosw
        stosw
        mov     si,9*4
        mov     di,offset old9o_0
        movsw
        movsw
        mov     si,10h*4
        mov     di,offset old10o
        movsw
        movsw
        mov     si,13h*4
        mov     di,offset old13o
        movsw
        movsw
        mov     word ptr ds:[9*4],offset int9_0
        mov     word ptr ds:[9*4+2],cs
        mov     word ptr ds:[10h*4],offset int10
        mov     word ptr ds:[10h*4+2],cs
        mov     word ptr ds:[13h*4],offset int13
        mov     word ptr ds:[13h*4+2],cs
        mov     word ptr ds:[89h*4],offset int89
        mov     word ptr ds:[89h*4+2],cs
        mov     word ptr ds:[88h*4],offset int88
        mov     word ptr ds:[88h*4+2],cs
        mov     word ptr cs:old88o,offset int88
        mov     word ptr cs:old88s,cs

        mov     dx,offset Install

Resident:
        sti
        int     27h
Mess:
 db  '------------------------------------------[ RSsoftware ]----',10,13
 db  'PC-Speaker Changer  v1.0  Copyright (C) 1993 by MasyutinMax~',10,13
 db  '------------------------------------------------------------',10,13,'$'
CODE    ends
        end     Start

