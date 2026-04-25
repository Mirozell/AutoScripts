#include <PixelDiff.au3>
#include <ScreenCapture.au3>
#include-once

Func Logger($msg, $v1=Null, $v2=Null, $v3=Null, $v4=Null, $v5=Null, $v6=Null, $v7=Null, $v8=Null)
	$message = StringFormat($msg, $v1, $v2, $v3, $v4 ,$v5, $v6, $v7, $v8)
	ConsoleWrite(_NowTime() & " " & $message & @CRLF)
EndFunc

; target = [x, y, hexcolor]
Func MouseClick_Target($target, $tolerance=0, $timeout = 30)
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

Func QuitHandler()
   ConsoleWrite(_NowTime() & " Exiting" & @CRLF)
    Exit 0
EndFunc