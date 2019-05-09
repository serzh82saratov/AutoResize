Class AutoResize
{
	;  автор - serzh82saratov
	;  версия - 1.10
	;  13:23 09.05.2019
	;  https://github.com/serzh82saratov/AutoResize
	
	Static types := ["x", "y", "w", "h"]
	
	__New(Gui, Options = "") {
		Gui, %Gui%:+HWNDhGui
		this.A := {Gui:Gui, hGui:hGui, B:{}}
		this.ps := {xm:0, ym:0}, this.s := {cLeft:0, cTop:0, cRight:0, cBottom:0}
		this.Round := ObjBindMethod(this, "Return")
		If RegExMatch(Options, "(?<d>(Floor|Ceil|Round))", _)   ;	< Floor, > Ceil, <> Round
			this.Round := Func(_d)
		for k, v in ["xm", "ym"]
			RegExMatch(Options, "(?<Key>" v ")(?<Value>\d+)", _), this.ps[_Key] := _Value
	}
	Item(Control, Options, Ex = "") {
		Static SWP_NOZORDER := 0x0004, SWP_NOCOPYBITS := 0x0100
		Options := StrReplace(Options, " ")
		Options := StrReplace(Options, "-", "+-")
		If (Control + 0 = "") || (0, Hwnd := Control)
			GuiControlGet, Hwnd, % this.A.Gui ":Hwnd", % Control
		a := {CH:Hwnd, CN:Control, F:(Ex ~= "Draw" ? SWP_NOZORDER|SWP_NOCOPYBITS : SWP_NOZORDER), Section:!!(Ex ~= "Section")}
		b := StrSplit(Options, ",")
		for k, type in this.types
		{
			a[type] := []
			for k2, word in StrSplit(b[k], "+")
			{ 
				If (word ~= "S)^-?\d+$") ;	-, Num
					a[type].Push(["Num", word, 1])
				Else If RegExMatch(word, "S)^(?<s>-)?r(?<d>\d+)$", _)  ;	-, rNum
					a[type].Push(["R", _d, (_s ? -1 : 1)]) 
				Else If (k < 3) && (k2 = 1) && RegExMatch(word, "S)^(?<d>(x|y))$", _)  ;	x, y
					a[type].Push(["XY", _d])
				Else If (k < 3) && (k2 = 1) && (word = "o")  ;	o
					a[type].Push(["O"])
				Else If (k < 3) && RegExMatch(word, "S)^(?<d>(x|y)(m|p|s))$", _)  ;	xm, ym, xp, yp, xs, ys
					a[type].Push(["N", _d, 1])
				Else If (k < 3) && (k2 = 1) && RegExMatch(word, "S)^(?<d>(x|y)so)$", _)  ;	xso, yso
					a[type].Push(["SO"]) 
				Else If (k > 2) && (k2 = 1) && (word = "ro")  ;	RO
					a[type].Push(["RO"])
				Else If RegExMatch(word, "S)(?<s>-)?(?<d>(w|h)(p|s)?)(?<n>\d+(\.\d+)?)?$", _)  ;	-, w, wp, ws, h, hp, hs and Number
					a[type].Push(["WH", _d, (_s ? -1 : 1) * (_n ? _n : 1)])
				Else
					Throw Exception("Class AutoResize invalid option """ Format("{:U}", type) """ member: """ word """", -1)
			}
		}
		this.A.B.Push(a)
	}
	Resize(W = "", H = "") {
		If (W = "")
			this.GetClientSize(this.A.hGui, W, H)
		this.s.cw := W - this.ps.xm * 2 - this.s.cLeft - this.s.cRight
		this.s.ch := H - this.ps.ym * 2 - this.s.cTop - this.s.cBottom
		hDWP := this.BeginDeferWindowPos(this.A.B.Count())
		for k, v in this.A.B
		{
			this.ps.w := this.EvalSize("w", v.w, "x")
			this.ps.h := this.EvalSize("h", v.h, "y")
			this.ps.x := this.EvalPos("x", v.x, "w")
			this.ps.y := this.EvalPos("y", v.y, "h")
			
			for k2, type in this.types
				this.ps[type "p"] := this.ps[type]
				, v.Section && this.ps[type "s"] := this.ps[type]
				
			hDWP := this.DeferWindowPos(hDWP, v.CH, v.F, this.ps.x + this.s.cLeft, this.ps.y + this.s.cTop, this.ps.w, this.ps.h)
		}
		this.EndDeferWindowPos(hDWP)
	}
	EvalPos(n, a, s, m = 1, ret = 0) {
		for k, v in a
		{ 
			If (v[1] = "XY")  ;	first
				ret := this.ps[n "p"] + this.ps[s "p"]
			Else If (v[1] = "N")
				ret += this.ps[v[2]]
			Else If (v[1] = "Num")
				ret += v[2] * v[3] * m
			Else If (v[1] = "R")
				ret += this.Round.Call((this.s["c" s] * (v[2] / 1000)) * v[3] * m)
			Else If (v[1] = "WH")
				ret += this.ps[v[2]] * v[3] * m
			Else If (v[1] = "O")  ;	first
				ret := this.ps[n "m"] + this.s["c" s] - this.ps[s], m := -1
			Else If (v[1] = "SO")  ;	first
				ret := this.ps[n "s"] + this.ps[s "s"]
		}
		Return ret
	}
	EvalSize(n, a, s, ret = 0) {
		for k, v in a
		{
			If (v[1] = "WH")
				ret += this.ps[v[2]] * v[3]
			Else If (v[1] = "R") 
				ret += this.Round.Call(this.s["c" n] * (v[2] / 1000) * v[3])
			Else If (v[1] = "Num")
				ret += v[2]
			Else If (v[1] = "RO")  ;	first
				ret := this.s["c" n] - (this.ps[s "p"] + this.ps[n "p"])
		}
		Return ret
	}
	Return(n) {
		Return n
	}
	SetArea(cLeft = 0, cTop = 0, cRight = 0, cBottom = 0) {
		this.s.cLeft := cLeft, this.s.cTop := cTop
		this.s.cRight := cRight, this.s.cBottom := cBottom
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
