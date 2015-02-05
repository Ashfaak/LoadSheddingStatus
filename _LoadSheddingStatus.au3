#include-once
; ------------------------------------------------------------------------------
; Title .........: Eskom Load Shedding Status Checker library for AutoIt v3
; AutoIt Version: 3.3.12++
; Language:       English
; Description:    Functions for checking load shedding status from various
;                 sources/municipalities

;===============================================================================
; Includes

; Global Vars
;~ $Verbose = 1

;~ Example of usage
;~ ConsoleWrite("Checking CoCT" & @CRLF)
;~ $coctstatus = LSS_CT("http://ewn.co.za/assets/loadshedding/assets/loadshedding/api/status", "http://www.capetown.gov.za/en/electricity/Pages/LoadShedding.aspx")
;~ ConsoleWrite("CoCT Status = " & $coctstatus & @CRLF)
;~ ConsoleWrite("Checking Durban" & @CRLF)
;~ $durbanstatus = LSS_Durban("http://www.durban.gov.za/City_Services/electricity/Load_Shedding/Pages/default.aspx")
;~ ConsoleWrite("Durban Status = " & $durbanstatus & @CRLF)
;~ ConsoleWrite("Checking Eskom" & @CRLF)
;~ $eskomstatus = LSS_Eskom("http://loadshedding.eskom.co.za/LoadShedding/GetStatus")
;~ ConsoleWrite("Eskom Status = " & $eskomstatus & @CRLF)
;~ ConsoleWrite("Checking Joburg" & @CRLF)
;~ $joburgstatus = LSS_Joburg("https://www.citypower.co.za/customers/pages/Load_Shedding.aspx")
;~ ConsoleWrite("Joburg Status = " & $joburgstatus & @CRLF)

Func LSS_Durban($durbanls_URL) ; Check loadshedding status according to Durban

;~ 	ClearIECache()
  
  Local $output

	Local $_htmlDurban1 = StringRegExpReplace(BinaryToString(InetRead($durbanls_URL), 19), '<[^>]*>', "")
	If $_htmlDurban1 = "" Then Return -1
	Local $_htmlDurban1a = StringRegExpReplace($_htmlDurban1, 'Â', "")
  If StringInStr(StringStripWS(StringMid($_htmlDurban1a,StringInStr($_htmlDurban1a, "STATUS") + 7, 10), 8),"INACTIVE") > 1 Then Return 0
  Local $_htmlDurban2 = StringInStr($_htmlDurban1a, "LOAD SHEDDING STAGE:")
	Local $_htmlDurban3 = StringStripWS(StringMid($_htmlDurban1a, $_htmlDurban2 + 20, 10), 8)
	Select
		Case StringInStr($_htmlDurban3, "N/A") > 0 Or StringInStr($_htmlDurban3, "NOTAPPL")
			$output = 0
		Case StringInStr($_htmlDurban3, "ONE") > 0 Or StringInStr($_htmlDurban3, "1") > 0
			$output = 1
		Case StringInStr($_htmlDurban3, "TWO") > 0 Or StringInStr($_htmlDurban3, "2") > 0
			$output = 2
		Case StringInStr($_htmlDurban3, "THREE") > 0 Or StringInStr($_htmlDurban3, "3") > 0
			$output = 3
		Case Else
			$output = -1
	EndSelect
	Return $output
EndFunc   ;==>LSStatus_Durban

Func LSS_CT($ewnls_URL, $coctls_URL) ; Check loadshedding status according to ewn + coct

;~ 	ClearIECache()
	;needs to consider other sources of data still
	Local $output

	Local $_htmlEwn = BinaryToString(InetRead($ewnls_URL), 19) ;Get data from EWN's LoadShedding page

	Select
		Case $_htmlEwn = "LOAD SHEDDING HAS BEEN SUSPENDED UNTIL FURTHER NOTICE" Or (StringLen($_htmlEwn) > 3 And StringInStr($_htmlEwn, "Stage") = 0)
			Return 0
		Case $_htmlEwn = 1 Or $_htmlEwn = 2 Or $_htmlEwn = "3A" Or $_htmlEwn = "3B"
			Return $_htmlEwn
		Case StringInStr($_htmlEwn, "1") > 0
			Return 1
		Case StringInStr($_htmlEwn, "2") > 0
			Return 2
		Case StringInStr($_htmlEwn, "3A") > 0
			Return "3A"
		Case StringInStr($_htmlEwn, "3B") > 0
			Return "3B"
		Case Else
			$output = -1
			Local $_htmlCoCT1 = StringRegExpReplace(BinaryToString(InetRead($coctls_URL), 19), '<[^>]*>', "")
			If $_htmlCoCT1 = "" Then Return $output
;~ 	$_htmlDurban1a = StringRegExpReplace($_htmlDurban1, 'Â', "")
			Local $_htmlCoCT2 = StringInStr($_htmlCoCT1, "CAPE TOWN IS CURRENTLY EXPERIENCING LOADSHEDDING")
			If $_htmlCoCT2 = 0 Then Local $_htmlCoCT2a = StringInStr($_htmlCoCT1, "LOAD SHEDDING HAS BEEN SUSPENDED UNTIL FURTHER NOTICE")
			Select
				Case $_htmlCoCT2 = 0 And $_htmlCoCT2a > 0
					Return 0
				Case $_htmlCoCT2 = 0 And $_htmlCoCT2a = 0
					Return $output
			EndSelect
			Local $_htmlCoCT3 = StringStripWS(StringMid($_htmlCoCT1, $_htmlCoCT2 + 53, 4), 8)
			Select
				Case StringInStr($_htmlCoCT3, "1") > 0
					Return 1
				Case StringInStr($_htmlCoCT3, "2") > 0
					Return 2
				Case StringInStr($_htmlCoCT3, "3A") > 0
					Return "3A"
				Case StringInStr($_htmlCoCT3, "3B") > 0
					Return "3B"
				Case Else
					Return $output
			EndSelect
	EndSelect
EndFunc   ;==>LSStatus_CT

Func LSS_Eskom($eskomls_URL) ; Check loadshedding status according to Eskom

;~ 	ClearIECache()

	Local $output

	Local $_htmlEskom = BinaryToString(InetRead($eskomls_URL), 19) ;Get data from Eskom's LoadShedding page

	Select
		Case $_htmlEskom > 0
			$output = $_htmlEskom - 1
		Case Else
			$output = -1
	EndSelect
	Return $output
EndFunc   ;==>LSStatus_Eskom

Func LSS_Joburg($joburgls_URL) ; Check loadshedding status according to Durban

;~ 	ClearIECache()
  
  Local $output

	Local $_htmlJoburg1 = StringRegExpReplace(BinaryToString(InetRead($joburgls_URL), 19), '<[^>]*>', "")
  	If $_htmlJoburg1 = "" Then Return -1
	Local $_htmlJoburg1a = StringRegExpReplace($_htmlJoburg1, 'â€‹|\&#.*?\;', "")
;~   If StringInStr(StringStripWS(StringMid($_htmlJoburg1a,StringInStr($_htmlJoburg1a, "STATUS") + 7, 10), 8),"INACTIVE") > 1 Then Return 0
  Local $_htmlJoburg2 = StringInStr($_htmlJoburg1a, "We are currently")
  Local $JoburgBlock = StringInStr($_htmlJoburg1a, "Block")
  If $JoburgBlock = 0 Or $JoburgBlock - $_htmlJoburg2 > 65 Then
      Local $StringLength = 60
  Else
      Local $StringLength = $JoburgBlock - $_htmlJoburg2 - 16
  EndIf
	Local $_htmlJoburg3 = StringStripWS(StringMid($_htmlJoburg1a, $_htmlJoburg2 + 16, $StringLength), 8)
	Select
		Case StringInStr($_htmlJoburg3, "Not") > 0
			$output = 0
		Case StringInStr($_htmlJoburg3, "ONE") > 0 Or StringInStr($_htmlJoburg3, "1") > 0
			$output = 1
		Case StringInStr($_htmlJoburg3, "TWO") > 0 Or StringInStr($_htmlJoburg3, "2") > 0
			$output = 2
		Case StringInStr($_htmlJoburg3, "THREE") > 0 Or StringInStr($_htmlJoburg3, "3") > 0
			$output = 3
		Case Else
			$output = -1
	EndSelect
	Return $output
EndFunc   ;==>LSStatus_Durban

;~ Func ClearIECache() ; As the name suggests. Used internally. Probably not necessary
;~ 	Local $_ClearID = "8"
;~ 	Run("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess " & $_ClearID)
;~ EndFunc   ;==>ClearIECache
