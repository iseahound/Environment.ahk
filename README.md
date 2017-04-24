# Environment.ahk
Add, delete, sort, and backup Windows environment variables including PATH.

## Features

* Automatic REG_SZ and REG_EXPAND_SZ detection
* Backup before you make any changes with `EnvUserBackup()` and `EnvSystemBackup()`
* Sort your messy Windows PATH in alphabetical order.
* Edit both system and user path with separate commands.
* Broadcast changes to PATH in the current AutoHotKey script and System-wide.

### Create a Backup before you regret it.
    EnvUserBackup()
    EnvSystemBackup()

#### Add a directory to user PATH
    EnvUserAdd("PATH", "C:\bin")

#### Remove a directory from user PATH
    EnvUserSub("PATH", "C:\bin")

#### Using a Relative Path
    EnvUserAdd("PATH", RPath_Absolute(A_ScriptDir, "..\project1\bin"))

#### Create a new Environment Variable
    EnvUserNew("NUMBER_OF_GPU_CORES", "9")

#### Read an existing Environment Variable
    key := EnvUserRead("NUMBER_OF_GPU_CORES")
    ; returns 9

#### Delete an Environment Variable
    EnvUserDel("NUMBER_OF_GPU_CORES")

#### Use EnvSystem to edit the System Environment Variables
    EnvSystemAdd("PATH", "X:\Backup\bin")

#### Sort System PATH in alphabetical order
    EnvSystemSort("PATH")

##### Note: You need to run your script as Administrator to use the EnvSystem commands, with the exception of EnvSystemRead() and EnvSystemBackup().
