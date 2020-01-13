Class AutoResize
Class AutoResize
{
	;  автор - serzh82saratov
	;  версия - 3.04
	;  22:36 12.06.2019
	;  https://github.com/serzh82saratov/AutoResize
	;  http://forum.script-coding.com/viewtopic.php?id=14782

	Static types := ["x", "y", "w", "h"], oArea := ["Left", "Top", "Right", "Bottom"]

	__New(Gui, Options = "") {
		Local
		If (Options ~= "Foreign")
			this.Foreign := 1, hGui := Gui
		Else
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
		Local
		this.ItemsIndex[Control] := this.A.B.Count() + 1
		this.A.B.Push(this.StrToItem(Control, Options, Ex))
	}
	SetItem(Control, Options, Ex = "") {
		Local
		If !(i := this.ItemsIndex[Control])
			Throw Exception("Undefined control """ Control """, in gui """ this.A.Gui """", -1)
		this.A.B[i] := this.StrToItem(Control, Options, Ex)
	}
	RemoveItem(Control, Destroy = 0) {
		Local
		If Destroy
			DllCall("DestroyWindow", "Ptr", this.A.B[this.ItemsIndex[Control]].CH)
		this.A.B.RemoveAt(this.ItemsIndex[Control])
		this.ItemsIndex.Delete(Control)
	}
	InsertItem(ControlOff, Control, Options, Ex = "") {
		Local
		this.A.B.InsertAt(Off := this.ItemsIndex[ControlOff], this.StrToItem(Control, Options, Ex))
		for k, v in this.ItemsIndex
			If (v >= Off)
				this.ItemsIndex[k] := v + 1
		this.ItemsIndex[Control] := Off
	}
	StrToItem(Control, Options, Ex) {
		Static SWP_NOZORDER := 0x0004, SWP_NOCOPYBITS := 0x0100
		Local
		If this.Foreign
			Hwnd := Control
		Else
			GuiControlGet, Hwnd, % this.A.Gui ":Hwnd", % Control
		If !Hwnd
			Throw Exception("Undefined handle for """ Control """, in gui """ this.A.Gui """", -2)
		a := {CH: Hwnd, CN: Control, F: (Ex ~= "Draw" ? SWP_NOZORDER|SWP_NOCOPYBITS : SWP_NOZORDER), Section: !!(Ex ~= "Section"), Save: !!(Ex ~= "Save")}
		Options := StrReplace(Options, " ")
		Options := StrReplace(Options, "-", "+-")
		Options := StrReplace(Options, "*", "+*")
		Options := StrReplace(Options, "/", "+/")
		Options := StrReplace(Options, ">", "+>+")
		Options := Trim(Options, "+")
		b := StrSplit(Options, ",")

		for k, type in this.types
		{
			a[type] := []
			for k2, word in StrSplit(b[k], "+")
			{
				(word ~= "S)^-") ? (word := SubStr(word, 2), s := "-") : (s := "")

				If (word ~= "S)^\d+$") ; Num
					result := ["Num", s word]
				Else If RegExMatch(word, "iS)^r(?<d>\d+)$", _)  ; rNum
					result := ["R", s (_d / 1000)]
				Else If (word ~= "i)^R$")  ; R
					result := ["R", s 1]
				Else If RegExMatch(word, "iS)^(?<d>(x|y))$", _)  ;	x, y
					result := ["SPO", _d, "p", s]
				Else If RegExMatch(word, "iS)^(?<d>(x|y)(m|p|s))$", _)  ;	xm, ym, xp, yp, xs, ys
					result := ["N", _d, s]
				Else If RegExMatch(word, "iS)^(?<d>(x|y))(?<n>(p|s))o$", _)  ;	xso, yso, xpo, ypo
					result := ["SPO", _d, _n, s]
				Else If RegExMatch(word, "iS)^(?<d>(w|h)(p|s)?)(?<n>\d+(\.\d+)?)?$", _)  ; w, wp, ws, h, hp, hs and Number
					result := ["WH", _d, s (_n ? _n : 1)]
				Else If (word ~= "i)^Z$") && (k < 3)  ; Z only xy
					result := ["Z"]
				Else If (word ~= "i)^O$") && (k < 3) && (k2 = 1)  ;	O only xy
					result := ["O"]
				Else If (word ~= "i)^RO$") && (k > 2) && (k2 = 1)  ;	RO only wh
					result := ["RO"]
				Else If RegExMatch(word, "iS)^\*(?<d>\d+(\.\d+)?)$", _)  ;	Mult
					result := ["Mult", _d]
				Else If RegExMatch(word, "iS)^\/(?<d>\d+(\.\d+)?)$", _)  ;	Div
					result := ["Mult", 1 / _d]

				Else If !Region && (word = ">")  ; Region
					Region := k2, oRegion := []
				Else If (word ~= "i)^P$" && Region + 1 = k2)  ; P
					result := ["N", type, s]

				Else If (word ~= "i)^D$")  ; D
					result := ["Debug", prword]
				Else
					Throw Exception("Class AutoResize invalid option """ Format("{:U}", type) """ member: """ word """", -2)

				If !Region
					a[type].Push(result)
				Else If (k2 > Region)
					oRegion.Push(result)
				prword := word
			}
			If Region
				a[type][Region] := ["Region", oRegion], Region := 0
		}
		Return a
	}
	Resize(W = "", H = "") {
		Local
		If this.Block
			Return
		If (W = "" || H = "")
			this.GetClientSize(this.A.hGui, W, H)
		this.CreateWorkArea(W, H)
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
		Local
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
			Else If (v[1] = "SPO")
				ret += v[4] (this.ps[v[2] v[3]] + this.ps[side v[3]])
			Else If (v[1] = "Mult")
				ret *= v[2]
			Else If (v[1] = "Z")  ;	Z only xy
				ret += this.ps[type "m"] + this.s["c" side]
			Else If (v[1] = "RO")  ;	first only wh
				ret := Ceil(this.ps[vec "m"] + (this.s["c" type] - (this.ps[vec "p"] + this.ps[type "p"])))
			Else If (v[1] = "O")  ;	first only xy
				ret := this.ps[type "m"] + this.s["c" vec] - this.ps[vec], m := "-"

			Else If (v[1] = "Region")
				Return this.ps[type] := ret, this.ps[vec] := this.Eval(v[2], type, vec, side) - ret

			Else If (v[1] = "Debug")
				MsgBox % "Результат: " ret "`n type: " type  "`n prior word: " v[2]
					. "`n w: " this.ps.w "`n h: " this.ps.h
					. "`n x: " this.ps.x "`n y: " this.ps.y
					. "`n Ширина РЗ: " this.s.cw "`n Высота РЗ: " this.s.ch
		}
		Return ret
	}
	Return(n) {
		Return n
	}
	GetPos(Control, byref Left = "", byref Top = "", byref Right = "", byref Bottom = "", byref Width = "", byref Height = "") {
		Local
		GuiControlGet, _, % this.A.Gui ":Pos", %Control%
		Left := _X, Top := _Y, Right := _X + _W, Bottom := _Y + _H
		IsByRef(Width) && Width := _W, Height := _H
	}
	GetArea(Control, byref Left = "", byref Top = "", byref Right = "", byref Bottom = "", byref Width = "", byref Height = "") {
		Local
		Left := this.Save[Control].Left, Top := this.Save[Control].Top
		Right := this.Save[Control].Right, Bottom := this.Save[Control].Bottom
		IsByRef(Width) && Width := this.Save[Control].Width, Height := this.Save[Control].Height
	}
	SetArea(coords*) {
		Local
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
	CreateWorkArea(W, H, byref cw = "", byref ch = "") {
		Local
		for k, v in this.sa
			this.s[k] := this.Round.Call(v * (k = "Left" || k = "Right" ? W : H))
		this.s.WOFF := this.s.Left + this.s.Right + this.ps.xm * 2
		this.s.HOFF := this.s.Top + this.s.Bottom + this.ps.ym * 2
		this.s.cw := W - this.s.WOFF, this.s.ch := H - this.s.HOFF
	}
	IsCurrentArea(W = "", H = "") {
		Local
		If (W = "" || H = "")
			this.GetClientSize(this.A.hGui, W, H)
		Return (W = this.s.cw + this.s.WOFF && H = this.s.ch + this.s.HOFF)
	}
	Show(Show = 1) {
		Static SWP_NOSIZE := 0x0001, SWP_NOMOVE := 0x0002, SWP_SHOWWINDOW := 0x0040, SWP_HIDEWINDOW := 0x0080
		Local
		F := SWP_NOSIZE | SWP_NOMOVE | (Show ? SWP_SHOWWINDOW : SWP_HIDEWINDOW)
		hDWP := this.BeginDeferWindowPos(this.A.B.Count())
		for k, v in this.A.B
			hDWP := this.DeferWindowPos(hDWP, v.CH, F | v.F)
		this.EndDeferWindowPos(hDWP)
	}
	GetClientSize(hwnd, ByRef w, ByRef h) {
		Static pwi, _ := VarSetCapacity(pwi, 60, 0)
		Local
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
		Local
		GuiControlGet, Hwnd, % this.A.Gui ":Hwnd", % Control
		If !Hwnd
			Throw Exception("Undefined handle for """ Control """, in gui """ this.A.Gui """", -2)
		a := {CH: Hwnd, CN: Control, F: (Ex ~= "Draw" ? SWP_NOZORDER|SWP_NOCOPYBITS : SWP_NOZORDER), Section: !!(Ex ~= "Section"), Save: !!(Ex ~= "Save")}
		Options := StrReplace(Options, " ")
		Options := StrReplace(Options, "-", "+-")
		Options := StrReplace(Options, "*", "+*")
		Options := StrReplace(Options, "/", "+/")
		Options := StrReplace(Options, ">", "+>+")
		Options := Trim(Options, "+")
		b := StrSplit(Options, ",")

		for k, type in this.types
		{
			a[type] := []
			for k2, word in StrSplit(b[k], "+")
			{
				(word ~= "S)^-") ? (word := SubStr(word, 2), s := "-") : (s := "")

				If (word ~= "S)^\d+$") ; Num
					result := ["Num", s word]
				Else If RegExMatch(word, "iS)^r(?<d>\d+)$", _)  ; rNum
					result := ["R", s (_d / 1000)]
				Else If (word ~= "i)^R$")  ; R
					result := ["R", s 1]
				Else If RegExMatch(word, "iS)^(?<d>(x|y))$", _)  ;	x, y
					result := ["SPO", _d, "p", s]
				Else If RegExMatch(word, "iS)^(?<d>(x|y)(m|p|s))$", _)  ;	xm, ym, xp, yp, xs, ys
					result := ["N", _d, s]
				Else If RegExMatch(word, "iS)^(?<d>(x|y))(?<n>(p|s))o$", _)  ;	xso, yso, xpo, ypo
					result := ["SPO", _d, _n, s]
				Else If RegExMatch(word, "iS)^(?<d>(w|h)(p|s)?)(?<n>\d+(\.\d+)?)?$", _)  ; w, wp, ws, h, hp, hs and Number
					result := ["WH", _d, s (_n ? _n : 1)]
				Else If (word ~= "i)^Z$") && (k < 3)  ; Z only xy
					result := ["Z"]
				Else If (word ~= "i)^O$") && (k < 3) && (k2 = 1)  ;	O only xy
					result := ["O"]
				Else If (word ~= "i)^RO$") && (k > 2) && (k2 = 1)  ;	RO only wh
					result := ["RO"]
				Else If RegExMatch(word, "iS)^\*(?<d>\d+(\.\d+)?)$", _)  ;	Mult
					result := ["Mult", _d]
				Else If RegExMatch(word, "iS)^\/(?<d>\d+(\.\d+)?)$", _)  ;	Div
					result := ["Mult", 1 / _d]

				Else If !Region && (word = ">")  ; Region
					Region := k2, oRegion := []
				Else If (word ~= "i)^P$" && Region + 1 = k2)  ; P
					result := ["N", type, s]

				Else If (word ~= "i)^D$")  ; D
					result := ["Debug", prword]
				Else
					Throw Exception("Class AutoResize invalid option """ Format("{:U}", type) """ member: """ word """", -2)

				If !Region
					a[type].Push(result)
				Else If (k2 > Region)
					oRegion.Push(result)
				prword := word
			}
			If Region
				a[type][Region] := ["Region", oRegion], Region := 0
		}
		Return a
	}
	Resize(W = "", H = "") {
		Local
		If this.Block
			Return
		If (W = "" || H = "")
			this.GetClientSize(this.A.hGui, W, H)
		this.CreateWorkArea(W, H)
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
		Local
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
			Else If (v[1] = "SPO")
				ret += v[4] (this.ps[v[2] v[3]] + this.ps[side v[3]])
			Else If (v[1] = "Mult")
				ret *= v[2]
			Else If (v[1] = "Z")  ;	Z only xy
				ret += this.ps[type "m"] + this.s["c" side]
			Else If (v[1] = "RO")  ;	first only wh
				ret := Ceil(this.ps[vec "m"] + (this.s["c" type] - (this.ps[vec "p"] + this.ps[type "p"])))
			Else If (v[1] = "O")  ;	first only xy
				ret := this.ps[type "m"] + this.s["c" vec] - this.ps[vec], m := "-"

			Else If (v[1] = "Region")
				Return ret, this.ps[vec] := this.Eval(v[2], type, vec, side) - ret

			Else If (v[1] = "Debug")
				MsgBox % "Результат: " ret "`n type: " type  "`n prior word: " v[2]
					. "`n w: " this.ps.w "`n h: " this.ps.h
					. "`n x: " this.ps.x "`n y: " this.ps.y
					. "`n Ширина РЗ: " this.s.cw "`n Высота РЗ: " this.s.ch
		}
		Return ret
	}
	Return(n) {
		Return n
	}
	GetPos(Control, byref Left = "", byref Top = "", byref Right = "", byref Bottom = "", byref Width = "", byref Height = "") {
		Local
		GuiControlGet, _, % this.A.Gui ":Pos", %Control%
		Left := _X, Top := _Y, Right := _X + _W, Bottom := _Y + _H
		IsByRef(Width) && Width := _W, Height := _H
	}
	GetArea(Control, byref Left = "", byref Top = "", byref Right = "", byref Bottom = "", byref Width = "", byref Height = "") {
		Local
		Left := this.Save[Control].Left, Top := this.Save[Control].Top
		Right := this.Save[Control].Right, Bottom := this.Save[Control].Bottom
		IsByRef(Width) && Width := this.Save[Control].Width, Height := this.Save[Control].Height
	}
	SetArea(coords*) {
		Local
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
	CreateWorkArea(W, H, byref cw = "", byref ch = "") {
		Local
		for k, v in this.sa
			this.s[k] := this.Round.Call(v * (k = "Left" || k = "Right" ? W : H))
		this.s.WOFF := this.s.Left + this.s.Right + this.ps.xm * 2
		this.s.HOFF := this.s.Top + this.s.Bottom + this.ps.ym * 2
		this.s.cw := W - this.s.WOFF, this.s.ch := H - this.s.HOFF
	}
	IsCurrentArea(W = "", H = "") {
		Local
		If (W = "" || H = "")
			this.GetClientSize(this.A.hGui, W, H)
		Return (W = this.s.cw + this.s.WOFF && H = this.s.ch + this.s.HOFF)
	}
	Show(Show = 1) {
		Static SWP_NOSIZE := 0x0001, SWP_NOMOVE := 0x0002, SWP_SHOWWINDOW := 0x0040, SWP_HIDEWINDOW := 0x0080
		Local
		F := SWP_NOSIZE | SWP_NOMOVE | (Show ? SWP_SHOWWINDOW : SWP_HIDEWINDOW)
		hDWP := this.BeginDeferWindowPos(this.A.B.Count())
		for k, v in this.A.B
			hDWP := this.DeferWindowPos(hDWP, v.CH, F | v.F)
		this.EndDeferWindowPos(hDWP)
	}
	GetClientSize(hwnd, ByRef w, ByRef h) {
		Static _ := VarSetCapacity(pwi, 60, 0)
		Local
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
