; Script     Environment.ahk
; License:   MIT License
; Author:    Edison Hua (iseahound)
; Github:    https://github.com/iseahound/Environment.ahk
; Date       2023-11-04
; Version    1.3
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
;   SendMessage 0x1A, 0, "Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
;      - The above code will broadcast a message stating there has been a change of environment variables.
;      - Some programs have not implemented this message.
;      - v1.00 replaces this with a powershell command using asyncronous execution providing 10x speedup.
;   RefreshEnvironment()
;      - This function will update the environment variables within AutoHotkey.
;      - Command prompts launched by AutoHotkey inherit AutoHotkey's environment.
;   Any command prompts currently open will not have their environment variables changed.
;      - Please use the RefreshEnv.cmd batch script found at:
;        https://github.com/chocolatey-archive/chocolatey/blob/master/src/redirects/RefreshEnv.cmd

#Requires AutoHotkey v1.1.33+

Env_UserAdd(name, value, regType := "", location := "", top := False){
   value    := (value ~= "^\.(\.)?\\") ? GetFullPathName(value) : value
   location := (location == "")        ? "HKCU\Environment"     : location

   ; Check if key exists.
   RegRead registry, % location, % name
   if (registry) {
      Loop Parse, registry, % ";"
         if (A_LoopField == value)
            return -2
   registry := RTrim(registry, ";")
   if top
      value := value ";" registry 
   else
      value := registry ";" value
   }

   ; Create a new registry key.
   regType := (regType) ? regType : (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % regType, % location, % name, % value
   SettingChange()
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemAdd(name, value, regType := ""){
   return (A_IsAdmin) ? Env_UserAdd(name, value, regType, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserAddTop(name, value, regType := "", location := ""){
   return Env_UserAdd(name, value, regType, location, True)
}

Env_SystemAddTop(name, value, regType := ""){
   return (A_IsAdmin) ? Env_UserAddTop(name, value, regType, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserSub(name, value, regType := "", location := ""){
   value    := (value ~= "^\.(\.)?\\") ? GetFullPathName(value) : value
   location := (location == "")        ? "HKCU\Environment"     : location

   RegRead registry, % location, % name
   if ErrorLevel
      return -2

   Loop Parse, registry, % ";"
      if (A_LoopField != value) {
         output .= (A_Index > 1 && output != "") ? ";" : ""
         output .= A_LoopField
      }

   if (output == registry)
      return -2

   if (output != "") {
      regType := (regType) ? regType : (output ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
      RegWrite % regType, % location, % name, % output
   }
   else
      RegDelete % location, % name
   SettingChange()
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemSub(name, value, regType := ""){
   return (A_IsAdmin) ? Env_UserSub(name, value, regType, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserNew(name, value := "", regType := "", location := ""){
   value := (value ~= "^\.(\.)?\\") ? GetFullPathName(value) : value
   regType := (regType) ? regType : (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % regType, % (location == "") ? "HKCU\Environment" : location, % name, % value
   SettingChange()
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemNew(name, value := "", regType := ""){
   return (A_IsAdmin) ? Env_UserNew(name, value, regType, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

; Value does nothing except let me easily change between functions.
Env_UserDel(name, value := "", location := ""){
   RegDelete % (location == "") ? "HKCU\Environment" : location, % name
   SettingChange()
   RefreshEnvironment()
   return 0
}

Env_SystemDel(name, value := ""){
   return (A_IsAdmin) ? Env_UserDel(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserRead(name, value := "", location := ""){
   RegRead registry, % (location == "") ? "HKCU\Environment" : location, % name
   if (value != "") {
      Loop Parse, registry, % ";"
         if (A_LoopField = value)
            return A_LoopField
      return ; Value not found
   }
   return registry
}

Env_SystemRead(name, value := ""){
   return Env_UserRead(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
}

; Value does nothing except let me easily change between functions.
Env_UserSort(name, value := "", location := ""){
   RegRead registry, % (location == "") ? "HKCU\Environment" : location, % name
   Sort registry, % "D;"
   regType := (regType) ? regType : (registry ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % regType, % (location == "") ? "HKCU\Environment" : location, % name, % registry
   return (ErrorLevel) ? -1 : 0
}

Env_SystemSort(name, value := ""){
   return (A_IsAdmin) ? Env_UserSort(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

; Value does nothing except let me easily change between functions.
Env_UserRemoveDuplicates(name, value := "", location := ""){
   RegRead registry, % (location == "") ? "HKCU\Environment" : location, % name
   Sort registry, % "U D;"
   regType := (regType) ? regType : (registry ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite % regType, % (location == "") ? "HKCU\Environment" : location, % name, % registry
   return (ErrorLevel) ? -1 : 0
}

Env_SystemRemoveDuplicates(name, value := ""){
   return (A_IsAdmin) ? Env_UserRemoveDuplicates(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserBackup(fileName := "UserEnvironment.reg", location := ""){
   _cmd .= (A_Is64bitOS != A_PtrSize >> 3)    ? A_WinDir "\SysNative\cmd.exe"   : A_ComSpec
   _cmd .= " /K " Chr(0x22) "reg export " Chr(0x22)
   _cmd .= (location == "")                   ? "HKCU\Environment" : location
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
      Loop Reg, % A_LoopField, V
      {
         RegRead Value
         If (A_LoopRegType == "REG_EXPAND_SZ" && !ExpandEnvironmentStrings(Value))
            Continue
         If (A_LoopRegName = "PATH")
            Path .= Value . ";"
         Else If (A_LoopRegName = "PATHEXT")
            PathExt .= Value . ";"
         Else
            EnvSet % A_LoopRegName, % Value
      }
   }
   EnvSet PATH, % Path
   EnvSet PATHEXT, % PathExt
}

ExpandEnvironmentStrings(ByRef vInputString)
{
   ; get the required size for the expanded string
   vSizeNeeded := DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Int", 0, "Int", 0)
   If (vSizeNeeded == "" || vSizeNeeded <= 0)
      return False ; unable to get the size for the expanded string for some reason

   vByteSize := vSizeNeeded + 1
   VarSetCapacity(vTempValue, vByteSize*(A_IsUnicode?2:1))

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


; Source: https://gist.github.com/alphp/78fffb6d69e5bb863c76bbfc767effda
/*
$Script = @'
Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@

function Send-SettingChange {
  $HWND_BROADCAST = [IntPtr] 0xffff;
  $WM_SETTINGCHANGE = 0x1a;
  $result = [UIntPtr]::Zero

  [void] ([Win32.Nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 5000, [ref] $result))
}

Send-SettingChange;
'@

$ByteScript  = [System.Text.Encoding]::Unicode.GetBytes($Script)
[System.Convert]::ToBase64String($ByteScript)
*/

; To verify the encoded command, start a powershell terminal and paste the script above.
; 10x faster than SendMessage 0x1A, 0, "Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
SettingChange() {

   static _cmd := "
   ( LTrim
   QQBkAGQALQBUAHkAcABlACAALQBOAGEAbQBlAHMAcABhAGMAZQAgAFcAaQBuADMA
   MgAgAC0ATgBhAG0AZQAgAE4AYQB0AGkAdgBlAE0AZQB0AGgAbwBkAHMAIAAtAE0A
   ZQBtAGIAZQByAEQAZQBmAGkAbgBpAHQAaQBvAG4AIABAACIACgAgACAAWwBEAGwA
   bABJAG0AcABvAHIAdAAoACIAdQBzAGUAcgAzADIALgBkAGwAbAAiACwAIABTAGUA
   dABMAGEAcwB0AEUAcgByAG8AcgAgAD0AIAB0AHIAdQBlACwAIABDAGgAYQByAFMA
   ZQB0ACAAPQAgAEMAaABhAHIAUwBlAHQALgBBAHUAdABvACkAXQAKACAAIABwAHUA
   YgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABJAG4AdABQAHQA
   cgAgAFMAZQBuAGQATQBlAHMAcwBhAGcAZQBUAGkAbQBlAG8AdQB0ACgASQBuAHQA
   UAB0AHIAIABoAFcAbgBkACwAIAB1AGkAbgB0ACAATQBzAGcALAAgAFUASQBuAHQA
   UAB0AHIAIAB3AFAAYQByAGEAbQAsACAAcwB0AHIAaQBuAGcAIABsAFAAYQByAGEA
   bQAsACAAdQBpAG4AdAAgAGYAdQBGAGwAYQBnAHMALAAgAHUAaQBuAHQAIAB1AFQA
   aQBtAGUAbwB1AHQALAAgAG8AdQB0ACAAVQBJAG4AdABQAHQAcgAgAGwAcABkAHcA
   UgBlAHMAdQBsAHQAKQA7AAoAIgBAAAoACgBmAHUAbgBjAHQAaQBvAG4AIABTAGUA
   bgBkAC0AUwBlAHQAdABpAG4AZwBDAGgAYQBuAGcAZQAgAHsACgAgACAAJABIAFcA
   TgBEAF8AQgBSAE8AQQBEAEMAQQBTAFQAIAA9ACAAWwBJAG4AdABQAHQAcgBdACAA
   MAB4AGYAZgBmAGYAOwAKACAAIAAkAFcATQBfAFMARQBUAFQASQBOAEcAQwBIAEEA
   TgBHAEUAIAA9ACAAMAB4ADEAYQA7AAoAIAAgACQAcgBlAHMAdQBsAHQAIAA9ACAA
   WwBVAEkAbgB0AFAAdAByAF0AOgA6AFoAZQByAG8ACgAKACAAIABbAHYAbwBpAGQA
   XQAgACgAWwBXAGkAbgAzADIALgBOAGEAdABpAHYAZQBtAGUAdABoAG8AZABzAF0A
   OgA6AFMAZQBuAGQATQBlAHMAcwBhAGcAZQBUAGkAbQBlAG8AdQB0ACgAJABIAFcA
   TgBEAF8AQgBSAE8AQQBEAEMAQQBTAFQALAAgACQAVwBNAF8AUwBFAFQAVABJAE4A
   RwBDAEgAQQBOAEcARQAsACAAWwBVAEkAbgB0AFAAdAByAF0AOgA6AFoAZQByAG8A
   LAAgACIARQBuAHYAaQByAG8AbgBtAGUAbgB0ACIALAAgADIALAAgADUAMAAwADAA
   LAAgAFsAcgBlAGYAXQAgACQAcgBlAHMAdQBsAHQAKQApAAoAfQAKAAoAUwBlAG4A
   ZAAtAFMAZQB0AHQAaQBuAGcAQwBoAGEAbgBnAGUAOwA=
   )"
   Run % "powershell -NoProfile -EncodedCommand " _cmd,, Hide
}
