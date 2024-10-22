#Requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir
CoordMode("Mouse", "Window")
CoordMode("Pixel", "Window")
SetTitleMatchMode(2)
SetControlDelay(1)
SetWinDelay(0)
SetKeyDelay(-1)
SetMouseDelay(-1)

; ====== MODIFIABLE PARAMETERS ======
; Area to click
global clickAreaX1 := 404, clickAreaY1 := 500  ; Top-left coordinate
global clickAreaX2 := 710, clickAreaY2 := 525 ; Bottom-right coordinate

; Wait durations
tinyWait := 1      ; For very short waits
shortWait := 100    ; For short waits
mediumWait := 500   ; For medium waits

tooltipDuration := 1000  ; For tooltip display duration
spinClickDuration := 600000 ; Set the random click duration here for the first window, 60000 = 1 minute

scriptLoopWait := mediumWait ; Set the script loop wait time here
; ====== END MODIFIABLE PARAMETERS ======

global isClicking := false  ; Initialize isClicking
global isPaused := false    ; Initialize pause state
global box  ; Define the GUI globally for reference

F7::
{
    global isClicking  ; Declare isClicking as global
    if (!isClicking) {
        ShowClickArea()  ; Display the clickable area
        ShowTooltip("Line rectangle up with breakables. Press F7 to start clicking.")
        isClicking := true
        return
    }

    ; Start clicking
    ShowTooltip("Starting")  ; Show tooltip at the top left

    idList := WinGetList("ahk_exe RobloxPlayerBeta.exe")

    while isClicking
    {
        ; Check if paused
        if (isPaused) {
            ShowTooltip("Paused. Press F6 to resume, F8 to stop.")
            while isPaused {
                Sleep(shortWait)  ; Wait until unpaused
            }
            ShowTooltip("Resuming")
            Sleep(tooltipDuration)  ; Give time to show resume tooltip
        }

        windowCount := 1  ; Reset window counter for each loop iteration

        for id in idList
        {
            ; Activate the Roblox window
            WinActivate("ahk_id " id)
            Sleep(mediumWait)

            activeWindow := WinActive("ahk_id " id)
            if (!activeWindow)
            {
                Tooltip("Error: Window not activated")
                Sleep(tooltipDuration)
                continue
            }
            else
            {
                ShowTooltip("Found window " windowCount)
                Sleep(tooltipDuration)
            }

            ; Different actions for the first window vs other windows
            if (windowCount = 1)
            {
                SpinClick(spinClickDuration)  ; Use variable for spin duration
            }
            else
            {
                ; Action for other windows: call BackgroundAccounts function
                BackgroundAccounts()
            }

            windowCount++  ; Increment the window counter
        }

        Sleep(scriptLoopWait)  ; Use loop wait for the next iteration
    }
    ToolTip("")  ; Remove tooltip when loop ends
    HideClickArea()  ; Hide the clickable area when stopping

    isClicking := false  ; Reset clicking state when loop ends
}

; Random click within defined area
RandomClick() {
    randX := Random(clickAreaX1, clickAreaX2)
    randY := Random(clickAreaY1, clickAreaY2)
    SendEvent("{Click," randX "," randY ", 2}")
}

; Perform random clicks for the specified duration while holding the right arrow key
SpinClick(duration) {
    endTime := A_TickCount + duration
    
    while (A_TickCount < endTime)
    {
        ShowTooltip("Clicking")
        RandomClick()  ; Perform a random click
        Send("{r}")  ; Press 'r' while clicking
        Sleep(tinyWait)  ; Optional delay between clicks
    }
}

; Function for background accounts to press 'r'
BackgroundAccounts() {
    Loop 4  ; Loop four times
    {
        Send("{r}")  ; Press 'r'
        Sleep(shortWait)  ; Short delay between presses (adjust if necessary)
    }
}

ShowTooltip(text) {
    ToolTip(text, 10, 10)  ; Position the tooltip at (10, 10) in the window
}

; Show the clickable area with a GUI
ShowClickArea() {
    width := clickAreaX2 - clickAreaX1
    height := clickAreaY2 - clickAreaY1
    
    ; Create and show the GUI
    global box := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    box.Color := "FFFFFF"  ; White color
    box.Show("x" clickAreaX1 " y" clickAreaY1 " w" width " h" height " NoActivate")
    
    ; Set transparency to 50%
    WinSetTransparent(50, box.Hwnd)
}

; Hide the clickable area
HideClickArea() {
    box.Destroy()  ; Destroy the GUI
}

; ====== Pause/Resume on F6 ======
F6::
{
    global isPaused  ; Declare isPaused as global in the F6 hotkey
    isPaused := !isPaused  ; Toggle the paused state
    if (isPaused) {
        ShowTooltip("Pausing")
        Sleep(tooltipDuration)
    } else {
        ShowTooltip("Resuming")
        Sleep(tooltipDuration)
    }
}

; ====== F8 to Stop ======
F8::ExitApp  ; Close the script
