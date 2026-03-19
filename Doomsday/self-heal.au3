#include <Date.au3>
#include <Math.au3>
#include "lib/BotLib.au3"
#include "lib/PixelDiff.au3"

AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
HotKeySet( "{esc}","QuitHandler" )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]
$mainwindow = $windows[1][1]
ConsoleWrite(_NowTime() & " Found active windows: " & $windowcount & @CRLF)
$statusWindow = SplashTextOn ( "Doomsday Heal Script", "Starting...", 250, 120, 50, 50 )

global $healsize = 2700 ; GetHealSize($windowcount-1); + 87
global $elixerTab = False; or True

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
   $squadbox[1] += 65
EndIf

While True

   $healed = Heal()
   $waited = WaitAndHelps()
   Collect()

   $totalhealed += $healed
   $elapsed = _Max(_DateDiff("n", $starttime, _NowCalc()), 1)
   $rate = Round($totalhealed/$elapsed, 0)
   ConsoleWrite(_NowTime() & " Healed: " & $healed & " Total: " & $totalhealed & " Waited: " & $waited & " Rate: " & $rate & @CRLF)

   Sleep(300)
Wend

Func GetHealSize($helpcount)
   Return $helpcount * 86
EndFunc

Func Heal()
   ActivateWindow($mainwindow)

   ;hospital heal popover
   UpdateStatus("Entering hospital")
   $entered = MouseClick_Target($hospitalpopup, 35)
   If Not $entered Then
	  ConsoleWrite(_NowTime() & " No entry.  Printing screen to clipboard for review" & @CRLF)
	  Send("!{PRINTSCREEN}")
	  exit 1
   EndIf

   ;prevent elixer heal
   If $elixerTab Then
	  MouseClick("left", 1350, 240)
   EndIf

   ;zero out squads
   UpdateStatus("Clearing queue")
   MouseClick_Target($zerobtn, 5)

   ;set squads to heal
   UpdateStatus("Preparing squads")
   ClipPut("99999999")
   MouseMove($squadbox[0], $squadbox[1])
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
   MouseClick_Target($healbtn, 5)
   return $healed
EndFunc

Func WaitAndHelps()
   ActivateWindow($mainwindow)
   UpdateStatus("Waiting and helping...")
   $waitstart = _NowCalc()
   $lasthelp = "1970/01/01 00:00:00"

   While True

	  ;wait
	  $complete = CheckForHealComplete($waitbar, 25)
	  If $complete Then
		 ConsoleWrite(_NowTime() & " Detected heal finished..." & @CRLF)
		 $waited=_DateDiff("s", $waitstart, _NowCalc())
		 return $waited
	  EndIf

	  ; help at interval
	  If _DateDiff("s", $lasthelp, _NowCalc()) > 15 Then
		 ConsoleWrite(_NowTime() & " Helping..." & @CRLF)
		 For $i = 2 To $windowcount
			local $window = $windows[$i][1]
			ActivateWindow($window)
			MouseClick("left", $helpbtn[0], $helpbtn[1])
			Sleep(40) ; help click won't register if this is too short
		 Next
		 $lasthelp = _NowCalc()
	  EndIf
	  sleep(100)
   WEnd
EndFunc

Func Collect()
   ActivateWindow($mainwindow)

   ;collect
   UpdateStatus("Collecting")
   MouseClick("left", $hospitalpopup[0]+Random(0, 3, 1), $hospitalpopup[1]+Random(0, 3, 1))
   return $waited
EndFunc

Func CheckForHealComplete($target, $tolerance)
   ;ActivateWindow($mainwindow)

   ;MouseMove($target[0], $target[1])

   $color = GetPixelHexColor($target[0], $target[1], $mainwindow)
   If $color = "000000" Then
	  ConsoleWrite("Failed to detect color. Expected: " & $target[1] & " Found: " & $color & @CRLF)
	  exit 4
   EndIf

   $diff = HexDiff($target[2], $color)
   ;ConsoleWrite(_NowTime() & " Waiting for change: " & $target[0] & "," & $target[1] & " " & $target[2] & " Current: " & $color & " Diff: " & $diff & @CRLF)

   return $diff > $tolerance
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

