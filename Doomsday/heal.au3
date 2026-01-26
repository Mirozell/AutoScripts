#include <Date.au3>
#include <Math.au3>
#include <ScreenCapture.au3>
#include "lib/BotLib.au3"
#include "lib/PixelDiff.au3"

AutoItSetOption("MouseCoordMode", 0)
AutoItSetOption("PixelCoordMode", 0)
HotKeySet( "{esc}","QuitHandler" )

Local $healsize = 450 ; 82
local $capWait = False
local $elixerTab = False
Local $healvary = 5

; target = [x, y, hex color]
Local $hospitalpopup = [675, 566, "DBDDDE"]
Local $zerobtn = [1795, 716, "EFBD84"]
Local $squadbox = [1570, 345-50, "13120F"]
Local $healbtn = [1720, 931, "D69539"]
Local $selfhelp = [1039, 980, "DEA742"]
Local $waitbar = [588, 742, "399A29"]

Local $totalhealed = 0
Local $starttime = _NowCalc()

If $elixerTab Then
   $squadbox += 50
EndIf

$mainHwnd = WinGetHandle("[TITLE:Doomsday_Steam; INSTANCE:1]")
$farmHwnd = WinGetHandle("[TITLE:Doomsday_Steam; INSTANCE:2]")
ConsoleWrite(_NowTime() & " Found active windows.  Main: " & $mainHwnd & " Farm: " & $farmHwnd & @CRLF)
WinActivate($mainHwnd)

$statusWindow = SplashTextOn ( "Doomsday Heal Script", "Starting...", 250, 120, 50, 50 )

Sleep(400)

While 1=1
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
   $h = String($healsize-Random(0, $healvary, 1))
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

   ;if farm window is open, use it to self-help
   If $farmHwnd <> 0 Then
	  If $capWait Then
		 Sleep(3*60*1000)
	  EndIf
	  UpdateStatus("Self helping")
	  WinActivate($farmHwnd)
	  Sleep(50)
	  MouseClick("left", $selfhelp[0], $selfhelp[1])
	  Sleep(50)
	  ;MouseClick_Target($selfhelp, 10)
	  WinActivate($mainHwnd)
	  Sleep(200)
   EndIf

   ;wait
   UpdateStatus("Waiting...")
   sleep(200)
   Local $waitstart = _NowCalc()
   WaitForHealComplete($waitbar, 35)
   Local $waited=_DateDiff("s", $waitstart, _NowCalc())

   ;collect
   UpdateStatus("Collecting")
   MouseClick("left", $hospitalpopup[0]+Random(0, 3, 1), $hospitalpopup[1]+Random(0, 3, 1))
   $totalhealed += $healed

   Local $elapsed = _Max(_DateDiff("n", $starttime, _NowCalc()), 1)
   Local $rate = Round($totalhealed/$elapsed, 0)
   ConsoleWrite(_NowTime() & " Healed: " & $healed & " Total: " & $totalhealed & " Waited: " & $waited & " Rate: " & $rate & @CRLF)

Wend

ConsoleWrite(_NowTime() & " Healing complete" & @CRLF)

WinKill("[TITLE:Doomsday_Steam]")
Sleep(2000)
WinKill("[TITLE:Doomsday_Steam]")
exit 0


Func WaitForHealComplete($target, $tolerance)
   ;MouseMove($target[0], $target[1])

   Do
	  Sleep(500)
	  Local $color = GetPixelHexColor($target[0], $target[1])
	  If $color = "000000" Then
		 ConsoleWrite("Failed color check: " & $color & @CRLF)
		 exit 4
	  EndIf

	  Local $diff = HexDiff($target[2], $color)
	  ;ConsoleWrite(_NowCalc() & " Waiting for change: " & $target[0] & "," & $target[1] & " " & $target[2] & " Current: " & $color & " Diff: " & $diff & @CRLF)
   Until $diff > $tolerance

   ;ConsoleWrite(_NowTime() & "     Complete. Target: " & $target[2] & " Current: " & $color & " Diff: " & $diff & @CRLF)
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


