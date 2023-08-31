Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class MouseOperations
    {
        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);

        public const int MOUSEEVENTF_ABSOLUTE = 0x8000;
        public const int MOUSEEVENTF_LEFTDOWN = 0x0002;
        public const int MOUSEEVENTF_LEFTUP = 0x0004;
        public const int MOUSEEVENTF_MIDDLEDOWN = 0x0020;
        public const int MOUSEEVENTF_MIDDLEUP = 0x0040;
        public const int MOUSEEVENTF_MOVE = 0x0001;
        public const int MOUSEEVENTF_RIGHTDOWN = 0x0008;
        public const int MOUSEEVENTF_RIGHTUP = 0x0010;
        public const int MOUSEEVENTF_XDOWN = 0x0080;
        public const int MOUSEEVENTF_XUP = 0x0100;
        public const int MOUSEEVENTF_WHEEL = 0x0800;
        public const int MOUSEEVENTF_HWHEEL = 0x01000;
    }
    public struct Point
    {
        public int X;
        public int Y;
    }

    public class User32
    {
        [DllImport("user32.dll")]
        public static extern bool GetCursorPos(out Point lpPoint);
    }
"@

# Function to get the current mouse position
function Get-CursorPos {
    $point = New-Object Point
    [void][User32]::GetCursorPos([ref]$point)
    return $point
}

# Function to get the screen dimensions
function Get-ScreenDimensions {
    $screenWidth = Get-WmiObject -Class Win32_VideoController | Select-Object -First 1 | ForEach-Object { $_.CurrentHorizontalResolution }
    $screenHeight = Get-WmiObject -Class Win32_VideoController | Select-Object -First 1 | ForEach-Object { $_.CurrentVerticalResolution }
    return $screenWidth, $screenHeight
}

# Function to move the mouse to an absolute screen position
function Move-MouseAbsolute {
    param(
        [int]$x,
        [int]$y
    )

    $screenWidth, $screenHeight = Get-ScreenDimensions

    # Calculate the relative position based on the absolute position (0 to 65535 range)
    $relativeX = ($x * 65535) / $screenWidth
    $relativeY = ($y * 65535) / $screenHeight

    [MouseOperations]::mouse_event([MouseOperations]::MOUSEEVENTF_MOVE -bor [MouseOperations]::MOUSEEVENTF_ABSOLUTE, $relativeX, $relativeY, 0, 0)
}

# Function to perform a left-click at the current mouse position
function Perform-LeftClick {
    [MouseOperations]::mouse_event([MouseOperations]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    [MouseOperations]::mouse_event([MouseOperations]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
}

# Function to move the mouse to a specific screen position
function Move-Mouse {
    param(
        [int]$x,
        [int]$y
    )

    [MouseOperations]::mouse_event([MouseOperations]::MOUSEEVENTF_MOVE, $x, $y, 0, 0)
}

# Example usage: Move the mouse to an absolute position and perform a left-click
# Adjust the coordinates as needed for your specific use case
#Move-MouseAbsolute -x 500 -y 500
#Start-Sleep -Milliseconds 500  # Add a small delay (optional)
#Perform-LeftClick

while ($true){
    Move-MouseAbsolute -x $(get-random -Minimum 0 -Maximum 3400) -y $(get-random -Minimum 0 -Maximum 1440)
    Start-Sleep $(Get-Random -Minimum 0 -Maximum 1) 
}