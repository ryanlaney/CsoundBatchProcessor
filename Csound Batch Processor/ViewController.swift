//
//  ViewController.swift
//  Csound Batch Processor
//
//  Created by Ryan Laney on 10/7/15.
//  Copyright © 2015 Ryan Laney. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSTextFieldDelegate {

    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var fileSelectMenu: NSPopUpButton!
    @IBOutlet weak var fileSelectMenu2: NSPopUpButton!
    @IBOutlet weak var outputFolderSelectMenu: NSPopUpButton!
    @IBOutlet var csoundOutputTextView: NSTextView!
    @IBOutlet weak var parametersView: NSView!
    @IBOutlet weak var parametersScrollView: NSScrollView!
    @IBOutlet weak var namingConventionTextField: NSTextField!
    
    @IBOutlet weak var selectACsdTextField: NSTextField!
    @IBOutlet weak var selectAScoTextField: NSTextField!
    
    var openPanel:NSOpenPanel = NSOpenPanel()
    
    var variableTypes:[String] = [String]()
    var variableLabel:[NSTextField] = [NSTextField]()
    var variableTextView:[MacroTextView] = [MacroTextView]()
    
    var tasks:[NSTask] = [NSTask]()
    var stop:Bool = false
    
    var helpPanel:NSPanel = NSPanel()
    
    let terminalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    let serialQueue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)
    let compileSerialQueue = dispatch_queue_create("compile-queue",DISPATCH_QUEUE_SERIAL)

    //var textContents:String = String()
        
    @IBAction func closeHelpPanel(sender: AnyObject?) {
        self.view.window!.endSheet(self.helpPanel)
        self.view.window!.makeKeyWindow()
        self.helpPanel.orderOut(nil)
    }
    
    @IBAction func chooseAFile(sender: NSMenuItem) {
        dispatch_async(dispatch_get_main_queue(),{
            self.openPanel.title = "Choose a File"
            self.openPanel.showsResizeIndicator = false
            self.openPanel.showsHiddenFiles = false
            self.openPanel.canChooseDirectories = false
            self.openPanel.canChooseFiles = true
            self.openPanel.canCreateDirectories = false
            self.openPanel.allowsMultipleSelection = false
            if (Settings.source == "csd"){
                self.openPanel.allowedFileTypes = ["csd"]
            }
            else{
                self.openPanel.allowedFileTypes = ["orc"]
            }
            
            self.openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: { [unowned self] (result) -> Void in
                if result == NSModalResponseOK {
                    let selection:NSURL = self.openPanel.URL!
                    if (Settings.source == "csd"){
                        Settings.csdUrl = selection
                        Settings.csdPath = selection.path!
                    }
                    else{
                        Settings.orcUrl = selection
                        Settings.orcPath = selection.path!
                    }
                    self.fileSelectMenu.itemAtIndex(3)!.title = selection.lastPathComponent!
                    
                    if (Settings.source == "csd"){
                        self.readFile()
                    }
                    else if (Settings.scoUrl != NSURL()) && (Settings.orcUrl != NSURL()) {
                        self.readFile()
                    }
                }
                self.fileSelectMenu.selectItemAtIndex(3)
                })
        })
    }
    
    @IBAction func chooseAScoFile(sender: NSMenuItem) {
        dispatch_async(dispatch_get_main_queue(),{
            self.openPanel.title = "Choose a File"
            self.openPanel.showsResizeIndicator = false
            self.openPanel.showsHiddenFiles = false
            self.openPanel.canChooseDirectories = false
            self.openPanel.canChooseFiles = true
            self.openPanel.canCreateDirectories = false
            self.openPanel.allowsMultipleSelection = false
            self.openPanel.allowedFileTypes = ["sco"]
            
            self.openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: { [unowned self] (result) -> Void in
                if result == NSModalResponseOK {
                    let selection:NSURL = self.openPanel.URL!
                    Settings.scoUrl = selection
                    Settings.scoPath = selection.path!
                    self.fileSelectMenu2.itemAtIndex(3)!.title = selection.lastPathComponent!
                    
                    if (Settings.scoUrl != NSURL()) && (Settings.orcUrl != NSURL()) {
                        self.readFile()
                    }
                }
                self.fileSelectMenu2.selectItemAtIndex(3)
                })
        })
    }
    
    @IBAction func showFile1InFinder(sender: NSMenuItem) {
        if Settings.source == "csd"{
            NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([Settings.csdUrl])
        }
        else{
            NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([Settings.orcUrl])
        }
        
        self.fileSelectMenu.selectItemAtIndex(3)
    }
    @IBAction func showFile2InFinder(sender: NSMenuItem) {
        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([Settings.scoUrl])
        
        self.fileSelectMenu2.selectItemAtIndex(3)
    }
    
    @IBAction func chooseOutputFolder(sender: NSMenuItem) {
        dispatch_async(dispatch_get_main_queue(),{
            self.openPanel.title = "Choose a Folder"
            self.openPanel.showsResizeIndicator = false
            self.openPanel.showsHiddenFiles = false
            self.openPanel.canChooseDirectories = true
            self.openPanel.canChooseFiles = false
            self.openPanel.canCreateDirectories = true
            self.openPanel.allowsMultipleSelection = false
            
            self.openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: { [unowned self] (result) -> Void in
                if result == NSModalResponseOK {
                    let selection:NSURL = self.openPanel.URL!
                    Settings.outputDirectoryUrl = selection
                    Settings.outputDirectoryPath = selection.path!
                    self.outputFolderSelectMenu.itemAtIndex(3)!.title = selection.lastPathComponent!
                }
                self.outputFolderSelectMenu.selectItemAtIndex(3)
                })
        })
    }
    
    @IBAction func showOutputDirectoryInFinder(sender: NSMenuItem) {
        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([Settings.outputDirectoryUrl])
        
        self.outputFolderSelectMenu.selectItemAtIndex(3)
        
    }
    
    func info(){
        dispatch_async(dispatch_get_main_queue(),{
            self.view.window!.beginSheet(self.helpPanel, completionHandler: {[unowned self] (result) -> Void in NSModalResponse()})
        })
    }
    
    func alert(messageText: String, _ informativeText: String? = nil){
        dispatch_async(dispatch_get_main_queue(),{
            let alert = NSAlert()
            alert.addButtonWithTitle("OK")
            alert.messageText = messageText
            if informativeText != nil{
                alert.informativeText = informativeText!
            }
            alert.alertStyle = NSAlertStyle.InformationalAlertStyle
            NSBeep()
            alert.runModal()
        })
    }
    
    func cleanup(){
        for i in (0..<self.parametersView.subviews.count).reverse(){
            self.parametersView.subviews[i].removeFromSuperview()
        }
        
        self.parametersScrollView.removeConstraints(self.parametersScrollView.constraints)
    }
    
    func getVariables(allWords: [String]) -> [String]{
        var variables = [String]()
        for i in 0..<allWords.count{
            if allWords[i].hasPrefix("$") == false {
                continue
            }
            if (allWords[i].characters.count <= 1){
                continue
            }
            if allWords[i].hasPrefix("$0") ||
                allWords[i].hasPrefix("$1") ||
                allWords[i].hasPrefix("$2") ||
                allWords[i].hasPrefix("$3") ||
                allWords[i].hasPrefix("$4") ||
                allWords[i].hasPrefix("$5") ||
                allWords[i].hasPrefix("$6") ||
                allWords[i].hasPrefix("$7") ||
                allWords[i].hasPrefix("$8") ||
                allWords[i].hasPrefix("$9") {
                    continue
            }
            if "$" + allWords[i].componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").invertedSet).joinWithSeparator("") != allWords[i] {
                continue
            }
            variables.append(allWords[i])
        }
        return variables
    }
    
    private func formatTextView(textView: MacroTextView, scrollView: NSScrollView){
        textView.allowsUndo = true
        textView.automaticSpellingCorrectionEnabled = false
        textView.automaticLinkDetectionEnabled = false
        textView.automaticDataDetectionEnabled = false
        textView.automaticQuoteSubstitutionEnabled = false
        textView.automaticTextReplacementEnabled = false
        textView.automaticDashSubstitutionEnabled = false
        textView.richText = false
        textView.allowsDocumentBackgroundColorChange = false
        textView.registerForDraggedTypes([String(kUTTypeFileURL)])
        textView.delegate = self
        textView.verticallyResizable = true
        textView.horizontallyResizable = true
        textView.minSize = NSMakeSize(CGFloat(FLT_MAX), scrollView.frame.height)
        textView.maxSize = NSMakeSize(CGFloat(FLT_MAX), CGFloat(FLT_MAX))
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = textView
    }
    
    func readFile(){
        var orcPath = String()
        var scoPath = String()
        if (Settings.source == "csd"){
            orcPath = Settings.csdPath
            scoPath = Settings.csdPath
        }
        else{
            orcPath = Settings.orcPath
            scoPath = Settings.scoPath
        }
        
        var orcContentsString:String = String()
        var scoContentsString:String = String()
        do{
            orcContentsString = try NSString(contentsOfFile: orcPath, encoding: NSUTF8StringEncoding) as String
            scoContentsString = try NSString(contentsOfFile: scoPath, encoding: NSUTF8StringEncoding) as String
        }
        catch _ as NSError {
            return
        }
    
        var orcContents = orcContentsString.componentsSeparatedByString("<CsInstruments>")
        if (orcContents.count <= 1){
            self.alert("An error occured", "Could not find </CsInstruments> in file.")
            cleanup()
            return
        }
        orcContents = orcContents[1].componentsSeparatedByString("</CsInstruments>")
        if (orcContents.count <= 1){
            self.alert("An error occured", "Could not find </CsInstruments> in file.")
            cleanup()
            return
        }
        
        let allOrcWords = orcContents[0].componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var orcVariables = unique(getVariables(allOrcWords))
        
        var scoContents = scoContentsString.componentsSeparatedByString("<CsScore>")
        if (scoContents.count <= 1){
            self.alert("An error occured", "Could not find <CsScore> in file.")
            cleanup()
            return
        }
        scoContents = scoContents[1].componentsSeparatedByString("</CsScore>")
        if (scoContents.count <= 1){
            self.alert("An error occured", "Could not find </CsScore> in file.")
            cleanup()
            return
        }
        
        let allScoWords = scoContents[0].componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var scoVariables = unique(getVariables(allScoWords))
        
        /* macros that are common to orchestra and score should only be displayed once */
        var commonVariables:[String] = [String]()
        for i in (0..<orcVariables.count).reverse(){
            for j in (0..<scoVariables.count).reverse(){
                if (orcVariables[i] == scoVariables[j]){
                    commonVariables.append(orcVariables[i])
                    orcVariables.removeAtIndex(i)
                    scoVariables.removeAtIndex(j)
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(),{
            let item_height = 100
            
            self.cleanup()
            
            self.variableLabel = [NSTextField]()
            self.variableTextView = [MacroTextView]()
            self.variableTypes = [String]()
            var y:CGFloat = 10
            var n:Int = 0
            if orcVariables.count > 0 || scoVariables.count > 0{
                if orcVariables.count > 0 {
                    let omacroLabel = NSTextField()
                    omacroLabel.stringValue = "Orchestra Macros"
                    omacroLabel.editable = false
                    omacroLabel.selectable = false
                    omacroLabel.bordered = false
                    omacroLabel.backgroundColor = NSColor.clearColor()
                    omacroLabel.frame = NSMakeRect(10,y,400,30)
                    omacroLabel.font = NSFont(name: "Arial Bold", size: 16)
                    self.parametersView.addSubview(omacroLabel)
                    let variables = orcVariables
            
                    y += omacroLabel.frame.height
                    for i in 0..<variables.count{
                        autoreleasepool {
                            self.variableTypes.append("o")
                            
                            self.variableLabel.append(NSTextField())
                            self.variableLabel[n].stringValue = variables[i].stringByReplacingOccurrencesOfString("$", withString: "")
                            self.variableLabel[n].alignment = NSTextAlignment.Right
                            self.variableLabel[n].editable = false
                            self.variableLabel[n].selectable = false
                            self.variableLabel[n].bordered = false
                            self.variableLabel[n].backgroundColor = NSColor.clearColor()
                            self.parametersView.addSubview(self.variableLabel[n])
                            self.variableLabel[n].translatesAutoresizingMaskIntoConstraints = false
                            
                            let scrollView = NSScrollView()
                            scrollView.translatesAutoresizingMaskIntoConstraints = false
                            scrollView.hasVerticalScroller = true
                            scrollView.hasHorizontalScroller = true
                            scrollView.borderType = NSBorderType.BezelBorder
                            scrollView.focusRingType = NSFocusRingType.Exterior
                            self.parametersView.addSubview(scrollView)
                            
                            let widthConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 150)
                            
                            let yConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self.variableLabel[n].superview!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: y)
                            
                            let heightConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(item_height))
                            
                            let xConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: self.variableLabel[n].superview!, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 10)
                            
                            self.parametersView.addConstraint(yConstraint)
                            self.parametersView.addConstraint(widthConstraint)
                            self.parametersView.addConstraint(heightConstraint)
                            self.parametersView.addConstraint(xConstraint)
                            
                            self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Left, multiplier: 1, constant: 170)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Right, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Right, multiplier: 1, constant: -10)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Top, multiplier: 1, constant: y)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(item_height))
                            )
                            
                            self.variableTextView.append(MacroTextView())
                            self.formatTextView(self.variableTextView[n], scrollView: scrollView)
                            
                            y += CGFloat(item_height + 10)
                            n += 1
                        }
                    }
                }
                if scoVariables.count > 0 {
                    let smacroLabel = NSTextField()
                    smacroLabel.stringValue = "Score Macros"
                    smacroLabel.editable = false
                    smacroLabel.selectable = false
                    smacroLabel.bordered = false
                    smacroLabel.backgroundColor = NSColor.clearColor()
                    smacroLabel.frame = NSMakeRect(10,y,400,30)
                    smacroLabel.font = NSFont(name: "Arial Bold", size: 16)
                    self.parametersView.addSubview(smacroLabel)
                    let variables = scoVariables
                    y += smacroLabel.frame.height
                    for i in 0..<variables.count{
                        autoreleasepool {
                            self.variableTypes.append("s")
                            
                            self.variableLabel.append(NSTextField())
                            self.variableLabel[n].stringValue = variables[i].stringByReplacingOccurrencesOfString("$", withString: "")
                            self.variableLabel[n].alignment = NSTextAlignment.Right
                            self.variableLabel[n].editable = false
                            self.variableLabel[n].selectable = false
                            self.variableLabel[n].bordered = false
                            self.variableLabel[n].backgroundColor = NSColor.clearColor()
                            self.parametersView.addSubview(self.variableLabel[n])
                            self.variableLabel[n].translatesAutoresizingMaskIntoConstraints = false
                            
                            let scrollView = NSScrollView()
                            scrollView.translatesAutoresizingMaskIntoConstraints = false
                            scrollView.hasVerticalScroller = true
                            scrollView.hasHorizontalScroller = true
                            scrollView.borderType = NSBorderType.BezelBorder
                            scrollView.focusRingType = NSFocusRingType.Exterior
                            self.parametersView.addSubview(scrollView)
                            
                            let widthConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 150)
                            
                            let yConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self.variableLabel[n].superview!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: y)
                            
                            let heightConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(item_height))
                            
                            let xConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: self.variableLabel[n].superview!, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 10)
                            
                            self.parametersView.addConstraint(yConstraint)
                            self.parametersView.addConstraint(widthConstraint)
                            self.parametersView.addConstraint(heightConstraint)
                            self.parametersView.addConstraint(xConstraint)
                            
                            self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Left, multiplier: 1, constant: 170)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Right, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Right, multiplier: 1, constant: -10)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Top, multiplier: 1, constant: y)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(item_height))
                            )
                            
                            self.variableTextView.append(MacroTextView())
                            self.formatTextView(self.variableTextView[n], scrollView: scrollView)
                            
                            y += CGFloat(item_height + 10)
                            n += 1
                        }
                    }
                }
                if commonVariables.count > 0 {
                    let commonMacroLabel = NSTextField()
                    commonMacroLabel.stringValue = "Orchestra + Score Macros"
                    commonMacroLabel.editable = false
                    commonMacroLabel.selectable = false
                    commonMacroLabel.bordered = false
                    commonMacroLabel.backgroundColor = NSColor.clearColor()
                    commonMacroLabel.frame = NSMakeRect(10,y,400,30)
                    commonMacroLabel.font = NSFont(name: "Arial Bold", size: 16)
                    self.parametersView.addSubview(commonMacroLabel)
                    let variables = commonVariables
                    y += commonMacroLabel.frame.height
                    for i in 0..<variables.count{
                        autoreleasepool {
                            self.variableTypes.append("c")
                            
                            self.variableLabel.append(NSTextField())
                            self.variableLabel[n].stringValue = variables[i].stringByReplacingOccurrencesOfString("$", withString: "")
                            self.variableLabel[n].alignment = NSTextAlignment.Right
                            self.variableLabel[n].editable = false
                            self.variableLabel[n].selectable = false
                            self.variableLabel[n].bordered = false
                            self.variableLabel[n].backgroundColor = NSColor.clearColor()
                            self.parametersView.addSubview(self.variableLabel[n])
                            self.variableLabel[n].translatesAutoresizingMaskIntoConstraints = false
                            
                            let scrollView = NSScrollView()
                            scrollView.translatesAutoresizingMaskIntoConstraints = false
                            scrollView.hasVerticalScroller = true
                            scrollView.hasHorizontalScroller = true
                            scrollView.borderType = NSBorderType.BezelBorder
                            scrollView.focusRingType = NSFocusRingType.Exterior
                            self.parametersView.addSubview(scrollView)
                            
                            let widthConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 150)
                            
                            let yConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self.variableLabel[n].superview!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: y)
                            
                            let heightConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(item_height))
                            
                            let xConstraint = NSLayoutConstraint(item: self.variableLabel[n], attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: self.variableLabel[n].superview!, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 10)
                            
                            self.parametersView.addConstraint(yConstraint)
                            self.parametersView.addConstraint(widthConstraint)
                            self.parametersView.addConstraint(heightConstraint)
                            self.parametersView.addConstraint(xConstraint)
                            
                            self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Left, multiplier: 1, constant: 170)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Right, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Right, multiplier: 1, constant: -10)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: scrollView.superview!, attribute: .Top, multiplier: 1, constant: y)
                            )
                            self.view.addConstraint(
                                NSLayoutConstraint(item: scrollView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(item_height))
                            )
                            
                            self.variableTextView.append(MacroTextView())
                            self.formatTextView(self.variableTextView[n], scrollView: scrollView)
                            
                            y += CGFloat(item_height + 10)
                            n += 1
                        }
                    }
                }
            }
            else{
                let omacroLabel = NSTextField()
                omacroLabel.stringValue = "No macros were found."
                omacroLabel.editable = false
                omacroLabel.selectable = false
                omacroLabel.bordered = false
                omacroLabel.backgroundColor = NSColor.clearColor()
                omacroLabel.frame = NSMakeRect(10,y,400,30)
                omacroLabel.font = NSFont(name: "Arial Bold", size: 16)
                self.parametersView.addSubview(omacroLabel)
                y += omacroLabel.frame.height
            }
            self.parametersView.translatesAutoresizingMaskIntoConstraints = false
            self.parametersScrollView.addConstraint(NSLayoutConstraint(item: self.parametersView, attribute: .Top, relatedBy: .Equal, toItem: self.parametersScrollView, attribute: .Top, multiplier: 1, constant: 0))
            self.parametersScrollView.addConstraint(NSLayoutConstraint(item: self.parametersView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: y))
            self.parametersScrollView.addConstraint(NSLayoutConstraint(item: self.parametersView, attribute: .Left, relatedBy: .Equal, toItem: self.parametersScrollView, attribute: .Left, multiplier: 1, constant: 5))
            self.parametersScrollView.addConstraint(NSLayoutConstraint(item: self.parametersView, attribute: .Right, relatedBy: .Equal, toItem: self.parametersScrollView, attribute: .Right, multiplier: 1, constant: 0))
            
            self.namingConventionTextField.enabled = true

            self.appDelegate.windowController!.compileBtn.enabled = true
            self.appDelegate.windowController!.showCommands.enabled = true
            
            self.parametersScrollView.contentView.scrollToPoint(NSPoint(x: 0, y: 0))
        })
    }
    
    func stopCsoundProcesses(){
        self.stop = true //at this point, the compile queue should return and GUI elements should be re-enabled
       
        //terminate old tasks
        for i in 0..<self.tasks.count{
            if (self.tasks[i].running){
                self.tasks[i].terminate()
            }
        }
        self.tasks = [NSTask]()
    }
    
    func _compile() {
        return compile()
    }
    
    func compile() {
        return compile(doit: true)
    }
    
    func showCommands() {
        return compile(doit: false)
    }
    
    private func compile(doit doit: Bool){
        
        if !NSFileManager.defaultManager().fileExistsAtPath(Settings.csoundLaunchPath) {
            alert("An error occured.","Csound launch path " + Settings.csoundLaunchPath + " does not exist... make sure this is set correctly in Preferences.")
            return
        }
        
        if self.appDelegate.preferencesViewController != nil{
            Settings.csoundLaunchPath = self.appDelegate.preferencesViewController!.csoundLaunchPathTextField.stringValue
            Settings.additionalFlags = self.appDelegate.preferencesViewController!.additionalFlagsTextField.stringValue
        }
        
        var namingConvention = self.namingConventionTextField.stringValue
        dispatch_async(self.compileSerialQueue,{
            self.stop = false
            
            dispatch_async(dispatch_get_main_queue(),{
                self.fileSelectMenu.enabled = false
                self.outputFolderSelectMenu.enabled = false
                self.namingConventionTextField.enabled = false
                self.appDelegate.windowController!.clearOutputBtn.enabled = false
                if doit {
                    self.appDelegate.windowController!.compileBtn.image = NSImage(named: "stop")
                    self.appDelegate.windowController!.compileBtn.label = "Stop"
                    self.appDelegate.windowController!.compileBtn.target = self
                }
                else{
                    self.appDelegate.windowController!.compileBtn.enabled = false
                }
                self.appDelegate.windowController!.compileBtn.action = #selector(self.stopCsoundProcesses)
                self.appDelegate.windowController!.showCommands.enabled = false
                for i in 0..<self.variableLabel.count{
                    self.variableLabel[i].enabled = false
                    self.variableTextView[i].enabled = false
                }
            })
            
            //terminate old tasks
            for i in 0..<self.tasks.count{
                if (self.tasks[i].running){
                    self.tasks[i].terminate()
                }
            }
            self.tasks = [NSTask]()
            
            //get a list of all variables/values

            var variableTypesArr = Array<String>()
            var variableNamesArr = Array<String>()
            var variableValuesArr = Array<Array<String>>()
            for i in 0..<self.variableLabel.count{
                autoreleasepool {
                    let vals = self.variableTextView[i].string!.componentsSeparatedByString("\n")
                    variableTypesArr.append(self.variableTypes[i])
                    variableNamesArr.append(self.variableLabel[i].stringValue)
                    var arr = Array<String>()
                    for j in 0..<vals.count{
                        if vals[j].containsString("\\"){
                            self.alert("Illegal macro value.","Bad character \\ in macro value " + vals[j])
                            self.stop = true
                            return
                        }
                        arr.append(vals[j])
                    }
                    arr = unique(arr)
                    variableValuesArr.append(arr)
                }
                if self.stop {
                    return
                }
            }
            
            var combos = Array<Array<String>>()
            var combo = Array<String>(count:variableNamesArr.count, repeatedValue: "")
            var variableCombos = Array<Array<String>>()
            
            func getCombo(layer: Int){
                for i in 0..<variableValuesArr[layer].count{
                    combo[layer] = variableValuesArr[layer][i];
                    if (layer < variableValuesArr.count-1){
                        getCombo(layer+1);
                    }
                    else{
                        variableCombos.append(combo)
                    }
                }
            }
            
            if variableNamesArr.count > 0{
                getCombo(0)
            }
            else{
                variableCombos = [Array<String>()]
            }
            
            var macroFlags = Array<Array<String>>()
            for i in 0..<variableCombos.count{
                if (self.stop == true) {
                    return
                }
                autoreleasepool {
                    macroFlags.append(Array<String>())
                    for j in 0..<variableCombos[i].count{
                        if (variableTypesArr[j] != "c"){
                            var flag = ""
                            if (variableTypesArr[j] == "o"){
                                flag += "--omacro:"
                            }
                            else if (variableTypesArr[j] == "s"){
                                flag += "--smacro:"
                            }
                            flag += variableNamesArr[j]
                            flag += "="
                            flag += variableCombos[i][j]
                            macroFlags[macroFlags.count-1].append(flag)
                        }
                        else{
                            var flag = ""
                            flag += "--omacro:"
                            flag += variableNamesArr[j]
                            flag += "="
                            flag += variableCombos[i][j]
                            macroFlags[macroFlags.count-1].append(flag)
                            
                            flag = ""
                            flag += "--smacro:"
                            flag += variableNamesArr[j]
                            flag += "="
                            flag += variableCombos[i][j]
                            macroFlags[macroFlags.count-1].append(flag)
                        }
                    }
                    var fileName = namingConvention
                    if (fileName.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).joinWithSeparator("") == "") {
                        let now = NSDate(timeIntervalSinceNow: 0)
                        let currentCalendar = NSCalendar.currentCalendar()
                        let year = currentCalendar.component(NSCalendarUnit.Year, fromDate: now).forceNumDigits(4)
                        let month = currentCalendar.component(NSCalendarUnit.Month, fromDate: now).forceNumDigits(2)
                        let day = currentCalendar.component(NSCalendarUnit.Day, fromDate: now).forceNumDigits(2)
                        let hour = currentCalendar.component(NSCalendarUnit.Hour, fromDate: now).forceNumDigits(2)
                        let minute = currentCalendar.component(NSCalendarUnit.Minute, fromDate: now).forceNumDigits(2)
                        let second = currentCalendar.component(NSCalendarUnit.Second, fromDate: now).forceNumDigits(2)
                        let nanosecond = currentCalendar.component(NSCalendarUnit.Nanosecond, fromDate: now).forceNumDigits(9)
                        fileName = "csoutput_" + year + month + day + "_" + hour + minute + second + "_" + nanosecond
                    }
                    
                    var strArr = self.namingConventionTextField.stringValue.componentsSeparatedByString("<")
                    for k in 0..<strArr.count{
                        let variableArr = strArr[k].componentsSeparatedByString(">")
                        if (variableArr.count > 0){
                            for l in 0..<variableCombos[i].count{
                                if variableArr[0] == variableNamesArr[l]{
                                    fileName = fileName.stringByReplacingOccurrencesOfString("<" + variableArr[0] + ">",withString: variableCombos[i][l])
                                }
                            }
                        }
                    }
                    
                    var command = Array<String>()
                    var fullStringCommand = Array<String>()
                    if (Settings.verboseDisplay != 0){
                        command.append("-v")
                        fullStringCommand.append("-v")
                        
                    }
                    
                    if (Settings.suppressGraphics != 0){
                        command.append("-d")
                        fullStringCommand.append("-d")
                    }
                    
                    command.append("--m-amps=" + String(Settings.includeAmplitudeLevelMessages))
                    fullStringCommand.append("--m-amps=" + String(Settings.includeAmplitudeLevelMessages))
                    command.append("--m-range=" + String(Settings.includeSamplesOutOfRangeMessages))
                    fullStringCommand.append("--m-range=" + String(Settings.includeSamplesOutOfRangeMessages))
                    command.append("--m-warnings=" + String(Settings.includeWarnings))
                    fullStringCommand.append("--m-warnings=" + String(Settings.includeWarnings))
                    command.append("--m-benchmarks=" + String(Settings.includeBenchmarkInformation))
                    fullStringCommand.append("--m-benchmarks=" + String(Settings.includeBenchmarkInformation))
                    
                    command.append("-+ignore_csopts=" + String(Settings.ignoreFlagsInFile))
                    fullStringCommand.append("-+ignore_csopts=" + String(Settings.ignoreFlagsInFile))
                    
                    for j in 0..<macroFlags[macroFlags.count-1].count{
                        command.append(macroFlags[macroFlags.count-1][j])
                        
                        let p1 = macroFlags[macroFlags.count-1][j].componentsSeparatedByString("=")[0]
                        let p2 = "="
                        let p3 = macroFlags[macroFlags.count-1][j].componentsSeparatedByString("=")[1]
                        fullStringCommand.append(p1+p2+"'"+p3.stringByReplacingOccurrencesOfString("'",withString:"'\"'\"'")+"'")
                    }
                    
                    if (Settings.outputFileType != "don't write file"){
                        let originalName = fileName
                        var fileSuffix = 2
                        while NSFileManager.defaultManager().fileExistsAtPath(Settings.outputDirectoryPath + "/" + fileName + "." + Settings.outputFileType){
                            fileName = originalName + " " + String(fileSuffix)
                            fileSuffix += 1
                        }
                        
                        let outputFile = Settings.outputDirectoryPath + "/" + fileName + "." + Settings.outputFileType
                        
                        command.append("--format=" + Settings.outputFileType)
                        fullStringCommand.append("--format='" + Settings.outputFileType + "'")
                        if (Settings.sampleType != "default"){
                            var formatFlag = "--format="
                            switch Settings.sampleType {
                                case "float": formatFlag += "float"
                                case "long integer": formatFlag += "long"
                                case "short integer": formatFlag += "short"
                                case "24-bit integer": formatFlag += "24bit"
                                case "8-bit unsigned integer": formatFlag += "uchar"
                                case "8-bit signed integer": formatFlag += "schar"
                                case "a-law": formatFlag += "alaw"
                                case "u-law": formatFlag += "ulaw"
                            default: Swift.print("Bad format flag: " + Settings.sampleType); return
                            }
                            command.append(formatFlag)
                            fullStringCommand.append(formatFlag)
                        }
                        command.append("--output=" + outputFile)
                        fullStringCommand.append("--output='" + outputFile.stringByReplacingOccurrencesOfString("'",withString:"'\"'\"'") + "'")
                    }
                    else{
                        command.append("-n")
                    }
                    
                    if Settings.additionalFlags != "" {
                        let addl_flags = Settings.additionalFlags.componentsSeparatedByString(" ")
                        for flagNum in 0..<addl_flags.count{
                            command.append(addl_flags[flagNum])
                            fullStringCommand.append(addl_flags[flagNum])
                        }
                    }
                    
                    if Settings.source == "csd" {
                        command.append(Settings.csdPath)
                        fullStringCommand.append("'" + Settings.csdPath.stringByReplacingOccurrencesOfString("'",withString:"'\"'\"'") + "'")
                    }
                    else{
                        command.append(Settings.orcPath)
                        fullStringCommand.append("'" + Settings.orcPath.stringByReplacingOccurrencesOfString("'",withString:"'\"'\"'") + "'")
                        command.append(Settings.scoPath)
                        fullStringCommand.append("'" + Settings.scoPath.stringByReplacingOccurrencesOfString("'",withString:"'\"'\"'") + "'")
                    }
                    
                    //Swift.print(command)
                    if doit {
                        self.doCsoundCmd(command/*, outputFile*/)
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(),{
                            if (self.csoundOutputTextView.string == ""){
                                self.csoundOutputTextView.string! += Settings.csoundLaunchPath
                                self.csoundOutputTextView.string! +=  " "
                                self.csoundOutputTextView.string! += fullStringCommand.joinWithSeparator(" ")
                            }
                            else{
                                self.csoundOutputTextView.string! += "\n"
                                self.csoundOutputTextView.string! += Settings.csoundLaunchPath
                                self.csoundOutputTextView.string! +=  " "
                                self.csoundOutputTextView.string! += fullStringCommand.joinWithSeparator(" ")
                            }
                        })
                    }
                }
            }
        })
        
        dispatch_async(self.compileSerialQueue,{
            dispatch_async(self.serialQueue,{
                dispatch_async(dispatch_get_main_queue(),{
                    //Swift.print("DONE")
                    if doit {
                        if Settings.playAlertSoundWhenFinished != 0 {
                            NSBeep()
                        }
                        if Settings.closeProgramWhenFinished != 0 {
                            if Settings.playAlertSoundWhenFinished != 0 {
                                sleep(1)
                            }
                            self.closeApp()
                        }
                    }
                    
                    self.fileSelectMenu.enabled = true
                    self.outputFolderSelectMenu.enabled = true
                    self.namingConventionTextField.enabled = true
                    self.appDelegate.windowController!.clearOutputBtn.enabled = true
                    self.appDelegate.windowController!.compileBtn.image = NSImage(named: "play")
                    self.appDelegate.windowController!.compileBtn.label = "Compile"
                    self.appDelegate.windowController!.compileBtn.target = self
                    self.appDelegate.windowController!.compileBtn.action = #selector(ViewController._compile)
                    self.appDelegate.windowController!.compileBtn.enabled = true
                    self.appDelegate.windowController!.showCommands.enabled = true
                    for i in 0..<self.variableLabel.count{
                        self.variableLabel[i].enabled = true
                        self.variableTextView[i].enabled = true
                    }
                })
            })
        })
        
    }
    
    func doCsoundCmd(arguments:[String]/*, _ outputFile: String*/) -> Void{
        dispatch_sync(serialQueue,{
            //NSFileManager.defaultManager().createFileAtPath(outputFile, contents: nil, attributes: nil)

            self.tasks.append(NSTask()) 
            let i = self.tasks.count-1
            //Swift.print(i)
            self.tasks[i].launchPath = Settings.csoundLaunchPath
            self.tasks[i].arguments = arguments
            
            let pipe = NSPipe()
            self.tasks[i].standardOutput = pipe
            self.tasks[i].standardError = pipe
            let outHandle = pipe.fileHandleForReading
            outHandle.waitForDataInBackgroundAndNotify()
            
            var obs1 : NSObjectProtocol!
            obs1 = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification,
                object: outHandle, queue: nil) {  notification -> Void in
                    let data = outHandle.availableData
                    if data.length > 0 {
                        if let str = NSString(data: data, encoding: NSUTF8StringEncoding) {
                            dispatch_async(dispatch_get_main_queue(),{
                                self.csoundOutputTextView.string! += str as String
                            })
                        }
                        outHandle.waitForDataInBackgroundAndNotify()
                    } else {
                        //Swift.print("EOF on stdout from process")
                        if (self.tasks.count > i){
                            self.tasks[i].terminate()
                        }
                        NSNotificationCenter.defaultCenter().removeObserver(obs1)
                    }
            }

            var obs2 : NSObjectProtocol!
            obs2 = NSNotificationCenter.defaultCenter().addObserverForName(NSTaskDidTerminateNotification,
                object: self.tasks[i], queue: nil) { notification -> Void in
                    //Swift.print("terminated")
                    NSNotificationCenter.defaultCenter().removeObserver(obs2)
            }
            
            self.tasks[i].launch()
            self.tasks[i].waitUntilExit()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.viewController = self
        
        self.loadDataFromPlist()
        for i in 0..<variableTextView.count{
            self.variableTextView[i].needsDisplay = true
        }
        self.csoundOutputTextView.font = NSFont(name: "Courier", size: 12)

        Settings.outputDirectoryPath = NSString(string: "~/Desktop").stringByExpandingTildeInPath
        Settings.outputDirectoryUrl = NSURL(fileURLWithPath: Settings.outputDirectoryPath)
        self.outputFolderSelectMenu.itemAtIndex(3)!.title = Settings.outputDirectoryUrl.lastPathComponent!
        self.outputFolderSelectMenu.selectItemAtIndex(3)
        
        self.namingConventionTextField.delegate = self
        
        self.csoundOutputTextView.enclosingScrollView!.hasHorizontalScroller = true
        self.csoundOutputTextView.horizontallyResizable = true
        self.csoundOutputTextView.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
        self.csoundOutputTextView.textContainer!.containerSize = NSMakeSize(CGFloat(FLT_MAX),CGFloat(FLT_MAX))
        self.csoundOutputTextView.textContainer!.widthTracksTextView = false
        
        var nibObjects:NSArray?
        NSBundle.mainBundle().loadNibNamed("HelpPanel",
            owner:self, topLevelObjects:&nibObjects)
        
        var nibDict:Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        if nibObjects != nil{
            let objects = nibObjects!
            for i in 0..<objects.count{
                if (String(objects[i].dynamicType) != "NSApplication"){
                    nibDict[objects[i].identifier!!] = objects[i]
                }
            }
        }
        
        self.helpPanel = nibDict["HelpPanel"]! as! NSPanel
        
        self.fileSelectMenu.selectItemAtIndex(3)
        self.fileSelectMenu2.selectItemAtIndex(3)
        
        self.fileSelectMenu.registerForDraggedTypes([String(kUTTypeFileURL)])
        self.fileSelectMenu2.registerForDraggedTypes([String(kUTTypeFileURL)])
        
        self.outputFolderSelectMenu.registerForDraggedTypes([String(kUTTypeFileURL)])
        
    }
    
    override func viewDidAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(closeApp), name: NSWindowWillCloseNotification, object: self.view.window!)
    }
    
    func closeApp(){
        for i in 0..<self.tasks.count{
            if (self.tasks[i].running){
                self.tasks[i].terminate()
            }
        }
        self.saveDataToPlist()
        NSApp.terminate(self)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidLayout() {
    }
    
    //delegate methods
    func textView(textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertTab(_:)){
            for i in 0..<self.variableTextView.count{
                if (self.variableTextView[i] == textView){
                    let h = self.parametersScrollView.contentView.visibleRect.height
                    if (CGFloat(40+(110*(i+1))) < self.parametersScrollView.contentView.visibleRect.minY) || (CGFloat(40+(110*(i+1))) > self.parametersScrollView.contentView.visibleRect.maxY){
                        self.parametersScrollView.contentView.scrollToPoint(NSPoint(x: 0, y: self.variableTextView[i + 1].superview!.superview!.frame.minY-10))
                        if (self.variableTextView[i + 1].superview!.superview!.frame.minY-10 + h > self.parametersScrollView.documentView!.bounds.height){
                            self.parametersScrollView.contentView.scrollToPoint(NSPoint(x: 0, y: self.parametersScrollView.documentView!.bounds.height - h))
                        }
                    }
                    self.view.window!.makeFirstResponder(self.variableTextView[i + 1])
                    return true
                }
            }
            self.view.window!.makeFirstResponder(self.variableTextView[0])
            if (40 < self.parametersScrollView.contentView.visibleRect.minY) || (40 > self.parametersScrollView.contentView.visibleRect.maxY){
                self.parametersScrollView.contentView.scrollToPoint(NSPoint(x: 0, y: 0))
            }
            return true
            
        }
        
        return false
    }
    
}

