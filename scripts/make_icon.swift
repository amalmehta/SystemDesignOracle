// Draws the app icon (four stacked layers) and writes Resources/AppIcon.icns.
// Run: swift scripts/make_icon.swift
import AppKit

let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

// Background: rounded square with a deep blue-to-purple gradient.
let inset: CGFloat = 100
let bg = NSBezierPath(roundedRect: NSRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset),
                      xRadius: 185, yRadius: 185)
NSGradient(colors: [NSColor(red: 0.10, green: 0.14, blue: 0.32, alpha: 1),
                    NSColor(red: 0.27, green: 0.13, blue: 0.45, alpha: 1)])!.draw(in: bg, angle: -90)

// Four isometric layers, teal → purple, matching the app's layer colours.
let colors: [NSColor] = [.systemTeal, .systemBlue, .systemIndigo, .systemPurple]
for (i, color) in colors.enumerated().reversed() {
    let y = 330 + CGFloat(3 - i) * 95
    let path = NSBezierPath()
    path.move(to: NSPoint(x: 512, y: y + 130))
    path.line(to: NSPoint(x: 780, y: y))
    path.line(to: NSPoint(x: 512, y: y - 130))
    path.line(to: NSPoint(x: 244, y: y))
    path.close()
    ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    color.withAlphaComponent(0.95).setFill()
    path.fill()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    NSColor.white.withAlphaComponent(0.55).setStroke()
    path.lineWidth = 6
    path.stroke()
}
image.unlockFocus()

let fm = FileManager.default
let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let iconset = fm.temporaryDirectory.appendingPathComponent("AppIcon.iconset")
try? fm.removeItem(at: iconset)
try! fm.createDirectory(at: iconset, withIntermediateDirectories: true)

func png(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: px, height: px))
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}
for base in [16, 32, 128, 256, 512] {
    try! png(base).write(to: iconset.appendingPathComponent("icon_\(base)x\(base).png"))
    try! png(base * 2).write(to: iconset.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}
try! png(1024).write(to: root.appendingPathComponent("Resources/AppIcon.png"))
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", iconset.path, "-o", root.appendingPathComponent("Resources/AppIcon.icns").path]
try! p.run(); p.waitUntilExit()
print(p.terminationStatus == 0 ? "Wrote Resources/AppIcon.icns" : "iconutil failed")
