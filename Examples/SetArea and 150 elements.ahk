#SingleInstance Force
#NoEnv
SetBatchLines -1
; #Include <AutoResize>

Gui, +Resize

Loop 150
	Gui, Add, Edit, vEL%A_Index%, %A_Index%

Gui1 := New AutoResize(1, "xm10 ym10")

Gui1.Item("EL1", "xm, ym, r20, r333")
Loop 49
	Gui1.Item("EL" A_Index + 1, "x, yp, wp, hp") 
	
Gui1.Item("EL51", "xm, y, wp, hp")
Loop 49
	Gui1.Item("EL" A_Index + 51, "x, yp, wp, hp") 
	
Gui1.Item("EL101", "xm, y, wp, hp")
Loop 49
	Gui1.Item("EL" A_Index + 101, "x, yp, wp, hp") 

Gui, Show, x10 y10 w600 h200
Return

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	Gui1.Resize(A_GuiWidth, A_GuiHeight)
	Return
	
1::
	Gui1.SetArea(55, 55, 55, 55)
	Gui1.Resize()
	Return
	
2::
	Gui1.SetArea()
	Gui1.Resize()
	Return
	
GuiClose:
Escape:: ExitApp
