# Project 1
## Authors
- Fergus Charles
- Snow Dodgson
- Mitch Hewitt

## Exercise 1 Documentation 

### Summary of Task:

Exercise 1 should take a pre-defined string from the program and load the memory address that references the start of the string into an index register. Once this has been completed 4 tasks involving bit manipulation must be performed on the string with the resulting modified string to be printed out on the terminal once the function has completed. The tasks are as follows:

	1 – Make all of the letters lower case 
	2 – Make all of the letters upper case  
	3 – Capitalise only the first letter of each word
	4 – Capitalise the first letter of the string, and the first letter after a full-stop

### Program Summary:

- The program defines required string and other variables
- Loads the starting address of input string into x
-	Using subroutine “processstring” 
    - Accumulator B is loaded with byte 0+x to allow iteration of string
    - Register b checked against terminating char
      -If terminating go to terminating branch, if not keep processing
    -	In keepprocessing, Char is checked to be valid once transferred to accumulator A, if the current char is less than decimal value 65, or greater than 122, as these the range of values for valid input characters the program will go to the nextchar. If the ASCII rangle is from 65-90 or 97-122 then the program branches to “validchar”
  -	Required function is then applied as decided in “validchar”
    -	allToUpper: checks if the char present is already capitalised (less than decimal 90) If it is greater than 90, 32 is subtracted from the value to get its lower case equivalent
    -	allToLower: Checks if the char present is already lower case (greater than decimal 90) If it is less than 90, 32 is added to attain the lower case decimal value.
    -	Capspace & fullspace: Checks for fullstop and or space flags are set. If both return true for fullspace or space true for capspace, the character will be put into “allToUpper” and the following characters all run through “allToLower”
- The nextchar section is used to check if the current character is a fullstop or a space using fullstopcheck & spacecheck, this then triggers a flag which is used by a the Capspace and fullspace function, after this x will increment and then move to the next char by going back to the processstring loop.
  
### Diagram:
![alt text](https://github.com/littlepetal/treasureForest/blob/0bc68a495badff4f2c6611e881f95329f719049f/Project_Docs/Exercise%201/exercise%201%20Documentation/ex1%20(3).png)

### Discussion Questions:

What happens if the end of the string is not detected?
 - if the end of the string has not been recognised by the definition given by the label “terminating_character” when used in the function “processstring” with a CMPB operation, then the program will continue functioning. As the input string variable (“inpstr”) has been declared with a “fcc” command, and despite the fact that this operation doesn’t concatenate a terminating character, by default the string is delimited with the quotation marks and so the address of the final character of the input string is known. However if the end of the string is still not identified, by comparing the decimal value of the next char to be analysed with the range of values of valid characters it is ensured that once the end of the string is reached that the next function will begin, and if all functions have been performed then an “rts” operation is read.

What else can go wrong?
    -	Time taken for relatively long strings will start to increase noticeably due to the requirement of using branches instead of jump operations. However as the program is relatively small, and conditional jumps are required, branching operations are the most suitable operation to be used in this program.
    -	There is the possibility that the string entered exceeds the available memory to store its contents, in which case it would be truncated. Although this is not a serious concern as the program would become unfeasibly slow, it would result in the memory being overwritten by the character manipulations which would then result in the following tasks receiving a different string to the original.	Non-English characters entered that may translate to valid decimal values
 
 How do you select which function you want to perform?
  -	The selection is made in the sub-routine “validchar” by commenting out the functions that are not wished to be tested at the time. An iterative way was previously looked at where the task numbers (shown at the top) where used to set their precedence and could all be run one after the other, however this did not allow for full control and concise version testing. As all functions remain defined and it is just the branching that is commented out, it does allow the use of them in other functions which becomes particularly useful in tasks 3 & 4

### Testing:

Inputting a string from the terminal 
- Check that the sub-routine is being called and run by setting a breakpoint in the processstring subroutine.
- Check that register X is loading the start of the memory’s location, e.g load a string of char a and check it's ascii value is loading into b
- check that the terminating character is causing the program to end the subroutine by placing a breakpoint at terminate
- Is the current char valid? check that the program goes to the nextchar brack or the keepprocessing branch
    -	Is the current char upper case(dec value >65 and <90)
    -	Is the current char lower case(dec >97 and <120) 
  -	Is the current char a full stop
- Check that the functions lower and upper subtract and add #32 to the registers by loading a string of one character and stepping through.
- Check the capspace and fullspce have the flags set for their desired operation by loading in a string such as ". a" and step through untill the a character.



## Exercise 3 Documentation 

### Summary of Task:
Exercise 3 should take a string from the terminal emulator which is connected to the SCI1 input port, then be read in through the SCI to be stored in memory. This string stored in memory should then be outputted through the SCI port and displayed on the terminal. The carriage break character should be used to denote the end of the string. The string should print out once per second. 

### Program Summary:
-	The program reserves 300 bytes of memory at address inpstr
-	The program sets the baud rate at 9600 by writing to the SCI1BDH/DL registers 
-	Loads the address of inpstr to register x
-	Using a subroutine the program jumps to the receive subroutine, The control register 2 is set to receiving enabled. When the mask for RDRF empty is 1, the subroutine will run, not moving to the next character until this mask is met. The data in the SCI1DRL register is stored in reg b. This is compared to the carriage character value. If 0, return from the function and add the carriage character to the current memory address of inpstr. Else store the value of the char in reg b at current address position in x, increment x
-	Using a subroutine there is a delay of 1 second.
-	Using a subroutine the program jumps to the transmit subroutine. The control register 2 is set to transmitting enabled. When the mask for RTDE empty is 1, the subroutine will run, not moving to the next character until this mask is met. The data in the address of x in moved to SCI1DRL register. This is compared to the carriage character value. If 0, return from the subroutine as this is the end of the string, only return when transmission is complete. Else store loop through the reserved memory until the carriage character.

### Diagram 
![alt text](https://github.com/littlepetal/treasureForest/blob/0bc68a495badff4f2c6611e881f95329f719049f/Project_Docs/Exercise%203/ex3_documnetation/diagram%20(1).png)

### Discussion Questions:
What problems can you see arising from the use of polling when dealing with data input? 
- The main problem will polling is it limits the device to waiting for the data to be ready before it can move on. This is fine if time is not important and this is the only task we want to achieve. However if we want to perform other tasks at the same time, this is not possible as polling relies on a sequential order of events. Another Main issues is the problem arising when timing is critical, as polling does take a finite amount of time, this can have negative effects on the program. 

What happens if there are more characters input than there is space to store them?
- These characters will flow onto the next memory addresses. This is ok if there is nothing else being stored in memory, but in our example we have another space for memory where we store the numbers used for the seven 7. If there isn’t enough space defined, the string will fill this space, then this will be overwritten by characters or the characters will be later sent to the seven seg. Further more when this str goes to be sent out via serial, it could be overwritten by numbers. 

### Testing:
Are the SCI registers for baud rate, control and status being set correctly?
- Check that SCI1BDH is set to #00
- Check that SCI1BDL is set #156 (baud rate) 
- Check that SCI1CR2 has a binary value of #%00001100
- Check status register for errors when unexpected behavior occurs. 

Printing to the terminal
- Check that the sub-routine is being called and run by setting a breakpoint in the TE subroutine.
- Check that register X is loading the start of the strings location
- Check that the branch until the TDRF flag is being set and the code runs past this branch by setting a breakpoint after this conditional branch.
- Use Putty to verify serial signals can be sent by sending chars from string. If this doesn’t work, verify comm ports. Verify serial registers are all for port 1. Check code loaded successfully onto the board.
- Check that the terminating character is causing the code to break from the sub-routine by setting a breakpoint before the RTS.
- If there are errors use the status registers to check for framing, parity, or other others. 

Inputting a string from the terminal 
- Check that the sub-routine is being called and run by setting a breakpoint in the RE subroutine.
- Check that register X is loading the start of the memory’s location
- Check that the branch until the RDRF flag is being set and the code runs past this branch by setting a breakpoint after this conditional branch.
- Check that the SCI1DRL is loading a value into a register. 
- Check that ascii values are entering as expected by using ascii table.
- Make sure X is incrementing as desired by using a breakpoint to the step through the increment step.
- Check that the terminating character is causing the code to break from the sub-routine by setting a breakpoint before the RTS.
- If there are errors use the status registers to check for framing, parity, or other others. 


## Exercise 4 Documentation 

### Summary of Task:
Exercise 4 should take a string from the terminal emulator, such as putty, which is connected to the SCI1 input port. This string should be stored in a memory location. After the string is stored it should be manipulated such that it is either converted such that all letters following a space are uppercase (and the remaining characters become lowercase), or b. converted so that all letters are uppercase. This decision is done a switch in port p. A copy of the numerical characters will be stored in a new location. The manipulated string is sent to serial with a delay of 1 second. After this has been executed the numerical characters of the string will be sent to the 7 seg which will scroll through these. After which the program will return and wait for a new input.

### Program Summary:

Note detailed documentation for each of these steps can be found in each exercises own documentation*
- Sets Baud rate and control registers for SCI.
- Jump to receive subroutine for serial input.
 -	Wait until TDRE bit is set. 
 -	Then transmit data into memory location. 
 -	Once the CR is hit, add newline and CR.
 -	Jump to Delay subroutine 
 -	Delay for 1 second
 -	Load the start of the receive string into x. 
 -	Store an initial flag into memory locations, this is used to capitalise the first letter of the string if required. 
 -	Jump to the string manipulation subroutine. 
  -	Check if the string should terminate. 
  -	Check if char is alpha. Alpha chars get processed. Non alpha chars get skipped. 
  -	Processed chars have a function applied to them. All upper or Upper after a space
  -	Non valid chars are skipped. 
  -	Before moving to the next char the current char is tested if it is a space, this information is stored in memory as a flag. 
  -	Position is incremented and branches back to start of the subroutine.
 -	Jump to Numerical store Subroutine.
  -	Store the numerical characters from the string into a new memory location.
 - 	Jump to transmit subroutine. 
  -	Wait until TDRF is set then transmit characters. 
-	Jump to the seven seg display subroutine. 
  -	Only utilise the scroll function. 
  -	Add in a feature where if the numerical string is simply the null character, i.e no numerical characters, the scrolling code is skipped and the led remains off. 
- 	Return to the start of the loop

### Diagram
![alt text](https://github.com/littlepetal/treasureForest/blob/0bc68a495badff4f2c6611e881f95329f719049f/Project_Docs/Exercise%204/integration%20docs/ex4.png)


### Discussion Questions:
 
How can the 7-seg string be displayed if the microprocessor is currently waiting for information from the serial port? 
-	Initially port b should be cleared such that the LED is disabled.
-	At the end of the scroll for the numerical characters it should also be cleared.


What design and planning strategies did you use to incorporate all of the previous exercises into this task? 
-	For each module there is specified inputs and outputs which would be needed in the pipeline. For example, the string manipulation tasks and the seven seg scrolling functions. Required a string which a way of determining the end of the string. 
-	We tried to standardise aspects of the code such as what would be the terminating character. 
-	We broke the integration task into a flow diagram of what should happen and aimed at decoupling each of the exercises. Whilst this may have not been the most efficient approach, it makes testing much easier as for each stage of the pipeline there are clear inputs and clear desired outputs. This approach is best seen where exercise 1 the string is restored in the memory location and then for exercise 2 this new string is copied to a new memory location for the numerical characters, rather than attempt to do it all in one go. 
-	This makes testing easier. 
-	Also, where previously in exercise 1 each of the tasks were subroutine functions. We made these branches. 
-	Other strategies also included reloading registers to ensure that previous operations would not affect the aims, this was particularly important as new sections of the code were appended or added to the old code. 

How did you test the code?

-	For the testing, please refer to each exercises specific section for testing. 
-	Exercise 3 for receiving characters testing. 
-	Exercise 1 for testing the string manipulation. 
-	Additionally check using breakpoint that the comparator is working for port H, when 7th bit is 1 it should go to capspace subroutine, if 0 the allupper.
-	For the storing of only numerical characters 
-	Check that loading #numbers using spc has created free memory. 
-	Check numbers and inpstr memory locations have loaded into y and x.
-	Enter all 1 into the terminal, set breakpoints at the numbering subroutine. 
-	Check that the asci comparator works as the branch to ‘next’ should not occur. 
-	Step through to make sure x is inc and y in inc if there is a number.
-	Check that the subroutine terminates at the carriage char.
-	See Exercise 3 for receiving characters testing.

![image](https://user-images.githubusercontent.com/79816824/112794901-6ef49300-90b3-11eb-81a8-421f8ef5244d.png)

# end
