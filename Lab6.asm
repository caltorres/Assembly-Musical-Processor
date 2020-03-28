#-------------------------------------------------------------------------------------------------------------------------------------------------------
# Created by:   Torres Facio, Carlos Oscar 
#               CruzID: ctorresf
#               8/31/18
#
# Assigment:    Lab 6: Musical Subroutines
#               CMPE 12, Computer Systems and Assembly Language 
#               UC Santa Cruz, Summer 2018
#
# Description:  The following program contains subroutines and plays musical notes using the MIDE synchronous outputs through the usage of syscall 
#               service (33). The user will be able to run this file using another files called Lab6_test.asm. The user will be able to input a  
#               tempo and a song in a string format. 
#
# Notes         This program needs to be run using the MARS IDE
#-------------------------------------------------------------------------------------------------------------------------------------------------------

.data
previous:  .word 4

 
#---------------------------------------------------------------------------------------------------------------------------
# REGISTER USAGE:
# $a0: containts the first argument for the subroutine get_song_length, which in this case is the adress of first character in string. 
# $s1: containts the tempo of song in beats per minute. 
# $t3: containts the previous rhythm.
# $s0: containts the number of notes in song.
# $t9: containts the number that will denote when to leave the loop.
# $t6: containts the the address of first character of what woulf be the next note, which comes from the subroutine read_note as return value store in $v1
# $t1: containts an immediate value of 4. 
# $t2: containts the new rhythm given as an output from executing the read_note subroutine.
# $a0: containts the rhythm as argument for the subrotine play_note.
# $a1: containts the note duration in milliseconds.
#
# Note: that register usege will chage throughout the code, but any change will be specified in each line comment. The register
# mentioned above are the most significant registers.   
#---------------------------------------------------------------------------------------------------------------------------
play_song:
     
      la   $a0, ($a0)                          # Load address of $a0 into $a0.
      la   $s1, ($a1)                          # Load adresss of $a1 into $s1.
      lw   $t3, previous                       # Load word of label "previous" into $t3.
      jal  get_song_length                     # Jump and link to the subroutine get_song_length.
      li   $t9, 0                              # Load immediate value of 0 into $t9
      la   $s0, ($v0)                          # Load address of $v0 into $s0. 
      
loop: beq  $t9, $s0, end_and_exit              # Branch to end_and_exit if $t9 is equal to $s0.
       
      move $a1, $t3                            # Move the content of $t3 into $a1.
          
      jal  read_note                           # Jump and link to the subroutine read_note.
      move $t6, $v1                            # Move the content of $v1 into $t6.
      li   $t1, 4                              # Load immediate value of 4 into $t1.
      la   $t2, ($v0)                          # Load address of $v0 into $t2.
      andi $a0, $t2, 0x0000ffff                # Apply AND operation on $t2 with an immediate value 0x0000ffff and store the result in $a0. (Pitch)
      srl  $t3, $t2, 16                        # Shift right logical $t2 by 16 bits and store the result in $t3.
      sw   $t3, previous                       # Store word of $t3 into the address given by label "previous". (Rhythm)
      mul  $t5, $t1, 60000                     # Apply multiplication between $t1 and the immediate value 60000 and store the result in $t5.
      mul  $t8, $t3, $s1                       # Apply multiplication between $t3 and $s1 and store the result in $t8.
      div  $t8, $t5,$t8                        # Apply division between $t5 and $t8 and store the result in $t8.
      move $a1, $t8                            # Move the content of $t8 into $a1. 
      
      jal  play_note                           # Jump and link to the subroutine play_note. 
      addi $t9, $t9, 1                         # Add the immediate value of 1 to $t9 and store the result back into $t9.
      move $a0, $t6                            # Move the content of $t6 into $a0. 
      j loop                                   # Jump back to the beginning of the loop. 
     
end_and_exit:

      li $v0 10                                # Load the immediate value of 10 into $v0 to end the program. 
      syscall       
          
#---------------------------------------------------------------------------------------------------------------------------
# REGISTER USAGE:
# $a0: containts the address of first character in string containing the given song. 
# $t0: containts a copy to address of $a0.
# $t3: containts an immediate value of 0. (Counter) 
# $t1: containts the first character in song. 
# $t3: containts an immediate value of 1 and increase as we count the number of spaces. 
# $ra: containts the return address. 

# Note: that register usege will chage throughout the code, but any change will be specified in each line comment. The register
# mentioned above are the most significant registers.                                                                                                                                
#---------------------------------------------------------------------------------------------------------------------------                                                                                

get_song_length:                     

      move $t0, $a0                            # Move $a0 into $t0.
      li   $t3, 0                              # Load an immediate value of 0 into $t3. 
      
loop_count_spaces:  
           
      lb   $t1, ($t0)                          # Load byte at the address given by $t0 into $t1.
      beq  $t1,  ' ',  update_count            # Branch to update_count if $t1 is equal to 'space'. 
      beq  $t1, 0, exit_loop_count_spaces      # Branch to exit_loop_count_spaces if $t1 is equal to the terminator. 
      addi $t0,  $t0, 1                        # Add the immediate value of 1 to $t0 and store the result into $t0. 
      j loop_count_spaces                      # Jump to the beginning of the loop_count_spaces.
      
update_count:

      addi $t0,  $t0, 1                        # Add the immediate value of 1 with $t0 and store the result into $t0. 
      addi $t3,  $t3, 1                        # Add the immediate value of 1 with $t3 and store the result into $t3.
      j loop_count_spaces                      # Jump to the beginning of the loop_count_spaces.
      
exit_loop_count_spaces:
      
      addi $t3,  $t3, 1                        # Add the immediate value of 1 with $t3 and store the result into $t3.
      la   $v0, ($t3)                          # Load address given by $t3 into $v0. 
      jr   $ra                                 # Jump to rester $ra. 

#---------------------------------------------------------------------------------------------------------------------------
# REGISTER USAGE:
# $v0: containts the immediate value of 33. 
# $a2: containts the immediate value of 7. (instrument) 
# $ra: containts the return address. 

# Note: that register usege will chage throughout the code, but any change will be specified in each line comment. The register
# mentioned above are the most significant registers.                                                                                
#---------------------------------------------------------------------------------------------------------------------------

play_note:                                     

      li $v0, 33                               # $v0: containts the immediate value of 33.
      li $a2, 7                                # $a2: containts the immediate value of 7. (instrument) 
      syscall 
      jr $ra                                   # Jump to rester $ra.

#---------------------------------------------------------------------------------------------------------------------------
# REGISTER USAGE:
# $sp: containts the stack pointer address offset it minus 4. 
# $ra: containts the return address.  
# $a0: containts the address of first character in string. 
# $v0: containts return result of the rythm and the pitch in one register.  
# $t0: containts the pitch.
# $a0: containts the address of the character in the string after the pitch is determined by get_pitch.
# $a1: containts the previous rhythm.  
# $ra: containts the return address.

# Note: that register usege will chage throughout the code, but any change will be specified in each line comment. The register
# mentioned above are the most significant registers.  
#---------------------------------------------------------------------------------------------------------------------------

read_note: 

      subi $sp, $sp, 4                         # Substract the immediate value of 4 to the $sp and store the result in $sp. 
      sw   $ra, ($sp)                          # Store word denoted at the address of $sp into $ra. 
      
      la   $a0, ($a0)                          # Load address of first character of the string into $a0. 
      jal get_pitch                            # Jump and link get_pitch.
      la   $v0, ($v0)                          # Load address given by $v0 into $v0. 
      andi $v0, $v0, 0x0000ffff                # Add the immediate value of 0x0000ffff with $v0 and store the result into $v0.
      la   $t0, ($v0)                          # Load address given by $v0 into $t0. 
      la   $a0, ($v1)                          # Load address given by $v1 into $a0. 
      la   $a1  ($a1)                          # Load address given by $a1 into $a1.  
      jal get_rhythm                           # Jump and link get_rhythm. 
      la   $v0, ($v0)                          # Load address given by $v0 into $v0. 
      sll  $v0, $v0, 16                        # Shift left logical $v0 by 16 bits and store the result into $v0. 
      or   $v0, $v0, $t0                       # Apply the OR operation between $v0 and $t0 and store the result into $v0. 
      la   $v1, ($v1)                          # Load address given by $v1 into $v1. 
      j end                                    # Jump to end.
     
end:

      lw    $ra, ($sp)                         # Load word given by address denoted by $sp into $ra. 
      jr $ra                                   # Jump to $ra. 

#---------------------------------------------------------------------------------------------------------------------------
# REGISTER USAGE:
# $a0: containts the address of the first character in the string. 
# $t1: containts the address of the first character plus an immediate value of 0. 
# $t3: containts the byte starting at the address indicated by $t1 and stores it into $t3. 
# $a3: containts the immediate value of 100 which is the value of the volume. 
# $v0: containts the content of $t4. (MIDI value) 
# $v1: containts the address of character after pitch is determined by the loop inside the subroutine. 
# $ra: containts the return address.

# Note: that register usege will chage throughout the code, but any change will be specified in each line comment. The register
# mentioned above are the most significant registers.  
#---------------------------------------------------------------------------------------------------------------------------

get_pitch:

      addi $t1, $a0, 0                         # Add the immediate value of 0 to $a0 and store the result in $t1. 
      li   $t5, 0                              # Load the immediate value of 0 into $t5. 
       
loop_through_characters: 
      
      lb   $t3, ($t1)                          # Load byte indicated by the address of $t1 into $t3. 
      beq  $t3, 'a', set_value_of_a            # Branch to set_value_of_a if $t3 equals 'a'.
      beq  $t3, 'b', set_value_of_b            # Branch to set_value_of_b if $t3 equals 'b'.
      beq  $t3, 'c', set_value_of_c            # Branch to set_value_of_c if $t3 equals 'c'.
      beq  $t3, 'd', set_value_of_d            # Branch to set_value_of_d if $t3 equals 'd'.
      beq  $t3, 'e', set_value_of_e            # Branch to set_value_of_e if $t3 equals 'e'.
      beq  $t3, 'f', set_value_of_f            # Branch to set_value_of_f if $t3 equals 'f'.
      beq  $t3, 'g', set_value_of_g            # Branch to set_value_of_g if $t3 equals 'g'.
      beq  $t3, 'r', set_value_of_r            # Branch to set_value_of_r if $t3 equals 'r'.
      beq  $t3, 'i', set_pitch_value_is        # Branch to set_pitch_value_is if $t3 equals 'i'.
      beq  $t3,  0x2c, set_value_of_comma      # Branch to set_value_of_comma $t3 equals 0x2c.
      beq  $t3,  0x27, set_value_of_apostrophe # Branch to set_value_of_apostrophe $t3 equals 0x27. 
      j exit                                   # Jump to exit equals 
      
set_value_of_a:
      
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      addi $t5, $t5, 1                         # Add the immediate value of 1 to $t5 and store the result in $t5.
      li   $t4, 57                             # Load immediate value of 57 into $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
set_value_of_b:
      
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      addi $t5, $t5, 1                         # Add the immediate value of 1 to $t5 and store the result in $t5.
      li   $t4, 59                             # Load immediate value of 59 into $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
set_value_of_c: 
      
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      addi $t5, $t5, 1                         # Add the immediate value of 1 to $t5 and store the result in $t5.
      li   $t4, 60                             # Load immediate value of 60 into $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
set_value_of_d: 
      
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      addi $t5, $t5, 1                         # Add the immediate value of 1 to $t5 and store the result in $t5.
      li   $t4, 62                             # Load immediate value of 62 into $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
set_value_of_e: 
      
      beq $t5, 0, special_case_1               # Branch to special_case_1 if $t5 is equal to 0. 
      beq $t5, 1, special_case_2               # Branch to special_case_2 if $t5 is equal to 1. 
      
special_case_1: 

      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      addi $t5, $t5, 1                         # Add the immediate value of 1 to $t5 and store the result in $t5.
      li   $t4, 64                             # Load immediate value of 64 into $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
special_case_2:
 
      addi $t2, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      lb   $t3, ($t2)                          # Load byte at the indicated address of $t2 and store the content into $t3.
      beq  $t3, 's', decrease_pitch            # Branch to decrease_pitch if $t3 equals 's'. 
      
decrease_pitch:

      addi $t1, $t1, 2                         # Add the immediate value of 2 to $t1 and store the result in $t1.
      sub  $t4, $t4, 1                         # Substract the immediate value of 1 to $t4 and store the result in $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
set_value_of_f: 
      
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      addi $t5, $t5, 1                         # Add the immediate value of 1 to $t5 and store the result in $t5.
      li   $t4, 65                             # Load immediate value of 65 into $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
set_value_of_g: 
      
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1. 
      addi $t5, $t5, 1                         # Substract the immediate value of 1 to $t1 and store the result in $t1.
      li   $t4, 67                             # Load immediate value of 67 into $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
      
set_value_of_r: 
      
      addi $t4, $t4, 0                         # Add the immediate value of 0 to $t4 and store the result in $t4.
      addi $t5, $t5, 1                         # Substract the immediate value of 1 to $t5 and store the result in $t5.
      addi $t1, $t1, 1                         # Substract the immediate value of 1 to $t1 and store the result in $t1.
      li   $a3, 0                              # Load immediate vlaue of 0 into $a3.
      j loop_through_characters                # Jump to loop_through_characters. 
   
set_pitch_value_is:

      addi $t2, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      lb   $t3, ($t2)                          # Load byte at the indicated address of $t2 and store the content into $t3.
      beq  $t3, 's', increase_pitch            # Branch to decrease_pitch if $t3 equals 's'. 
     
increase_pitch:

      addi $t1, $t1, 2                         # Add the immediate value of 2 to $t1 and store the result in $t1.
      addi $t4, $t4, 1                         # Add the immediate value of 1 to $t4 and store the result in $t4.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters.
      
set_value_of_comma: 

      subi $t4, $t4, 12                        # Substract the immediate value of 12 to $t4 and store the result in $t4.
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters.
      
set_value_of_apostrophe:

      addi $t4, $t4, 12                        # Add the immediate value of 12 to $t4 and store the result in $t4.
      addi $t1, $t1, 1                         # Add the immediate value of 1 to $t1 and store the result in $t1.
      li   $a3, 100                            # Load immediate vlaue of 100 into $a3.
      j loop_through_characters                # Jump to loop_through_characters.
      
exit:

      move $v0, $t4                            # Move the content of $t4 into $v0.
      la   $v1, ($t1)                          # Load address given by $t1 into $v1.
      jr $ra                                   # Jump to register $ra. 

#---------------------------------------------------------------------------------------------------------------------------
# REGISTER USAGE:
# $a0: containts the address of the character after the pitch is determined. 
# $t3: containts a copy of the $a0.
# $v0: containts the rhythm 
# $v1: containts the address of the first character of the next note.
# $ra: containts the return address.

# Note: that register usege will chage throughout the code, but any change will be specified in each line comment. The register
# mentioned above are the most significant registers.  
#---------------------------------------------------------------------------------------------------------------------------
 
get_rhythm:
  
      lb   $t3, ($a0)                          # Load byte indicated by the address of $a0 into $t3.
      
      beq  $t3, '1', set_a0_1_or_16            # Branch to set_a0_or_16 if $t3 is equal to '1'.
      beq  $t3, '2', set_a0_2                  # Branch to set_a0_2 if $t3 is equal to '2'.
      beq  $t3, '4', set_a0_4                  # Branch to set_a0_4 if $t3 is eqaul to '4'
      beq  $t3, '8', set_a0_8                  # Branch to set_a0_8 if $t3 is eqaul to '8'
      beq  $t3, ' ', default                   # Branch to default if $t3 is equal 'space'
      beq  $t3, 0  , default                   # Branch to default if $t3 is equal to the terminator.
            
set_a0_1_or_16:

      addi $a0, $a0, 1                         # Add the immediate value of 1 to $a0 and store the data in $a0.
      lb   $t3, ($a0)                          # Load byte indicated by $a0 into $a0.
      beq  $t3, '6', set_a0_16                 # Branch to set_a0_16 if $t3 is equal to '6'
      li $v0 1                                 # Load the immediate value of 1 in $v0
      addi $v1 $a0 1                           # Add the immediate value of 1 to $a0 and store the result in $v1.
      j end_if                                 # Jump to end_if.
      
set_a0_2:
      
      li $v0 2                                 # Load the immediate value of 2 in $v0.
      addi $v1 $a0 2                           # Add the immediate value of 2 to $a0 and store the result in $v1.
      j end_if                                 # Jump to end_if.
      
set_a0_4:

      li $v0 4                                 # Load the immediate value of 4 in $v0.
      addi $v1 $a0 2                           # Add the immediate value of 2 to $a0 and store the result in $v1.
      j end_if                                 # Jump to end_if.
      
set_a0_8:

      li $v0 8                                 # Load the immediate value of 8 in $v0.
      addi $v1 $a0 2                           # Add the immediate value of 2 to $a0 and store the result in $v1.
      j end_if                                 # Jump to end_if.
      
set_a0_16:

      li $v0 16                                # Load the immediate value of 16 in $v0.
      addi $v1 $a0 2                           # Add the immediate value of 2 to $a0 and store the result in $v1.
      j end_if                                 # Jump to end_if.
      
default:

      move $v0, $a1                            # Move the content of $a1 to $v0.
      addi $v1, $a0, 1                         # Add the immediate value of 1 to $a0 and store the result in $v1.
      j end_if                                 # Jump to end_if.
      
end_if:

      jr $ra                                   # Jump to register $ra. 
 
#---------------------------------------------------------------------------------------------------------------------------


