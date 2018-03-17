import Cocoa

class NSFlippedView:NSView {
    override var flipped:Bool {
        get {
            return true
        }
    }
}