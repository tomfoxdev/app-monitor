# App Monitor - Window Screenshot & OCR Tool

A macOS CLI application written in Swift that can monitor windows for screenshots or scan them for specific text using OCR.

## Features

### Two Operating Modes:

**1. Save Pictures Mode**
- 📸 Captures screenshots every 4 seconds
- 📁 Saves screenshots to a timestamped folder on your Desktop
- 🖥️ Monitor any specific window

**2. OCR Scanning Mode**
- 🔍 Scan windows for specific text patterns
- 🎯 Custom mode: Search for any phrase (up to 20 characters)
  - Choose horizontal regions: top half, bottom half, or all
  - Choose vertical regions: left 1/3, middle 1/3, right 1/3, or all
  - Can scan multiple regions simultaneously
- 🖱️ Cursor preset: Scans both full window AND right 1/3 for "Run this command?"
- 🖥️ Cursor Agent preset: Scans bottom half of terminal for "Run this Command?"
- 🔊 Plays rich multi-tone cash register sound when text is detected
- 📊 Real-time logging shows results for each scanned region
- ⏱️ Scans every 4 seconds
- 🚫 Doesn't save images (just scans them)

### General Features
- 🖥️ Lists all open application windows
- 🎨 Colorful CLI interface for easy navigation
- ⚡ Native macOS performance using Swift

## Requirements

- macOS 12.0 (Monterey) or later
- Swift 5.9 or later (comes with Xcode)
- Screen Recording permission (will be prompted on first run)

## Building the Application

### Option 1: Build and Run Directly

```bash
# Navigate to the project directory
cd app-monitor  # or the folder you cloned

# Build and run in one command
swift run
```

### Option 2: Build for Release

```bash
# Build the release version (optimized)
swift build -c release

# The executable will be at:
# .build/release/AppMonitor
```

### Option 3: Install to System

```bash
# Build release version
swift build -c release

# Copy to a location in your PATH
sudo cp .build/release/AppMonitor /usr/local/bin/app-monitor

# Now you can run from anywhere:
app-monitor
```

## Usage

1. **Run the application:**
   ```bash
   swift run
   # or if installed:
   app-monitor
   ```

2. **Select a mode:**
   ```
   Pick a Mode:
   [1] Save Pictures in Folder
   [2] Scan for OCR
   ```

3. **Select a window:**
   - The app will display a numbered list of all open windows
   - Each entry shows the application name and window title
   - Type the number of the window you want to monitor
   - Press Enter

4. **Mode-specific behavior:**

   **Save Pictures Mode:**
   - Screenshots saved every 4 seconds to Desktop folder
   - Each screenshot is numbered sequentially
   - Shows confirmation for each saved screenshot

   **OCR Scanning Mode:**
   - Choose between:
     - **Custom**: Enter your own phrase to search for (max 20 chars)
       - Select horizontal region: top/bottom/all
       - Select vertical region: left/middle/right third/all
       - Option to scan multiple regions simultaneously
     - **Cursor Preset**: Automatically scans full window + right 1/3 for "Run this command?"
     - **Cursor Agent**: Scans bottom half of terminal window for "Run this Command?"
   - Scans every 4 seconds
   - Plays rich multi-tone cash register sound when text is found
   - Shows scan results for each region separately
   - No images are saved

5. **Stop monitoring:**
   - Press `Ctrl+C` to stop
   - The app will exit gracefully

## Permissions

On first run, macOS will ask for **Screen Recording** permission:

1. When prompted, click "Open System Preferences"
2. Go to Privacy & Security → Screen Recording
3. Enable the checkbox next to Terminal (or your terminal app)
4. Restart the terminal and run the app again

## Screenshot Storage

Screenshots are saved to:
```
~/Desktop/AppMonitor_YYYY-MM-DD_HH-mm-ss/
├── screenshot_0001_HH-mm-ss-SSS.png
├── screenshot_0002_HH-mm-ss-SSS.png
├── screenshot_0003_HH-mm-ss-SSS.png
└── ...
```

## Features in Detail

### Window Detection
- Detects all visible windows on screen
- Shows both application name and window title
- Handles multiple windows from the same application
- Automatically excludes desktop elements

### Automatic Monitoring
- Takes screenshots exactly every 2 seconds
- Continues until you stop it or the window closes
- Automatically stops if the monitored window is closed
- Numbers screenshots sequentially for easy sorting

### Error Handling
- Gracefully handles window closure during monitoring
- Validates user input for window selection
- Creates screenshot folder with unique timestamps to avoid conflicts

## Troubleshooting

**"No windows found"**
- Make sure you have at least one application window open
- Check that Screen Recording permission is granted

**"Failed to capture screenshot"**
- Ensure Screen Recording permission is enabled in System Preferences
- The window might have been minimized or closed

**Permission denied when building**
- Make sure you have write permissions in the project directory
- Try running with `sudo` if installing to system directories

## Technical Details

Built with:
- Swift 5.9
- CoreGraphics for window management
- Cocoa for image handling
- Vision framework for OCR text recognition
- AVFoundation for sound playback
- No external dependencies

The app uses native macOS APIs:
- `CGWindowListCopyWindowInfo` for window enumeration
- `CGWindowListCreateImage` for screenshot capture
- `VNRecognizeTextRequest` for OCR text detection
- Timer-based polling for periodic scanning/capture
- Image cropping for targeted region scanning

## License

This tool is provided as-is for personal use. Feel free to modify and extend as needed.
