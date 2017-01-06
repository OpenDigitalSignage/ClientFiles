#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=DS-Shutdown.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Homepage: http://www.mcmilk.de/projects/DS-Shutdown/
#AutoIt3Wrapper_Res_Description=Digital Signage Background Daemon - DS-Shutdown
#AutoIt3Wrapper_Res_Fileversion=0.1.0.0
#AutoIt3Wrapper_Res_ProductVersion=0.1.0.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2016 Tino Reichardt
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Res_Field=Productname|DS-Shutdown
#AutoIt3Wrapper_Res_Field=CompanyName|Tino Reichardt
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Run_After=mpress -q -r -s DS-Shutdown.exe
#AutoIt3Wrapper_Run_After=signtool sign /v /tr http://time.certum.pl/ /f DS-Shutdown.p12 /p pass DS-Shutdown.exe
#AutoIt3Wrapper_Run_After=del DS-Shutdown_stripped.au3
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /sv /rm /mi 6
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs
	Copyright © 2016 Tino Reichardt

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License Version 2, as
	published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
#ce

; ctime: /TR 2016-08-22
; mtime: /TR 2016-08-24

#include <Array.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <Misc.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include <WinAPIFiles.au3>

; Titel, Name und so weiter definieren...
Global Const $sTitle = "Digital Signage - DS-Shutdown"
Global Const $sVersion = "0.1"
Global Const $sAppName = "DS-Shutdown"
Global Const $sIniFile = @AppDataDir & "\" & $sAppName & "\" & $sAppName & ".ini"

; INI Values
Global $sURL = "http://dsbserver/dsb/status.txt"
Global $sAskForShutdown = 1
Global $sCheckInterval = 1

Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 1 + 2 + 4)
Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Opt("WinTitleMatchMode", 2)

; main gui
Global $hGUI

; Controls, Buttons, Trayitems
Global $idCheckBox, $idURL, $idStatus, $idCheckInterval, $idAskForShutdown
Global $btnUpdate, $btnOkay, $btnCancel, $btnSave, $btnInfo
Global $aTrayItems[1] = [0]
Global $tidSettings, $tidInfo, $tidExit

#include "DS-Shutdown_Lang.au3"

Func ReadConfiguration()
	If Not FileExists(@AppDataDir & "\" & $sAppName) Then
		DirCreate(@AppDataDir & "\" & $sAppName)
	EndIf

	Local $sSection = "Options"
	$sURL = IniRead($sIniFile, $sSection, "URL", $sURL)
	$sAskForShutdown = IniRead($sIniFile, $sSection, "AskForShutdown", $sAskForShutdown)
	$sCheckInterval = IniRead($sIniFile, $sSection, "CheckInterval", $sCheckInterval)

	If $sCheckInterval < 3 Then $sCheckInterval = 3

	; run CheckStatus() each $sCheckInterval minutes...
	AdlibUnRegister("CheckStatus")
	AdlibRegister("CheckStatus", 1000 * 60 * $sCheckInterval)

	; just write an cleanup version...
	WriteConfiguration()
EndFunc   ;==>ReadConfiguration

Func WriteConfiguration()
	Local $sSection = "Options"
	IniReadSection($sIniFile, $sSection)
	IniWrite($sIniFile, $sSection, "URL", $sURL)
	IniWrite($sIniFile, $sSection, "AskForShutdown", $sAskForShutdown)
	IniWrite($sIniFile, $sSection, "CheckInterval", $sCheckInterval)
EndFunc   ;==>WriteConfiguration

; #FUNCTION# ====================================================================================================================
; Name ..........: ShowSettings
; Description ...: show gui
; Syntax ........: ShowSettings()
; Author ........: Tino Reichardt
; Modified ......: 22.08.2016
; ===============================================================================================================================
Func ShowSettings()
	DisableTrayMenu()
	GUISetState(@SW_SHOW, $hGUI)
EndFunc   ;==>ShowSettings

; #FUNCTION# ====================================================================================================================
; Name ..........: ShowInfo
; Description ...: show info
; Syntax ........: ShowInfo()
; Author ........: Tino Reichardt
; Modified ......: 22.08.2016
; ===============================================================================================================================
Func ShowInfo()
	Local $sText = ""
	$sText &= "Copyright 2016, Tino Reichardt" & @CRLF & @CRLF
	$sText &= "Version: " & $sVersion & " (" & FileGetVersion(@ScriptFullPath) & ") " & @CRLF
	MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), $sTitle, $sText)
EndFunc   ;==>ShowInfo

; #FUNCTION# ====================================================================================================================
; Name ..........: InitGui
; Description ...: init the main gui and it's controls
; Syntax ........: InitGui()
; Author ........: Tino Reichardt
; Modified ......: 22.08.2016
; ===============================================================================================================================
Func InitGui()
	$hGUI = GUICreate($sTitle, 552, 305, 341, 297, $WS_CAPTION)

	GUICtrlCreateGroup("", 8, 0, 537, 265)
	GUICtrlCreateLabel(Msg($mLabels[1]), 16, 15, 81, 17)
	GUICtrlCreateLabel(Msg($mLabels[2]), 16, 203, 63, 17)
	$idAskForShutdown = GUICtrlCreateCheckbox(Msg($mMessages[1]), 16, 238, 358, 17)
	$idURL = GUICtrlCreateInput($sURL, 80, 200, 385, 21)
	$idCheckInterval = GUICtrlCreateInput($sCheckInterval, 472, 200, 65, 21, BitOR($ES_CENTER, $ES_NUMBER))
	GUICtrlCreateUpdown($idCheckInterval)
	GUICtrlSetLimit($idCheckInterval, 999, 3)
	$idStatus = GUICtrlCreateEdit("", 16, 32, 521, 161, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN))
	$btnUpdate = GUICtrlCreateButton(Msg($mButtons[5]), 392, 232, 147, 25)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$btnOkay = GUICtrlCreateButton(Msg($mButtons[1]), 232, 272, 99, 25)
	$btnCancel = GUICtrlCreateButton(Msg($mButtons[2]), 338, 272, 99, 25)
	$btnSave = GUICtrlCreateButton(Msg($mButtons[3]), 444, 272, 99, 25)
	$btnInfo = GUICtrlCreateButton(Msg($mButtons[4]), 8, 272, 99, 25)
	EnableTrayMenu()
EndFunc   ;==>InitGui

Func DisableTrayMenu()
	For $i = 1 To $aTrayItems[0]
		TrayItemDelete($aTrayItems[$i])
	Next
	ReDim $aTrayItems[1]
	$aTrayItems[0] = 0
EndFunc   ;==>DisableTrayMenu

Func EnableTrayMenu()
	Local $tid

	DisableTrayMenu()

	$tidSettings = TrayCreateItem(Msg($mTraymenu[1]))
	_ArrayAdd($aTrayItems, $tidSettings)
	$tid = TrayCreateItem("")
	_ArrayAdd($aTrayItems, $tid)
	$tidInfo = TrayCreateItem(Msg($mTraymenu[2]))
	_ArrayAdd($aTrayItems, $tidInfo)
	$tidExit = TrayCreateItem(Msg($mTraymenu[3]))
	_ArrayAdd($aTrayItems, $tidExit)

	; save id count to [0]
	$aTrayItems[0] = UBound($aTrayItems) - 1
	TraySetState($TRAY_ICONSTATE_SHOW)
EndFunc   ;==>EnableTrayMenu

; #FUNCTION# ====================================================================================================================
; Name ..........: GetWMIServiceObject
; Description ...: Holt sich Infos zu den aktuell gesteckten USB Sticks ... das dauert eine Weile... schnell ist anders!!
; Syntax ........: GetWMIServiceObject()
; Author ........: Tino Reichardt
; Modified ......: 22.08.2016
; ===============================================================================================================================
Func GetWMIServiceObject()
	Local $objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!\\.\root\CIMV2")
	If Not IsObj($objWMIService) Then Return 0
	Return $objWMIService
EndFunc   ;==>GetWMIServiceObject

; #FUNCTION# ====================================================================================================================
; Name ..........: GetProcessorInfo
; Description ...: CPU Namen und Anzahl Kerne (logische, inkl. HT) als String ermitteln
; Syntax ........: GetProcessorInfo()
; Author ........: Tino Reichardt
; Modified ......: 01.04.2015
; ===============================================================================================================================
Func GetProcessorInfo()
	Local $sDefault = "Unknown CPU, 1"

	Local $objWMIService = GetWMIServiceObject()
	If $objWMIService = 0 Then Return $sDefault

	Local $colItems = $objWMIService.ExecQuery("SELECT Name,NumberOfLogicalProcessors FROM Win32_Processor")
	If Not IsObj($colItems) Then Return $sDefault

	Local $objItem
	For $objItem In $colItems
		Local $s = StringStripWS($objItem.Name, 1)
		$s = StringReplace($s, ";", "") ; nehmen wir selber als seperator...
		Return $s & "; " & $objItem.NumberOfLogicalProcessors
	Next
EndFunc   ;==>GetProcessorInfo

; #FUNCTION# ====================================================================================================================
; Name ..........: CheckStatus
; Description ...: aktuellen status ermitteln
; Syntax ........: CheckStatus()
; Author ........: Tino Reichardt
; Modified ......: 04.03.2015
; ===============================================================================================================================
Func CheckStatus()
	; DS-Shutdown/0.1 (nutzer; VBOX; 0407; WIN_XP; X86; Intel Pentium III Xeon-Prozessor; 1)
	HttpSetUserAgent($sAppName & "/" & $sVersion & " (" & @UserName & "; " & @ComputerName & "; " & @OSLang & "; " & @OSVersion & "; " & @OSArch & "; " & GetProcessorInfo() & ")")
	; http://192.168.100.254/dsb/status.txt
	Local $sStatus = BinaryToString(InetRead(GUICtrlRead($idURL), $INET_FORCERELOAD + $INET_FORCEBYPASS))
	If @error <> 0 Then
		$sStatus = @error
	EndIf

	$sStatus = StringReplace($sStatus, "\n", "\r\n")

	;WinMinimizeAll()
	; msgbox(yes / no)
	; Shutdown($SD_FORCE  + $SD_POWERDOWN)
	GUICtrlSetData($idStatus, $sStatus)
EndFunc   ;==>CheckStatus

; Main entry point
; wenn es schon läuft, nix weiter machen...
If _Singleton($sTitle, 1) = 0 Then
	MsgBox($MB_OK, $sTitle, Msg($mMessages[2]))
	Exit
EndIf

InitLanguage()
ReadConfiguration()
InitGui()

While 1
	; Traymenu
	Local $iTrayMsg = TrayGetMsg()
	Switch $iTrayMsg
		Case $tidSettings
			ShowSettings()

		Case $tidInfo
			ShowInfo()

		Case $tidExit
			Exit
	EndSwitch

	; Gui
	Local $iMsg = GUIGetMsg()

	; ignore some messages
	If $iMsg = $GUI_EVENT_NONE Then ContinueLoop
	If $iMsg = $GUI_EVENT_MOUSEMOVE Then ContinueLoop
	If $iMsg = $GUI_EVENT_PRIMARYUP Then ContinueLoop
	If $iMsg = $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
	If $iMsg = $GUI_EVENT_SECONDARYUP Then ContinueLoop
	If $iMsg = $GUI_EVENT_SECONDARYDOWN Then ContinueLoop
	; ConsoleWrite("$iMsg =" & $iMsg & @CRLF)

	Switch $iMsg
		Case $btnInfo
			ShowInfo()

		Case $btnUpdate
			GUICtrlSetState($btnUpdate, $GUI_DISABLE)
			CheckStatus()
			GUICtrlSetState($btnUpdate, $GUI_ENABLE)

		Case $btnOkay
			GUISetState(@SW_HIDE, $hGUI)
			WriteConfiguration()
			EnableTrayMenu()

		Case $btnSave
			WriteConfiguration()
			GUICtrlSetState($btnSave, $GUI_DISABLE)

		Case $btnCancel, $GUI_EVENT_CLOSE
			EnableTrayMenu()
			GUISetState(@SW_HIDE, $hGUI)
	EndSwitch
WEnd
