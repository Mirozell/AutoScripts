#include <Date.au3>
#include <Math.au3>
#include <String.au3>
#include "lib/BotLib.au3"
#include "lib/PixelDiff.au3"

AutoItSetOption("MouseClickDelay", 200)
AutoItSetOption("MouseClickDownDelay", 50)
AutoItSetOption("MouseCoordMode", 2)
AutoItSetOption("PixelCoordMode", 2)
HotKeySet( "{esc}","QuitHandler" )

$windows = WinList("Doomsday_Steam")
$windowcount = $windows[0][0]

$statusWindow = SplashTextOn ( "Doomsday Farm Script", "Farming...", 200, 120, 50, 50 )

local $farmwindow = True
local $squadsize = 0 ; 0 to send auto full squad
local $wait = 1000*180 ;1000 * $squadsize / 100 * 20
local $clicktargetwait = 3

; target = [x, y, hex color]
local $shelterbtn = [34, 686, "8D714B"]
local $searchbtn = [38, 455, "FDFBE9"]
local $centerfarm = [641, 356]
local $gatherbtn = [880, 507, "E7B54A"]
local $emptysquadbox = [1212, 125, "EFC897"]
local $createbtn = [970, 261, "D69639"]
local $squadbox = [1036, 105, "141311"]
local $marchbtn = [943, 626, "E0A842"]

; rss button x y, search button x y,
local $farmfood = [550, 590, 550, 480]
local $farmwood = [720, 590, 720, 480]
local $farmsteel = [880, 590, 880, 480]
local $farmoil = [1050, 590, 1050, 480]
local $farms = [$farmsteel, $farmoil]

local $starttime = _NowCalc()

Logger("Starting %s farms. Squad size: %s Wait: %s", $windowcount, $squadsize, $wait)

While True
   For $i=1 To $windowcount
	  $hwnd = $windows[$i][1]
	  $isReset = ResetToRegionView($hwnd, $shelterbtn)
	  If Not $isReset Then
		 ContinueLoop
	  EndIf

	  $err = Gather($farms)
	  If $err Then
		 Logger($err)
		 ContinueLoop
	  EndIf

	  Sleep(500)
	  $ready = IsSquadReady($hwnd)
	  If Not $ready Then
		 Logger("%s: No squad ready", $i)
		 ResetToRegionView($hwnd, $shelterbtn)
		 ContinueLoop
	  EndIf

	  $err = SendSquad()
	  If $err Then
		 Logger("%s: %s", $i, $msg)
	  Else
		 Logger("%s: squad dispatched", $i)
	  EndIf
   Next
   Sleep($wait)
Wend

Func PickOne($arr)
   return $arr[Random(0, UBound($arr)-1, 1)]
EndFunc

Func Gather($farms)
   $tries = 0
   While $tries < 5
	  local $farmbtns = PickOne($farms)
	  SearchFarm($farmbtns)
	  ;MouseMove($gatherbtn[0]+2, $gatherbtn[1]+2)
	  $clicked = MouseClick_Target($gatherbtn, 15, $clicktargetwait)
	  If $clicked Then
		 return ""
	  EndIf
	  $tries += 1
   WEnd

   return "Failed to click gather"
EndFunc

Func SearchFarm($fbtns)
   MouseClick("left", $searchbtn[0], $searchbtn[1])

   MouseClick("left", $fbtns[0], $fbtns[1])

   MouseClick("left", $fbtns[2], $fbtns[3])
   Sleep(2000)

   MouseClick("left", $centerfarm[0], $centerfarm[1])
EndFunc

Func IsSquadReady($hwnd)
   ;MouseMove($emptysquadbox[0], $emptysquadbox[1])
   $c = GetPixelHexColor($emptysquadbox[0], $emptysquadbox[1], $hwnd)
   If HexDiff($emptysquadbox[2], $c) < 10 Then
	  return True
   EndIf

   return False
EndFunc

Func SendSquad()
   $clicked = MouseClick_Target($createbtn, 5, $clicktargetwait)
   If Not ($clicked) Then
	  return "Failed to click create"
   EndIf

   If $squadsize > 0 Then
	  $clicked = MouseClick_Target($squadbox, 5, $clicktargetwait)
	  If Not ($clicked) Then
		 return "Failed to click squad box"
	  EndIf

	  Send(_StringRepeat("{Backspace}", 6))
	  Send(String($squadsize))
   EndIf

   $clicked = MouseClick_Target($marchbtn, 5, $clicktargetwait)
   If Not ($clicked) Then
	  return "Failed to click march"
   EndIf

   return ""
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

Func ActivateWindow($hwnd)
	;ConsoleWrite("Activate Window: " & $window & @CRLF)
	WinActivate($hwnd)
	$window = WinWaitActive($hwnd, 1)
	If $window == 0 Then
		ConsoleWriteError("Window not found")
		Exit 1
	EndIf
EndFunc

