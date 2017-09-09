# Environment.ahk
Add, delete, sort, and backup Windows environment variables including PATH.

## Features

* Automatic REG_SZ and REG_EXPAND_SZ detection
* Backup before you make any changes with `EnvUserBackup()` and `EnvSystemBackup()`
* Sort your messy Windows PATH in alphabetical order.
* Edit both system and user path with separate commands.
* Broadcast changes to PATH in the current AutoHotKey script and System-wide.

### Create a Backup before you regret it.
    Env_UserBackup()
    Env_SystemBackup()

#### Add a directory to user PATH
    Env_UserAdd("PATH", "C:\bin")

#### Remove a directory from user PATH
    Env_UserSub("PATH", "C:\bin")

#### Using a Relative Path
    Env_UserAdd("PATH", RPath_Absolute(A_ScriptDir, "..\project1\bin"))

#### Create a new Environment Variable
    Env_UserNew("NUMBER_OF_GPU_CORES", "9")

#### Read an existing Environment Variable
    key := Env_UserRead("NUMBER_OF_GPU_CORES")
    ; returns 9

#### Delete an Environment Variable
    Env_UserDel("NUMBER_OF_GPU_CORES")

#### Use EnvSystem to edit the System Environment Variables
    Env_SystemAdd("PATH", "X:\Backup\bin")

#### Sort System PATH in alphabetical order
    Env_SystemSort("PATH")

#### Remove Duplicates from System PATH and sort in alphabetical order
    Env_SystemRemoveDuplicates("PATH")

##### Note: EnvSystem commands need to be Run As Administrator, with the exception of EnvSystemRead() and EnvSystemBackup().
