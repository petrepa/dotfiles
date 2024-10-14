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