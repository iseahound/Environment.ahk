; Script:    Environment.ahk
; Author:    iseahound
; Date:      2017-02-11
;
; ExpandEnvironmentStrings(), RefreshEnvironment()   by NoobSawce + DavidBiesack (modified by BatRamboZPM)
;   https://autohotkey.com/board/topic/63312-reload-systemuser-environment-variables/
;
; RPath_Absolute()   Modified by Iggy_
;   https://autohotkey.com/board/topic/17922-func-relativepath-absolutepath/page-3



; SetEnvironmentVariable("TEST", "5555")                           ; Makes a new variable TEST with the value 5555
; SetEnvironmentVariable("TEST", "5555", "DEL")                    ; Deletes TEST
; SetEnvironmentVariable("PATH", "dir\to\someplace", "ADD")        ; Appends dir\to\someplace to PATH
; SetEnvironmentVariable("PATH", "dir\to\someplace", "SUB")        ; Removes every instance of  dir\to\someplace to PATH
; SetEnvironmentVariable("PATH", "C:\Windows", "EXIST")            ; Returns 1 if the value "C:\Windows" is in the variable PATH

SetEnvironmentVariable(name, value, option := "") {
   if (option == "")
      RegWrite, REG_SZ, HKEY_CURRENT_USER\Environment, % name, % value
   else if (option ~= "i)del(ete)?")
      RegDelete, HKEY_CURRENT_USER\Environment, % name
   else
   {
      RegRead, registry, HKEY_CURRENT_USER\Environment, % name

      if (option ~= "i)(add|append)") {
         registry .= (registry ~= "(;$|^$)") ? "" : ";"
         value := registry . value
         RegWrite, REG_SZ, HKEY_CURRENT_USER\Environment, % name, % value
      }
      else if (option ~= "i)(sub(tract)?|rem(ove)?)") {
         if ErrorLevel
            return
         Loop, parse, registry, `;
         {
            if (A_LoopField != value) {
               output .= (A_Index > 1 && output != "") ? ";" : ""
               output .= A_LoopField
            }
         }
         RegWrite, REG_SZ, HKEY_CURRENT_USER\Environment, % name, % output
      }
      else {
          if ErrorLevel
             return
          Loop, parse, registry, `;
          {
             if (A_LoopField == value)
                return 1
          }
      }
   }
   RefreshEnvironment()
   EnvUpdate
   SendMessage, 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   return 1
}

RefreshEnvironment()
{
	Path := ""
	PathExt := ""
	RegKeys := "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,HKCU\Environment"
	Loop, Parse, RegKeys, CSV
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
				EnvSet, %A_LoopRegName%, %Value%
		}
	}
	EnvSet, PATH, %Path%
	EnvSet, PATHEXT, %PathExt%
}

ExpandEnvironmentStrings(ByRef vInputString)
{
   ; get the required size for the expanded string
   vSizeNeeded := DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Int", 0, "Int", 0)
   If (vSizeNeeded == "" || vSizeNeeded <= 0)
      return False ; unable to get the size for the expanded string for some reason

   vByteSize := vSizeNeeded + 1
   If (A_PtrSize == 8) { ; Only 64-Bit builds of AHK_L will return 8, all others will be 4 or blank
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

; Modified: AbsolutePath
RPath_Absolute(AbsolutPath, RelativePath, s="\") {

    len := InStr(AbsolutPath, s, "", InStr(AbsolutPath, s . s) + 2) - 1   ;get server or drive string length
    pr := SubStr(AbsolutPath, 1, len)                                     ;get server or drive name
    AbsolutPath := SubStr(AbsolutPath, len + 1)                           ;remove server or drive from AbsolutPath
    If InStr(AbsolutPath, s, "", 0) = StrLen(AbsolutPath)                 ;remove last \ from AbsolutPath if any
        StringTrimRight, AbsolutPath, AbsolutPath, 1

    If InStr(RelativePath, s) = 1                                         ;when first char is \ go to AbsolutPath of server or drive
        AbsolutPath := "", RelativePath := SubStr(RelativePath, 2)        ;set AbsolutPath to nothing and remove one char from RelativePath
    Else If InStr(RelativePath,"." s) = 1                                 ;when first two chars are .\ add to current AbsolutPath directory
        RelativePath := SubStr(RelativePath, 3)                           ;remove two chars from RelativePath
    Else If InStr(RelativePath,".." s) = 1 {                              ;otherwise when first 3 char are ..\
        StringReplace, RelativePath, RelativePath, ..%s%, , UseErrorLevel     ;remove all ..\ from RelativePath
        Loop, %ErrorLevel%                                                    ;for all ..\
            AbsolutPath := SubStr(AbsolutPath, 1, InStr(AbsolutPath, s, "", 0) - 1)  ;remove one folder from AbsolutPath
    } Else                                                                ;relative path does not need any substitution
        pr := "", AbsolutPath := "", s := ""                              ;clear all variables to just return RelativePath

    Return, pr . AbsolutPath . s . RelativePath                           ;concatenate server + AbsolutPath + separator + RelativePath
}
