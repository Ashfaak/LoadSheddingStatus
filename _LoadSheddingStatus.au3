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
;~ $coctstatus = LSS_CT("http://ewn.co.za/assets/loadshedding/assets/loadshedding/api/status", "http://www.capetown.gov.za/en/electricity/Pages/LoadShedding.aspx", $Verbose)
;~ ConsoleWrite("CoCT Status = " & $coctstatus & @CRLF)

;~ ConsoleWrite("Checking Durban" & @CRLF)
;~ $durbanstatus = LSS_Durban("http://www.durban.gov.za/City_Services/electricity/Load_Shedding/Pages", $Verbose)
;~ ConsoleWrite("Durban Status = " & $durbanstatus & @CRLF)

;~ ConsoleWrite("Checking Eskom" & @CRLF)
;~ $eskomstatus = LSS_Eskom("http://loadshedding.eskom.co.za/LoadShedding/GetStatus", $Verbose)
;~ ConsoleWrite("Eskom Status = " & $eskomstatus & @CRLF)

;~ ConsoleWrite("Checking Joburg" & @CRLF)
;~ $joburgstatus = LSS_Joburg("https://www.citypower.co.za/customers/pages/Load_Shedding.aspx", $Verbose)
;~ ConsoleWrite("Joburg Status = " & $joburgstatus & @CRLF)

;~ ConsoleWrite("Checking News24" & @CRLF)
;~ $news24status = LSS_N24("http://loadshedding.news24.com/api/stage", $Verbose)
;~ ConsoleWrite("News24 Status = " & $news24status & @CRLF)

Func LSS_Durban($durbanls_URL, $Verbose = 0) ; Check loadshedding status according to Durban
  
	Local $_htmlDurban1 = BinaryToString(InetRead($durbanls_URL), 19)
  If $_htmlDurban1 = "" Then Return -1
  Local $StringID = "ms-rteForeColor-2"
  
  Local $_htmlDurban2[2]
  $_htmlDurban2 = ParseBurn($_htmlDurban1, $StringID)
  Local $_htmlDurban2a = StringRegExpReplace($_htmlDurban2[0], 'Â| |\r', " ")
  
  Local $_htmlDurban3[2]
  $_htmlDurban3 = ParseBurn($_htmlDurban2[1], $StringID)
  Local $_htmlDurban3a = StringRegExpReplace($_htmlDurban3[0], 'Â| |\r', " ")
  
  Local $_htmlDurban4[2]
  $_htmlDurban4 = ParseBurn($_htmlDurban3[1], $StringID)
  Local $_htmlDurban4a = StringRegExpReplace($_htmlDurban4[0], 'Â| |\r', " ")
  
  Local $_htmlDurban5[2]
  $_htmlDurban5 = ParseBurn($_htmlDurban4[1], $StringID)
  Local $_htmlDurban5a = StringRegExpReplace($_htmlDurban5[0], 'Â| |\r', " ")
  
  Local $_htmlDurban6[2]
  $_htmlDurban6 = ParseBurn($_htmlDurban5[1], $StringID)
  Local $_htmlDurban6a = StringRegExpReplace($_htmlDurban6[0], 'Â| |\r', " ")
  
  Local $_htmlDurbanRed = StringStripWS(StringRegExpReplace($_htmlDurban2a & $_htmlDurban3a & $_htmlDurban4a & $_htmlDurban5a & $_htmlDurban6a, '<[^>]*>', ""),4+2+1)
    
;~ 	
;~ 	Local $_htmlDurban1a = StringRegExpReplace($_htmlDurban1, 'Â', "")
;~   If StringInStr(StringStripWS(StringMid($_htmlDurban1a,StringInStr($_htmlDurban1a, "STATUS") + 7, 10), 8),"INACTIVE") > 1 Then Return 0
;~   Local $_htmlDurban2 = StringInStr($_htmlDurban1a, "LOAD SHEDDING STAGE:")
;~ 	Local $_htmlDurban3 = StringStripWS(StringMid($_htmlDurban1a, $_htmlDurban2 + 20, 10), 8)

  If $Verbose Then ConsoleWrite("Durban Raw = " & $_htmlDurbanRed & @CRLF)
  
  Local $aHtmlDurbanStage[2]
  $aHtmlDurbanStage = ParseBurn($_htmlDurbanRed,"stage",":","", 2)
  $_htmlDurbanStage = $aHtmlDurbanStage[0]
  
;~   ConsoleWrite($_htmlDurbanRed & @CRLF)
;~   ConsoleWrite($aHtmlDurbanStage[0] & @CRLF)
  
	Select
		Case StringInStr($_htmlDurbanRed, "N/A") > 0 Or StringInStr($_htmlDurbanRed, "NOT APPL") > 0 Or StringInStr($_htmlDurbanRed, "INACTIVE") > 0
			Return 0
		Case StringInStr($_htmlDurbanStage, "ONE") > 0 Or StringInStr($_htmlDurbanStage, "1") > 0
			Return 1
		Case StringInStr($_htmlDurbanStage, "TWO") > 0 Or StringInStr($_htmlDurbanStage, "2") > 0
			Return 2
		Case StringInStr($_htmlDurbanStage, "THREE") > 0 Or StringInStr($_htmlDurbanStage, "3") > 0
			Return 3
		Case Else
			Return -1
	EndSelect
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
      If $_htmlCoCT1 = -1 Then Return -1
      
      Local $StringID = "color:#FFFFFF; padding:10px; width:100%; text-align:center;  padding-left:20px; padding-right:20px"
  
      Local $_htmlCoCT2[2]
      $_htmlCoCT2 = ParseBurn($_htmlCoCT1, $StringID)
      $_htmlCoCT3 = $_htmlCoCT2[0]
            
      If $Verbose Then ConsoleWrite("Cape Town Raw = " & $_htmlCoCT3 & @CRLF)
      
			Select
        Case StringInStr($_htmlCoCT3, "Suspended") > 0
          Return 0
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
  
  Local $StringID = "ms-rteForeColor-2"
  
  Local $_htmlJoburg2[2]
  $_htmlJoburg2 = ParseBurn($_htmlJoburg1, $StringID, "<strong>", "</", 8)
  Local $_htmlJoburg3a = StringStripWS(StringRegExpReplace($_htmlJoburg2[0], 'â€‹|\&#.*?\;', " "), 4+2+1 )
  
  If $Verbose Then ConsoleWrite("Joburg Raw = " & $_htmlJoburg3a & @CRLF)
  
	Select
		Case (StringInStr($_htmlJoburg3a, "Not") > 0) And (StringInStr($_htmlJoburg3a, "Note") = 0)
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

	Local $_htmlN24 = BinaryToString(InetRead($news24ls_URL), 19) ;Get data from News24's LoadShedding page
  
  If $Verbose Then ConsoleWrite("News24 Raw = " & $_htmlN24 & @CRLF)

Return $_htmlN24
EndFunc   ;==>LSS_N24

Func ParseBurn($htmlString, $stringID, $initialSymbol = ">", $finalSymbol = "</", $offset = 1) ; used internally to parse html a bit better
  Local $_ClassID = StringInStr($htmlString, $stringID) ; Start at stringID
;~   ConsoleWrite($_ClassID & @CRLF)      ; Must be a better way to do this
; Add checks for broken stuff
  Local $htmlString1 = StringTrimLeft($htmlString,$_ClassID) ;Trim off until stringID
  Local $bracketEnd = StringInStr($htmlString1, $initialSymbol)
  Local $bracketStart = StringInStr($htmlString1, $finalSymbol) ; find the bracket points
  Local $htmlStringOut = StringMid($htmlString1,$bracketEnd + $offset,$bracketStart - $bracketEnd - $offset) ; cut the string according to the brackets
  Local $Output[2]
  $Output[0] = $htmlStringOut ; the filtered string
  $Output[1] = $htmlString1 ; output the remainder of the string
  Return $Output
EndFunc
  
  
