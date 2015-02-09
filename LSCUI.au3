#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Load Shedding CUI
#AutoIt3Wrapper_Res_Description=Checks the current load shedding status
#AutoIt3Wrapper_Res_Fileversion=1.0.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=2015 Ashfaak
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

	AutoIt Version: 	3.3.12.0
	Author:         	Ashfaak

	Script Function:	CUI: Checks Eskom's + COCT's Loadshedding status

#ce ----------------------------------------------------------------------------

#include <Array.au3>
#include <_LoadSheddingStatus.au3>
;~ #include <GetOpt.au3>

Local $ewnls_URL = "http://ewn.co.za/assets/loadshedding/assets/loadshedding/api/status"
Local $news24ls_URL = "http://loadshedding.news24.com/api/stage"
Local $eskomls_URL = "http://loadshedding.eskom.co.za/LoadShedding/GetStatus"
Local $durbanls_URL = "http://www.durban.gov.za/City_Services/electricity/Load_Shedding/Pages/default.aspx"
Local $coctls_URL = "http://www.capetown.gov.za/en/electricity/Pages/LoadShedding.aspx"
Local $joburgls_URL = "https://www.citypower.co.za/customers/pages/Load_Shedding.aspx"
Local $emd_URL = "https://twitter.com/Eskom_MediaDesk/"
Local $Source = 1 ; default = 1 CoCT
Local $ForceSource = 0
Local $noSplit = 0
Local $help = 0
Local $aSourceChange[2]
Local $allsources = 0
Local $aCMD[6] ;Number of command line input variables, see cmdlineParse()
Global $Verbose = 0

Local $scmdline = _ArrayToString($CmdLine, " ", 1)

If StringLen($scmdline) > 0 Then ; Handling commandline inputs


	$aCMD = cmdlineParse($scmdline)

	$Verbose = $aCMD[0]
	$Source = $aCMD[1]
	$ForceSource = $aCMD[2]
	$noSplit = $aCMD[3]
	$help = $aCMD[4]
	$allsources = $aCMD[5]

	If $help = 1 Then Help()

	If $Verbose = 1 Then
		ConsoleWrite("Verbose Mode" & @CRLF)
		If $noSplit = 1 Then ConsoleWrite("NoSplit" & @CRLF)
		Switch $Source
			Case 0
				ConsoleWrite("Source = Eskom" & @CRLF)
			Case 1
				ConsoleWrite("Source = Cape Town" & @CRLF)
			Case 2
				ConsoleWrite("Source = Durban" & @CRLF)
			Case 3
				ConsoleWrite("Source = Joburg" & @CRLF)
		EndSwitch
	EndIf
EndIf

If $allsources = 1 Then ; When 'all' is input

	Local $CTStatus = LSS_CT($ewnls_URL, $coctls_URL, $Verbose)
	ConsoleWrite("Cape Town = ")
	ConsoleWrite($CTStatus & @CRLF)

	Local $EskomStatus = LSS_Eskom($eskomls_URL, $Verbose)
	ConsoleWrite("Eskom = ")
	ConsoleWrite($EskomStatus & @CRLF)

	Local $DurbanStatus = LSS_Durban($durbanls_URL, $Verbose)
	ConsoleWrite("Durban = ")
	ConsoleWrite($DurbanStatus & @CRLF)

	Local $news24status = LSS_N24($news24ls_URL, $Verbose)
	ConsoleWrite("News24 = ")
	ConsoleWrite($news24status & @CRLF)

	Local $JoburgStatus = LSS_Joburg($joburgls_URL, $Verbose)
	ConsoleWrite("Joburg = ")
	ConsoleWrite($JoburgStatus & @CRLF)

	Exit
EndIf

Select ; Source output and fallback, convert to function
	Case $Source = 2 ; If source is Durban
		$out = LSS_Durban($durbanls_URL)
		If $out = -1 Then
			$Source = 1
			$ForceSource = 0 ;If it fails set back to default values
			If $Verbose = 1 Then ConsoleWrite("Source failed, fallback to default" & @CRLF)
		Else
			If $Verbose = 1 Then ConsoleWrite("Status Durban = ")
			ConsoleWrite($out)
			Exit
		EndIf
	Case $Source = 3 ; If source is Joburg
		$out = LSS_Joburg($joburgls_URL)
		If $out = -1 Then
			$Source = 1
			$ForceSource = 0 ;If it fails set back to default values
			If $Verbose = 1 Then ConsoleWrite("Source failed, fallback to default" & @CRLF)
		Else
			If $Verbose = 1 Then ConsoleWrite("Status Joburg = ")
			ConsoleWrite($out)
			Exit
		EndIf
EndSelect

Local $aLSStatus[2] ; move this into the previous selectionSection
$aLSStatus[0] = LSS_Eskom($eskomls_URL) ; shouldn't check eskom if forcesource=1
$aLSStatus[1] = LSS_CT($ewnls_URL, $coctls_URL)
;~ $aLSStatus[0] = 3 ; Simulation
;~ $aLSStatus[1] = -1 ; Simulation
If $Verbose = 1 Then ConsoleWrite("Status Eskom = " & $aLSStatus[0] & @CRLF & "Status Cape Town = " & $aLSStatus[1] & @CRLF)

$aSourceChange = SourceDigestChange($aLSStatus, $Source, $ForceSource)

If ($Source = 0 Or $noSplit = 1) And ($aSourceChange = "3A" Or $aSourceChange = "3B") Then ; Change to function
	If $Verbose Then ConsoleWrite("Output = ") ; Standardise this according to the others
	ConsoleWrite(3)
Else
	If $Verbose Then ConsoleWrite("Output = ")
	ConsoleWrite($aSourceChange)
EndIf


Func cmdlineParse($acmdline) ; Parses commandline inputs
	Local $Verbose = 0
	Local $ForceSource = 0
	Local $Source = 1
	Local $noSplit = 0
	Local $help = 0
	Local $allsources = 0
	Local $aOutput[6]

	If StringInStr($acmdline, "verbose") Then $Verbose = 1 ; [0]
	If StringInStr($acmdline, "nosplit") Then $noSplit = 1 ; [3]
	If StringInStr($acmdline, "?") Or StringInStr($acmdline, "help") Then $help = 1 ; [4]
	If StringInStr($acmdline, "all") Then $allsources = 1 ; [5]

	If StringInStr($acmdline, "durban") Then
		$Source = 2 ; [1]
		$ForceSource = 1 ; [2]
	EndIf
	If StringInStr($acmdline, "joburg") Then
		$Source = 3 ; [1]
		$ForceSource = 1 ; [2]
	EndIf
	If StringInStr($acmdline, "eskom") Then
		$Source = 0 ; [1]
		$ForceSource = 1 ; [2]
	EndIf
	If StringInStr($acmdline, "coct") Then
		$Source = 1 ; [1]
		$ForceSource = 1 ; [2]
	EndIf

	$aOutput[0] = $Verbose
	$aOutput[1] = $Source
	$aOutput[2] = $ForceSource
	$aOutput[3] = $noSplit
	$aOutput[4] = $help
	$aOutput[5] = $allsources

	Return $aOutput
EndFunc   ;==>cmdlineParse

Func Help()
	ConsoleWrite("Flags:" & @CRLF)
	ConsoleWrite("[default]	It will output the worst case scenario based on CoCT/Eskom" & @CRLF)
	ConsoleWrite("-eskom		Forces it to use Eskom as a source, will fallback to CoCT if broken" & @CRLF)
	ConsoleWrite("-coct		Forces it to use CoCT as a source, will fallback to Eskom if broken" & @CRLF)
	ConsoleWrite("-durban		Forces it to use Durban as a source, will fallback to default if broken" & @CRLF)
	ConsoleWrite("-joburg		Forces it to use Joburg as a source, will fallback to default if broken" & @CRLF)
	ConsoleWrite("-verbose	Verbose output" & @CRLF)
	ConsoleWrite("-nosplit	Outputs 3 instead of 3A or 3B" & @CRLF & @CRLF)
	ConsoleWrite("-all  	Reports status from all sources" & @CRLF & @CRLF)
	ConsoleWrite("Outputs:" & @CRLF)
	ConsoleWrite("-1		Error or no internet" & @CRLF)
	ConsoleWrite("0,1,2,3,3A,3B	The current load shedding status based on your settings above" & @CRLF)
	Exit
EndFunc   ;==>Help

Func Sanitise($_Source, $aLSStatus, $ForceSource = 0) ; Outputs Source and Status as used in SourceDigestChange()

	Local $aOutput[2]
	Local $ChangedSource = 0

	Select
		Case $_Source = 0 And $aLSStatus[0] = -1
			$aLSStatus[0] = $aLSStatus[1]
			$_Source = 1
			$ChangedSource = 1
			If $Verbose Then ConsoleWrite("Source failed, fallback to CoCT" & @CRLF)
		Case $_Source = 1 And $aLSStatus[1] = -1
			$aLSStatus[1] = $aLSStatus[0]; Switches to alternate source if the selected source fails
			$_Source = 0
			$ChangedSource = 1
			If $Verbose Then ConsoleWrite("Source failed, fallback to Eskom" & @CRLF)
	EndSelect

	If $ForceSource = 1 Then
		$aOutput[0] = $_Source
		$aOutput[1] = $aLSStatus

		If $aLSStatus[0] = 3 And $aOutput[0] = 0 And $ChangedSource = 1 Then
			$aLSStatus[0] = "3B" ;Worst case outputted if the only source is Eskom
			$aOutput[1] = $aLSStatus
;~       	 ConsoleWrite($aLSStatus[1] & $aLSStatus[0] & @CRLF)
		EndIf

		Return $aOutput
	EndIf

	Select ; Converts Eskom Source to say 3A/3B instead of just 3
		Case IsInt($aLSStatus[1]) = 0 And $aLSStatus[1] = "3A" And $aLSStatus[0] = 3
			$aLSStatus[0] = "3A"
		Case IsInt($aLSStatus[1]) = 0 And $aLSStatus[1] = "3B" And $aLSStatus[0] = 3
			$aLSStatus[0] = "3B"
		Case $aLSStatus[1] = 3 And $aLSStatus[0] = 3
			$aLSStatus[0] = "3B"
			$aLSStatus[1] = "3B" ;Sets to worst case scenario in case of failure
		Case $aLSStatus[0] = 3 And ($aLSStatus[1] = 0 Or $aLSStatus[1] = 1 Or $aLSStatus[1] = 2)
			$aLSStatus[0] = "3B"
			$_Source = 0
		Case ($aLSStatus[1] = 0 And ($aLSStatus[0] = 1 Or $aLSStatus[0] = 2)) Or ($aLSStatus[1] = 1 And $aLSStatus[0] = 2)
			$_Source = 0
	EndSelect
	$aOutput[0] = $_Source
	$aOutput[1] = $aLSStatus
	If $aOutput[1] = 3 And $aOutput[0] = 1 Then $aOutput[1] = "3B"

	Return $aOutput
EndFunc   ;==>Sanitise

Func SourceDigestChange($aLSStatus, $_Source = 1, $ForceSource = 0) ; Outputs array with preferred status
	Local $aOutput
	Local $2Source
	If $aLSStatus[0] = -1 And $aLSStatus[1] = -1 Then ; Use previous values if disconnected from the internet
		$aOutput = -1
		If $Verbose Then ConsoleWrite("All sources failed" & @CRLF)
		Return $aOutput
	EndIf

	$Sanitise = Sanitise($_Source, $aLSStatus, $ForceSource)

	$_Source = $Sanitise[0]
	$aLSStatus = $Sanitise[1]
	$aOutput = $aLSStatus[$_Source]
	Return $aOutput
EndFunc   ;==>SourceDigestChange




