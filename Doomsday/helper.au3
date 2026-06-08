#include <Date.au3>
#include <Math.au3>
#include <lib/PixelDiff.au3>
#include <lib/BotLib.au3>


AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
AutoItSetOption("MouseClickDownDelay", 30)

;Local $helpbtn = [550, 510, "DEA342"]
Local $helpbtn = [680, 640, "DCA23F"]
Local $coveredhelpbtn = [680, 640, "4C3610"]
Local $inactivehelpbtn = [680, 640, "444544"]
Local $helpinterval = 500

HotKeySet( "{esc}","QuitHandler" )
$statusWindow = SplashTextOn ( "Doomsday Help Script", "Helping...", 200, 80, 50, 50 )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]
ConsoleWrite(_NowTime() & " Found active windows: " & $windowcount & @CRLF)

StackWindows()

While 1=1

   For $i = 1 To $windowcount
		$window = $windows[$i][1]
		ActivateWindow($window)

		; sleep and skip if help inactive
		$color = GetPixelHexColor($inactivehelpbtn[0], $inactivehelpbtn[1])
		If HexDiff($inactivehelpbtn[2], $color) < 1 Then
		  WinSetState($window, "", @SW_MINIMIZE)
		  Sleep($helpinterval)
		 ContinueLoop
		EndIf

		Logger("%s: Helping", $i)
		MouseClick("left", $helpbtn[0], $helpbtn[1])
		Sleep(30)
		WinSetState($window, "", @SW_MINIMIZE)
   Next

   Sleep($helpinterval)

WEnd

Func StackWindows()
	For $i = 1 To $windowcount
		Logger("%s: Stacking", $i)
		$window = $windows[$i][1]
		ActivateWindow($window)
		$hwnd = WinMove($window, "", 10, 10)
		if not $hwnd then Logger("%s: move failed", $i)
		Sleep(30)
		WinSetState($window, "", @SW_MINIMIZE)
	Next
EndFunc
