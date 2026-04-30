#include <Date.au3>
#include <Math.au3>
#include "lib/BotLib.au3"
#include "lib/PixelDiff.au3"

AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
AutoItSetOption("MouseClickDownDelay", 30)
HotKeySet( "{esc}","QuitHandler" )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]
$mainwindow = $windows[1][1]
Logger("Found active windows: %s", $windowcount)
$statusWindow = SplashTextOn ( "Doomsday Heal Script", "Starting...", 250, 120, 50, 50 )

global $healsize = 700 ; GetHealSize($windowcount-1); + 87
global $elixerTab = False ; or True

; target = [x, y, hex color]
local $hospitalpopup = [446, 377, "B0B4B5"]
local $zerobtn = [1194, 467, "EFC794"]
local $squadbox = [1129, 183, "13120F"]
local $healbtn = [1068, 600, "DEA742"]
local $waitbar = [389, 473, "6AC762"]
local $helpbtn = [763, 666, "not used"]
local $shelterbtn = [34, 686, "8D6F4B"]

local $totalhealed = 0
local $starttime = _NowCalc()
local $fails = 0
local $healed = 0

If $elixerTab Then
   Logger("fix offset")
   exit 1
   $squadbox[1] += 65
EndIf

While True

   $err = EnterHospital()
   If Not $err Then
	  $healed = Heal()
	  $fails = 0
   Else
	  Logger("Fail %s: %s", $fails, $err)
	  If $fails > 5 Then exit 1
   EndIf

   $waited = WaitAndHelps()
   Collect()

   $totalhealed += $healed
   $elapsed = _Max(_DateDiff("s", $starttime, _NowCalc()), 1)
   $rate = Round($totalhealed/$elapsed*60, 0)
   Logger("Healed: %s Total: %s Waited: %s  Rate: %s", $healed, $totalhealed, $waited, $rate)

   Sleep(300)
Wend

Func GetHealSize($helpcount)
   Return $helpcount * 86
EndFunc

Func EnterHospital()
   ActivateWindow($mainwindow)

   ;hospital heal popover
   UpdateStatus("Entering hospital")
   $entered = MouseClick_Target($hospitalpopup, 35)
   If $entered Then return ""

   Logger("  Failed to enter hospital, attempting reset")
   $reset = ResetToBaseView($mainwindow, $shelterbtn)
   If Not $reset Then return "Failed to reset for entry"

   $entered = MouseClick_Target($hospitalpopup, 35)
   If $entered Then return ""

   return "Failed to enter hospital"
EndFunc

Func Heal()
   ;prevent elixer heal
   If $elixerTab Then
	  MouseClick("left", 1330, 220)
	  $elixerTab=False
	  Sleep(500)
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
   ;Logger("     to heal: %s", $h)
   Send ( "{RIGHT}" & $h & "^a^c")
   Sleep(200)
   $healed = Number(ClipGet())

   ;safety check
   If $healed > $healsize Then
	  Logger("Too many squads for healing! (%s) Halting!", $healed)
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
   ;MouseMove($hospitalpopup[0], $hospitalpopup[1])

   While True

	  ;wait
	  $complete = CheckForHealComplete($waitbar, 25)
	  If $complete Then
		 Logger("Detected heal finished...")
		 $waited=_DateDiff("s", $waitstart, _NowCalc())
		 return $waited
	  EndIf

	  ; help at interval
	  If _DateDiff("s", $lasthelp, _NowCalc()) > 30 Then
		 Logger("Helping...")
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
	  Logger("Failed to detect color. Expected: %s Found: %s", $target[1], $color)
	  exit 4
   EndIf

   $diff = HexDiff($target[2], $color)
   ;Logger("Waiting for change: %s,%s Target: %s Current: %s,%s %s Diff: %s", $target[0], $target[1], $target[2], $color, $diff)

   return $diff > $tolerance
EndFunc

Func UpdateStatus($message)
   Local $elapsed = _Max(_DateDiff("s", $starttime, _NowCalc()), 1)
   Local $rate = Round($totalhealed/$elapsed*60, 0)
   Logger($message)
   Local $elapsedmin = Round($elapsed/60, 0)
   Local $content = "Healed: " & $totalhealed & @CRLF _
   & "Heal size: " & $healsize & @CRLF _
   & $message & @CRLF _
   & "Elapsed: " & $elapsedmin & " min" & @CRLF _
   & "Rate: " & $rate & "/min"

   ControlSetText ( $statusWindow, "", "[CLASSNN:Static1]", $content & @CRLF & "Press esc to exit...")
EndFunc

