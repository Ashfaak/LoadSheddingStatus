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

;~ ConsoleWrite("Checking News24" & @CRLF)
;~ $news24status = LSS_N24("http://loadshedding.news24.com/api/stage")
;~ ConsoleWrite("News24 Status = " & $news24status & @CRLF)

Func LSS_Durban($durbanls_URL, $Verbose = 0) ; Check loadshedding status according to Durban
  
  Local $output

	Local $_htmlDurban1 = StringRegExpReplace(BinaryToString(InetRead($durbanls_URL), 19), '<[^>]*>', "")
	If $_htmlDurban1 = "" Then Return -1
	Local $_htmlDurban1a = StringRegExpReplace($_htmlDurban1, 'Â', "")
  If StringInStr(StringStripWS(StringMid($_htmlDurban1a,StringInStr($_htmlDurban1a, "STATUS") + 7, 10), 8),"INACTIVE") > 1 Then Return 0
  Local $_htmlDurban2 = StringInStr($_htmlDurban1a, "LOAD SHEDDING STAGE:")
	Local $_htmlDurban3 = StringStripWS(StringMid($_htmlDurban1a, $_htmlDurban2 + 20, 10), 8)
  
  If $Verbose Then ConsoleWrite("Durban Raw = " & $_htmlDurban3 & @CRLF)
  
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

Func LSS_CT($ewnls_URL, $coctls_URL, $Verbose = 0) ; Check loadshedding status according to ewn + coct
  
	Local $_htmlEwn = BinaryToString(InetRead($ewnls_URL), 19) ;Get data from EWN's LoadShedding page
  
  If $Verbose Then ConsoleWrite("Cape Town EWN Raw = " & $_htmlEwn & @CRLF)

	Select
		Case $_htmlEwn = "LOAD SHEDDING HAS BEEN SUSPENDED UNTIL FURTHER NOTICE" Or (StringLen($_htmlEwn) > 3 And StringInStr($_htmlEwn, "Stage") = 0)
			Return 0
		Case $_htmlEwn = 1 Or $_htmlEwn = 2 Or $_htmlEwn = "3A" Or $_htmlEwn = "3B"
			Return $_htmlEwn
		Case (StringInStr($_htmlEwn, "1") > 0) And (StringInStr($_htmlEwn, "-1") = 0)
			Return 1
		Case StringInStr($_htmlEwn, "2") > 0
			Return 2
		Case StringInStr($_htmlEwn, "3A") > 0
			Return "3A"
		Case StringInStr($_htmlEwn, "3B") > 0
			Return "3B"
		Case Else
			Local $_htmlCoCT1 = BinaryToString(InetRead($coctls_URL), 19)
      Local $_ClassID = StringInStr($_htmlCoCT1, "color:#FFFFFF; padding:10px; width:100%; text-align:center;  padding-left:20px; padding-right:20px")
      ; Must be a better way to do this
      Local $_htmlCoCT2 = StringTrimLeft($_htmlCoCT1,$_ClassID)
      Local $bracketEnd = StringInStr($_htmlCoCT2,">")
      Local $bracketStart = StringInStr($_htmlCoCT2,"</")
      Local $_htmlCoCT3 = StringMid($_htmlCoCT2,$bracketEnd + 1,$bracketStart - $bracketEnd - 1)
      
      If $Verbose Then ConsoleWrite("Cape Town Raw = " & $_htmlCoCT3 & @CRLF)
      
			Select
				Case (StringInStr($_htmlCoCT3, "1") > 0) And (StringInStr($_htmlCoCT3, "-1") = 0)
					Return 1
				Case StringInStr($_htmlCoCT3, "2") > 0
					Return 2
				Case StringInStr($_htmlCoCT3, "3A") > 0
					Return "3A"
				Case StringInStr($_htmlCoCT3, "3B") > 0
					Return "3B"
				Case Else
					Return -1
			EndSelect
	EndSelect
EndFunc   ;==>LSStatus_CT

Func LSS_Eskom($eskomls_URL, $Verbose = 0) ; Check loadshedding status according to Eskom ; Move news24 here after testing

	Local $output

	Local $_htmlEskom = BinaryToString(InetRead($eskomls_URL), 19) ;Get data from Eskom's LoadShedding page
  
  If $Verbose Then ConsoleWrite("Eskom Raw = " & $_htmlEskom & @CRLF)

	Select
		Case $_htmlEskom > 0
			$output = $_htmlEskom - 1
		Case Else
			$output = -1
	EndSelect
	Return $output
EndFunc   ;==>LSStatus_Eskom

Func LSS_Joburg($joburgls_URL, $Verbose = 0) ; Check loadshedding status according to Joburg
  
  Local $output

	Local $_htmlJoburg1 = BinaryToString(InetRead($joburgls_URL), 19)
  If $_htmlJoburg1 = "" Then Return -1
  Local $_ClassID = StringInStr($_htmlJoburg1, "ms-rteForeColor-2")
      ; Must be a better way to do this
  Local $_htmlJoburg2 = StringTrimLeft($_htmlJoburg1,$_ClassID)
  Local $bracketEnd = StringInStr($_htmlJoburg2,"<strong>")
  Local $bracketStart = StringInStr($_htmlJoburg2,"</")
  Local $_htmlJoburg3 = StringMid($_htmlJoburg2,$bracketEnd + 8,$bracketStart - $bracketEnd - 8)
  Local $_htmlJoburg3a = StringRegExpReplace($_htmlJoburg3, 'â€‹|\&#.*?\;', " ")
  
  If $Verbose Then ConsoleWrite("Joburg Raw = " & $_htmlJoburg3a & @CRLF)
  
	Select
		Case (StringInStr($_htmlJoburg3a, "Not") > 0) And (StringInStr($_htmlJoburg3, "Note") = 0)
			$output = 0
		Case StringInStr($_htmlJoburg3a, "ONE") > 0 Or StringInStr($_htmlJoburg3a, "1") > 0
			$output = 1
		Case StringInStr($_htmlJoburg3a, "TWO") > 0 Or StringInStr($_htmlJoburg3a, "2") > 0
			$output = 2
		Case StringInStr($_htmlJoburg3a, "THREE") > 0 Or StringInStr($_htmlJoburg3a, "3") > 0
			$output = 3
		Case Else
			$output = -1
	EndSelect
	Return $output
EndFunc   ;==>LSS_Joburg

Func LSS_N24($news24ls_URL, $Verbose = 0) ; Check loadshedding status according to News24

	Local $output

	Local $_htmlN24 = BinaryToString(InetRead($news24ls_URL), 19) ;Get data from Eskom's LoadShedding page
  
  If $Verbose Then ConsoleWrite("News24 Raw = " & $_htmlN24 & @CRLF)

Return $_htmlN24
EndFunc   ;==>LSS_N24

