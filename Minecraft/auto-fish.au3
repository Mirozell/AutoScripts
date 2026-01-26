#include <AutoItConstants.au3>

Local $clickwait = 6000 ;milliseconds
Local $status = "Paused"
Local $mousePosition = MouseGetPos()
Local $fishEffectX = 1854
Local $fishEffectY = 1158

HotKeySet( "{esc}","EscapeHandler" )
Func EscapeHandler()
   Exit 0
EndFunc

HotKeySet( "`","Toggle" )
Func Toggle()
   If $status=="Paused" Then
	  $status = "Clicking"
	  $mousePosition = MouseGetPos()
	  UpdateStatus()
   Else
	  $status = "Paused"
	  UpdateStatus()
   EndIf
EndFunc

Func UpdateStatus()
   Local $content = $status & @CRLF _
   & "x: " & $fishEffectX & " y: " & $fishEffectY & @CRLF _
   & "color: " & PixelGetColor($fishEffectX, $fishEffectY) & @CRLF _
   & "Press ~ to toggle" & @CRLF _
   & "Press Esc to exit..."
   ControlSetText ( $statusWindow, "", "[CLASSNN:Static1]", $content )
EndFunc
6
$statusWindow = SplashTextOn ( "Autoclicker", "", 250, 100, $fishEffectX+5, $fishEffectY+5 )
UpdateStatus()


While 1=1
   If $status == "Clicking" Then
	  MouseClick($MOUSE_CLICK_RIGHT)
	  Sleep(5500)
	  MouseClick($MOUSE_CLICK_RIGHT)
	  Sleep(400)

   EndIf
Wend
