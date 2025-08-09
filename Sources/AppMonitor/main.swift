import Foundation
import Cocoa
import CoreGraphics
import Vision
import AVFoundation
import Darwin

// ANSI color codes for better terminal output
struct Colors {
    static let reset = "\u{001B}[0m"
    static let green = "\u{001B}[32m"
    static let blue = "\u{001B}[34m"
    static let yellow = "\u{001B}[33m"
    static let red = "\u{001B}[31m"
    static let cyan = "\u{001B}[36m"
    static let magenta = "\u{001B}[35m"
    static let bold = "\u{001B}[1m"
}

// In-place status line updater (clears current line and rewrites)
func updateStatusLine(_ text: String) {
    let clearLine = "\u{001B}[2K"
    let carriageReturn = "\r"
    if let data = (carriageReturn + clearLine + text).data(using: .utf8) {
        FileHandle.standardOutput.write(data)
        fflush(stdout)
    }
}

// Window information structure
struct WindowInfo {
    let windowID: CGWindowID
    let appName: String
    let windowTitle: String
    let bounds: CGRect
}

// App modes
enum AppMode {
    case savePictures
    case scanOCR
}

// OCR modes
enum OCRMode {
    case custom(phrase: String)
    case cursorPreset
    case cursorAgentPreset
}

// Function to get list of all windows
func getAllWindows() -> [WindowInfo] {
    var windows: [WindowInfo] = []
    
    // Get window list
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
        return windows
    }
    
    for windowInfo in windowList {
        // Skip windows without proper information
        guard let windowID = windowInfo[kCGWindowNumber as String] as? CGWindowID,
              let ownerName = windowInfo[kCGWindowOwnerName as String] as? String,
              let boundsDict = windowInfo[kCGWindowBounds as String] as? [String: Any],
              let x = boundsDict["X"] as? CGFloat,
              let y = boundsDict["Y"] as? CGFloat,
              let width = boundsDict["Width"] as? CGFloat,
              let height = boundsDict["Height"] as? CGFloat else {
            continue
        }
        
        // Skip windows with zero size
        if width <= 0 || height <= 0 {
            continue
        }
        
        // Get window title if available
        let windowTitle = windowInfo[kCGWindowName as String] as? String ?? "Untitled"
        
        let bounds = CGRect(x: x, y: y, width: width, height: height)
        windows.append(WindowInfo(windowID: windowID, appName: ownerName, windowTitle: windowTitle, bounds: bounds))
    }
    
    return windows
}

// Function to display windows and get user selection
func selectWindow() -> WindowInfo? {
    let windows = getAllWindows()
    
    if windows.isEmpty {
        print("\(Colors.red)No windows found.\(Colors.reset)")
        return nil
    }
    
    print("\n\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\(Colors.green)Available Windows:\(Colors.reset)")
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    
    for (index, window) in windows.enumerated() {
        let number = String(format: "%2d", index + 1)
        let appName = window.appName.padding(toLength: 20, withPad: " ", startingAt: 0)
        let title = window.windowTitle.count > 40 ? 
            String(window.windowTitle.prefix(37)) + "..." : 
            window.windowTitle
        
        print("\(Colors.yellow)[\(number)]\(Colors.reset) \(Colors.blue)\(appName)\(Colors.reset) │ \(title)")
    }
    
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\n\(Colors.green)Enter the number of the window to monitor (or 'q' to quit):\(Colors.reset) ", terminator: "")
    
    guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        return nil
    }
    
    if input.lowercased() == "q" {
        return nil
    }
    
    guard let selection = Int(input), selection > 0, selection <= windows.count else {
        print("\(Colors.red)Invalid selection. Please try again.\(Colors.reset)")
        return selectWindow()
    }
    
    return windows[selection - 1]
}

// Function to select app mode
func selectMode() -> AppMode? {
    print("\n\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\(Colors.green)Pick a Mode:\(Colors.reset)")
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\(Colors.yellow)[1]\(Colors.reset) Save Pictures in Folder")
    print("\(Colors.yellow)[2]\(Colors.reset) Scan for OCR")
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\n\(Colors.green)Enter your choice (or 'q' to quit):\(Colors.reset) ", terminator: "")
    
    guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        return nil
    }
    // test
    if input.lowercased() == "q" {
        return nil
    }
    
    switch input {
    case "1":
        return .savePictures
    case "2":
        return .scanOCR
    default:
        print("\(Colors.red)Invalid selection. Please try again.\(Colors.reset)")
        return selectMode()
    }
}

// Function to select OCR mode
func selectOCRMode() -> OCRMode? {
    print("\n\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\(Colors.green)OCR Mode Selection:\(Colors.reset)")
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\(Colors.yellow)[1]\(Colors.reset) Custom - Enter your own phrase to search for")
    print("\(Colors.yellow)[2]\(Colors.reset) Cursor App - Scan right 1/3 for \"Run this command?\"")
    print("\(Colors.yellow)[3]\(Colors.reset) Cursor Agent - Terminal bottom half scan")
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\n\(Colors.green)Enter your choice (or 'q' to quit):\(Colors.reset) ", terminator: "")
    
    guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        return nil
    }
    
    if input.lowercased() == "q" {
        return nil
    }
    
    switch input {
    case "1":
        print("\n\(Colors.green)Enter the phrase to search for (max 20 characters):\(Colors.reset) ", terminator: "")
        guard let phrase = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        if phrase.isEmpty {
            print("\(Colors.red)Phrase cannot be empty.\(Colors.reset)")
            return selectOCRMode()
        }
        if phrase.count > 20 {
            print("\(Colors.red)Phrase must be 20 characters or less.\(Colors.reset)")
            return selectOCRMode()
        }
        return .custom(phrase: phrase)
    case "2":
        return .cursorPreset
    case "3":
        return .cursorAgentPreset
    default:
        print("\(Colors.red)Invalid selection. Please try again.\(Colors.reset)")
        return selectOCRMode()
    }
}

// Function to create screenshot folder
func createScreenshotFolder() -> URL? {
    let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let folderName = "AppMonitor_\(dateFormatter.string(from: Date()))"
    let folderURL = desktopURL.appendingPathComponent(folderName)
    
    do {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        return folderURL
    } catch {
        print("\(Colors.red)Failed to create screenshot folder: \(error)\(Colors.reset)")
        return nil
    }
}

// Function to capture window screenshot
func captureWindowScreenshot(windowID: CGWindowID, saveTo folderURL: URL, count: Int) -> Bool {
    // Create CGImage from window
    guard let image = CGWindowListCreateImage(.null, 
                                             .optionIncludingWindow, 
                                             windowID, 
                                             [.boundsIgnoreFraming, .nominalResolution]) else {
        return false
    }
    
    // Create NSImage from CGImage
    let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
    
    // Convert to PNG data
    guard let tiffData = nsImage.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        return false
    }
    
    // Save to file
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH-mm-ss-SSS"
    let filename = "screenshot_\(String(format: "%04d", count))_\(dateFormatter.string(from: Date())).png"
    let fileURL = folderURL.appendingPathComponent(filename)
    
    do {
        try pngData.write(to: fileURL)
        return true
    } catch {
        print("\(Colors.red)Failed to save screenshot: \(error)\(Colors.reset)")
        return false
    }
}

// Function to capture window screenshot for OCR (returns CGImage)
func captureWindowImage(windowID: CGWindowID, cropToRightThird: Bool = false, cropToBottomHalf: Bool = false) -> CGImage? {
    // Create CGImage from window
    guard let fullImage = CGWindowListCreateImage(.null,
                                                  .optionIncludingWindow,
                                                  windowID,
                                                  [.boundsIgnoreFraming, .nominalResolution]) else {
        return nil
    }
    
    // If we need to crop to right third
    if cropToRightThird {
        let width = fullImage.width
        let height = fullImage.height
        let cropRect = CGRect(x: width * 2 / 3, y: 0, width: width / 3, height: height)
        
        return fullImage.cropping(to: cropRect)
    }
    
    // If we need to crop to bottom half
    if cropToBottomHalf {
        let width = fullImage.width
        let height = fullImage.height
        let cropRect = CGRect(x: 0, y: height / 2, width: width, height: height / 2)
        
        return fullImage.cropping(to: cropRect)
    }
    
    return fullImage
}

// Function to perform OCR on image
func performOCR(on image: CGImage, searchPhrase: String, scanCount: Int) -> Bool {
    let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
    var foundText = false
    let semaphore = DispatchSemaphore(value: 0)
    
    let request = VNRecognizeTextRequest { request, error in
        defer { semaphore.signal() }
        
        if let error = error {
            print("\(Colors.red)OCR Error: \(error)\(Colors.reset)")
            return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        var allText = ""
        for observation in observations {
            if let topCandidate = observation.topCandidates(1).first {
                allText += topCandidate.string + " "
            }
        }
        
        let searchLower = searchPhrase.lowercased()
        let textLower = allText.lowercased()
        
        if textLower.contains(searchLower) {
            foundText = true
        }
    }
    
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    
    do {
        try requestHandler.perform([request])
        semaphore.wait()
    } catch {
        print("\(Colors.red)Failed to perform OCR: \(error)\(Colors.reset)")
    }
    
    return foundText
}

// Function to play cash register sound
func playCashRegisterSound() {
    // Try to play our custom cash register sound file
    let soundPath = FileManager.default.currentDirectoryPath + "/Resources/cash.mp3"
    
    if let sound = NSSound(contentsOfFile: soundPath, byReference: false) {
        sound.play()
    } else {
        // Fallback to system Tink sound if our file isn't found
        if let sound = NSSound(contentsOfFile: "/System/Library/Sounds/Tink.aiff", byReference: false) {
            sound.play()
        } else {
            // Last resort - system beep
            NSSound.beep()
        }
    }
}

// Function to check if window still exists
func windowExists(windowID: CGWindowID) -> Bool {
    let windows = getAllWindows()
    return windows.contains { $0.windowID == windowID }
}

// Main monitoring function for saving pictures
func startMonitoringSavePictures(window: WindowInfo, folderURL: URL) {
    print("\n\(Colors.green)✓ Monitoring started for:\(Colors.reset) \(Colors.blue)\(window.appName)\(Colors.reset) - \(window.windowTitle)")
    print("\(Colors.green)✓ Screenshots saving to:\(Colors.reset) \(folderURL.path)")
    print("\(Colors.yellow)Press Ctrl+C to stop monitoring\(Colors.reset)\n")
    
    var screenshotCount = 0
    _ = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
        // Check if window still exists
        if !windowExists(windowID: window.windowID) {
            print("\n\(Colors.red)Window closed or no longer available. Stopping monitoring.\(Colors.reset)")
            exit(0)
        }
        
        screenshotCount += 1
        if captureWindowScreenshot(windowID: window.windowID, saveTo: folderURL, count: screenshotCount) {
            print("\(Colors.green)📸\(Colors.reset) Screenshot #\(screenshotCount) saved at \(Date())")
        } else {
            print("\(Colors.red)❌ Failed to capture screenshot #\(screenshotCount)\(Colors.reset)")
        }
    }
    
    // Take first screenshot immediately
    screenshotCount += 1
    if captureWindowScreenshot(windowID: window.windowID, saveTo: folderURL, count: screenshotCount) {
        print("\(Colors.green)📸\(Colors.reset) Screenshot #\(screenshotCount) saved at \(Date())")
    }
    
    // Keep the run loop alive
    RunLoop.current.run()
}

// Main monitoring function for OCR scanning
func startMonitoringOCR(window: WindowInfo, ocrMode: OCRMode) {
    let (searchPhrase, cropToRightThird, cropToBottomHalf) = switch ocrMode {
    case .custom(let phrase):
        (phrase, false, false)
    case .cursorPreset:
        ("Run this command?", true, false)
    case .cursorAgentPreset:
        ("Run this Command?", false, true)
    }
    
    let modeDescription = switch ocrMode {
    case .custom(let phrase):
        "Custom mode - searching for: \"\(phrase)\""
    case .cursorPreset:
        "Cursor App - searching for: \"Run this command?\" in right 1/3"
    case .cursorAgentPreset:
        "Cursor Agent - searching for: \"Run this Command?\" in bottom half"
    }
    
    print("\n\(Colors.green)✓ OCR Monitoring started for:\(Colors.reset) \(Colors.blue)\(window.appName)\(Colors.reset) - \(window.windowTitle)")
    print("\(Colors.magenta)🔍 \(modeDescription)\(Colors.reset)")
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)")
    print("\(Colors.yellow)⎵ Press SPACE to pause/unpause   •   Press Ctrl+C to stop\(Colors.reset)")
    print("\(Colors.cyan)═══════════════════════════════════════════════════════\(Colors.reset)\n")
    
    var scanCount = 0
    var consecutiveDetections = 0  // Count consecutive scans where text is found
    var isPaused = false
    
    // Set up keyboard input monitoring in background
    DispatchQueue.global(qos: .userInteractive).async {
        // Disable buffering for immediate input
        var oldTermios = termios()
        tcgetattr(STDIN_FILENO, &oldTermios)
        var newTermios = oldTermios
        newTermios.c_lflag &= ~(UInt(ICANON | ECHO))
        tcsetattr(STDIN_FILENO, TCSANOW, &newTermios)
        
        while true {
            let char = getchar()
            if char == 32 { // Space bar
                isPaused.toggle()
                if isPaused {
                    consecutiveDetections = 0 // reset streak on pause
                    print("\n\(Colors.yellow)⏸  PAUSED - Press SPACE to resume (streak reset)\(Colors.reset)\n")
                } else {
                    print("\n\(Colors.green)▶️  RESUMED - Scanning continues\(Colors.reset)\n")
                }
            }
        }
    }
    
    _ = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
        // Skip if paused
        if isPaused {
            updateStatusLine("\(Colors.yellow)⏸  PAUSED • [SPACE to resume] • Scan #\(scanCount)\(Colors.reset)")
            return
        }
        
        // Check if window still exists
        if !windowExists(windowID: window.windowID) {
            print("\n\(Colors.red)Window closed or no longer available. Stopping monitoring.\(Colors.reset)")
            exit(0)
        }
        
        scanCount += 1
        let timestamp = Date()
        
        // Compose base status
        var status = "\(Colors.cyan)🔍 Scan #\(scanCount) \(Colors.reset)@ \(timestamp)  \(Colors.yellow)[SPACE to pause]\(Colors.reset)"
        
        guard let image = captureWindowImage(windowID: window.windowID, cropToRightThird: cropToRightThird, cropToBottomHalf: cropToBottomHalf) else {
            status += "  - \(Colors.red)Capture failed\(Colors.reset)"
            consecutiveDetections = 0
            updateStatusLine(status)
            return
        }
        
        if performOCR(on: image, searchPhrase: searchPhrase, scanCount: scanCount) {
            // Text found - increment consecutive detections
            consecutiveDetections += 1
            
            // Play sound on odd streak counts: 1, 3, 5, ... (resets when not found)
            let shouldPlaySound = (consecutiveDetections % 2 == 1)
            
            if shouldPlaySound {
                status += "  - \(Colors.green)FOUND 🔔\(Colors.reset)  (streak: \(consecutiveDetections))"
                playCashRegisterSound()
            } else {
                status += "  - \(Colors.green)FOUND\(Colors.reset)  (streak: \(consecutiveDetections))"
            }
        } else {
            status += "  - \(Colors.yellow)Not found\(Colors.reset)"
            consecutiveDetections = 0  // Reset counter when text not found
        }
        
        updateStatusLine(status)
    }
    
    // Perform first scan immediately
    scanCount += 1
    let timestamp = Date()
    var initialStatus = "\(Colors.cyan)🔍 Scan #\(scanCount) \(Colors.reset)@ \(timestamp)  \(Colors.yellow)[SPACE to pause]\(Colors.reset)"
    
    if let image = captureWindowImage(windowID: window.windowID, cropToRightThird: cropToRightThird, cropToBottomHalf: cropToBottomHalf) {
        if performOCR(on: image, searchPhrase: searchPhrase, scanCount: scanCount) {
            consecutiveDetections = 1
            initialStatus += "  - \(Colors.green)FOUND 🔔\(Colors.reset)  (streak: 1)"
            playCashRegisterSound()
        } else {
            initialStatus += "  - \(Colors.yellow)Not found\(Colors.reset)"
            consecutiveDetections = 0
        }
    } else {
        initialStatus += "  - \(Colors.red)Capture failed\(Colors.reset)"
        consecutiveDetections = 0
    }
    
    updateStatusLine(initialStatus)
    
    // Keep the run loop alive
    RunLoop.current.run()
}

// Handle Ctrl+C gracefully
signal(SIGINT) { _ in
    print("\n\n\(Colors.yellow)Monitoring stopped by user.\(Colors.reset)")
    exit(0)
}

// Main execution
print("\(Colors.cyan)╔══════════════════════════════════════════════════════╗\(Colors.reset)")
print("\(Colors.cyan)║            \(Colors.green)App Monitor - Window Screenshot Tool\(Colors.cyan)      ║\(Colors.reset)")
print("\(Colors.cyan)╚══════════════════════════════════════════════════════╝\(Colors.reset)")

// Select mode
guard let mode = selectMode() else {
    print("\(Colors.yellow)No mode selected. Exiting.\(Colors.reset)")
    exit(0)
}

// Select window
guard let selectedWindow = selectWindow() else {
    print("\(Colors.yellow)No window selected. Exiting.\(Colors.reset)")
    exit(0)
}

// Execute based on mode
switch mode {
case .savePictures:
    // Create screenshot folder
    guard let folderURL = createScreenshotFolder() else {
        print("\(Colors.red)Failed to create screenshot folder. Exiting.\(Colors.reset)")
        exit(1)
    }
    startMonitoringSavePictures(window: selectedWindow, folderURL: folderURL)
    
case .scanOCR:
    guard let ocrMode = selectOCRMode() else {
        print("\(Colors.yellow)No OCR mode selected. Exiting.\(Colors.reset)")
        exit(0)
    }
    startMonitoringOCR(window: selectedWindow, ocrMode: ocrMode)
}