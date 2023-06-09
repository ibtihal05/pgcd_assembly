data segment
ancien_ip dw ?
ancien_cs dw ?
done dw 0    
message_1 db "fin du calcul du PGCD de val1 et val2",10,13,"$"    
x db  60  
y db  12  

ends

stack segment
    dw   128  dup(0) 
    tos label word
ends  


code segment
  Assume cs:code, ds:data, ss:stack  
      
    
    LireVecteurDiv0 proc
         mov ah, 35h
         mov al, 0
         int 21h
         
         mov ancien_ip, bx
         mov ancien_cs, es
         
        
        ret
    LireVecteurDiv0 endp     
                        
                        
    afficherChaine proc
        mov ah,9
        int 21h  
        ret
    afficherChaine endp
                         
                         
    new_routine:
    
        mov ax, seg message_1
        mov ds, ax
        mov dx, offset message_1  ; lea dx, message_1
        call afficherChaine
        mov done,1
    
    iret 
    
    deroutement proc
        
         mov dx, offset new_routine 
         mov ax, seg new_routine  
         mov ds, ax
         mov al, 0
         mov ah, 25h
         int 21h
         
         mov ax, data
         mov ds, ax
        
        
        ret 
    deroutement endp 
   

    PGCD_IB proc
       mov done,0 ;il faut le reinitialise a 0 car il va etre a 1 apres la 1ere call
       mov bl,y
       mov al,x 
       
       division:
       mov x,al   ;le dernier dividende avant l'int 0 est le pgcd (dernier rest non nule)
       mov ah,0   ; div utilise le registre ax donc il faut mettre ah a 0 ainsi la valeur de ax sera la meme que al et n'est pas affecte le rest
       div bl
       Cmp done,1  ; si done=1 : l'int de devision par 0 a ete declenche
       jz fin
       mov al,bl  ; le dividende recoit l'ancien diviseur 
       mov bl,ah  ; le diviseur recoit le rest   
       jmp division
       fin:
       pop dx  ; depiler l'@ de retour  
       mov ah,0
       mov al,x
       push ax ; empiler le pgcd
       push dx ; empiler l'@ de retour
       ret
     PGCD_IB endp
    
     restaurerVecteurDiv0 proc
        
         mov dx, ancien_ip
         mov ax, ancien_cs  
         mov ds, ax
         mov al, 0
         mov ah, 25h
         int 21h
         
         mov ax, data
         mov ds, ax
        
        
        ret 
    restaurerVecteurDiv0 endp
     
     
     start:
; set segment registers:
    mov ax, data
    mov ds, ax 
    mov ax, stack
    mov ss, ax
    mov sp, offset tos
 
 
     call LireVecteurDiv0 
     call deroutement
     call PGCD_IB
     call restaurerVecteurDiv0
 
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
