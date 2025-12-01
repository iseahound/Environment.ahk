; Script     Environment.ahk
; License:   MIT License
; Author:    Edison Hua (iseahound)
; Github:    https://github.com/iseahound/Environment.ahk
; Date       2025-12-01
; Version    2.1
;
; ExpandEnvironmentStrings(), RefreshEnvironment()   by NoobSawce + DavidBiesack (modified by BatRamboZPM)
;   https://www.autohotkey.com/board/topic/63312-reload-systemuser-environment-variables/
;
; Global Error Values
;   0 - Value already added or value already deleted. Also means the filepath does not exist.
;   1 - Success.
;
; Notes
;   SendMessage 0x1A, 0, "Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
;      - The above code will broadcast a message stating there has been a change of environment variables.
;      - Some programs have not implemented this message. You may need to restart the program.
;   RefreshEnvironment()
;      - This function will update the environment variables within AutoHotkey.
;      - Command prompts launched by AutoHotkey inherit AutoHotkey's environment.
;   Any terminals currently open will NOT have their environment variables updated.
;      - Please use the RefreshEnv.cmd batch script found at:
;        https://github.com/chocolatey-archive/chocolatey/blob/master/src/redirects/RefreshEnv.cmd

#Requires AutoHotkey v2.0-beta.3+

Env_UserAddFirst(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, True, 0)
Env_UserAddLast(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, True, 1)
Env_UserAddSort(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, True, 2)
Env_UserAddUnique(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, True, 3)
Env_UserAddFirstUnblock(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, True, 0))
Env_UserAddLastUnblock(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, True, 1))
Env_UserAddSortUnblock(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, True, 2))
Env_UserAddUniqueUnblock(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, True, 3))
Env_UserAddFirstFast(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, False, 0)
Env_UserAddLastFast(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, False, 1)
Env_UserAddSortFast(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, False, 2)
Env_UserAddUniqueFast(name, value, type?, key?) => Env_UserAdd(name, value, type?, key?, False, 3)
Env_UserAddFirstUnblockFast(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, False, 0))
Env_UserAddLastUnblockFast(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, False, 1))
Env_UserAddSortUnblockFast(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, False, 2))
Env_UserAddUniqueUnblockFast(name, value, type?, key?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, key?, False, 3))
Env_UserSubFast(name, value, type?, key?) => Env_UserSub(name, value, type?, key?, False)
Env_UserRemove(name, value, type?, key?) => Env_UserSub(name, value, type?, key?)
Env_UserRemoveFast(name, value, type?, key?) => Env_UserSub(name, value, type?, key?, False)
Env_UserTempFirst(name, value, type?, key?) => Env_UserTemp(name, value, type?, key?, True, 0)
Env_UserTempLast(name, value, type?, key?) => Env_UserTemp(name, value, type?, key?, True, 1)
Env_UserTempFirstUnblock(name, value, type?, key?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, key?, True, 0))
Env_UserTempLastUnblock(name, value, type?, key?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, key?, True, 1))
Env_UserTempFirstFast(name, value, type?, key?) => Env_UserTemp(name, value, type?, key?, False, 0)
Env_UserTempLastFast(name, value, type?, key?) => Env_UserTemp(name, value, type?, key?, False, 1)
Env_UserTempFirstUnblockFast(name, value, type?, key?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, key?, False, 0))
Env_UserTempLastUnblockFast(name, value, type?, key?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, key?, False, 1))

Env_SystemAdd(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
Env_SystemAddFirst(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0)
Env_SystemAddLast(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1)
Env_SystemAddSort(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 2)
Env_SystemAddUnique(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 3)
Env_SystemAddFirstUnblock(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0))
Env_SystemAddLastUnblock(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1))
Env_SystemAddSortUnblock(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 2))
Env_SystemAddUniqueUnblock(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 3))
Env_SystemAddFirstFast(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 0)
Env_SystemAddLastFast(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1)
Env_SystemAddSortFast(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 2)
Env_SystemAddUniqueFast(name, value, type?) => Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 3)
Env_SystemAddFirstUnblockFast(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session\Manager\Environment", False, 0))
Env_SystemAddLastUnblockFast(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1))
Env_SystemAddSortUnblockFast(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 2))
Env_SystemAddUniqueUnblockFast(name, value, type?) => (Env_Unblock(value), Env_UserAdd(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 3))
Env_SystemSub(name, value, type?) => Env_UserSub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True)
Env_SystemSubFast(name, value, type?) => Env_UserSub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False)
Env_SystemRemove(name, value, type?) => Env_UserSub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True)
Env_SystemRemoveFast(name, value, type?) => Env_UserSub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False)
Env_SystemTemp(name, value, type?) => Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0)
Env_SystemTempFirst(name, value, type?) => Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0)
Env_SystemTempLast(name, value, type?) => Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1)
Env_SystemTempFirstUnblock(name, value, type?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0))
Env_SystemTempLastUnblock(name, value, type?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1))
Env_SystemTempFirstFast(name, value, type?) => Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 0)
Env_SystemTempLastFast(name, value, type?) => Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1)
Env_SystemTempFirstUnblockFast(name, value, type?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 0))
Env_SystemTempLastUnblockFast(name, value, type?) => (Env_Unblock(value), Env_UserTemp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1))
Env_SystemNew(name, value?, type?) => Env_UserNew(name, value?, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
Env_SystemDel(name, value?) => Env_UserDel(name, value?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
Env_SystemRead(name, value?) => Env_UserRead(name, value?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
Env_SystemSort(name) => Env_UserSort(name, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
Env_SystemUnique(name) => Env_UserUnique(name, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
Env_SystemBackup(filepath := "SystemEnvironment.reg") => Env_UserBackup(filepath, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
Env_SystemRestore(filepath := "SystemEnvironment.reg") => Env_UserRestore(filepath)

Env_UserAdd(name, value, type := "", key := "HKCU\Environment", broadcast := true, pos := 0) {
   (value ~= "^\.(\.)?\\") && value := Env_GetFullPathName(value)

   ; Check if the registry key exists.
   try reg := RegRead(key, name)
   if IsSet(reg) {
      Loop Parse, reg, ";"
         if (A_LoopField == value)
            return 0

      reg := Trim(reg, ";")
      value := (pos = 0) ? value ";" reg
         :     (pos = 1) ? reg ";" value
         :     (pos = 2) ? Sort(reg ";" value, "D;") 
         :                 Sort(reg ";" value, "U D;")
   }

   ; Create a new registry key.
   (type) || type := (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite value, type, key, name

   if (broadcast) {
      Env_SettingChange()
      Env_RefreshEnvironment()
   }
   return 1
}

Env_UserSub(name, value, type := "", key := "HKCU\Environment", broadcast := True) {
   (value ~= "^\.(\.)?\\") && value := Env_GetFullPathName(value)

   ; Registry key may be deleted.
   try reg := RegRead(key, name)
   catch
      return 0

   ; Can't use RegEx because of special characters.
   out := ""
   Loop Parse, reg, ";"
      if (A_LoopField != value) {
         out .= (A_Index > 1 && out != "") ? ";" : ""
         out .= A_LoopField
      }

   if (out = reg)
      return 0

   if (out != "") {
      (type) || type := (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
      RegWrite out, type, key, name
   }
   else
      RegDelete key, name

   if (broadcast) {
      Env_SettingChange()
      Env_RefreshEnvironment()
   }
   return 1
}

Env_UserTemp(name, value, type := "", key := "HKCU\Environment", broadcast := True, pos := 0) {
   if !DirExist(value)
      return 0

   Env_UserAdd(name, value, type, key, broadcast, pos)
   OnExit (*) => (Env_UserSub(name, value, type, key, broadcast), 0)
}

Env_UserNew(name, value := "", type := "", key := "HKCU\Environment", broadcast := True) {
   (value ~= "^\.(\.)?\\") && value := Env_GetFullPathName(value)
   (type) || type := (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite value, type, key, name
   if (broadcast) {
      Env_SettingChange()
      Env_RefreshEnvironment()
   }
   return 1
}

; Value does nothing except let me easily change between functions.
Env_UserDel(name, value := "", key := "HKCU\Environment", broadcast := True) {
   RegDelete key, name
   if (broadcast) {
      Env_SettingChange()
      Env_RefreshEnvironment()
   }
   return 1
}

Env_UserRead(name, value := "", key := "HKCU\Environment") {
   reg := RegRead(key, name)
   if (value != "") {
      Loop Parse, reg, ";"
         if (A_LoopField = value)
            return A_LoopField
      return "" ; Value not found
   }
   return reg
}

Env_UserSort(name, key := "HKCU\Environment") {
   reg := RegRead(key, name)
   reg := Sort(reg, "D;")
   type := (reg ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite reg, type, key, name
   return 1
}

Env_UserUnique(name, key := "HKCU\Environment") {
   reg := RegRead(key, name)
   reg := Sort(reg, "U D;")
   type := (reg ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite reg, type, key, name
   return 1
}

Env_UserBackup(filepath := "UserEnvironment.reg", key := "HKCU\Environment") {
   _cmd := (A_Is64bitOS != A_PtrSize >> 3) ? A_WinDir "\SysNative\cmd.exe" : A_ComSpec
   _cmd .= ' /K "reg export "' key '" "' filepath '" && pause && exit'
   try RunWait _cmd
   catch
      return "FAIL"
   return "SUCCESS"
}

Env_UserRestore(filepath := "UserEnvironment.reg") {
   try RunWait filepath
   catch
      return "FAIL"
   return "SUCCESS"
}

Env_RefreshEnvironment() {
   Path := ""
   PathExt := ""
   Loop Parse, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,HKCU\Environment", "CSV"
   {
      Loop Reg, A_LoopField
      {
         value := RegRead()
         if (A_LoopRegType == "REG_EXPAND_SZ")
            value := Env_ExpandEnvironmentStrings(value)

         if (A_LoopRegName = "PATH")
            Path .= value . ";"
         else if (A_LoopRegName = "PATHEXT")
            PathExt .= value . ";"
         else
            EnvSet A_LoopRegName, value
      }
   }
   EnvSet "PATH", Path
   EnvSet "PATHEXT", PathExt
}

Env_ExpandEnvironmentStrings(str) {
   length := 1 + DllCall("ExpandEnvironmentStrings", "str", str, "ptr", 0, "int", 0)
   VarSetStrCapacity(&expanded_str, length)
   DllCall("ExpandEnvironmentStrings", "str", str, "str", expanded_str, "int", length)
   return expanded_str
}

Env_GetFullPathName(path) {
   cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
   VarSetStrCapacity(&buf, cc)
   DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
   return buf
}

Env_SettingChange() {
   SendMessage 0x1A, 0, StrPtr("Environment"),, "ahk_id" 0xFFFF ; 0x1A is WM_SETTINGCHANGE
}

Env_Unblock(filepath) {
   Loop Files filepath "\*", 'FR'
      if FileExist(A_LoopFileFullPath ":Zone.Identifier:$DATA")
         FileDelete A_LoopFileFullPath ":Zone.Identifier:$DATA"
}