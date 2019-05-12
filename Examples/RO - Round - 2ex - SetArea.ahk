#SingleInstance Force
#NoEnv
SetBatchLines -1
; #Include <AutoResize>

Gui, +Resize

Loop 200
	Gui, Add, Edit, vEL%A_Index%, %A_Index%

ex1 := New AutoResize(1, "Floor") 

ex1.Item("EL1", "xm, ym, r20 * 5, r333")
Loop 44
	ex1.Item("EL" A_Index + 1, "x, yp, r20, hp")
ex1.Item("EL" 50, "x, yp, ro, hp") 
	
ex1.Item("EL51", "xm, y, r20, hp")
Loop 49
	ex1.Item("EL" A_Index + 51, "x, yp, wp, hp") 
	
ex1.Item("EL101", "xm, y, wp, ro")
Loop 49
	ex1.Item("EL" A_Index + 101, "x, yp, wp, hp")

Gui, Show, x10 y10 w610 h200

ex2 := New AutoResize(1)

Gui, Add, Progress, vP1 BackgroundBlack Hidden 
ex2.Item("P1", "0, 0, r1000, 111", "Section Draw")
Gui, Add, Progress, vP2 BackgroundRed Hidden
ex2.Item("P2", "o, y, 33, ro", "Draw")
Gui, Add, Progress, vP3 BackgroundGreen Hidden
ex2.Item("P3", "0, o, r1000 - wp, wp", "Draw")
Gui, Add, Progress, vP4 BackgroundBlue Hidden
ex2.Item("P4", "xs, yso, hs, r1000 - hs - hp", "Draw")
Return
	
GuiClose:
Escape:: ExitApp

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	ex1.Resize(A_GuiWidth, A_GuiHeight)
	If Area
		ex2.Resize(A_GuiWidth, A_GuiHeight)
	Return
	
1::
	Area := 0
	Loop 4
		GuiControl, Hide, P%A_Index%
	ex1.SetArea()
	ex1.Resize()
	Return
	
2::
	Area := 1
	ex1.SetArea(111, 111, 33, 33)
	ex1.Resize()
	ex2.Resize()
	Loop 4
		GuiControl, Show, P%A_Index%
	Return
