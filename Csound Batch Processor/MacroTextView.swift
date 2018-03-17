import Cocoa

class MacroTextView:NSTextView {
    
    private var _enabled:Bool = true
    
    var enabled:Bool {
        get {
            return _enabled
        }
        set (val){
            _enabled = val
            if val {
                self.selectable = true
                self.editable = true
                self.textColor = NSColor.blackColor()
            }
            else {
                self.selectable = false
                self.editable = false
                self.textColor = NSColor.grayColor()
            }
        }
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let urls = sender.draggingPasteboard().readObjectsForClasses([NSURL.classForCoder()], options: nil) as! [NSURL]
        dispatch_async(dispatch_get_main_queue(),{
            for i in 0..<urls.count{
                let url = urls[i]
                if i == 0{
                    self.textStorage!.appendAttributedString(NSAttributedString(string: "\"" + url.path!.stringByReplacingOccurrencesOfString("\"", withString: "\\\"") + "\""))
                    continue
                }
                self.insertNewline(nil)
                self.textStorage!.appendAttributedString(NSAttributedString(string: "\"" + url.path!.stringByReplacingOccurrencesOfString("\"", withString: "\\\"") + "\""))
            }
        })
        return true
    }
    
}