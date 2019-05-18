#SingleInstance Force
#NoEnv
SetBatchLines -1
#Include <AutoResize>

OnMessage(0x201, "WM_LBUTTONDOWN")
BarH := 7
Gui, +HWNDhGui +Resize -DPIScale
Gui, Add, Progress, y66 hwndhBar backgroundff0000 

Loop 6
	Gui, Add, Edit, vED%A_Index%, Edit%A_Index%
	
ex1 := New AutoResize(1, "Ceil")
ex1.SetArea("r200", "r150", 30, 20)
ex1.Item("ED1", "0, ym, r333, r500 - " BarH // 2, "Section")
ex1.Item("ED2", "x, ys, ws, hs")
ex1.Item("ED3", "x, ys, ro, hs") 
ex1.Item(hBar, "xs, y, r1000, " BarH, "Draw") 
ex1.Item("ED4", "xm, y, ws, ro")
ex1.Item("ED5", "x, yp, wp, hp")
ex1.Item("ED6", "x, yp, ro, hp")
Gui, Show, w540 h305
return


WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	Global hBar, hGui, ex1, BarH 
	If (hwnd != hBar)
		Return 
	pry := ""
	CoordMode, Mouse, Client
	AutoResize.GetClientSize(hGui, W, H)
	top := ex1.s.Top + ex1.ps.ym
	bottom := H - ex1.s.Bottom + ex1.ps.ym - BarH / 2	
	GuiControl, +backgroundf0f0f0, %hBar% 
	While GetKeyState("LButton", "P") 
	{
		Sleep 10
		MouseGetPos, , y
		If !WinActive("ahk_id" hGui)
			Break
		If (pry = y || (y < top && _y = top) || (y > bottom  && _y = Ceil(bottom - (BarH / 2))))
			Continue
		y := y < top ? top : y > bottom ? bottom : (y - BarH / 2)
		pry := (y := y < top ? top : y)
		If (y = bottom)
			R := "1000 - " BarH
		Else 
			R := ex1.Round.Call(1000 / ((H - ex1.s.HOFF) / (y - top)))
		ex1.SetItem("ED1", "xm, ym, r333, r" R, "Section")
		ex1.Resize(W, H)
		GuiControlGet, _, Pos, %hBar%
	} 
	GuiControl, +backgroundff0000, %hBar%
}

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return		
	ex1.Resize(A_GuiWidth, A_GuiHeight)
	Return

GuiClose:
Escape:: ExitApp 
