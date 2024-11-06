/************************************************************************
 * @description Auto-Jelly is a macro for the game Bee Swarm Simulator on Roblox. It automatically rolls bees for mutations and stops when a bee with the desired mutation is found. It also has the ability to stop on mythic and gifted bees.
 * @file auto-jelly.ahk
 * @author ninju | .ninju.
 * @date 2024/07/24
 * @version 0.0.1
 ***********************************************************************/

#SingleInstance Force
#Requires AutoHotkey v2.0
#Warn VarUnset, Off
;=============INCLUDES=============
#Include %A_ScriptDir%\lib\Gdip_All.ahk
#include %A_ScriptDir%\lib\Roblox.ahk
#include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk
#include %A_ScriptDir%\lib\Gdip_PixelSearch.ahk
#Include %A_ScriptDir%\lib\OCR.ahk
#Include %A_ScriptDir%\lib\DarkMsgbox.ahk
;==================================
CoordMode('Pixel', 'Screen')
CoordMode('Mouse', 'Screen')
;==================================
TraySetIcon('images/logo.ico')
;==================================
pToken := Gdip_Startup(), autoNeonberry := 0, neonberryX := 0, neonberryY := 0
OnExit((*) => (closefunction()), -1)
OnError (e, mode) => (mode = "Return") ? -1 : 0
stopToggle(*) {
	global stopping := true
}
if A_ScreenDPI !== 96
	throw Error("This macro requires a display-scale of 100%")
traySetIcon(".\nm_image_assets\auryn.ico")
sendMode("event")
getConfig() {
	global
	local k, v, p, c, i, section, key, value, inipath, config, f, ini
	config := {
		mutations: {
			Mutations: 0,
			Ability: 0,
			Gather: 0,
			Convert: 0,
			Energy: 0,
			Movespeed: 0,
			Crit: 0,
			Instant: 0,
			Attack: 0
		},
		bees: {
			Bomber: 0,
			Brave: 0,
			Bumble: 0,
			Cool: 0,
			Hasty: 0,
			Looker: 0,
			Rad: 0,
			Rascal: 0,
			Stubborn: 0,
			Bubble: 0,
			Bucko: 0,
			Commander: 0,
			Demo: 0,
			Exhausted: 0,
			Fire: 0,
			Frosty: 0,
			Honey: 0,
			Rage: 0,
			Riley: 0,
			Shocked: 0,
			Baby: 0,
			Carpenter: 0,
			Demon: 0,
			Diamond: 0,
			Lion: 0,
			Music: 0,
			Ninja: 0,
			Shy: 0,
			Buoyant: 0,
			Fuzzy: 0,
			Precise: 0,
			Spicy: 0,
			Tadpole: 0,
			Vector: 0,
			selectAll: 0
		},
		GUI: {
			xPos: A_ScreenWidth // 2 - w // 2,
			yPos: A_ScreenHeight // 2 - h // 2
		},
		extrasettings: {
			mythicStop: 0,
			giftedStop: 0,
		}
	}
	for i, section in config.OwnProps()
		for key, value in section.OwnProps()
			%key% := value
	if !FileExist(".\settings")
		DirCreate(".\settings")
	inipath := ".\settings\mutations.ini"
	if FileExist(inipath) {
		loop parse FileRead(inipath), "`n", "`r" A_Space A_Tab {
			switch (c := SubStr(A_LoopField, 1, 1)) {
				case "[", ";": continue
				default:
					if (p := InStr(A_LoopField, "="))
						try k := SubStr(A_LoopField, 1, p - 1), %k% := IsInteger(v := SubStr(A_LoopField, p + 1)) ? Integer(v) : v
			}
		}
	}
	ini := ""
	for k, v in config.OwnProps() {
		ini .= "[" k "]`r`n"
		for i in v.OwnProps()
			ini .= i "=" %i% "`r`n"
		ini .= "`r`n"
	}
	(f := FileOpen(inipath, "w")).Write(ini), f.Close()
}
;===Dimensions===
w := 500, h := 437
;===Bee Array===
beeArr := ["Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley", "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
mutationsArr := [{ name: "Ability", triggers: ["rate", "abil", "ity"], full: "AbilityRate" }, { name: "Gather", triggers: ["gath", "herAm"], full: "GatherAmount" }, { name: "Convert", triggers: ["convert", "vertAm"], full: "ConvertAmount" }, { name: "Instant", triggers: ["inst", "antConv"], full: "InstantConversion" }, { name: "Crit", triggers: ["crit", "chance"], full: "CriticalChance" }, { name: "Attack", triggers: ["attack", "att", "ack"], full: "Attack" }, { name: "Energy", triggers: ["energy", "rgy"], full: "Energy" }, { name: "Movespeed", triggers: ["movespeed", "speed", "move"], full: "MoveSpeed" },]
extrasettings := [{ name: "mythicStop", text: "Stop on mythics" }, { name: "giftedStop", text: "Stop on gifteds" }]
getConfig()
(bitmaps := Map()).CaseSense := 0
#Include .\images\bitmaps.ahk
startGui() {
	global
	local i, j, y, hBM, x
	(mgui := Gui("+E" (0x00080000) " +OwnDialogs -Caption -DPIScale", "Auto-Jelly")).OnEvent("Close", closefunction)
	mgui.Show("NA")
	for i, j in [{ name: "move", options: "x0 y0 w" w " h36" }, { name: "selectall", options: "x" w - 330 " y220 w40 h18" }, { name: "mutations", options: "x" w - 170 " y220 w40 h18" }, { name: "close", options: "x" w - 40 " y5 w28 h28" }, { name: "roll", options: "x10 y" h - 42 " w" w - 56 " h30" }, { name: "help", options: "x" w - 40 " y" h - 42 " w28 h28" }, { name: "neonberry", options: "x10 y" h - 80 " w" w / 2 - 14 " h30" }]
		mgui.AddText("v" j.name " " j.options)
	for i, j in beeArr {
		y := (A_Index - 1) // 8 * 1
		mgui.AddText("v" j " x" 10 + mod(A_Index - 1, 8) * 60 " y" 50 + y * 40 " w45 h36")
	}
	for i, j in mutationsArr {
		y := (A_Index - 1) // 4 * 1
		mgui.AddText("v" j.name " x" 10 + mod(A_Index - 1, 4) * 120 " y" 260 + y * 25 " w40 h18")
	}
	for i, j in extrasettings {
		x := 10 + (w - 12) / extrasettings.length * (i - 1), y := (316 + h - 82) // 2 - 10
		mgui.AddText("v" j.name " x" x " y" y " w40 h18")
	}
	hBM := CreateDIBSection(w, h)
	hDC := CreateCompatibleDC()
	SelectObject(hDC, hBM)
	G := Gdip_GraphicsFromHDC(hDC)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetInterpolationMode(G, 7)
	update := UpdateLayeredWindow.Bind(mgui.hwnd, hDC)
	update(xpos < 0 ? 0 : xpos > A_ScreenWidth ? 0 : xpos, ypos < 0 ? 0 : ypos > A_ScreenHeight ? 0 : ypos, w, h)
	hovercontrol := ""
	DrawGUI()
}
startGUI()
OnMessage(0x201, WM_LBUTTONDOWN)
OnMessage(0x200, WM_MOUSEMOVE)
OnMessage(0x20, (*) => 0)
DrawGUI() {
	Gdip_GraphicsClear(G)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid(0xFF131416), 2, 2, w - 4, h - 4, 20), Gdip_DeleteBrush(brush)
	region := Gdip_GetClipRegion(G)
	Gdip_SetClipRect(G, 2, 21, w - 2, 30, 4)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), 2, 2, w - 4, 40, 20)
	Gdip_SetClipRegion(G, region)
	Gdip_FillRectangle(G, brush, 2, 20, w - 4, 14)
	Gdip_DeleteBrush(brush), Gdip_DeleteRegion(region)
	Gdip_TextToGraphics(G, "Auto-Jelly", "s20 x20 y5 w460 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFF131416")), "Comic Sans MS", 460, 30), Gdip_DeleteBrush(brush)
	Gdip_DrawImage(G, bitmaps["close"], w - 40, 5, 28, 28)
	for i, j in beeArr {
		;bitmaps are w45 h36
		y := (A_Index - 1) // 8
		bm := hovercontrol = j && (%j% || SelectAll) ? j "bghover" : %j% || SelectAll ? j "bg" : hovercontrol = j ? j "hover" : j
		Gdip_DrawImage(G, bitmaps[bm], 10 + mod(A_Index - 1, 8) * 60, 50 + y * 40, 45, 36)
	}
	;===Switches===
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13 * 2 . 14 * 2 . 16 * 2), w - 330, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), selectAll ? w - 310 : w - 332, 218, 22, 22)
	Gdip_TextToGraphics(G, "Select All Bees", "s14 x" w - 284 " y220 Near vCenter c" brush, "Comic Sans MS", , 20), Gdip_DeleteBrush(brush)
	if !SelectAll {
		Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFF" . 13 * 2 . 14 * 2 . 16 * 2), w - 330, 220, 18, 18), Gdip_DeleteBrush(brush)
		Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFFCC0000", 2), [[w - 325, 225], [w - 317, 233]])
		Gdip_DrawLines(G, Pen, [[w - 325, 233], [w - 317, 225]]), Gdip_DeletePen(Pen)
	}
	else
		Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFF006600", 2), [[w - 303, 229], [w - 300, 232], [w - 295, 225]]), Gdip_DeletePen(Pen)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13 * 2 . 14 * 2 . 16 * 2), w - 170, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), mutations ? w - 150 : w - 172, 218, 22, 22)
	Gdip_TextToGraphics(G, "Mutations", "s14 x" w - 124 " y220 Near vCenter c" (brush), "Comic Sans MS", , 20), Gdip_DeleteBrush(brush)
	if !mutations {
		Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFF" . 13 * 2 . 14 * 2 . 16 * 2), w - 170, 220, 18, 18), Gdip_DeleteBrush(brush)
		Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFFCC0000", 2), [[w - 165, 225], [w - 157, 233]])
		Gdip_DrawLines(G, Pen, [[w - 165, 233], [w - 157, 225]]), Gdip_DeletePen(Pen)
	}
	else
		Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFF006600", 2), [[w - 143, 229], [w - 140, 232], [w - 135, 225]]), Gdip_DeletePen(Pen)
	For i, j in mutationsArr {
		y := (A_Index - 1) // 4
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13 * 2 . 14 * 2 . 16 * 2), 10 + mod(A_Index - 1, 4) * 120, 260 + y * 25, 40, 18, 9), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), (%j.name% ? 3.2 : 1) * 8 + mod(A_Index - 1, 4) * 120, 258 + y * 25, 22, 22), Gdip_DeleteBrush(brush)
		Gdip_TextToGraphics(G, j.name, "s13 x" 56 + mod(A_Index - 1, 4) * 120 " y" 260 + y * 25 " vCenter c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS", 100, 20), Gdip_DeleteBrush(brush)
		if !%j.name% {
			Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFF262832"), x := 10 + mod(A_Index - 1, 4) * 120, yp := 258 + y * 25 + 2, 18, 18), Gdip_DeleteBrush(brush)
			Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFFCC0000", 2), [[x + 5, yp + 5], [x + 13, yp + 13]])
			Gdip_DrawLines(G, Pen, [[x + 5, yp + 13], [x + 13, yp + 5]]), Gdip_DeletePen(Pen)
		}
		else
			Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFF006600", 2), [[x := 32.6 + mod(A_Index - 1, 4) * 120, yp := 269 + y * 25], [x + 3, yp + 3], [x + 8, yp - 4]]), Gdip_DeletePen(Pen)
	}
	if !mutations
		Gdip_FillRectangle(G, brush := Gdip_BrushCreateSolid("0x70131416"), 9, 255, w - 18, 52), Gdip_DeleteBrush(brush)
	Gdip_DrawLine(G, Pen := Gdip_CreatePen("0xFFFEC6DF", 2), 10, 315, w - 12, 315), Gdip_DeletePen(Pen)
	;two more switches for "stop on mythic" and "stop on gifted"
	for i, j in extrasettings {
		x := 10 + (tw := (w - 12) / extrasettings.length) * (i - 1), y := (316 + h - 82) // 2 - 10
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF262832"), x, y, 40, 18, 9), Gdip_DeleteBrush(brush), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), %j.name% ? x + 18 : x - 2, y - 2, 22, 22)
		Gdip_TextToGraphics(G, j.text, "s14 x" x + 46 " y" y " vCenter c" brush, "Comic Sans MS", tw, 20), Gdip_DeleteBrush(brush)
		if !%j.name% {
			Gdip_FillEllipse(G, brush := Gdip_BrushCreateSolid("0xFF262832"), x, y, 18, 18), Gdip_deleteBrush(brush)
			Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFFCC0000", 2), [[x + 5, y + 5], [x + 13, y + 13]])
			Gdip_DrawLines(G, Pen, [[x + 5, y + 13], [x + 13, y + 5]]), Gdip_DeletePen(Pen)
		}
		else
			Gdip_DrawLines(G, Pen := Gdip_CreatePen("0xFF006600", 2), [[x + 25, y + 9], [x + 28, y + 12], [x + 33, y + 5]]), Gdip_DeletePen(Pen)
	}
	if hovercontrol = "roll"
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0x30FEC6DF"), 10, h - 42, w - 56, 30, 10), Gdip_DeleteBrush(brush)
	if hovercontrol = "help"
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0x30FEC6DF"), w - 40, h - 42, 30, 30, 10), Gdip_DeleteBrush(brush)
	if hovercontrol = "neonberry"
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0x30FEC6DF"), 10, h - 80, w / 2 - 14, 30, 10), Gdip_DeleteBrush(brush)
	Gdip_TextToGraphics(G, "Roll!", "x10 y" h - 40 " Center vCenter s15 c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS", w - 56, 28)
	Gdip_TextToGraphics(G, "Auto-neonberry: " (autoNeonberry ? "On" : "Off"), "x10 y" h - 80 " Center vCenter s15 c" brush, "Comic Sans MS", w / 2 - 14, 28)
	Gdip_TextToGraphics(G, "cool feature coming soon™", "x" w / 2 + 4 " y" h - 80 " Center vCenter s15 c" brush, "Comic Sans MS", w / 2 - 14, 28)
	Gdip_TextToGraphics(G, "?", "x" w - 39 " y" h - 40 " Center vCenter s15 c" brush, "Comic Sans MS", 30, 28), Gdip_DeleteBrush(brush)
	Gdip_DrawRoundedRectanglePath(G, pen := Gdip_CreatePen("0xFFFEC6DF", 4), 10, h - 42, w - 56, 30, 10)
	Gdip_DrawRoundedRectanglePath(G, pen, 10, h - 82, w / 2 - 14, 30, 10)
	Gdip_DrawRoundedRectanglePath(G, pen, w / 2 + 4, h - 82, w / 2 - 14, 30, 10)
	Gdip_DrawRoundedRectanglePath(G, pen, w - 40, h - 42, 30, 30, 10), Gdip_DeletePen(pen)
	update()
}
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	global hovercontrol, mutations, Bomber, Brave, Bumble, Cool, Hasty, Looker, Rad, Rascal
		, Stubborn, Bubble, Bucko, Commander, Demo, Exhausted, Fire, Frosty, Honey, Rage
		, Riley, Shocked, Baby, Carpenter, Demon, Diamond, Lion, Music, Ninja, Shy, Buoyant
		, Fuzzy, Precise, Spicy, Tadpole, Vector, SelectAll, Ability, Gather, Convert, Energy
		, Movespeed, Crit, Instant, Attack, mythicStop, giftedStop, autoNeonberry, neonberryX, neonberryY
	MouseGetPos(, , , &ctrl, 2)
	if !ctrl
		return
	switch mgui[ctrl].name, 0 {
		case "move":
			PostMessage(0x00A1, 2)
		case "close":
			while GetKeyState("LButton", "P")
				sleep -1
			mousegetpos , , , &ctrl2, 2
			if ctrl = ctrl2
				PostMessage(0x0112, 0xF060)
		case "roll":
			blc_start()
		case "help":
			Msgbox("- Select the bees and mutations you want`n- put a neonberry on the bee you want to change`n- make sure your in-game Auto-Jelly settings are right`n- use one royal jelly on the bee and click yes.`n`nThen click on Roll.`nTo stop press the escape key`n`nStops:`n- GiftedStop stops on any gifted bee ignoring the`n  mutation and your bee selection`n- MythicStop stops on any gifted bee ignoring the`n  mutation and your bee selection", "Auto-Jelly Help", "0x40040")
		case "selectAll":
			IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
		case "Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley":
			if !selectAll
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
		case "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector":
			if !selectAll
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
		case "giftedStop", "mythicStop":
			IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "extrasettings", mgui[ctrl].name)
		case "mutations":
			IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
		case "neonberry":
			if !autoNeonberry && msgbox("When enabled, the macro will automatically put a neonberry on the bee you want to change if mutations are enabled. When using this, make sure you have neonberries in your inventory and not to touch your keyboard or mouse while the macro is running.`nDo you want to proceed?", "Auto-Jelly", 0x40134) = "yes" {
				if MsgBox("Click on the bee you want to change and the macro will do the rest!`n`nRemember to have neonberries in your inventory and not to touch your keyboard or mouse while the macro is running.`nPress 'Okay' to proceed", "Auto-Jelly", 0x40041) = "OK" {
					GetNeonberryPos()
				}
			}
			else
				autoNeonberry := 0, neonberryX := 0, neonberryY := 0

		default:
			if mutations
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
	}
	DrawGUI()
}
GetNeonberryPos() {
	global autoNeonberry, neonberryX, neonberryY
	mgui.Hide()
	nGUI := Gui("+E" (0x08080000) " +OwnDialogs -Caption -DPIScale", "Auto-Jelly")
	/*     if !GetRobloxClientPos() || !windowWidth
	return msgbox("You must have Bee Swarm Simulator open to use this!", "Auto-Jelly", 0x40030) */
	windowX := 0, windowY := 0, windowWidth := A_ScreenWidth, windowHeight := A_ScreenHeight
	nGUI.Show()
	hBM := CreateDIBSection(windowWidth, windowHeight)
	hDC := CreateCompatibleDC()
	SelectObject(hDC, hBM)
	G := Gdip_GraphicsFromHDC(hDC)
	Gdip_GraphicsClear(G, 0x88000000)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetInterpolationMode(G, 7)
	update := UpdateLayeredWindow.Bind(nGUI.hwnd, hDC)
	update(windowX, windowY, windowWidth, windowHeight)
	KeyWait("LButton", "D")
	MouseGetPos(&x, &y)
	nGUI.Destroy()
	mgui.Show()
	autoNeonberry := 1, neonberryX := x, neonberryY := y
}
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	global
	local ctrl, hover_ctrl
	static IDC_HAND := DllCall("LoadCursor", "Ptr", 0, "UInt", 32649, "Ptr"), IDC_ARROW := DllCall("LoadCursor", "Ptr", 0, "UInt", 32512, "Ptr"), current := 0, _ := (DllCall("SetCursor", "Ptr", IDC_ARROW, "Ptr"), 0)
	MouseGetPos(, , , &ctrl, 2)
	if !ctrl || mgui["move"].hwnd = ctrl || mgui["close"].hwnd = ctrl || (!mutations && !!find(mutationsArr, (j) => j.name = mgui[ctrl].name))
		return ((current ? DllCall("SetCursor", "Ptr", IDC_ARROW, "Ptr") : 0), current := 0)
	if !current
		current := (DllCall("SetCursor", "Ptr", IDC_HAND), 1)
	hovercontrol := mgui[ctrl].name
	hover_ctrl := mgui[ctrl].hwnd
	DrawGUI()
	while ctrl = hover_ctrl
		sleep(20), MouseGetPos(, , , &ctrl, 2)
	hovercontrol := ""
	current := 0, DllCall("SetCursor", "Ptr", IDC_ARROW, "Ptr")
	DrawGUI()
}
blc_start() {
	global stopping := false
	hotkey "~*esc", stopToggle, "On"
	selectedBees := [], selectedMutations := []
	for i in beeArr
		if %i% || SelectAll
			selectedBees.push(i)
	if mutations {
		for i in mutationsArr
			if %i.name%
				selectedMutations.push(i)
	}
	if autoNeonberry && mutations && selectedMutations.Length {
		if !neonberryX || !neonberryY
			return msgbox("You must select a bee to put a neonberry on!", "Auto-Jelly", 0x40030)
		global MouseHook := DllCall("SetWindowsHookEx", "int", 14, "ptr", hp:=CallbackCreate(HookProc), "ptr", 0, "uint", 0)
		global KeyboardHook := DllCall("SetWindowsHookEx", "int", 13, "ptr", hp, "ptr", 0, "uint", 0)
	}
	ocr_enabled := 1
	ocr_language := ""
	for k, v in Map("Windows.Globalization.Language", "{9B0252AC-0C27-44F8-B792-9793FB66C63E}", "Windows.Graphics.Imaging.BitmapDecoder", "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", "Windows.Media.Ocr.OcrEngine", "{5BFFA85A-3384-3540-9940-699120D428A8}") {
		CreateHString(k, &hString)
		GUID := Buffer(16), DllCall("ole32\CLSIDFromString", "WStr", v, "Ptr", GUID)
		result := DllCall("Combase.dll\RoGetActivationFactory", "Ptr", hString, "Ptr", GUID, "PtrP", &pClass := 0)
		DeleteHString(hString)
		if (result != 0)
		{
			ocr_enabled := 0
			break
		}
	}
	if !(ocr_enabled) && mutations
		msgbox "OCR is disabled. This means that the macro will not be able to detect mutations.", , 0x40010
	list := ocr("ShowAvailableLanguages")
	lang := "en-"
	Loop Parse list, "`n", "`r" {
		if (InStr(A_LoopField, lang) = 1) {
			ocr_language := A_LoopField
			break
		}
	}
	if (ocr_language = "" && ocr_enabled)
		if ((ocr_language := SubStr(list, 1, InStr(list, "`n") - 1)) = "")
			return msgbox("No OCR supporting languages are installed on your system! Please follow the Knowledge Base guide to install a supported language as a secondary language on Windows.", "WARNING!!", 0x1030)
	if !(hwndRoblox := GetRobloxHWND()) || !(GetRobloxClientPos(), windowWidth)
		return msgbox("You must have Bee Swarm Simulator open to use this!", "Auto-Jelly", 0x40030)
	if !selectedBees.length
		return msgbox("You must select at least one bee to run this macro!", "Auto-Jelly", 0x40030)
	yOffset := GetYOffset(hwndRoblox, &fail)
	if fail
		MsgBox("Unable to detect in-game GUI offset!`nThis means the macro will NOT work correctly!`n`nThere are a few reasons why this can happen:`n- Incorrect graphics settings (check Troubleshooting Guide!)`n- Your Experience Language is not set to English`n- Something is covering the top of your Roblox window`n`nJoin our Discord server for support!", "WARNING!!", 0x1030 " T60")
	if mgui is Gui
		mgui.hide()
	While !stopping {
		ActivateRoblox()
		click windowX + Round(0.5 * windowWidth + 10) " " windowY + yOffset + Round(0.4 * windowHeight + 230)
		sleep 600
		pBitmap := Gdip_BitmapFromScreen(windowX + 0.5 * windowWidth - 155 "|" windowY + yOffset + 0.425 * windowHeight - 200 "|" 320 "|" 140)
		if mythicStop
			for i, j in ["Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
				if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
					Gdip_DisposeImage(pBitmap)
					msgbox "Found a myhic bee!", "Auto-Jelly", 0x40040
					break 2
				}
		if giftedStop
			for i, j in beeArr {
				if Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
					Gdip_DisposeImage(pBitmap)
					msgbox "Found a gifted bee!", "Auto-Jelly", 0x40040
					break 2
				}
			}
		found := 0
		for i, j in selectedBees {
			if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
				if (!mutations || !ocr_enabled || !selectedMutations.length) {
					Gdip_DisposeImage(pBitmap)
					if msgbox("Found a match!`nDo you want to keep this?", "Auto-Jelly!", 0x40024) = "Yes"
						break 2
					else
						continue 2
				}
				found := 1
				break
			}
		}
		Gdip_DisposeImage(pBitmap)
		pBitmap := Gdip_BitmapFromScreen(windowX + Round(0.5 * windowWidth - 320) "|" windowY + yOffset + Round(0.4 * windowHeight + 17) "|210|90")
		if !found {
            if autoNeonberry && !Gdip_PixelSearch(pBitmap, 0xFF276339) {
                Click(windowX + Round(0.5 * windowWidth) " " windowY + yOffset + Round(0.5 * windowHeight)) ; close the bee info
                placeNeonberry()
            }
			Gdip_DisposeImage(pBitmap)
			continue
		}
		pEffect := Gdip_CreateEffect(5, -60, 30)
		Gdip_BitmapApplyEffect(pBitmap, pEffect)
		Gdip_DisposeEffect(pEffect)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
		pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
		text := RegExReplace(ocr(pIRandomAccessStream), "i)([\r\n\s]|mutation)*")
		found := 0
		for i, j in selectedMutations
			for k, trigger in j.triggers
				if inStr(text, trigger) {
					found := 1
					break
				}
		if !found {
            if autoNeonberry && !Gdip_PixelSearch(pBitmap, 0xFF276339) {
                Click(windowX + Round(0.5 * windowWidth) " " windowY + yOffset + Round(0.5 * windowHeight)) ; close the bee info
                placeNeonberry()
            }
            Gdip_DisposeImage(pBitmap)
            continue
        }
        Gdip_DisposeImage(pBitmap)
		if msgbox("Found a match!`nDo you want to keep this?", "Auto-Jelly!", 0x40024) = "Yes"
			break
	}
	hotkey "~*esc", stopToggle, "Off"
	mgui.show()
}
find(arr, function) {
	for i, j in arr
		if function(j)
			return j
}
closeFunction(*) {
	global xPos, yPos
	try {
		mgui.getPos(&xp, &yp)
		if !(xp < 0) && !(xp > A_ScreenWidth) && !(yp < 0) && !(yp > A_ScreenHeight)
			xPos := xp, yPos := yp
		IniWrite(xpos, ".\settings\mutations.ini", "GUI", "xpos")
		IniWrite(ypos, ".\settings\mutations.ini", "GUI", "ypos")
		Gdip_Shutdown(pToken)
	}
	ExitApp()
}
placeNeonberry() {
    ActivateRoblox()
    GetRobloxClientPos(), yOffset:=GetYOffset()
    if openInventory()
        sleep 300
    MouseMove(windowX + 30 , windowY + yOffset + 200)
    loop 50
        Send "{WheelDown 50}"
    msgbox "done"
    loop 25 {
        Send "{WheelUp 50}"
        sleep 500
        pBitmap := Gdip_BitmapFromScreen(windowX "|" windowY+yOffset+175 "|80|" windowHeight - yOffset - 175)
        if Gdip_ImageSearch(pBitmap, bitmaps["Neonberry"],&pos,,,,,2) {
            Gdip_DisposeImage(pBitmap)
            x:=SubStr(pos,1,InStr(pos, ",")-1), y:=SubStr(pos,InStr(pos, ",")+1)
            MouseMove(windowX + x, windowY + yOffset + 175 + y)
            Send "{Click Down}"
            MouseMove neonberryX, neonberryY
            Send "{Click Up}"
            return 1
        }
        Gdip_DisposeImage(pBitmap)
    }
    openInventory(close:=0) {
        pBitmap := Gdip_BitmapFromScreen(windowX "|" windowY+yOffset+70 "|70|70")
        if (close && Gdip_ImageSearch(pBitmap, bitmaps["Inventory"], ,,,,, 2)) || (!close && !Gdip_ImageSearch(pBitmap, bitmaps["Inventory"], ,,,,, 2))
            return(Click(windowX+30 " " windowY+yOffset+95), Gdip_DisposeImage(pBitmap), 1)
        Gdip_DisposeImage(pBitmap)
        return 0
    }
}

HookProc(ncode, wParam, lParam, extraParam?) {
	if !(wParam = 0x200 || wParam = 0x100 || wParam = 0x20A)
		return 0
    if wParam = 0x20A {
        DllCall("UnhookWindowsHookEx", "ptr", MouseHook), DllCall("UnhookWindowsHookEx", "ptr", KeyboardHook)
        Hotkey "~*esc", stopToggle, "Off"
        msgbox("Detected mouse input!`nMacro was Interrupted and will not continue rolling","Auto-Jelly", "0x40030")
        stopToggle()
    }
	if wParam = 0x200 {
		if !GetKeyState("RButton")
			return 0
		DllCall("UnhookWindowsHookEx", "ptr", MouseHook), DllCall("UnhookWindowsHookEx", "ptr", KeyboardHook)
		Hotkey "~*esc", stopToggle, "Off"
        msgbox("Detected mouse input!`nMacro was Interrupted and will not continue rolling","Auto-Jelly", "0x40030")
		stopToggle()
	}
	switch k := GetKeyName(Format("vk{:x}", NumGet(lParam, "uint"))), 0 {
		case "w", "a", "s", "d", "i", "o", "<", ">", "Space", "Left", "Right", "Up", "Down", "PgUp", "PgDn", "Escape", "LWin", "RWin", ",", ".":
			DllCall("UnhookWindowsHookEx", "ptr", MouseHook), DllCall("UnhookWindowsHookEx", "ptr", KeyboardHook)
			Hotkey "~*esc", stopToggle, "Off"
			msgbox("Detected keyboard input!`nMacro was Interrupted and will not continue rolling","Auto-Jelly", "0x40030")
			stopToggle()
		case "shift":
			DllCall("UnhookWindowsHookEx", "ptr", MouseHook), DllCall("UnhookWindowsHookEx", "ptr", KeyboardHook)
			Hotkey "~*esc", stopToggle, "Off"
			msgbox("Detected keyboard input!`nMacro was Interrupted and will not continue rolling","Auto-Jelly", "0x40030")
			stopToggle()
        case "tab":
            if !(GetKeyState("Alt"))
                return 0
            DllCall("UnhookWindowsHookEx", "ptr", MouseHook), DllCall("UnhookWindowsHookEx", "ptr", KeyboardHook)
            Hotkey "~*esc", stopToggle, "Off"
            MsgBox("Detected keyboard input!`nMacro was Interrupted and will not continue rolling","Auto-Jelly", "0x40030")
            stopToggle()
	}
}

