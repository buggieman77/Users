#Requires AutoHotkey v2.0

; --- Shortcut aktif dan tray tetap hidup ---
; Tidak perlu Run as Admin

; Alt+Tab seperti Task View
;#InputLevel 1
;~!Tab:: {
;    SendEvent("{LWin down}{Tab}")
;    Sleep(100)
;    SendEvent("{LWin up}")
;}

; Shortcut lain
#f::Run("explorer.exe")
#q::Send("!{F4}")


#c:: {
    cmdPath := A_ComSpec
    bashPath := "C:\Program Files\Git\git-bash.exe"
    workingDir := "C:\Users\erensa"

    Run(Format('{} /c start "" "{}"', cmdPath, bashPath), workingDir)
}

; --- Loop untuk menjaga skrip tetap hidup tanpa admin ---
; dan munculkan tray icon
Loop {
    Sleep(1000)
}
