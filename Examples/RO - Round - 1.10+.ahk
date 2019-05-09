#SingleInstance Force
#NoEnv
SetBatchLines -1
; #Include <AutoResize>

Gui, +Resize

Loop 150
	Gui, Add, Edit, vEL%A_Index%, %A_Index%

Gui1 := New AutoResize(1, "Floor") 

Gui1.Item("EL1", "xm, ym, r100, r333")
Loop 44
	Gui1.Item("EL" A_Index + 1, "x, yp, r20, hp") 
Gui1.Item("EL" 50, "x, yp, ro, hp") 
	
Gui1.Item("EL51", "xm, y, r20, hp")
Loop 49
	Gui1.Item("EL" A_Index + 51, "x, yp, wp, hp") 
	
Gui1.Item("EL101", "xm, y, wp, ro")
Loop 49
	Gui1.Item("EL" A_Index + 101, "x, yp, wp, hp") 

Gui, Show, x10 y10 w610 h200
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
