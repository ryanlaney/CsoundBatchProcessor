import Cocoa

class WindowController: NSWindowController, NSWindowDelegate{
    
    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var compileBtn: NSToolbarItem!
    @IBOutlet weak var clearOutputBtn: NSToolbarItem!
    @IBOutlet weak var infoBtn: NSToolbarItem!
    @IBAction func clearOutput(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(),{
            self.appDelegate.viewController!.csoundOutputTextView.string = ""
        })
    }
    
    @IBOutlet weak var showCommands: NSToolbarItem!
    @IBAction func showCommands(sender: AnyObject) {
        self.appDelegate.viewController!.showCommands()
    }
    
    @IBAction func getInfo(sender: AnyObject) {
        self.appDelegate.viewController!.info()
    }
    
    override func windowDidLoad(){
        self.appDelegate.windowController = self
        
        self.compileBtn.enabled = false
        self.compileBtn.target = self.appDelegate.viewController!
        self.compileBtn.action = #selector(ViewController.compile)
        
        self.showCommands.enabled = false
        
    }
    
}