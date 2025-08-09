# Usage Examples

## Example 1: Save Pictures Mode

```
╔══════════════════════════════════════════════════════╗
║            App Monitor - Window Screenshot Tool       ║
╚══════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════
Pick a Mode:
═══════════════════════════════════════════════════════
[1] Save Pictures in Folder
[2] Scan for OCR
═══════════════════════════════════════════════════════

Enter your choice (or 'q' to quit): 1

═══════════════════════════════════════════════════════
Available Windows:
═══════════════════════════════════════════════════════
[ 1] Chrome               │ GitHub - microsoft/vscode
[ 2] Chrome               │ Stack Overflow - Swift OCR
[ 3] Cursor               │ app-monitor
[ 4] Terminal             │ fish
[ 5] Finder               │ Desktop
═══════════════════════════════════════════════════════

Enter the number of the window to monitor (or 'q' to quit): 3

✓ Monitoring started for: Cursor - app-monitor
✓ Screenshots saving to: /Users/marty/Desktop/AppMonitor_2024-01-15_14-30-22
Press Ctrl+C to stop monitoring

📸 Screenshot #1 saved at 2024-01-15 14:30:22
📸 Screenshot #2 saved at 2024-01-15 14:30:24
📸 Screenshot #3 saved at 2024-01-15 14:30:26
...
```

## Example 2: OCR Scanning - Custom Mode

```
╔══════════════════════════════════════════════════════╗
║            App Monitor - Window Screenshot Tool       ║
╚══════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════
Pick a Mode:
═══════════════════════════════════════════════════════
[1] Save Pictures in Folder
[2] Scan for OCR
═══════════════════════════════════════════════════════

Enter your choice (or 'q' to quit): 2

[Window selection...]

═══════════════════════════════════════════════════════
OCR Mode Selection:
═══════════════════════════════════════════════════════
[1] Custom - Enter your own phrase to search for
[2] Cursor Preset - Scan for "Run this command?"
═══════════════════════════════════════════════════════

Enter your choice (or 'q' to quit): 1

Enter the phrase to search for (max 20 characters): ERROR

✓ OCR Monitoring started for: Chrome - Application Logs
🔍 Custom mode - searching for: "ERROR"
Press Ctrl+C to stop monitoring

🔍 Scan #1 at 2024-01-15 14:35:10 - Not found
🔍 Scan #2 at 2024-01-15 14:35:12 - Not found
🔍 Scan #3 at 2024-01-15 14:35:14 - ✅ FOUND! Playing sound...
🔍 Scan #4 at 2024-01-15 14:35:16 - ✅ FOUND! Playing sound...
🔍 Scan #5 at 2024-01-15 14:35:18 - Not found
...
```

## Example 3: OCR Scanning - Cursor Preset Mode

```
╔══════════════════════════════════════════════════════╗
║            App Monitor - Window Screenshot Tool       ║
╚══════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════
Pick a Mode:
═══════════════════════════════════════════════════════
[1] Save Pictures in Folder
[2] Scan for OCR
═══════════════════════════════════════════════════════

Enter your choice (or 'q' to quit): 2

[Window selection - select Cursor window...]

═══════════════════════════════════════════════════════
OCR Mode Selection:
═══════════════════════════════════════════════════════
[1] Custom - Enter your own phrase to search for
[2] Cursor Preset - Scan for "Run this command?"
═══════════════════════════════════════════════════════

Enter your choice (or 'q' to quit): 2

✓ OCR Monitoring started for: Cursor - my-project
🔍 Cursor preset - searching for: "Run this command?" in right 1/3
Press Ctrl+C to stop monitoring

🔍 Scan #1 at 2024-01-15 14:40:10 - Not found
🔍 Scan #2 at 2024-01-15 14:40:12 - Not found
🔍 Scan #3 at 2024-01-15 14:40:14 - ✅ FOUND! Playing sound...
[Cash register sound plays: "Ka-ching!"]
🔍 Scan #4 at 2024-01-15 14:40:16 - ✅ FOUND! Playing sound...
...
```

## Tips

1. **For Cursor Preset Mode**: 
   - Works best when Cursor's AI panel is on the right side
   - Detects the "Run this command?" prompt that appears when AI suggests a command

2. **For Custom Mode**:
   - Keep phrases short and specific
   - Case-insensitive matching
   - Works with partial matches

3. **Sound Alerts**:
   - Sound only plays once every 5 seconds to avoid spam
   - Uses system beep sound (double beep for cash register effect)

4. **Performance**:
   - Scans happen every 2 seconds
   - OCR is optimized for accuracy
   - No images are saved in OCR mode (memory efficient)
