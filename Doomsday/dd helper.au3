#include <Date.au3>
#include <Math.au3>
#include <lib/PixelDiff.au3>
#include <lib/BotLib.au3>


AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
AutoItSetOption("MouseClickDownDelay", 30)

;Local $helpbtn = [550, 510, "DEA342"]
Local $helpbtn = [680, 640, "DCA23F"]
Local $wait = 0
Local $interval = 1
Local $forceclick = 0

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

	  If $forceclick > 9 Then
		 MouseClick("left", $helpbtn[0], $helpbtn[1])
		 $forceclick = 0
	  Else
		 $clicked = MouseClick_Target($helpbtn, 10)
		 If $clicked Then
			Logger("%s: Helped", $i)
			$forceclick = 0
		 Else
			$forceclick += 1
		 EndIf
	  EndIf
	  Sleep($interval*1000)
	  WinSetState($window, "", @SW_MINIMIZE )

   Next

   WinActivate($statusWindow)
   Sleep($wait * 1000)

WEnd