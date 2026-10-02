// Captures the frontmost window of a running app to a PNG (used for README screenshots).
// Usage: swift scripts/window_shot.swift <process name> <out.png>
import CoreGraphics
import Foundation

let args = CommandLine.arguments
guard args.count == 3 else { print("usage: window_shot <process name> <out.png>"); exit(2) }
let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
    as? [[String: Any]] ?? []
guard let window = windows.first(where: {
    ($0[kCGWindowOwnerName as String] as? String) == args[1] && ($0[kCGWindowLayer as String] as? Int) == 0
}), let id = window[kCGWindowNumber as String] as? Int else {
    print("no window for \(args[1])"); exit(1)
}
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
p.arguments = ["-x", "-o", "-l", "\(id)", args[2]]
try p.run(); p.waitUntilExit()
exit(p.terminationStatus)
