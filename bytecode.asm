data segment
ancien_ip dw ?
ancien_cs dw ?
done db 0    
message_1 db "fin du calcul du PGCD de val1 et val2",10,13,"$"     

tab db 12,6,9,18
pgcd db ? 

date db 18 dup(?)
time db 5 dup(?)

day0 db "Dimanche","$"
day1 db "Lundi","$"
day2 db "Mardi","$"
day3 db "Mercredi","$"
day4 db "Jeudi","$"
day5 db "Vendredi","$"
day6 db "Samedi","$"
 
msg1 db "N=4","$" ;N depend de taille tab 
msg2 db 20 dup(?) ;pour les elements de tab
msg3 db 5 dup(?)  ;pour la valeur de pgcd
msg4 db "tab=","$"
msg5 db "PGCD=","$"

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
   

    PGCD_I proc
       mov done,0 ;il faut le reinitialise a 0 car il va etre a 1 apres la 1ere call
       division:
       mov pgcd,al ;le dernier dividende avant l'int 0 est le pgcd (dernier rest non nule)
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
       mov al,pgcd
       push ax ; empiler le pgcd
       push dx ; empiler l'@ de retour
       ret
     PGCD_I endp
    
      PGCD_IN proc
       Mov cx, 3  ;l'initialisation de cx depend de N le nombre des valeurs (cx=N-1)
       Mov si, 0 
       Mov al, tab[si] ; al recoit la 1ere val (le 1er dividende)

      Enc:                 
       inc si
       Mov bl, tab[si] ; a chaque fois bl va recoit la valeur suivante
       Call PGCD_I  
       pop ax   ;ax recoit le pgcd precedent pour calculer le nouveau pgcd
       loop Enc
       ret

      PGCD_IN endp

    
     
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
     
                
     decimal proc  ;cette proc convert un nombre decimal au des caracteres et les remplir dans une chaine
      
        Mov bx, 10  ;on devise par 10 a chaque fois 
        Decomposer:
        Dec si
        mov dx,0
        Div bx
        Add dl, 48  ;pour avoir le code ASCI de chiffre
        Mov [si], dl ;remplir le chaine
        Cmp ax, 0    ;ax=0 -> on a arrive au dernier chiffre
        jne Decomposer
        ret
      decimal endp
      
      position proc
        mov ah, 2 
        mov bh, 0         
        int 10h
      ret
      position endp

                 
     GetSystemDate proc
      Mov ah, 2ah
      Int 21h 
      ret    
     GetSystemDate endp  
         
         
     GetSystemtime proc
      Mov ah, 2ch
      Int 21h 
      ret    
     GetSystemtime endp 
     
     
     day proc      ;afficher le jour par rapport le contenue de al
         cmp al,0
         jne test1 
         lea dx,day0
         call afficherchaine 
         jmp out
         
         test1:
         cmp al,1
         jne test2 
         lea dx,day1
         call afficherchaine
         jmp out
         
         test2:
         cmp al,2
         jne test3
         lea dx,day2
         call afficherchaine
         jmp out
         
         test3:
         cmp al,3
         jne test4
         lea dx,day3
         call afficherchaine
         jmp out
         
         test4:
         cmp al,4
         jne test5 
         lea dx,day4
         call afficherchaine
         jmp out
         
         test5:
         cmp al,5
         jne test6 
         lea dx,day5
         call afficherchaine
         jmp out
         
         test6:
         cmp al,6 
         lea dx,day6
         call afficherchaine
       
         out:
        
         ret
     day endp
   
   afficherDate proc
    
    Lea si, date[17]
    Mov [si], '$'              
    
    call GetSystemDate  ;pour avoir l'annee
    mov ax,cx
    call decimal 
    
    dec si
    mov al,'/'
    mov [si],al 
    
    call GetSystemDate   ;pour avoir le mois
    mov al,dh
    mov ah,0
    call decimal 
                   
    dec si
    mov al,'/'
    mov [si],al 
    
    call GetSystemDate   ;pour avoir le numero de jour
    mov al,dl
    mov ah,0
    call decimal 
    
    dec si
    mov al,','
    mov [si],al 
 
    mov dl,64  ;colonne de l'ecran
    mov dh,0   ;ligne de l'ecran 
    call position 
    call GetSystemDate ;pour afficher le jour
    call day
    mov DX,si   ;pour afficher la date
    call afficherchaine
  ret            
  afficherDate endp 
   
  afficherTime proc
    
    Lea si, time[4]
    Mov [si], '$'              
    
    call GetSystemTime   ;pour avoir le minute
    mov al, cl 
    mov ah, 0
    call decimal 
    
    dec si
    mov al,'h'
    mov [si],al 
    
    call GetSystemTime  ;pour avoir l'heure
    mov al, ch
    mov ah, 0
    call decimal 
                 
     
    mov dl,74  ;colonne de l'ecran
    mov dh,2   ;ligne de l'ecran 
    call position
    mov DX,si 
    call afficherchaine
  ret            
 afficherTime endp
     
     
 affichertab proc
       
       mov dl,1  ;colonne de l'ecran
       mov dh,4   ;ligne de l'ecran 
       call position 
       Lea dx, msg1     
       call afficherchaine  ;afficher N=4
       
        
       Lea si, msg2[19]  
       Mov [si], '$' 
       mov di,3
       mov cx,4
       do: 
       mov al,tab[di]
       mov ah,0 
       call decimal
       dec si
       mov al,','
       mov [si],al
       dec di  
       loop do
       
       
       mov dl,33  ;colonne de l'ecran
       mov dh,4   ;ligne de l'ecran 
       call position
       lea dx,msg4
       call afficherchaine  ;afficher tab= 
       
       inc si ;pour n'afficher pas la dernier vergule
       mov DX,si
       call afficherchaine  ;afficher les elements du tab
    
     ret            
  affichertab endp 

  
  
    
  afficherPgcd proc
    
    Lea si, msg3[4]
    Mov [si], '$'              
    mov al,pgcd 
    mov ah, 0
    call decimal 
    
  
    mov dl,37  ;colonne de l'ecran
    mov dh,6   ;ligne de l'ecran 
    call position
    lea dx,msg5
    call afficherchaine ;afficher PGCD=
    
    mov dx,si 
    call afficherchaine  ;afficher la valeur pgcd
    ret            
  afficherPgcd endp
  
   
  affichage proc
    
    mov ax , 3    ;pour effacer l'ecran
    int 10h

    call afficherDate
    call afficherTime 
    call affichertab
    call afficherPgcd
    ret
  affichage endp   
    
    
    
start:
; set segment registers:
    mov ax, data
    mov ds, ax 
    mov ax, stack
    mov ss, ax
    mov sp, offset tos
 
 
     call LireVecteurDiv0 
     call deroutement
     call PGCD_IN
     call restaurerVecteurDiv0
 
     call affichage 
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
