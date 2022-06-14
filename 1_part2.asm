          global    _start

          section   .text
_start:
          mov       rax, 0
          mov       [number], rax           ; start from 0

          mov       rax, 2                  ; open
          mov       rdi, input
          mov       rsi, 0                  ; O_RDONLY
          syscall

          mov       [fd], rax               ; save fd


          mov       r12, 0                  ; data index


read_char:
          mov       r9, -1                  ; offset to read_buf

read_char_loop:
          inc       r9

          mov       rax, 0                  ; read
          mov       rdi, [fd]
          mov       rsi, read_buf
          add       rsi, r9
          mov       rdx, 1
          syscall

          mov       rdi, 10                 ; check if end of line (\n)
          xor       rdx, rdx
          mov       dl, [read_buf + r9]
          cmp       rdx, rdi
          je        parse_number

          cmp       rax, 0                  ; check if end-of-file (return value from read syscall)
          je        parse_number

          jmp       read_char_loop


parse_number:
          mov       r8, r9                  ; iterator
          mov       r10, 1                  ; number multiplier
          xor       r11, r11                ; parsed number

parse_number_loop:
          dec       r8
          xor       rdx, rdx
          mov       dl, [read_buf + r8]
          sub       rdx, 48                 ; substract ascii zero
          imul      rdx, r10
          add       r11, rdx

          imul      r10, 10

          cmp       r8, 0
          jg        parse_number_loop


push_to_depths:
          mov       [depths + r12], r11d
          add       r12, 4

          cmp       rax, 0                  ; end-of-file
          jne       read_char


process_depths:
          mov       r12, -4                  ; data index

process_depths_loop:
          add       r12, 4

          xor       rax, rax                ; sum1
          add       eax, [depths + r12]
          add       eax, [depths + r12 + 4]
          add       eax, [depths + r12 + 8]

          xor       rdx, rdx                ; sum2
          add       edx, [depths + r12 + 4]
          add       edx, [depths + r12 + 8]
          add       edx, [depths + r12 + 12]

          xor       rsi, rsi                ; score
          cmp       rax, rdx
          setb      sil

          mov       rdi, [number]
          add       rdi, rsi
          mov       [number], rdi

          cmp       r12, 8000 - 3*4
          jbe       process_depths_loop

num_to_string:
          mov       eax, [number]
          push      rax

          xor       r8, r8                  ; number length

num_to_string_length_loop:
          cmp       rax, 0
          je        num_to_string_parse

          mov       rsi, 10
          xor       rdx, rdx
          div       rsi
          inc       r8

          jmp       num_to_string_length_loop

num_to_string_parse:
          pop       rax

          mov       r9, r8                  ; iterator
          dec       r9

num_to_string_parse_loop:
          cmp       rax, 0
          je        output

          mov       rsi, 10
          xor       rdx, rdx
          div       rsi

          add       rdx, 48                 ; add ascii zero
          mov       [write_buf + r9], dl

          dec       r9 

          jmp       num_to_string_parse_loop

output:
          mov       rax, 1                  ; write
          mov       rdi, 1                  ; fd is stdout
          mov       rsi, write_buf
          mov       rdx, r8
          syscall

          mov       rax, 3                  ; close
          mov       rdi, [fd]
          mov       rdi, rax
          syscall

          mov       rax, 60                 ; exit
          xor       rdi, rdi                ; exit code 0
          syscall


          section   .data
input:    db        "input/1.txt", 0


          section   .bss
read_buf: resb      10
write_buf:resb      10
depths:   resb      8000                    ; each num is 4 bytes
number:   resb      8
fd:       resb      8
