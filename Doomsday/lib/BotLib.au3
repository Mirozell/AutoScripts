#include <PixelDiff.au3>
#include <ScreenCapture.au3>
#include-once

Func Logger($msg, $v1=Null, $v2=Null, $v3=Null, $v4=Null, $v5=Null, $v6=Null, $v7=Null, $v8=Null)
	$message = StringFormat($msg, $v1, $v2, $v3, $v4 ,$v5, $v6, $v7, $v8)
	ConsoleWrite(_NowTime() & "| " & $message & @CRLF)
EndFunc

; target = [x, y, hexcolor]
Func MouseClick_Target($target, $tolerance=0, $timeout = 10)
   $x = $target[0]
   $y = $target[1]
   $expected = $target[2]

   ;MouseMove($x+3, $y+3)
   $timedout = _DateAdd("s", $timeout, _NowCalc())
   $clicked =  False

   Do
	  $actual = GetPixelHexColor($x, $y)
	  $diff = HexDiff($expected, $actual)

	  If $diff < $tolerance Then
		 MouseClick("left", $x+Random(3), $y+Random(3))
		 $clicked = True
	  EndIf

	  Sleep(200)
   Until $clicked Or _NowCalc() > $timedout

   If Not $clicked Then
	  ;Logger("Click Target: %s, %s Clicked: %s Expected: %s Actual: %s Diff: %s", $x, $y, $clicked, $expected, $actual,  $diff)
   EndIf

   return $clicked
EndFunc

Func ResetToRegionView($hwnd, $btn, $interval=1000, $limit=10)
   ActivateWindow($hwnd)
   $color = GetPixelHexColor($btn[0], $btn[1], $hwnd)
   $count = 0
   While HexDiff($color, $btn[2]) > 0
	  $count += 1
	  If $count > $limit Then
		 Return False
	  EndIf

	  MouseClick("left", $btn[0], $btn[1])
	  Sleep($interval)
	  $color = GetPixelHexColor($btn[0], $btn[1], $hwnd)
   WEnd

   Return True
EndFunc

Func ResetToBaseView($hwnd, $btn, $interval=1000, $limit=10)
   If Not ResetToRegionView($hwnd, $btn, $interval, $limit) Then return False
   Sleep(100)
   MouseClick("left", $btn[0], $btn[1])
   return True
EndFunc

Func ActivateWindow($hwnd)
	;Logger("Activate Window: %s", $window)
	WinActivate($hwnd)
	$window = WinWaitActive($hwnd, 1)
	If $window == 0 Then
		Logger("Window not found")
		Exit 1
	EndIf
EndFunc

Func QuitHandler()
   ConsoleWrite(_NowTime() & " Exiting" & @CRLF)
    Exit 0
EndFunc

