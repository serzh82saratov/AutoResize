Class AutoResize
{
	;  автор - serzh82saratov
	;  версия - 2.01
	;  18:55 23.05.2019
	;  https://github.com/serzh82saratov/AutoResize
	;  http://forum.script-coding.com/viewtopic.php?id=14782

	Static types := ["x", "y", "w", "h"], oArea := ["Left", "Top", "Right", "Bottom"]

	__New(Gui, Options = "") {
		Gui, %Gui%:+HWNDhGui
		this.A := {Gui:Gui, hGui:hGui, B:{}}, this.ItemsIndex := {}
		this.ps := {xm:0, ym:0}, this.s := {Left:0, Top:0, Right:0, Bottom:0}, this.Save := {}
		this.Round := ObjBindMethod(this, "Return")
		If RegExMatch(Options, "(?<d>(Floor|Ceil|Round))", _)   ;	< Floor, > Ceil, <> Round
			this.Round := Func(_d)
		for k, v in ["xm", "ym"]
			RegExMatch(Options, "(?<Key>" v ")(?<Value>\d+)", _), this.ps[_Key] := _Value
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
	RemoveItem(Control, Destroy = 0) {
		If Destroy
			DllCall("DestroyWindow", "Ptr", this.A.B[this.ItemsIndex[Control]].CH)
		this.A.B.RemoveAt(this.ItemsIndex[Control])
		this.ItemsIndex.Delete(Control)
	}
	InsertItem(ControlOff, Control, Options, Ex = "") {
		this.A.B.InsertAt(Off := this.ItemsIndex[ControlOff], this.StrToItem(Control, Options, Ex))
		for k, v in this.ItemsIndex
			If (v >= Off)
				this.ItemsIndex[k] := v + 1
		this.ItemsIndex[Control] := Off
	}
	StrToItem(Control, Options, Ex) {
		Static SWP_NOZORDER := 0x0004, SWP_NOCOPYBITS := 0x0100
		GuiControlGet, Hwnd, % this.A.Gui ":Hwnd", % Control
		If !Hwnd
			Throw Exception("Undefined handle for """ Control """, in gui """ this.A.Gui """", -2)
		a := {CH:Hwnd, CN:Control, F:(Ex ~= "Draw" ? SWP_NOZORDER|SWP_NOCOPYBITS : SWP_NOZORDER), Section:!!(Ex ~= "Section"), Save:!!(Ex ~= "Save")}
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
				(word ~= "S)^-") ? (word := SubStr(word, 2), s := "-") : (s := "")

				If (word ~= "S)^\d+$") ; Num
					a[type].Push(["Num", s word])
				Else If RegExMatch(word, "S)^r(?<d>\d+)$", _)  ; rNum
					a[type].Push(["R", s (_d / 1000)])
				Else If (word = "r")  ; r
					a[type].Push(["R", s 1])
				Else If RegExMatch(word, "S)^(?<d>(x|y))$", _)  ;	x, y
					a[type].Push(["XY", _d, s])
				Else If (word = "o") && (k < 3) && (k2 = 1)  ;	o only xy
					a[type].Push(["O"])
				Else If RegExMatch(word, "S)^(?<d>(x|y)(m|p|s))$", _)  ;	xm, ym, xp, yp, xs, ys
					a[type].Push(["N", _d, s])
				Else If RegExMatch(word, "S)^(?<d>(x|y))so$", _)  ;	xso, yso
					a[type].Push(["SO", _d, s])
				Else If (word = "ro") && (k > 2) && (k2 = 1)  ;	ro only wh
					a[type].Push(["RO"])
				Else If RegExMatch(word, "S)^\*(?<d>\d+(\.\d+)?)$", _)  ;	Mult
					a[type].Push(["Mult", _d])
				Else If RegExMatch(word, "S)^\/(?<d>\d+(\.\d+)?)$", _)  ;	Div
					a[type].Push(["Mult", 1 / _d])
				Else If RegExMatch(word, "S)^(?<d>(w|h)(p|s)?)(?<n>\d+(\.\d+)?)?$", _)  ; w, wp, ws, h, hp, hs and Number
					a[type].Push(["WH", _d, s (_n ? _n : 1)])
				Else
					Throw Exception("Class AutoResize invalid option """ Format("{:U}", type) """ member: """ word """", -2)
			}
		}
		Return a
	}
	Resize(W = "", H = "") {
		If this.Block
			Return
		If (W = "" || H = "")
			this.GetClientSize(this.A.hGui, W, H)
		this.CreateWorkArea(W, H)
		this.s.cw := W - this.s.WOFF
		this.s.ch := H - this.s.HOFF
		hDWP := this.BeginDeferWindowPos(this.A.B.Count())
		for k, v in this.A.B
		{
			this.ps.w := this.Eval(v.w, "w", "x", "w")
			this.ps.h := this.Eval(v.h, "h", "y", "h")
			this.ps.x := this.Eval(v.x, "x", "w", "w")
			this.ps.y := this.Eval(v.y, "y", "h", "h")

			X := this.ps.x + this.s.Left
			Y := this.ps.y + this.s.Top

			for k2, type in this.types
				this.ps[type "p"] := this.ps[type]

			If v.Save
				this.Save[v.CN] := {Left: X, Top: Y, Right: W - X - this.ps.w, Bottom: H - Y - this.ps.h, Width: this.ps.w, Height: this.ps.h}

			If v.Section
				for k2, type in this.types
					this.ps[type "s"] := this.ps[type]

			hDWP := this.DeferWindowPos(hDWP, v.CH, v.F, X, Y, this.ps.w, this.ps.h)
		}
		this.EndDeferWindowPos(hDWP)
	}
	Eval(arr, type, vec, side, ret = 0) {
		for k, v in arr
		{
			If (v[1] = "N")
				ret += v[3] this.ps[v[2]]
			Else If (v[1] = "WH")
				ret += m this.ps[v[2]] * v[3]
			Else If (v[1] = "R")
				ret += m this.Round.Call((this.s["c" side] * v[2]))
			Else If (v[1] = "Num")
				ret += m v[2]
			Else If (v[1] = "XY")
				ret += v[3] (this.ps[v[2] "p"] + this.ps[side "p"])
			Else If (v[1] = "Mult")
				ret *= v[2]
			Else If (v[1] = "SO")
				ret += v[3] (this.ps[v[2] "s"] + this.ps[side "s"])
			Else If (v[1] = "O")  ;	first only xy
				ret := this.ps[type "m"] + this.s["c" vec] - this.ps[vec], m := "-"
			Else If (v[1] = "RO")  ;	first only wh
				ret := Ceil(this.ps[vec "m"] + (this.s["c" type] - (this.ps[vec "p"] + this.ps[type "p"])))
		}
		Return ret
	}
	Return(n) {
		Return n
	}
	GetPos(Control, byref Left = "", byref Top = "", byref Right = "", byref Bottom = "", byref Width = "", byref Height = "") {
		GuiControlGet, _, % this.A.Gui ":Pos", %Control%
		Left := _X, Top := _Y, Right := _X + _W, Bottom := _Y + _H
		IsByRef(Width) && Width := _W, Height := _H
	}
	GetArea(Control, byref Left = "", byref Top = "", byref Right = "", byref Bottom = "", byref Width = "", byref Height = "") {
		Left := this.Save[Control].Left, Top := this.Save[Control].Top
		Right := this.Save[Control].Right, Bottom := this.Save[Control].Bottom
		IsByRef(Width) && Width := this.Save[Control].Width, Height := this.Save[Control].Height
	}
	SetArea(coords*) {
		this.sa := {}
		for k, v in this.oArea
		{
			a := coords[k]
			If (a + 0 != "")
				this.s[v] := a
			Else If (a = "")
				this.s[v] := 0
			Else If RegExMatch(a, "S)^r(?<d>\d+)$", _)
				this.sa[v] := (_d / 1000)
			Else
				Throw Exception("Class AutoResize invalid option """ this.oArea[k] """ member: """ a """", -1) 
		}
	}
	CreateWorkArea(W, H) {
		for k, v in this.sa
			this.s[k] := this.Round.Call(v * (k = "Left" || k = "Right" ? W : H))
		this.s.WOFF := this.s.Left + this.s.Right + this.ps.xm * 2
		this.s.HOFF := this.s.Top + this.s.Bottom + this.ps.ym * 2
	}
	IsCurrentArea(W = "", H = "") {
		If (W = "" || H = "")
			this.GetClientSize(this.A.hGui, W, H)
		Return (W = this.s.cw + this.s.WOFF && H = this.s.ch + this.s.HOFF)
	}
	Show(Show = 1) {
		Static SWP_NOSIZE := 0x0001, SWP_NOMOVE := 0x0002, SWP_SHOWWINDOW := 0x0040, SWP_HIDEWINDOW := 0x0080
		F := SWP_NOSIZE | SWP_NOMOVE | (Show ? SWP_SHOWWINDOW : SWP_HIDEWINDOW)
		hDWP := this.BeginDeferWindowPos(this.A.B.Count())
		for k, v in this.A.B
			hDWP := this.DeferWindowPos(hDWP, v.CH, F | v.F)
		this.EndDeferWindowPos(hDWP)
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
