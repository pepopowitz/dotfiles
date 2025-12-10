import Cocoa

class HUDWindow: NSWindow {
    init(message: String, width: CGFloat, height: CGFloat, yOffset: CGFloat, fontSize: CGFloat, opacity: Double) {
        // Create a window at the top center of the screen
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        let xPos = (screenFrame.width - width) / 2
        let yPos = screenFrame.height - height - yOffset
        
        let frame = NSRect(x: xPos, y: yPos, width: width, height: height)
        
        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Window properties
        self.backgroundColor = NSColor.black.withAlphaComponent(opacity)
        self.isOpaque = false
        self.level = .statusBar
        self.ignoresMouseEvents = true
        self.hasShadow = true
        
        // Create label with dynamic padding
        let padding: CGFloat = 15
        let label = NSTextField(frame: NSRect(x: padding, y: padding, width: width - (padding * 2), height: height - (padding * 2)))
        label.stringValue = message
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.textColor = .white
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: fontSize, weight: .medium)
        
        self.contentView?.addSubview(label)
        
        // Round corners
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.cornerRadius = 10
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: HUDWindow?
    var duration: Double = 1.0
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let arguments = CommandLine.arguments

        // Kill any existing HUD process
        let pidFile = NSTemporaryDirectory() + "hud.pid"
        if let existingPid = try? String(contentsOfFile: pidFile, encoding: .utf8),
           let pid = Int32(existingPid.trimmingCharacters(in: .whitespacesAndNewlines)) {
            // Check if process exists (kill with signal 0 doesn't actually kill, just checks)
            if kill(pid, 0) == 0 {
                // Process exists, kill it
                kill(pid, SIGTERM)
                // Give it a moment to terminate gracefully
                usleep(50000) // 50ms
            }
            // Clean up stale or now-terminated PID file
            try? FileManager.default.removeItem(atPath: pidFile)
        }

        // Write current process ID
        let currentPid = getpid()
        try? String(currentPid).write(toFile: pidFile, atomically: true, encoding: .utf8)

        // Default values
        var message = "HUD Message"
        var width: CGFloat? = nil
        var height: CGFloat = 50
        var yOffset: CGFloat = 40
        var fontSize: CGFloat = 18
        var opacity: Double = 0.8

        // Parse arguments
        var i = 1
        while i < arguments.count {
            let arg = arguments[i]

            switch arg {
            case "-w", "--width":
                if i + 1 < arguments.count, let value = Double(arguments[i + 1]) {
                    width = CGFloat(value)
                    i += 1
                }
            case "-h", "--height":
                if i + 1 < arguments.count, let value = Double(arguments[i + 1]) {
                    height = CGFloat(value)
                    i += 1
                }
            case "-y", "--yoffset":
                if i + 1 < arguments.count, let value = Double(arguments[i + 1]) {
                    yOffset = CGFloat(value)
                    i += 1
                }
            case "-f", "--fontsize":
                if i + 1 < arguments.count, let value = Double(arguments[i + 1]) {
                    fontSize = CGFloat(value)
                    i += 1
                }
            case "-d", "--duration":
                if i + 1 < arguments.count, let value = Double(arguments[i + 1]) {
                    duration = value
                    i += 1
                }
            case "-o", "--opacity":
                if i + 1 < arguments.count, let value = Double(arguments[i + 1]) {
                    opacity = min(1.0, max(0.0, value))
                    i += 1
                }
            case "--help":
                printHelp()
                NSApplication.shared.terminate(nil)
                return
            default:
                // If it doesn't start with -, treat as message
                if !arg.hasPrefix("-") {
                    message = arg
                }
            }
            i += 1
        }

        // Calculate width dynamically if not specified
        let finalWidth: CGFloat
        if let specifiedWidth = width {
            finalWidth = specifiedWidth
        } else {
            // Estimate width based on message length and font size
            // Approximate character width is about 0.6 * fontSize for most fonts
            let padding: CGFloat = 30 // 15px on each side
            let estimatedTextWidth = CGFloat(message.count) * fontSize * 0.6
            finalWidth = max(100, min(600, estimatedTextWidth + padding))
        }

        // Create and show window
        window = HUDWindow(message: message, width: finalWidth, height: height, yOffset: yOffset, fontSize: fontSize, opacity: opacity)
        window?.makeKeyAndOrderFront(nil)
        
        // Auto-dismiss after specified duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.cleanup()
            NSApplication.shared.terminate(nil)
        }
    }

    func cleanup() {
        let pidFile = NSTemporaryDirectory() + "hud.pid"
        try? FileManager.default.removeItem(atPath: pidFile)
    }

    func applicationWillTerminate(_ notification: Notification) {
        cleanup()
    }

    func printHelp() {
        print("""
        HUD - Display a heads-up display message

        Usage: hud [message] [options]

        Options:
          -w, --width      Window width in pixels (default: auto-calculated from message)
          -h, --height     Window height in pixels (default: 50)
          -y, --yoffset    Distance from top of screen in pixels (default: 40)
          -f, --fontsize   Font size (default: 18)
          -d, --duration   Display duration in seconds (default: 1.0)
          -o, --opacity    Background opacity 0.0-1.0 (default: 0.8)
          --help           Show this help message

        Examples:
          hud "Hello World"
          hud "Task complete" -d 2.0
          hud "Error!" -f 24 -o 0.9 -d 1.5
        """)
    }
}

// Main execution
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()