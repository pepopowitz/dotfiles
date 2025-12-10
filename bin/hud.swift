import Cocoa

class HUDWindow: NSWindow {
    init(message: String, width: CGFloat, height: CGFloat, yOffset: CGFloat, fontSize: CGFloat, opacity: Double, bgColor: NSColor, fgColor: NSColor) {
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
        self.backgroundColor = .clear
        self.isOpaque = false
        self.level = .statusBar
        self.ignoresMouseEvents = true
        self.hasShadow = true

        // Create a background view with rounded corners
        let backgroundView = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = bgColor.withAlphaComponent(opacity).cgColor
        backgroundView.layer?.cornerRadius = 10
        self.contentView?.addSubview(backgroundView)

        // Create label with proper vertical centering
        let horizontalPadding: CGFloat = 15
        let label = NSTextField(frame: NSRect(x: horizontalPadding, y: 0, width: width - (horizontalPadding * 2), height: height))
        label.stringValue = message
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        label.textColor = fgColor
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: fontSize, weight: .medium)

        // Enable vertical centering in the cell
        if let cell = label.cell as? NSTextFieldCell {
            cell.usesSingleLineMode = false
            cell.wraps = false
            cell.isScrollable = false
            cell.lineBreakMode = .byTruncatingTail
        }

        // Calculate proper vertical position to center the baseline
        let font = label.font!
        let textHeight = font.ascender - font.descender
        let yOffset = (height - textHeight) / 2 - font.descender
        label.frame = NSRect(x: horizontalPadding, y: yOffset, width: width - (horizontalPadding * 2), height: textHeight)

        self.contentView?.addSubview(label)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: HUDWindow?
    var duration: Double = 1.0

    func parseColor(_ colorString: String) -> NSColor? {
        guard colorString.hasPrefix("#") else { return nil }

        var hexString = String(colorString.dropFirst())

        // Convert 3-digit hex to 6-digit
        if hexString.count == 3 {
            hexString = hexString.map { "\($0)\($0)" }.joined()
        }

        guard hexString.count == 6 || hexString.count == 8 else { return nil }

        var rgbValue: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgbValue) else { return nil }

        let r = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgbValue & 0xFF) / 255.0

        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }

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
        var height: CGFloat? = nil
        var yOffset: CGFloat = 40
        var fontSize: CGFloat = 14
        var opacity: Double = 0.8
        var bgColor: NSColor = .black
        var fgColor: NSColor = .white

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
            case "-bg", "--background":
                if i + 1 < arguments.count, let color = parseColor(arguments[i + 1]) {
                    bgColor = color
                    i += 1
                }
            case "-fg", "--foreground":
                if i + 1 < arguments.count, let color = parseColor(arguments[i + 1]) {
                    fgColor = color
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

        // Calculate height dynamically if not specified
        let finalHeight: CGFloat
        if let specifiedHeight = height {
            finalHeight = specifiedHeight
        } else {
            // Height based on font size plus reasonable padding
            // Font metrics: ascender + descender is roughly 1.2-1.4x the font size
            finalHeight = fontSize * 1.4 + 20
        }

        // Create and show window
        window = HUDWindow(message: message, width: finalWidth, height: finalHeight, yOffset: yOffset, fontSize: fontSize, opacity: opacity, bgColor: bgColor, fgColor: fgColor)
        window?.alphaValue = 0.0
        window?.makeKeyAndOrderFront(nil)

        // Fade in
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            window?.animator().alphaValue = 1.0
        })

        // Auto-dismiss after specified duration with fade out
        let fadeOutDelay = duration - 0.1 // Start fade out 0.2s before end
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.1
                self.window?.animator().alphaValue = 0.0
            }, completionHandler: {
                self.cleanup()
                NSApplication.shared.terminate(nil)
            })
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
          -w, --width        Window width in pixels (default: auto-calculated from message)
          -h, --height       Window height in pixels (default: auto-calculated from font size)
          -y, --yoffset      Distance from top of screen in pixels (default: 40)
          -f, --fontsize     Font size (default: 14)
          -d, --duration     Display duration in seconds (default: 1.0)
          -o, --opacity      Background opacity 0.0-1.0 (default: 0.8)
          -bg, --background  Background color in hex format (default: black #000000)
          -fg, --foreground  Foreground/text color in hex format (default: white #FFFFFF)
          --help             Show this help message

        Color formats:
          Hex: #RGB, #RRGGBB, #RRGGBBAA

        Examples:
          hud "Hello World"
          hud "Task complete" -d 2.0
          hud "Error!" -bg "#FF0000" -fg "#FFFFFF"
          hud "Success!" -bg "#00FF00" -fg "#000000"
          hud "Warning" -bg "#FFA500" -fg "#333"
        """)
    }
}

// Main execution
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()