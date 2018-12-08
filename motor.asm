org 100h
.stack
.data
    wtank db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
    choice db ? 
    count db 00
    count1 db 00 
    ipc db 00    
    ipc1 db 00
    max db 00
    maxc db 00
    ip db 00  
    ipwater db ?                                                   
    tapwater db 00 
    tapwatot db 00  
    t1 db 28
    t2 db 52 
    init db 00 
    res dw ?
    ;button dw ?  
    ;row dw ?
    ;col dw ?
display MACRO msg         ;macro
mov ah,9
lea dx,msg
int 21h

endm
;;;;;;;;;;;;;;;;;;;
.code
include 'emu8086.inc'     ;header files
define_scan_num
define_print_num
define_print_num_uns
;;;;;;;;;;;;;;;;;;;
mov ax,@data
mov ds,ax 

lea di,wtank  
dec di
;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;	
mov ah,2
mov dl,25             ;to display title
mov dh,0 
int 10h
mov ah,9
mov dx,offset mtit                                                                                                                    
int 21h 

mov ah,2
mov dl,4             ;to display tank title
mov dh,2 
int 10h
mov ah,9
mov dx,offset ttit                                                                                                                    
int 21h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;int 33h
;mov ax,00
;int 33h
;mov res,ax
;mov ax,01h
;int 33h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov ah,2
mov dl,45             ;tank capacity
mov dh,3 
int 10h
 
print 'Tank Capacity=' 
call scan_num
putc 0ah
putc 0dh

mov max,cl
mov maxc,cl

add cl,5
mov ip,cl
  
call DrawProc          ;to draw 

putc 0ah
putc 0dh

dec ip
jmp display
options:                ;option label
   
mov ah,2
mov dh,5               
mov dl,45
int 10h
mov cx,35  
clear:                  ;cleaning choice line
    mov ah,2
    mov dl,000
    int 21h
    loop clear     
    mov cx,16
mov dh,20 

mov ah,2                                                         
mov dh,6
mov dl,45
int 10h
mov cx,25  
clear2:                 ;cleaning next to choice line
    mov ah,2
    mov dl,000
    int 21h
    loop clear2     
    mov cx,16
mov dh,20 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display:    
mov ah,2
mov dl,45             ;to display choice
mov dh,5 
int 10h
 
print '1)FILLING 2)MOTOR 3)TAP=' 
call scan_num
putc 0ah
putc 0dh

mov choice,cl         ;comparing
cmp cl,1 
je fill
mov choice,cl
cmp cl,2
je motor
mov choice,cl
cmp cl,3
je tap 
call ExitProc
call exit1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill:                  ;filling

    mov dl,ipwater
    cmp dl,max
    je full 
    
    mov dl,ip
    cmp dl,4
    je full
    
    
    mov ah,2
    mov dl,45             ;filling input 
    mov dh,6 
    int 10h
    print 'How many Liters?='
    call scan_num
    putc 0ah
    putc 0dh  
    
    mov count,cl 
    cmp cl,max
    jg invalid
    cmp cl,0
    je invalid

pour:
    
    mov ah,2
    mov dh,ip
    mov dl,4                                               
    int 10h
    mov cx,16  
    
    bot:
        mov ah,2
        mov dl,219
        int 21h 
        loop bot     
    mov bx,0000h     ;stack operations
    push bx
    inc ipwater  
    dec count
    dec ip 
    mov dl,ip
    cmp dl,4
    je beep
    mov dl,count
    cmp dl,0
    je exit 
    jne pour 
;;;;;;;;;;;;;;;;;;;;;;;;
full:                       ;full label
    beep:                   ;overflow sound
        mov cx,5
    sound:
        mov dl,7
        mov ah,2
        int 21h
        loop sound
;;;;;;;;;;;;;;;;;;;;;;;;
call sub

mov ah,2
mov dl,45             ;to display overflow
mov dh,5 
int 10h 
display msg

mov ah,2
mov dl,62 
mov dh,16
int 10h
mov ah,2               ;timer set to 0
mov ah,0 

mov al,00
call print_num_uns
jmp exit  
;;;;;;;;;;;;;;;;;;;;;;;;;;
invalid:

call sub

mov ah,2
mov dl,45             ;to display invalid
mov dh,5 
int 10h 
print 'Invalid entry!!!'
jmp exit  
;;;;;;;;;;;;;;;;;;;;;;;;;;
motor:
    mov dl,max
    sub dl,ipwater
    mov maxc,dl
    mov dl,ipwater
    cmp dl,15
    je full 
    mov dl,ip
    cmp dl,4
    je full

pour1:
call delay
mov ah,2
mov dh,ip              ;motor
mov dl,4
int 10h
mov cx,16  

bot1:
    
    mov ah,2
    mov dl,219
    int 21h
    loop bot1     
    mov bx,0000h     ;stack operations
    push bx
inc ipwater
dec ip 
mov dl,ip
cmp dl,4
je full
jne pour1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
delay:
call timer
mov cx,2h
run:                    ;delay
dec cx
jnz run
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tap:
;;;;;;
;;;;
   
                        ;tap label
    mov dl,00
    mov tapwater,dl
    mov dl,ipwater
    cmp dl,0
    je empty
    mov dl,ip
    cmp dl,19
    je empty 

mov ah,2
mov dl,45             ;tap input
mov dh,6 
int 10h
print 'How many liters?='
call scan_num
putc 0ah
putc 0dh  

mov count1,cl 

cmp cl,15
jg invalid
cmp cl,0
je invalid

mov ah,2
 mov dh,16               ;print tap water initialize
 mov dl,40
 int 10h
 mov ah,2 
 mov ah,0
 call print_num_uns   
 
 mov ah,2
 mov dh,16               ;print tap water initialize
 mov dl,41
 int 10h
 mov ah,2 
 mov ah,0
 call print_num_uns
;;;;;;;;;;;;;;
pour2:
mov dl,ipwater
cmp dl,0
je empty1 

inc ip
                       ;decrement water
mov ah,2
mov dh,ip
mov dl,4
int 10h
mov cx,16  

bot2:
    mov ah,2
    mov dl,000
    int 21h
    loop bot2
    
    pop bx
    mov [di],bx
    inc di        ;stack operation

inc tapwater
inc tapwatot
call tapcap   
dec ipwater
dec count1
mov dl,tapwatot
cmp dl,0
je empty1
mov dl,count1
cmp dl,00
je exit 
jne pour2  
;;;;;;;;;;;;;;;;;;;;;; 
empty1: 

beep2:
mov cx,5
sound2:
mov dl,7                 ;empty 
mov ah,2
int 21h
loop sound2
;;;;;;;;;;;;;;;;;;;;;;
call sub
;;;;;;;;;;;;;;;;;;;;;;;;
mov ah,2
mov dl,45             ;to display empty mesg
mov dh,5 
int 10h 
print 'tank is empty!!!' 
jmp options
;;;;;;;;;;;;;;;;;;;;;;;;;;;     
empty:
     
beep1:
mov cx,5
sound1:
mov dl,7                 ;empty 
mov ah,2
int 21h
loop sound1
;;;;;;;;;;;;;;;;;;;;;;
call sub
;;;;;;;;;;;;;;;;;;;;;;;;
mov ah,2
mov dl,45             ;to display empty mesg
mov dh,5 
int 10h 
print 'tank is empty!!!' 

;;;;;;;;;;;;;;;;;;;;;;;
call sub 
mov ah,2
mov dl,45
mov dh,5
int 10h
print 'AutoMotor ON wait for-'
mov ah,2
mov ah,0
mov al,max
call print_num_uns
print '-minutes'
inc maxc
jmp motor
;;;;;;;;;;;;;;;;;;;;;; 
timer:
mov ah,2
mov dl,62 
mov dh,16
int 10h
mov ah,2               ;timer
mov ah,0 

mov al,maxc
call print_num_uns
dec maxc 
ret
;;;;;;;;;;;;;;;;;;
tapcap: 

mov cx,4                ;flow draw
mov dh,10

flow:

mov ah,2
mov dl,35    
inc dh
int 10h
mov ah,2
mov dl,248
int 21h
loop flow      
;;;;;;;;;;;;;;;;;;;;;
 mov ah,2
 mov dh,16               ;print tap water value
 mov dl,40
 int 10h
 mov ah,2 
 mov ah,0
 mov al,tapwater
 call print_num_uns
 
;;;;;;;;;;;;;;;;;;;; 
mov cx,4   
mov dh,10

flowstop:
mov ah,2
mov dl,35                 ;flow clear
inc dh
int 10h
mov ah,2
mov dl,000
int 21h
loop flowstop     
 ret

;;;;;;;;;;;;;;;;;;
ExitProc proc
    mov ah,2                        ;procedure exit details
    mov dh,8
    mov dl,45
    int 10h
    mov cx,35  

clearfinal:
    mov ah,2          ;clear 3 line
    mov dl,000
    int 21h
    loop clearfinal     
    mov cx,16
mov dh,20 

mov ah,2
mov dh,9
mov dl,45
int 10h
mov cx,35  

clearfinal1:            ;clear 4 line
    mov ah,2
    mov dl,000
    int 21h
    loop clearfinal1     
    mov cx,16
mov dh,20

;;;;;;;;;;;;;;;;;;;;;;;;    
mov ah,2
mov dl,45             
mov dh,8 
int 10h
 
print 'water remaining in tank '    ;display 3
mov ah,0 
mov al,ipwater
call print_num_uns
print ' liters'

mov ah,2
mov dl,45             
mov dh,9 
int 10h

print 'water consumed '           ;display 4
mov ah,0
mov al,tapwatot
call print_num_uns
print ' liters' 
ret
ExitProc endp
;;;;;;;;;;;;;;;;;;;;; 

DrawProc proc                  ;procedure draw
    mov ah,2
    mov dh,4       ;from top
    mov dl,3       ;to start
    int 10h
    mov cx,18      ;to end
    toplayer:
        mov ah,2
        mov dl,176
        int 21h
        loop toplayer     
        mov cx,16
    mov dh,4

side:
mov ah,2
mov dl,3    ;start
inc dh
int 10h
mov ah,2                         ;tank draw
mov dl,186
int 21h
mov ah,2
mov dl,20    ;start
int 10h
mov ah,2
mov dl,185
int 21h
loop side  

mov ah,2
mov dh,ip
mov dl,4
int 10h
mov cx,16  

botlayer:
    mov ah,2
    mov dl,236
    int 21h
    loop botlayer     
    mov cx,16
mov dh,20
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
mov ah,2
mov dh,19       ;from top
mov dl,21       ;to start
int 10h
mov cx,4      ;to end
tapp:                           ;tank side
    mov ah,2
    mov dl,216
    int 21h
    loop tapp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
mov cx,9
mov dh,9

sidetap:
mov ah,2
mov dl,25    ;start              ;tank side up pipe
inc dh
int 10h
mov ah,2
mov dl,186
int 21h 
loop sidetap  
;;;;;;;;;;;;;;;;;;;;;;;;

mov ah,2
mov dh,9
mov dl,26
int 10h
mov cx,9                          ;tap side

tapvalve:
    mov ah,2
    mov dl,216;229  227
    int 21h
    loop tapvalve       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov ah,2
    mov dh,19
    mov dl,25
    int 10h
    mov ah,2
    mov dl,188
    int 21h                    ;joint
    ;;
    mov ah,2
    mov dh,9
    mov dl,25
    int 10h
    mov ah,2
    mov dl,204
    int 21h 
    ;;
    mov ah,2
    mov dh,19
    mov dl,20
    int 10h
    mov ah,2
    mov dl,206
    int 21h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov ah,2
    mov dh,9
    mov dl,35
    int 10h                      ;tap cap draw
    mov ah,2
    mov dl,79
    int 21h 
;;;;;;;;;;;;;;
    mov ah,2
    mov dh,10
    mov dl,35                    ;tap down draw
    int 10h
    mov ah,2
    mov dl,227
    int 21h   
    
 
mov ah,2
mov dl,33             ;to display title tap
mov dh,7 
int 10h
mov ah,9
mov dx,offset taptit                                                                                                                    
int 21h   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;              

mov cl,13 
tapdraw:  
mov ah,2
mov dh,cl       
mov dl,t1                         ;draw tap tank side
int 10h
      
    mov ah,2
    mov dl,92
    int 21h  
    inc t1
    inc cl
    cmp cl,20
    jne tapdraw   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov cl,13 
tapdraw1:  
 mov ah,2
mov dh,cl       ;from top          ;draw tap tank side
mov dl,t2       ;to start
int 10h
      ;to end
    mov ah,2
    mov dl,47
    int 21h  
    dec t2
    inc cl
    cmp cl,20
    jne tapdraw1  
;;;;;;;;;;;;;;;;;;;  
mov ah,2
mov dh,20
mov dl,35
int 10h
mov cx,11                           ;draw basement for tap tank

basetap:
    mov ah,2
    mov dl,189
    int 21h
    loop basetap 
;;;;;;;;;;;;;;;;;;
mov ah,2
mov dl,57 
mov dh,14
int 10h
mov cx,9
boxtop:
    mov ah,2                    ;box top draw
    mov dl,196
    int 21h
    loop boxtop 


mov ah,2
mov dl,57 
mov dh,18
int 10h
mov cx,9                       ;boxbot draw
boxbot:
    mov ah,2
    mov dl,196
    int 21h
    loop boxbot  
    
 mov cx,3
 mov dh,14

sidetim:
mov ah,2
mov dl,57    ;start
inc dh
int 10h
mov ah,2                         ;timer side
mov dl,124
int 21h
mov ah,2
mov dl,65   ;start
int 10h
mov ah,2
mov dl,124
int 21h
loop sidetim

    mov ah,2
    mov dh,16
    mov dl,61                     ;:
    int 10h
    mov ah,2
    mov dl,58
    int 21h
    
mov ah,2
mov dl,58             ;to display title timer 
mov dh,20 
int 10h
mov ah,9
mov dx,offset timtit                                                                                                                    
int 21h    
     
    ret 
    DrawProc endp
 

sub:   
mov ah,2
mov dh,5               
mov dl,45
int 10h
mov cx,35  
clears:                  ;cleaning choice line
    mov ah,2
    mov dl,000
    int 21h
    loop clears     
    mov cx,16
mov dh,20 
ret
 
mtit db "WATER LEVEL CONTROL SYSTEM$"
ttit db "Tank$"
msg db "Tank full!!$" 
timtit db "Timer$"
taptit db "Tap$"
exit:
 call ExitProc
exit1:
 jmp options



