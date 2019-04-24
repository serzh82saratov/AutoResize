
  ;	http://forum.script-coding.com/viewtopic.php?pid=133764#p133764


; #Include <AutoResize>


#SingleInstance Force
#NoEnv 
SetBatchLines -1

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
ex1.Item("EL8", "xs - w, yso, wp, hp") 
ex1.Item("EL9", "xso, yso, wp, hp")
ex1.Item("EL10", "xso, ys - h, wp, hp")


ex2 := New AutoResize(1, "ym20")

ex2.Item("EL1", "xm, ym, r250, r333", "Section")
ex2.Item("EL2", "x, yp, wp, hp")
ex2.Item("EL3", "x, yp, wp, hp")
ex2.Item("EL4", "x, yp, wp, hp")

ex2.Item("EL5", "xs, y, r500, hp")
ex2.Item("EL6", "x, yp, wp, hp")

ex2.Item("EL7", "xs, y, r250, hp")
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


Class AutoResize
{
	;  автор - serzh82saratov
	;  версия - 1.02
	;  23.04.2019
	
	__New(Gui, Options = "") {
		If !WinExist("ahk_id" Gui)
			 Gui, %Gui%:+HWNDhGui
		this.A := {xm:0, ym:0, Gui:Gui, hGui:hGui, cLeft:0, cTop:0, cRight:0, cBottom:0, B:{}}
		this.pr := {}, this.s := {}
		for k, v in ["xm", "ym"]
			RegExMatch(Options, "(?<Key>" v ")(?<Value>\d+)", o), this.A[oKey] := oValue 
	}
	Item(Control, Options, Ex = "") {
		Static SWP_NOZORDER := 0x0004, SWP_NOCOPYBITS := 0x0100
		Options := StrReplace(Options, " ")
		Options := StrReplace(Options, "-", "+-")
		If (Control + 0 = "") || (0, Hwnd := Control)
			GuiControlGet, Hwnd, % this.A.Gui ":Hwnd", % Control
		a := {CH:Hwnd, CN:Control, M:(Ex ~= "Draw" ? SWP_NOZORDER|SWP_NOCOPYBITS : SWP_NOZORDER), Section:!!(Ex ~= "Section")}
		b := StrSplit(Options, ",")
		for k, v in ["x", "y", "w", "h"]
			a[v] := StrSplit(b[k], "+")
		this.A.B.Push(a)
	}
	Resize(W = "", H = "") {
		If (W = "")
			this.GetClientSize(this.A.hGui, W, H) 
		this.s.cw := W - this.A.xm * 2 - this.A.cLeft - this.A.cRight
		this.s.ch := H - this.A.ym * 2 - this.A.cTop - this.A.cBottom
		hDWP := this.BeginDeferWindowPos(this.A.B.Count())
		for k, v in this.A.B
		{
			this.pr.prwp := this.pr.wp
			this.pr.prhp := this.pr.hp
			this.pr.wp := this.EvalSize("w", v.w)
			this.pr.hp := this.EvalSize("h", v.h)
			this.pr.xp := this.EvalPos("x", v.x)
			this.pr.yp := this.EvalPos("y", v.y)
			If v.Section
				for k2, v2 in ["x", "y", "w", "h"]
					this.pr[v2 "section"] := this.pr[v2 "p"]
			hDWP := this.DeferWindowPos(hDWP, v.CH, v.M, this.pr.xp + this.A["cLeft"], this.pr.yp + this.A["cTop"], this.pr.wp, this.pr.hp, 0)  
		}
		this.EndDeferWindowPos(hDWP)
	}
	EvalPos(n, a) {
		s := n = "x" ? "w" : "h", m := 1, ret := 0
		for k, v in a
		{
			If (v ~= "S)^-?\d+$") ;	Num
				ret += (v * m)
			Else If RegExMatch(v, "S)^(?<s>-)?r(?<d>\d+)$", _)  ;	rNum, -rNum
				ret += (this.s["c" s] * (_d / 1000)) * (_s ? -1 : 1) * m
			Else If RegExMatch(v, "S)^(?<s>-)?(?<d>(x|y)m)$", _)  ;	xm, -xm, ym, -ym
				ret += this.A[_d] * (_s ? -1 : 1) * m
			Else If (k = 1)
			{  
				If (v = n "p")  ;	xp, yp
					ret := this.pr[n "p"]
				Else If (v = n)  ;	x, y
					ret := this.pr[n "p"] + this.pr["pr" s "p"]
				Else If (v = "o")  ;	o
					ret := this.A[n "m"] + this.s["c" s] - this.pr[s "p"], m := -1
				Else If (v = n "s")  ;	xs, ys
					ret := this.pr[n "section"]
				Else If (v = n "so")  ;	xso, yso
					ret := this.pr[n "section"] + this.pr[s "section"]
			} 
			Else If RegExMatch(v, "S)(?<s>-)?(?<d>(w|h))(?<pr>p)?$", _)  ;	w, -w, wp, -wp, h, -h, hp, -hp
				ret += this.pr[(_pr ? "pr" : "") _d "p"] * (_s ? -1 : 1) * m
			Else If RegExMatch(v, "S)(?<s>-)?(?<d>(w|h))s$", _)  ;	ws, -ws, hs, -hs
				ret += this.pr[_d "section"] * (_s ? -1 : 1) * m
		} 
		Return ret
	}
	EvalSize(n, a) {
		for k, v in a, ret := 0
		{
			If (v ~= "S)^-?\d+$") ;	Num
				ret += v
			Else If RegExMatch(v, "S)^(?<s>-)?r(?<d>\d+)$", _)  ;	rNum, -rNum
				ret += this.s["c" n] * (_d / 1000) * (_s ? -1 : 1)
			Else If (v = n "p")  ;	wp, hp
				ret += this.pr["pr" n "p"]
			Else If (v = n "s")  ;	ws, hs
				ret += this.pr[n "section"] 
		}
		Return ret
	}
	SetArea(cLeft = 0, cTop = 0, cRight = 0, cBottom = 0) {
		this.A.cLeft := cLeft, this.A.cTop := cTop
		this.A.cRight := cRight, this.A.cBottom := cBottom
	}
	GetClientSize(hwnd, ByRef w, ByRef h) {
		Static _ := VarSetCapacity(pwi, 60, 0)
		DllCall("GetWindowInfo", "Ptr", hwnd, "Ptr", &pwi)
		w := NumGet(pwi, 28, "Int") - NumGet(pwi, 20, "Int")
		h := NumGet(pwi, 32, "Int") - NumGet(pwi, 24, "Int")
	}
	BeginDeferWindowPos(Count) {
		Return DllCall("BeginDeferWindowPos", "Int", Count) 
	}
	DeferWindowPos(hDWP, hWnd, flag, x = 0, y = 0, w = 0, h = 0, hWndInsertAfter = 0) {
		Return DllCall("DeferWindowPos"
			, "Ptr", hDWP, "Ptr", hWnd, "UInt", hWndInsertAfter
			, "Int", x, "Int", y, "Int", w, "Int", h
			, "UInt", flag)
	}
	EndDeferWindowPos(hDWP) {
		DllCall("EndDeferWindowPos", "Ptr", hDWP)
	}
} 


  
/*


#SingleInstance Force
#NoEnv
SetBatchLines -1

Gui, +Resize

Loop 100
	Gui, Add, Edit, vEL%A_Index%, %A_Index%

Gui1 := New AutoResize(1, "xm10 ym10")

Gui1.Item("EL1", "xm, ym, r20, r500")
Loop 49
	Gui1.Item("EL" A_Index + 1, "x, yp, wp, hp") 
	
Gui1.Item("EL51", "xm, y, wp, hp")
Loop 49
	Gui1.Item("EL" A_Index + 51, "x, yp, wp, hp") 

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








#SingleInstance Force
#NoEnv 
SetBatchLines -1

Gui, +Resize

Loop 10
	Gui, Add, Edit, vEL%A_Index%, %A_Index%

Gui1 := New AutoResize(1, "xm10 ym10")

Gui1.Item("EL1", "xm, ym, r450, r200")
Gui1.Item("EL2", "o, yp, wp, hp")

Gui1.Item("EL3", "xm, o, r150, r300", "Section")
Gui1.Item("EL4", "o, ys, ws, hs")
Gui1.Item("EL5", "xso + 10, o + r100, r700 - 20, r100")

Gui1.Item("EL6", "xm + r400, ym + r400, r200, r200", "Section")
Gui1.Item("EL7", "xs - w, ys - h, 20, 30")
Gui1.Item("EL8", "xs - w, yso, wp, hp") 
Gui1.Item("EL9", "xso, yso, wp, hp")
Gui1.Item("EL10", "xso, ys - h, wp, hp")

Gui, Show, x100 y100 w200 h200
Return 

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	Gui1.Resize(A_GuiWidth, A_GuiHeight)
	Return

GuiClose:
Escape:: ExitApp





*/
  
