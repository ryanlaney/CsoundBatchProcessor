import Cocoa

class PreferencesViewController : NSViewController {
    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var csoundLaunchPathTextField: NSTextField!
    @IBOutlet weak var fileTypePopUpButton: NSPopUpButton!
    @IBOutlet weak var samplesPopUpButton: NSPopUpButton!
    @IBOutlet weak var verboseCheckbox: NSButton!
    @IBOutlet weak var suppressGraphicsCheckbox: NSButton!
    @IBOutlet weak var csdCheckbox: NSButton!
    @IBOutlet weak var orcscoCheckbox: NSButton!
    @IBOutlet weak var ignoreFlagsInFileCheckbox: NSButton!
    @IBOutlet weak var additionalFlagsTextField: NSTextField!
    @IBOutlet weak var includeAmplitudeLevelMessagesCheckbox: NSButton!
    @IBOutlet weak var includeSamplesOutOfRangeCheckbox: NSButton!
    @IBOutlet weak var includeWarningsCheckbox: NSButton!
    @IBOutlet weak var includeBenchmarkInformationCheckbox: NSButton!
    @IBOutlet weak var playAlertSoundWhenFinishedCheckbox: NSButton!
    @IBOutlet weak var closeProgramWhenFinishedCheckbox: NSButton!
    
    @IBAction func ignoreFlagsInFile(sender: AnyObject) {
        Settings.ignoreFlagsInFile = sender.state
    }
    
    @IBAction func suppressGraphics(sender: NSButton) {
        Settings.suppressGraphics = sender.state
    }
    
    @IBAction func selectSourceCsd(sender: AnyObject?) {
        if self.csdCheckbox.state != 1 {
            self.csdCheckbox.state = 1
        }
        self.orcscoCheckbox.state = 0
        
        Settings.source = "csd"
        
        self.appDelegate.viewController!.fileSelectMenu2.hidden = true
        self.appDelegate.viewController!.selectAScoTextField.hidden = true
    self.appDelegate.viewController!.selectACsdTextField.stringValue = "Select a .csd file:"
        
        self.appDelegate.viewController!.cleanup()
        
        if NSFileManager.defaultManager().fileExistsAtPath(Settings.csdPath){
            Settings.csdUrl = NSURL(fileURLWithPath: Settings.csdPath)
            self.appDelegate.viewController!.fileSelectMenu.itemAtIndex(3)!.title = Settings.csdUrl.lastPathComponent!
            self.appDelegate.viewController!.readFile()
        }
        else{
            self.appDelegate.viewController!.fileSelectMenu.itemAtIndex(3)!.title = ""
        }
    }
    
    @IBAction func selectSourceOrcSco(sender: AnyObject?) {
        if self.orcscoCheckbox.state != 1 {
            self.orcscoCheckbox.state = 1
        }
        self.csdCheckbox.state = 0
        Settings.source = "orcsco"
        self.appDelegate.viewController!.fileSelectMenu2.hidden = false
        self.appDelegate.viewController!.selectAScoTextField.hidden = false
        self.appDelegate.viewController!.selectACsdTextField.stringValue = "Select a .orc file:"
        
        var readFile = true
        if  NSFileManager.defaultManager().fileExistsAtPath(Settings.orcPath){
            Settings.orcUrl = NSURL(fileURLWithPath: Settings.orcPath)
            self.appDelegate.viewController!.fileSelectMenu.itemAtIndex(3)!.title = Settings.orcUrl.lastPathComponent!
        }
        else{
            self.appDelegate.viewController!.fileSelectMenu.itemAtIndex(3)!.title = ""
            readFile = false
        }
        
        if  NSFileManager.defaultManager().fileExistsAtPath(Settings.scoPath){
            Settings.scoUrl = NSURL(fileURLWithPath: Settings.scoPath)
            self.appDelegate.viewController!.fileSelectMenu2.itemAtIndex(3)!.title = Settings.scoUrl.lastPathComponent!
        }
        else{
            self.appDelegate.viewController!.fileSelectMenu2.itemAtIndex(3)!.title = ""
            readFile = false
        }
        
        self.appDelegate.viewController!.cleanup()
        dispatch_async(dispatch_get_main_queue(),{
            if readFile{
                self.appDelegate.viewController!.readFile()
                self.appDelegate.windowController!.compileBtn.enabled = true
                self.appDelegate.windowController!.showCommands.enabled = true
            }
            else{
                self.appDelegate.windowController!.compileBtn.enabled = false
                self.appDelegate.windowController!.showCommands.enabled = false
            }
        })
    }
    
    @IBAction func csoundLaunchPathTextFieldAction(sender: NSTextField) {
        Settings.csoundLaunchPath = sender.stringValue
    }
    @IBAction func additionalFlagsTextFieldAction(sender: NSTextField) {
        Settings.additionalFlags = sender.stringValue
    }
    @IBAction func fileTypePopUpButtonAction(sender: NSPopUpButton) {
        Settings.outputFileType = sender.selectedItem!.title
        self.enableOrDisableSampleType()
    }
    
    @IBAction func sampleTypePopUpButtonAction(sender: NSPopUpButton) {
        Settings.sampleType = sender.selectedItem!.title
    }
    @IBAction func verboseCheckboxAction(sender: NSButton) {
        Settings.verboseDisplay = sender.state
    }
    @IBAction func includeAmplitudeLevelMessagesCheckboxAction(sender: NSButton) {
        Settings.includeAmplitudeLevelMessages = sender.state
    }
    @IBAction func includeSamplesOutOfRangeCheckboxAction(sender: NSButton) {
        Settings.includeSamplesOutOfRangeMessages = sender.state
    }
    @IBAction func includeWarningsCheckboxAction(sender: NSButton) {
        Settings.includeWarnings = sender.state
    }
    @IBAction func includeBenchmarkInformationCheckboxAction(sender: NSButton) {
        Settings.includeBenchmarkInformation = sender.state
    }
    @IBAction func playAlertSoundWhenFinishedCheckboxAction(sender: NSButton) {
        Settings.playAlertSoundWhenFinished = sender.state
    }
    @IBAction func closeProgramWhenFinishedCheckboxAction(sender: NSButton) {
        Settings.closeProgramWhenFinished = sender.state
    }
    
    @IBAction func restoreDefaults(sender: AnyObject?) {
        dispatch_async(dispatch_get_main_queue(),{
            Settings.csoundLaunchPath = Defaults.csoundLaunchPath
            Settings.source = Defaults.source
            Settings.outputFileType = Defaults.outputFileType
            Settings.sampleType = Defaults.sampleType
            Settings.verboseDisplay = Defaults.verboseDisplay
            Settings.suppressGraphics = Defaults.suppressGraphics
            Settings.ignoreFlagsInFile = Defaults.ignoreFlagsInFile
            Settings.additionalFlags = Defaults.additionalFlags
            Settings.includeAmplitudeLevelMessages = Defaults.includeAmplitudeLevelMessages
            Settings.includeSamplesOutOfRangeMessages = Defaults.includeSamplesOutOfRangeMessages
            Settings.includeWarnings = Defaults.includeWarnings
            Settings.includeBenchmarkInformation = Defaults.includeBenchmarkInformation
            Settings.playAlertSoundWhenFinished = Defaults.playAlertSoundWhenFinished
            Settings.closeProgramWhenFinished = Defaults.closeProgramWhenFinished
            
            self.refresh()
        })
    }
    
    func refresh(){
        self.csoundLaunchPathTextField.stringValue = Settings.csoundLaunchPath
        if (Settings.source == "csd"){
            self.csdCheckbox.state = 1
            self.orcscoCheckbox.state = 0
        }
        else{
            self.csdCheckbox.state = 0
            self.orcscoCheckbox.state = 1
        }
        self.fileTypePopUpButton.selectItemWithTitle(Settings.outputFileType)
        self.samplesPopUpButton.selectItemWithTitle(Settings.sampleType)
        self.verboseCheckbox.state = Settings.verboseDisplay
        self.suppressGraphicsCheckbox.state = Settings.suppressGraphics
        self.ignoreFlagsInFileCheckbox.state = Settings.ignoreFlagsInFile
        
        self.additionalFlagsTextField.stringValue = Settings.additionalFlags
        
        self.includeAmplitudeLevelMessagesCheckbox.state = Settings.includeAmplitudeLevelMessages
        self.includeSamplesOutOfRangeCheckbox.state = Settings.includeSamplesOutOfRangeMessages
        self.includeWarningsCheckbox.state = Settings.includeWarnings
        self.includeBenchmarkInformationCheckbox.state = Settings.includeBenchmarkInformation
        
        self.playAlertSoundWhenFinishedCheckbox.state = Settings.playAlertSoundWhenFinished
        self.closeProgramWhenFinishedCheckbox.state = Settings.closeProgramWhenFinished
        
        self.enableOrDisableSampleType()
    }
    
    func enableOrDisableSampleType(){
        if (Settings.outputFileType == "don't write file"){
            self.samplesPopUpButton.enabled = false
        }
        else{
            self.samplesPopUpButton.enabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.preferencesViewController = self
        
        self.refresh()
    }
    
    override func viewDidDisappear() {
        Settings.csoundLaunchPath = self.csoundLaunchPathTextField.stringValue
        Settings.additionalFlags = self.additionalFlagsTextField.stringValue
    }
    
}
