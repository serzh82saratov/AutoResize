#SingleInstance Force
#NoEnv
SetBatchLines -1
; #Include <AutoResize>

Gui, +Resize

Loop 10
	Gui, Add, Edit, vEL%A_Index%, %A_Index%

ex1 := New AutoResize(1, "xm10 ym10")

ex1.Item("EL1", "xm, ym, r450, r200")
ex1.Item("EL2", "o, yp, wp, hp")

ex1.Item("EL3", "xm, o, r150, r300", "Section")
ex1.Item("EL4", "o, ys, ws, hs")
ex1.Item("EL5", "xso + 10, o + r100, r700 - 20, r100")

ex1.Item("EL6", "xm + r400, ym + r400, r200, r200", "Section")
ex1.Item("EL7", "xs - w, ys - h, 20, 30")
ex1.Item("EL8", "xp, yso, wp, hp")
ex1.Item("EL9", "xso, yso, wp, hp")
ex1.Item("EL10", "xp, ys - h, wp, hp")


ex2 := New AutoResize(1, "ym20")

ex2.Item("EL1", "xm, ym, r250, r333", "Section")
ex2.Item("EL2", "x, yp, wp, hp")
ex2.Item("EL3", "x, yp, wp, hp")
ex2.Item("EL4", "x, yp, wp, hp")

ex2.Item("EL5", "xs, y, ws2, hp")
ex2.Item("EL6", "x, yp, wp, hp")

ex2.Item("EL7", "xs, y, ws, hs")
ex2.Item("EL8", "x, yp, wp, hp")
ex2.Item("EL9", "x, yp, wp, hp")
ex2.Item("EL10", "x, yp, wp, hp")

ex := ex1

Gui, Show, x100 y100 w200 h200
Return 

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	ex.Resize(A_GuiWidth, A_GuiHeight)
	Return

GuiClose:
Escape:: ExitApp

1:: ex := ex1, ex.Resize()
	
2:: ex := ex2, ex.Resize()
