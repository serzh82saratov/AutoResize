#SingleInstance Force
#NoEnv
SetBatchLines -1
; #Include <AutoResize>

Gui, +Resize -DPIScale

Loop 150
	Gui, Add, Edit, vEL%A_Index%, %A_Index%

Gui1 := New AutoResize(1)

Gui1.SetArea(3, 3)

Gui1.Item("EL1", "xm, ym, r20 - 3, r333 - 3")
Loop 49
	Gui1.Item("EL" A_Index + 1, "x + 3, yp, wp, hp") 
	
Gui1.Item("EL51", "xm, y + 3, wp, hp")
Loop 49
	Gui1.Item("EL" A_Index + 51, "x + 3, yp, wp, hp") 
	
Gui1.Item("EL101", "xm, y + 3, wp, hp")
Loop 49
	Gui1.Item("EL" A_Index + 101, "x + 3, yp, wp, hp") 

Gui, Show, x10 y10 w600 h200
Return

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	Gui1.Resize(A_GuiWidth, A_GuiHeight)
	Return
	
1::
	Gui1.SetArea(3, 3)
	Gui1.Resize()
	Return
	
2::
	Gui1.SetArea(111, 111, 33, 33)
	Gui1.Resize()
	Return
	
GuiClose:
Escape:: ExitApp
