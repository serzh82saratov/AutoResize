Class AutoResize
{
	;  автор - serzh82saratov
	;  версия - 1.21
	;  04:57 15.05.2019
	;  https://github.com/serzh82saratov/AutoResize
	
	Static types := ["x", "y", "w", "h"]
	
	__New(Gui, Options = "") {
		Gui, %Gui%:+HWNDhGui
		this.A := {Gui:Gui, hGui:hGui, B:{}}, this.ItemsIndex := {}
		this.ps := {xm:0, ym:0}, this.s := {cLeft:0, cTop:0, cRight:0, cBottom:0}
		this.Round := ObjBindMethod(this, "Return")
		If RegExMatch(Options, "(?<d>(Floor|Ceil|Round))", _)   ;	< Floor, > Ceil, <> Round
			this.Round := Func(_d)
		for k, v in ["xm", "ym"]
			RegExMatch(Options, "(?<Key>" v ")(?<Value>\d+)", _), this.ps[_Key] := _Value 
		this.SetWHOff()
	}
	Item(Control, Options, Ex = "") {
		this.ItemsIndex[Control] := this.A.B.Count() + 1
		this.A.B.Push(this.StrToItem(Control, Options, Ex))
	}
	SetItem(Control, Options, Ex = "") {
		If !(i := this.ItemsIndex[Control])
			Return
		this.A.B[i] := this.StrToItem(Control, Options, Ex)
	}
	RemoveItem(Control) {
		this.A.B.RemoveAt(this.ItemsIndex[Control])
		this.ItemsIndex.Delete(Control)
	}
	InsertItem(ControlOff, Control, Options, Ex = "") {
		this.A.B.InsertAt(Off := this.ItemsIndex[ControlOff], this.StrToItem(Control, Options, Ex))
		this.ItemsIndex[Control] := Off
		for k, v in this.ItemsIndex
			If (A_Index > Off)
				this.ItemsIndex[k] := A_Index + 1
	}
	StrToItem(Control, Options, Ex) {
		Static SWP_NOZORDER := 0x0004, SWP_NOCOPYBITS := 0x0100
		If (Control + 0 = "") || (0, Hwnd := Control)
			GuiControlGet, Hwnd, % this.A.Gui ":Hwnd", % Control
		If !Hwnd
			Throw Exception("Undefined handle for """ Control """, in gui """ this.A.Gui """")
		a := {CH:Hwnd, CN:Control, F:(Ex ~= "Draw" ? SWP_NOZORDER|SWP_NOCOPYBITS : SWP_NOZORDER), Section:!!(Ex ~= "Section")}
		Options := StrReplace(Options, " ")
		Options := StrReplace(Options, "-", "+-")
		Options := StrReplace(Options, "*", "+*")
		Options := StrReplace(Options, "/", "+/")
		Options := Trim(Options, "+")
		b := StrSplit(Options, ",")
		for k, type in this.types
		{
			a[type] := []
			for k2, word in StrSplit(b[k], "+")
			{ 
				If (word ~= "S)^-?\d+$") ;	-, Num
					a[type].Push(["Num", word, 1])
				Else If RegExMatch(word, "S)^(?<s>-)?r(?<d>\d+)$", _)  ;	-, rNum
					a[type].Push(["R", _d / 1000 * (_s ? -1 : 1)]) 
				Else If RegExMatch(word, "S)^(?<d>(x|y))$", _) && (k < 3) && (k2 = 1)  ;	x, y
					a[type].Push(["XY", _d])
				Else If (word = "o") && (k < 3) && (k2 = 1)  ;	o
					a[type].Push(["O"])
				Else If RegExMatch(word, "S)^(?<d>(x|y)(m|p|s))$", _) && (k < 3)  ;	xm, ym, xp, yp, xs, ys
					a[type].Push(["N", _d, 1])
				Else If RegExMatch(word, "S)^(?<d>(x|y)so)$", _) && (k < 3) && (k2 = 1)  ;	xso, yso
					a[type].Push(["SO"])
				Else If (word = "ro") && (k > 2) && (k2 = 1)  ;	RO
					a[type].Push(["RO"])
				Else If RegExMatch(word, "S)^\*(?<d>\d+(\.\d+)?)$", _)  ;	Mult
					a[type].Push(["Mult", _d])
				Else If RegExMatch(word, "S)^\/(?<d>\d+(\.\d+)?)$", _)  ;	Div
					a[type].Push(["Mult", 1 / _d])
				Else If RegExMatch(word, "S)^(?<s>-)?(?<d>(w|h)(p|s)?)(?<n>\d+(\.\d+)?)?$", _)  ;	-, w, wp, ws, h, hp, hs and Number
					a[type].Push(["WH", _d, (_s ? -1 : 1) * (_n ? _n : 1)])
				Else
					Throw Exception("Class AutoResize invalid option """ Format("{:U}", type) """ member: """ word """", -1)
			}
		}
		Return a
	}
	Resize(W = "", H = "") {
		If this.Block
			Return
		If (W = "")
			this.GetClientSize(this.A.hGui, W, H) 
		this.s.cw := W - this.s.WOFF
		this.s.ch := H - this.s.HOFF
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
				ret += this.Round.Call((this.s["c" s] * v[2]) * m)
			Else If (v[1] = "WH")
				ret += this.ps[v[2]] * v[3] * m
			Else If (v[1] = "O")  ;	first
				ret := this.ps[n "m"] + this.s["c" s] - this.ps[s], m := -1
			Else If (v[1] = "SO")  ;	first
				ret := this.ps[n "s"] + this.ps[s "s"]
			Else If (v[1] = "Mult")
				ret *= v[2]
		} 
		Return ret
	}
	EvalSize(n, a, s, ret = 0) {
		for k, v in a
		{
			If (v[1] = "WH")
				ret += this.ps[v[2]] * v[3]
			Else If (v[1] = "R") 
				ret += this.Round.Call(this.s["c" n] * v[2])
			Else If (v[1] = "Num")
				ret += v[2]
			Else If (v[1] = "RO")  ;	first
				ret := Ceil(this.s["c" n] - (this.ps[s "p"] + this.ps[n "p"]))
			Else If (v[1] = "Mult")
				ret *= v[2]
		}
		Return ret
	}
	Return(n) {
		Return n
	}
	Show(Show = 1) {
		Static SWP_NOSIZE := 0x0001, SWP_NOMOVE := 0x0002, SWP_SHOWWINDOW := 0x0040, SWP_HIDEWINDOW := 0x0080 
		F := SWP_NOSIZE | SWP_NOMOVE | (Show ? SWP_SHOWWINDOW : SWP_HIDEWINDOW)
		hDWP := this.BeginDeferWindowPos(this.A.B.Count())
		for k, v in this.A.B
			hDWP := this.DeferWindowPos(hDWP, v.CH, F | v.F)
		this.EndDeferWindowPos(hDWP)
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
	SetArea(cLeft = 0, cTop = 0, cRight = 0, cBottom = 0) {
		this.s.cLeft := cLeft, this.s.cTop := cTop
		this.s.cRight := cRight, this.s.cBottom := cBottom
		this.SetWHOff()
	}
	SetWHOff() {
		this.s.WOFF := this.s.cLeft + this.s.cRight + this.ps.xm * 2
		this.s.HOFF := this.s.cTop + this.s.cBottom + this.ps.ym * 2
	} 
	GetClientSize(hwnd, ByRef w, ByRef h) {
		Static _ := VarSetCapacity(pwi, 60, 0)
		DllCall("GetWindowInfo", "Ptr", hwnd, "Ptr", &pwi)
		w := NumGet(pwi, 28, "Int") - NumGet(pwi, 20, "Int")
		h := NumGet(pwi, 32, "Int") - NumGet(pwi, 24, "Int")
	}
}
