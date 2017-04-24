# Environment.ahk
Set, change, add or delete Windows Environment variables

#### Add a directory to PATH
    SetEnvironmentVariable("PATH", "C:\bin", "ADD")

#### Remove a directory from PATH
    SetEnvironmentVariable("PATH", "C:\bin", "REMOVE")
    
#### Create a new Environment Variable
    SetEnvironmentVariable("NUMBER_Of_GPU_CORES", "9")




SetEnvironmentVariable("TEST", "5555")                           ; Makes a new variable TEST with the value 5555
; SetEnvironmentVariable("TEST", "5555", "DEL")                    ; Deletes TEST

; 
; SetEnvironmentVariable("PATH", "C:\Windows", "EXIST")            ; Returns 1 if the value "C:\Windows" is in the variable PATH
