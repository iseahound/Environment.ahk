; Script:    Environment.ahk
; Author:    iseahound
; License:   MIT License
; Target:    AutoHotkey v1
; Version:   2017-02-11
; Updated:   2019-12-06
;
; ExpandEnvironmentStrings(), RefreshEnvironment()   by NoobSawce + DavidBiesack (modified by BatRamboZPM)
;   https://autohotkey.com/board/topic/63312-reload-systemuser-environment-variables/
;
; Global Error Values
;   0 - Success.
;  -1 - Error when writing value to registry.
;  -2 - Value already added or value already deleted.
;  -3 - Need to Run As Administrator.
;
; Notes
;   SendMessage 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
;      - The above code will broadcast a message stating there has been a change of environment variables.
;      - Some programs have not implemented this message.
;   RefreshEnvironment()
;      - This function will update the environment variables within AutoHotkey.
;      - Command prompts launched by AutoHotkey inherit AutoHotkey's environment.
;   Any command prompts currently open will not have their environment variables changed.
;      - Please use the RefreshEnv.cmd batch script found at:
;        https://github.com/chocolatey-archive/chocolatey/blob/master/src/redirects/RefreshEnv.cmd

Env_UserAdd(name, value, type := "", location := ""){
   value    := (value ~= "^\.\.\\") ? GetFullPathName(value)          : value
   location := (location == "")     ? "HKEY_CURRENT_USER\Environment" : location

   RegRead registry, % location, % name
   if (!ErrorLevel) {
      Loop Parse, registry, `;
      {
         if (A_LoopField == value)
            return -2
      }
      registry .= (registry ~= "(;$|^$)") ? "" : ";"
      value := registry . value
   }
   type := (type) ? type : (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % type , % location, % name, % value
   SendMessage 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemAdd(name, value, type := ""){
   return (A_IsAdmin) ? Env_UserAdd(name, value, type, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserSub(name, value, type := "", location := ""){
   value    := (value ~= "^\.\.\\") ? GetFullPathName(value)          : value
   location := (location == "")     ? "HKEY_CURRENT_USER\Environment" : location

   RegRead registry, % location, % name
   if ErrorLevel
      return -2

   Loop Parse, registry, `;
   {
      if (A_LoopField != value) {
         output .= (A_Index > 1 && output != "") ? ";" : ""
         output .= A_LoopField
      }
   }

   if (output != "") {
      type := (type) ? type : (output ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
      RegWrite % type , % location, % name, % output
   }
   else
      RegDelete % location, % name
   SendMessage 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemSub(name, value, type := ""){
   return (A_IsAdmin) ? Env_UserSub(name, value, type, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserNew(name, value := "", type := "", location := ""){
   type := (type) ? type : (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % value
   SendMessage 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemNew(name, value := "", type := ""){
   return (A_IsAdmin) ? Env_UserNew(name, value, type, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

; Value does nothing except let me easily change between functions.
Env_UserDel(name, value := "", location := ""){
   RegDelete % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   SendMessage 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return 0
}

Env_SystemDel(name, value := ""){
   return (A_IsAdmin) ? Env_UserDel(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserRead(name, value := "", location := ""){
   RegRead registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   if (value) {
      Loop Parse, registry, `;
      {
         if (A_LoopField = value) {
            return A_LoopField
         }
      }
      return ; Value not found
   }
   return registry
}

Env_SystemRead(name, value := ""){
   return Env_UserRead(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
}

; Value does nothing except let me easily change between functions.
Env_UserSort(name, value := "", location := ""){
   RegRead registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   Sort registry, D`;
   type := (type) ? type : (registry ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % registry
   return (ErrorLevel) ? -1 : 0
}

Env_SystemSort(name, value := ""){
   return (A_IsAdmin) ? Env_UserSort(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

; Value does nothing except let me easily change between functions.
Env_UserRemoveDuplicates(name, value := "", location := ""){
   RegRead registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   Sort registry, U D`;
   type := (type) ? type : (registry ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % registry
   return (ErrorLevel) ? -1 : 0
}

Env_SystemRemoveDuplicates(name, value := ""){
   return (A_IsAdmin) ? Env_UserRemoveDuplicates(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserBackup(fileName := "UserEnvironment.reg", location := ""){
   _cmd .= (A_Is64bitOS <> A_PtrSize >> 3)    ? A_WinDir "\SysNative\cmd.exe"   : ComSpec
   _cmd .= " /K " Chr(0x22) "reg export " Chr(0x22)
   _cmd .= (location == "")                   ? "HKEY_CURRENT_USER\Environment" : location
   _cmd .= Chr(0x22) " " Chr(0x22)
   _cmd .= fileName
   _cmd .= Chr(0x22) . Chr(0x22) . " && pause && exit"
   try RunWait % _cmd
   catch
      return "FAIL"
   return "SUCCESS"
}

Env_SystemBackup(fileName := "SystemEnvironment.reg"){
   return Env_UserBackup(fileName, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
}

Env_UserRestore(fileName := "UserEnvironment.reg"){
   try RunWait % fileName
   catch
      return "FAIL"
   return "SUCCESS"
}

Env_SystemRestore(fileName := "SystemEnvironment.reg"){
   try RunWait % fileName
   catch
      return "FAIL"
   return "SUCCESS"
}


RefreshEnvironment()
{
   Path := ""
   PathExt := ""
   RegKeys := "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,HKCU\Environment"
   Loop Parse, RegKeys, CSV
   {
      Loop, Reg, %A_LoopField%, V
      {
         RegRead, Value
         If (A_LoopRegType == "REG_EXPAND_SZ" && !ExpandEnvironmentStrings(Value))
            Continue
         If (A_LoopRegName = "PATH")
            Path .= Value . ";"
         Else If (A_LoopRegName = "PATHEXT")
            PathExt .= Value . ";"
         Else
            EnvSet %A_LoopRegName%, %Value%
      }
   }
   EnvSet PATH, %Path%
   EnvSet PATHEXT, %PathExt%
}

ExpandEnvironmentStrings(ByRef vInputString)
{
   ; get the required size for the expanded string
   vSizeNeeded := DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Int", 0, "Int", 0)
   If (vSizeNeeded == "" || vSizeNeeded <= 0)
      return False ; unable to get the size for the expanded string for some reason

   vByteSize := vSizeNeeded + 1
   If (A_IsUnicode) { ; Only 64-Bit builds of AHK_L will return 8, all others will be 4 or blank
      vByteSize *= 2 ; need to expand to wide character sizes
   }
   VarSetCapacity(vTempValue, vByteSize, 0)

   ; attempt to expand the environment string
   If (!DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Str", vTempValue, "Int", vSizeNeeded))
      return False ; unable to expand the environment string
   vInputString := vTempValue

   ; return success
   Return True
}

GetFullPathName(path) {
    cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    VarSetCapacity(buf, cc*(A_IsUnicode?2:1))
    DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
    return buf
}
