
#SingleInstance Force
#NoEnv 
SetBatchLines -1
; #Include <AutoResize>
Arr := {}

Gui, New
Gui, +Resize +HWNDhGui1
Loop 2
	Gui, Add, Edit, vEL%A_Index%, %A_Index%
Arr[hGui1] := New AutoResize(hGui1, "xm10 ym10") 
Arr[hGui1].Item("EL1", "xm, ym, r1000, r500")
Arr[hGui1].Item("EL2", "xp, y, r1000, r500")  
Gui, Show, x100 y100 w200 h200

Gui, New
Gui, +Resize +HWNDhGui2
Loop 2
	Gui, Add, Edit, vEL%A_Index%, %A_Index%
Arr[hGui2] := New AutoResize(hGui2) 
Arr[hGui2].Item("EL1", "xm, ym, r500, r1000")
Arr[hGui2].Item("EL2", "x, yp, r500, r1000")  
Gui, Show, x400 y100 w200 h200
Return

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return 
	Arr[A_Gui].Resize(A_GuiWidth, A_GuiHeight)
	Return

GuiClose:
Escape:: ExitApp
