#Requires AutoHotkey v2.0
#SingleInstance Force

; Mac-style shortcuts on Windows for a MacBook keyboard.
; Physical keys: Cmd = Win, Option = Alt, Ctrl = Ctrl.
; Cmd+<key> sends Ctrl+<key>, so Cmd+C/V/X/Z/S/T/W/F... behave like on macOS,
; while the physical Ctrl key stays a normal Ctrl (Ctrl+C still interrupts in a shell).

IsTerminal(*) => WinActive("ahk_exe WindowsTerminal.exe")
IsBrowser(*) => WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe msedge.exe") || WinActive("ahk_exe firefox.exe")

; ---------- Windows Terminal: Cmd+C/V etc. must not send raw Ctrl+C (SIGINT) ----------
; Defined first so they take precedence over the generic Cmd+<key> hotkeys below.
HotIf IsTerminal
for key in ["c", "v", "t", "w", "f", "n"]
    Hotkey("#" key, SendCtrlShift.Bind(key))
HotIf

; ---------- Browsers: Cmd+[ / Cmd+] for back / forward ----------
HotIf IsBrowser
Hotkey("#[", (*) => Send("!{Left}"))
Hotkey("#]", (*) => Send("!{Right}"))
HotIf

; ---------- Cmd+<key> -> Ctrl+<key> ----------
keys := "abcdefghijklmnopqrstuvwxyz0123456789,.;'/\[]-=``"
Loop Parse keys {
    Hotkey("#" A_LoopField, SendCtrl.Bind(A_LoopField))
    Hotkey("#+" A_LoopField, SendCtrlShift.Bind(A_LoopField))
}

SendCtrl(key, *) => Send("^" key)
SendCtrlShift(key, *) => Send("^+" key)

; ---------- App / window management ----------
#q::Send "!{F4}"            ; Cmd+Q: quit
<#Tab::AltTab               ; Cmd+Tab: switch apps
#Space::Send "{LWin}"       ; Cmd+Space: search (Start menu)
#+3::Send "{PrintScreen}"   ; Cmd+Shift+3: screenshot
#+4::Send "#+s"             ; Cmd+Shift+4: snipping tool
#h::WinMinimize "A"         ; Cmd+H: hide
#!h::Send "#d"              ; Cmd+Opt+H: hide others (show desktop)

; ---------- Cursor movement (Cmd = line/document, Option = word) ----------
#Left::Send "{Home}"
#Right::Send "{End}"
#Up::Send "^{Home}"
#Down::Send "^{End}"
#+Left::Send "+{Home}"
#+Right::Send "+{End}"
#+Up::Send "^+{Home}"
#+Down::Send "^+{End}"

!Left::Send "^{Left}"
!Right::Send "^{Right}"
!+Left::Send "^+{Left}"
!+Right::Send "^+{Right}"

; ---------- Deleting ----------
#BackSpace::Send "+{Home}{Delete}"  ; Cmd+Backspace: delete to line start
!BackSpace::Send "^{BackSpace}"     ; Opt+Backspace: delete previous word
!Delete::Send "^{Delete}"           ; Opt+Fn+Backspace: delete next word
