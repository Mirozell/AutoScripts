#include <Date.au3>
#include <Math.au3>
#include <String.au3>
#include "lib/BotLib.au3"
#include "lib/PixelDiff.au3"

AutoItSetOption("MouseClickDelay", 200)
AutoItSetOption("MouseClickDownDelay", 50)
AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
HotKeySet( "{esc}","QuitHandler" )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]
$mainwindow = $windows[1][1]
ConsoleWrite(_NowTime() & " Found active windows: " & $windowcount & @CRLF)
$statusWindow = SplashTextOn ( "Doomsday Farm Script", "Farming...", 200, 120, 50, 50 )

local $squadsize = 2000
local $wait = 1000*20 ;1000 * $squadsize / 100 * 20

; target = [x, y, hex color]
local $shelterbtn = [49, 1028, "93744F"]
local $searchbtn = [72, 678, "FFF7E7"]
local $centerfarm = [959, 543]
local $gatherbtn = [1339, 773, "E1AB44"]
local $createbtn = [1457, 368, "DC9F3F"]
local $marchbtn = [1412, 940, "DFA842"]
local $squadbox = [1551, 139, "141311"]

;local $rssbtn = [831, 920]				; food
;local $rsssearchbtn = [816, 696]		; food
local $rssbtn = [1075, 920]	    		; wood
local $rsssearchbtn = [1064, 696]		; wood
;local $rssbtn = [1324, 920]			; steel
;local $rsssearchbtn = [1324, 696]		; steel
;local $rssbtn = [1574, 920]			; oil
;local $rsssearchbtn = [1574, 696]		; oil

local $starttime = _NowCalc()
local $squadcount = 0
local $clicktargetwait = 5

Logger("Starting farms. Squad size: %s Wait: %s", $squadsize, $wait)

While True
   ResetToRegionView($shelterbtn)

   SearchFarm()

   $sent = SendSquad()
   If $sent Then
	  $squadcount += 1
	  Logger("count: %s", $squadcount)
   Else
	  Logger("Failed to send")
   EndIf

   Sleep($wait)

   $elapsed = _Max(_DateDiff("n", $starttime, _NowCalc()), 1)
Wend

Func SearchFarm()
   MouseClick("left", $searchbtn[0], $searchbtn[1])

   MouseClick("left", $rssbtn[0], $rssbtn[1])

   MouseClick("left", $rsssearchbtn[0], $rsssearchbtn[1])
   Sleep(2000)

   MouseClick("left", $centerfarm[0], $centerfarm[1])
EndFunc

Func SendSquad()
   MouseMove($gatherbtn[0]+2, $gatherbtn[1]+2)
   $clicked = MouseClick_Target($gatherbtn, 15, $clicktargetwait)
   If Not ($clicked) Then
	  return False
   EndIf

   $clicked = MouseClick_Target($createbtn, 5, $clicktargetwait)
   If Not ($clicked) Then
	  return False
   EndIf

   $clicked = MouseClick_Target($squadbox, 5, $clicktargetwait)
   If Not ($clicked) Then
	  return False
   EndIf

   Send(_StringRepeat("{Backspace}", 6))
   Send(String($squadsize))

   $clicked = MouseClick_Target($marchbtn, 5, $clicktargetwait)

   return $clicked
EndFunc

Func ResetToRegionView($btn, $interval=1000, $limit=10)
   ActivateWindow($mainwindow)
   $color = GetPixelHexColor($btn[0], $btn[1], $mainwindow)
   $count = 0
   While HexDiff($color, $btn[2]) > 0
	  $count += 1
	  If $count > $limit Then
		 Return False
	  EndIf

	  MouseClick("left", $btn[0], $btn[1])
	  Sleep($interval)
	  $color = GetPixelHexColor($btn[0], $btn[1], $mainwindow)
   WEnd

   Return True
EndFunc

Func ActivateWindow($hwnd)
	;ConsoleWrite("Activate Window: " & $window & @CRLF)
	WinActivate($hwnd)
	$window = WinWaitActive($hwnd, 1)
	If $window == 0 Then
		ConsoleWriteError("Window not found")
		Exit 1
	EndIf
EndFunc

Func UpdateStatus($message)
   Local $elapsed = _Max(_DateDiff("n", $starttime, _NowCalc()), 1)
   Local $rate = Round($totalhealed/$elapsed, 0)
   ConsoleWrite(_NowTime() & " " & $message & @CRLF)
   Local $content = "Healed: " & $totalhealed & @CRLF _
   & "Heal size: " & $healsize & @CRLF _
   & $message & @CRLF _
   & "Elapsed: " & $elapsed & " min" & @CRLF _
   & "Rate: " & $rate & "/min"

   ControlSetText ( $statusWindow, "", "[CLASSNN:Static1]", $content & @CRLF & "Press esc to exit...")
EndFunc

