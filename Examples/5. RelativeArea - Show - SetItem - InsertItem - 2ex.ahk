#SingleInstance Force
#NoEnv 
SetBatchLines -1
; #Include <AutoResize> 

Gui, New
Gui, +Resize +HWNDhGui1 -DPIScale
Loop 5
	Gui, Add, Edit, vEL%A_Index% hwndhEL%A_Index%, %A_Index%
ex1 := New AutoResize(hGui1, "Ceil") 
ex1.SetArea("r100", "r100", "r600", "r600")
ex1.Item(1, "xm, ym, r1000, r500")
ex1.Item("EL2", "xp, y, wp, ro") 

ex2 := New AutoResize(hGui1, "Ceil") 
ex2.SetArea("r600", "r600", "r100", "r100")
ex2.Item("EL3", "xm, ym, r500, r1000")
ex2.Item("EL4", "x, ym, ro, r1000")

Gui, Show, x400 y100 w200 h200

MsgBox
ex2.SetItem("EL3", "xm, ym, r500, r500")
ex2.InsertItem("EL4", "EL5", "xp, y, r500, ro")
ex2.Resize()
Return

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	ex1.Resize(A_GuiWidth, A_GuiHeight) 
	ex2.Resize(A_GuiWidth, A_GuiHeight)
	Return

GuiClose:
Escape:: ExitApp

1::ex2.Show()
2::ex2.Show(0)
