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
Local $nohelpinterval = 2 * 1000

HotKeySet( "{esc}","QuitHandler" )
$statusWindow = SplashTextOn ( "Doomsday Help Script", "Helping...", 200, 80, 50, 50 )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]
ConsoleWrite(_NowTime() & " Found active windows: " & $windowcount & @CRLF)

While 1=1

   For $i = 1 To $windowcount
	  $window = $windows[$i][1]
	  WinSetState($window, "", @SW_RESTORE)
	  ActivateWindow($window)

	  ; sleep and skip if help inactive
	  $color = GetPixelHexColor($inactivehelpbtn[0], $inactivehelpbtn[1])
	  If HexDiff($inactivehelpbtn[2], $color) < 1 Then
		 WinSetState($window, "", @SW_MINIMIZE )
		 Sleep($nohelpinterval)
		 ContinueLoop
	  EndIf

	  ; try click help
	  $clicked = MouseClick_Target($helpbtn, 10)
	  If $clicked Then
		 Logger("%s: Helped", $i)
	  Else
		 ; try recovery from skill popup
		 MouseClick_Target($coveredhelpbtn, 10)
		 $clicked = MouseClick_Target($helpbtn, 10)
		 Logger("%s: Cleared cover and clicked: %s", $i, $clicked)
	  EndIf

	  If Not $clicked And Random() < .1 Then
		 ; attempt recovery from unknown
		 MouseClick("left", $helpbtn[0], $helpbtn[1])
		 Logger("%s: forced click")
	  EndIf

	  WinSetState($window, "", @SW_MINIMIZE )
	  Sleep($helpinterval)
   Next

   WinActivate($statusWindow)
WEnd