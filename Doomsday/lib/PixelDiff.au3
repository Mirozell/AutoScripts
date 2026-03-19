#include-once

Func GetPixelHexColor($x, $y, $hwnd = 0)
   $iColor = PixelGetColor($x, $y, $hwnd)
   return StringRight(Hex($iColor), 6)
EndFunc

; does this even work right??
Func PixelDiff($color1, $color2)
   ;ConsoleWrite("Hex input: " & Hex($color1) & " " & Hex($color2) & @CRLF)
   $diff = _Max($color1, $color2) - _Min($color1, $color2)
   $hexdiff = Hex($diff)
   ;ConsoleWrite("Diff: " & $diff & " Hex Diff: " & $hexdiff & @CRLF)

   $r = StringMid($hexdiff, 3, 2)
   $g = StringMid($hexdiff, 5, 2)
   $b = StringMid($hexdiff, 7, 2)

   ;ConsoleWrite("RGB Diffs: " & $r & " " & $g & " " & $b & @CRLF)

   $result = Dec($r) + Dec($g) + Dec($b)
   ConsoleWrite("Sum Diffs: " & $result & @CRLF)
   return $result
EndFunc

Func HexDiff($hex1, $hex2)
   ;ConsoleWrite("Hex input: " & $hex1 & " " & $hex2 & @CRLF)
   Local $length = StringLen($hex1)
   If Mod($length, 2) <> 0 Or $length <> StringLen($hex2) Then
	  ConsoleWrite("HexDiff invalid lengths")
	  Exit 1
   EndIf

   $totaldiff = 0

   For $i = 1 To $length-1 Step 2
	  Local $value1 = Dec(StringMid($hex1, $i, 2))
	  Local $value2 = Dec(StringMid($hex2, $i, 2))
	  Local $valuediff = _Max($value1, $value2) - _Min($value1, $value2)
	  $totaldiff += $valuediff
	  ;ConsoleWrite($i & " " & $value1 & " " & $value2 & " " & $valuediff & " " & $totaldiff & @CRLF)
   Next

   return $totaldiff
EndFunc