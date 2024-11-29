# Environment.ahk
Add, delete, sort, and backup Windows environment variables including PATH.

## Features

* Automatic REG_SZ and REG_EXPAND_SZ detection
* Backup before you make any changes with `EnvUserBackup()` and `EnvSystemBackup()`
* Sort your messy Windows PATH in alphabetical order and remove duplicate entries.
* Edit both system and user path with separate commands.
* Broadcast changes to PATH in the current AutoHotKey script and System-wide.
* Supports relative paths with just in time conversion.

## Usage
Create a new script with the following code.
```
#include Environment.ahk
Env_UserBackup(), Env_SystemBackup()      ; Always backup!
MsgBox userpath := Env_UserRead("PATH") ; Display the user path.
```

#### Create a Backup before you regret it.
    Env_UserBackup()
    Env_SystemBackup()

#### Add a directory to user PATH
    Env_UserAdd("PATH", "C:\bin")

#### Remove a directory from user PATH
    Env_UserSub("PATH", "C:\bin")
    Env_UserRemove("PATH", "C:\bin") ; Alias to above

#### Using a Relative Path
    Env_UserAdd("PATH", "..\project1\bin")

#### Temporarily add a directory to PATH until script exit.
    Env_UserTemp("PATH", "D:\Software\bin")

#### Because the order of entries in the PATH matters:
    Env_UserAddFirst("PATH", ".\bin")  ; Default behavior
    Env_UserAddLast("PATH", ".\bin")   ; Appends to the end
    Env_UserAddSort("PATH", ".\bin")   ; Sorts in alphabetical order
    Env_UserAddUnique("PATH", ".\bin") ; Removes duplicates
    Env_UserTempFirst("PATH", ".\bin")
    Env_UserTempLast("PATH", ".\bin")

#### Unblock folders on new computers
    Env_UserAddFirstUnblock("PATH", ".\bin")
    Env_UserAddLastUnblock("PATH", ".\bin")
    Env_UserAddSortUnblock("PATH", ".\bin")
    Env_UserAddUniqueUnblock("PATH", ".\bin")
    Env_UserTempFirstUnblock("PATH", ".\bin")
    Env_UserTempLastUnblock("PATH", ".\bin")

#### Broadcast changes to PATH in the current AutoHotkey script
    Env_RefreshEnvironment()

#### Broadcast changes to PATH System-wide
    Env_SettingChange()

#### Disable broadcasting for faster performance
    Env_UserTempFirstFast("GOPATH", ".\bin\go")
    Env_UserTempFirstFast("PY", ".\bin\python.exe")
    Env_UserTempFirstFast("JAVAFX", ".\java\javafx-sdk-11.0.2\lib")

    ; Then when you are ready to broadcast changes:
    Env_RefreshEnvironment()
    Env_SettingChange()

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
    Env_SystemUnique("PATH")

##### Note: Env_System commands need to be Run As Administrator, with the exception of EnvSystemRead() and EnvSystemBackup().
