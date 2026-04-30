#include <Date.au3>
#include <Math.au3>
#include <lib/PixelDiff.au3>
#include <ScreenCapture.au3>

AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
AutoItSetOption("MouseClickDownDelay", 30)

Local $helpbtn = [550, 510]
Local $wait = 0
Local $interval = 1

HotKeySet( "{esc}","QuitHandler" )
$statusWindow = SplashTextOn ( "Doomsday Help Script", "Helping...", 200, 80, 50, 50 )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]
ConsoleWrite(_NowTime() & " Found active windows: " & $windowcount & @CRLF)


While 1=1
	
	For $i = 1 To $windowcount
		$window = $windows[$i][1]
		ActivateWindow($window)
		
		MouseClick("left", $helpbtn[0], $helpbtn[1])
		Sleep($interval*1000)
	Next
	
	WinActivate($statusWindow)
	Sleep($wait * 1000)
	
WEnd

Func ActivateWindow($hwnd)
	;ConsoleWrite("Activate Window: " & $window & @CRLF)
	WinActivate($window)
	$window = WinWaitActive($window, 1)
	If $window == 0 Then
		ConsoleWriteError("Window not found")
		Exit 1
	EndIf
EndFunc

Func QuitHandler()
   ConsoleWrite(_NowTime() & " Exiting" & @CRLF)
    Exit 0
EndFunc
