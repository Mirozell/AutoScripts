#include <Date.au3>
#include <Math.au3>
#include <ScreenCapture.au3>
#include "lib/BotLib.au3"
#include "lib/PixelDiff.au3"

AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
HotKeySet( "{esc}","QuitHandler" )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]
ConsoleWrite(_NowTime() & " Found active windows: " & $windowcount & @CRLF)
$statusWindow = SplashTextOn ( "Doomsday Heal Script", "Starting...", 250, 120, 50, 50 )

global $healsize = GetHealSize($windowcount-1) + 0 ; 86
global $capWait = False
global $elixerTab = False

; target = [x, y, hex color]
global $hospitalpopup = [670, 590, "C38647"]
global $zerobtn = [1790, 700, "EFC793"]
global $squadbox = [1700, 240, "13120F"]
global $healbtn = [1530, 890, "E7C571"]
global $waitbar = [583, 713, "56BB43"]
global $helpbtn = [763, 666, "not used"]

global $totalhealed = 0
global $starttime = _NowCalc()

If $elixerTab Then
   $squadbox += 50
EndIf

While True

   $healed = Heal()
   Helps()
   $waited = WaitAndCollect()

   $totalhealed += $healed
   $elapsed = _Max(_DateDiff("n", $starttime, _NowCalc()), 1)
   $rate = Round($totalhealed/$elapsed, 0)
   ConsoleWrite(_NowTime() & " Healed: " & $healed & " Total: " & $totalhealed & " Waited: " & $waited & " Rate: " & $rate & @CRLF)

   Sleep(1000)
Wend

Func GetHealSize($helpcount)
   Return $helpcount * 86
EndFunc

Func Heal()
   $window = $windows[1][1]
   ActivateWindow($window)

   ;hospital heal popover
   UpdateStatus("Entering hospital")
   $entered = MouseClick_Target($hospitalpopup, 35)
   If Not $entered Then
	  ConsoleWrite(_NowTime() & " No entry" & @CRLF)
	  Send("!{PRINTSCREEN}")
	  exit 1
   EndIf

   ;prevent elixer heal
   If $elixerTab Then
	  MouseClick("left", 1200, 240)
   EndIf

   ;zero out squads
   UpdateStatus("Clearing queue")
   MouseClick_Target($zerobtn, 5)

   ;set squads to heal
   UpdateStatus("Preparing squads")
   ClipPut("99999999")
   MouseClick_Target($squadbox, 10)
   Sleep ( 100 )
   $h = String($healsize)
   ;ConsoleWrite(_NowTime() & "     to heal: " & $h & @CRLF)
   Send ( "{RIGHT}" & $h & "^a^c")
   Sleep(200)
   $healed = Number(ClipGet())

   ;safety check
   If $healed > $healsize Then
	  ConsoleWrite(String(_NowTime()) & "Too many squads for healing! (" & $healed & ") Halting!" & @CRLF)
	  Exit 2
   EndIf

   ;heal!
   UpdateStatus("Heal: " & $healed)
   _ScreenCapture_Capture(@MyDocumentsDir & "\Autoit Scripts\Screencaps\Heal.jpg", 0, 0, 2560, 1440)
   MouseClick_Target($healbtn, 5)
   return $healed
EndFunc

Func Helps()
   For $i = 2 To $windowcount
		local $window = $windows[$i][1]
		ActivateWindow($window)
		MouseClick("left", $helpbtn[0], $helpbtn[1])
		Sleep(100)
   Next
EndFunc

Func WaitAndCollect()
   $window = $windows[1][1]
   ActivateWindow($window)

   ;wait
   UpdateStatus("Waiting...")
   sleep(200)
   Local $waitstart = _NowCalc()
   WaitForHealComplete($waitbar, 35)
   Local $waited=_DateDiff("s", $waitstart, _NowCalc())

   ;collect
   UpdateStatus("Collecting")
   MouseClick("left", $hospitalpopup[0]+Random(0, 3, 1), $hospitalpopup[1]+Random(0, 3, 1))
   return $waited
EndFunc

Func WaitForHealComplete($target, $tolerance)
   ;MouseMove($target[0], $target[1])

   Do
	  Sleep(200)
	  Local $color = GetPixelHexColor($target[0], $target[1])
	  If $color = "000000" Then
		 ConsoleWrite("Failed color check: " & $color & @CRLF)
		 exit 4
	  EndIf

	  Local $diff = HexDiff($target[2], $color)
	  ;ConsoleWrite(_NowCalc() & " Waiting for change: " & $target[0] & "," & $target[1] & " " & $target[2] & " Current: " & $color & " Diff: " & $diff & @CRLF)
   Until $diff > $tolerance

   ConsoleWrite(_NowTime() & "     Complete. Target: " & $target[2] & " Current: " & $color & " Diff: " & $diff & @CRLF)
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
   $filename = @MyDocumentsDir&"\Autoit Scripts\Screencaps\"&$message&".jpg"
   _ScreenCapture_Capture($filename)
   Local $content = "Healed: " & $totalhealed & @CRLF _
   & "Heal size: " & $healsize & @CRLF _
   & $message & @CRLF _
   & "Elapsed: " & $elapsed & " min" & @CRLF _
   & "Rate: " & $rate & "/min"

   ControlSetText ( $statusWindow, "", "[CLASSNN:Static1]", $content & @CRLF & "Press esc to exit...")
EndFunc

