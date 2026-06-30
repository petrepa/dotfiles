/*-----------------------------------------------------------
Making deleting entire lines easier. More like macOS.
From: https://www.youtube.com/watch?v=xyWjNLR6OQI
-----------------------------------------------------------*/
!Right::Send("{End}")
!+Right::Send("+{End}")

!Backspace::Send("+{Home}{Delete}")

!Left::Send("{Home}")
!+Left::Send("+{Home}")



/*-----------------------------------------------------------
Switch between the windows of the open app
-----------------------------------------------------------*/
!|::{
  OldClass := WinGetClass("A")
  ActiveProcessName := WinGetProcessName("A")
  WinClassCount := WinGetCount("ahk_exe" ActiveProcessName)
  IF WinClassCount = 1
      Return
  loop 2 {
    WinMoveBottom("A")
    WinActivate("ahk_exe" ActiveProcessName)
    NewClass := WinGetClass("A")
    if (OldClass != "CabinetWClass" or NewClass = "CabinetWClass")
      break
  }
}



/*-----------------------------------------------------------
Center each Alacritty window on the primary screen when it opens.
Alacritty has no native "center" option, so we do it here.
-----------------------------------------------------------*/
CenterAlacritty() {
  static seen := Map()
  for hwnd in WinGetList("ahk_exe alacritty.exe") {
    if seen.Has(hwnd)
      continue
    seen[hwnd] := true
    WinGetPos(, , &w, &h, hwnd)
    x := (A_ScreenWidth - w) // 2
    y := (A_ScreenHeight - h) // 2
    WinMove(x, y, , , hwnd)
  }
}
SetTimer(CenterAlacritty, 250)