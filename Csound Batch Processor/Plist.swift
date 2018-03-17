import Cocoa

extension ViewController {
    func loadDataFromPlist(){
        var myDict: NSDictionary?
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("Config.plist")
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = myDict {
            if let val = dict["CsoundLaunchPath"] as? String{
                Settings.csoundLaunchPath = val
            }
            if let val = dict["SourceCSD"] as? String {
                Settings.csdPath = val
            }
            if let val = dict["SourceORC"] as? String {
                Settings.orcPath = val
            }
            if let val = dict["SourceSCO"] as? String {
                Settings.scoPath = val
            }
            if let val = dict["Source"] as? String{
                Settings.source = val
            }
            if let val = dict["IgnoreFlagsInFile"] as? Int{
                Settings.ignoreFlagsInFile = val
            }
            if (Settings.source != "csd"){
                self.selectACsdTextField.stringValue = "Select a .orc file:"
                self.selectAScoTextField.stringValue = "Select a .sco file:"
                self.selectAScoTextField.hidden = false
                self.fileSelectMenu2.hidden = false
                
                var readFile = true
                if Settings.orcPath != "" && NSFileManager.defaultManager().fileExistsAtPath(Settings.orcPath){
                    dispatch_async(dispatch_get_main_queue(),{
                        Settings.orcUrl = NSURL(fileURLWithPath: Settings.orcPath)
                        self.fileSelectMenu.itemAtIndex(3)!.title = Settings.orcUrl.lastPathComponent!
                        self.fileSelectMenu.selectItemAtIndex(3)
                    })
                }
                else{
                    readFile = false
                }
                if Settings.scoPath != "" && NSFileManager.defaultManager().fileExistsAtPath(Settings.scoPath){
                    dispatch_async(dispatch_get_main_queue(),{
                        Settings.scoUrl = NSURL(fileURLWithPath: Settings.scoPath)
                        self.fileSelectMenu2.itemAtIndex(3)!.title = Settings.scoUrl.lastPathComponent!
                        self.fileSelectMenu2.selectItemAtIndex(3)
                    })
                }
                else{
                    readFile = false
                }
                
                if readFile {
                    self.readFile()
                }
            }
            else{
                self.selectACsdTextField.stringValue = "Select a .csd file:"
                self.selectAScoTextField.hidden = true
                self.fileSelectMenu2.hidden = true
                if Settings.csdPath != "" && NSFileManager.defaultManager().fileExistsAtPath(Settings.csdPath){
                    dispatch_async(dispatch_get_main_queue(),{
                        Settings.csdUrl = NSURL(fileURLWithPath: Settings.csdPath)
                        self.fileSelectMenu.itemAtIndex(3)!.title = Settings.csdUrl.lastPathComponent!
                        self.fileSelectMenu.selectItemAtIndex(3)
                        self.readFile()
                    })
                }
            }
            if let val = dict["OutputFileType"] as? String{
                Settings.outputFileType = val
            }
            if let val = dict["SampleFormat"] as? String{
                Settings.sampleType = val
            }
            if let val = dict["VerboseDisplay"] as? Int{
                Settings.verboseDisplay = val
            }
            if let val = dict["SuppressGraphics"] as? Int{
                Settings.suppressGraphics = val
            }
            if let val = dict["IncludeAmplitudeLevelMessages"] as? Int{
                Settings.includeAmplitudeLevelMessages = val
            }
            if let val = dict["IncludeSamplesOutOfRangeMessages"] as? Int{
                Settings.includeSamplesOutOfRangeMessages = val
            }
            if let val = dict["IncludeWarnings"] as? Int{
                Settings.includeWarnings = val
            }
            if let val = dict["IncludeBenchmarkInformation"] as? Int{
                Settings.includeBenchmarkInformation = val
            }
            if let val = dict["PlayAlertSoundWhenFinished"] as? Int{
                Settings.playAlertSoundWhenFinished = val
            }
            if let val = dict["CloseProgramWhenFinished"] as? Int{
                Settings.closeProgramWhenFinished = val
            }
            if let val = dict["AdditionalFlags"] as? String{
                Settings.additionalFlags = val
            }
            if let val = dict["OutputDirectory"] as? String{
                if val != "" && NSFileManager.defaultManager().fileExistsAtPath(val){
                    dispatch_async(dispatch_get_main_queue(),{
                        Settings.outputDirectoryUrl = NSURL(fileURLWithPath: val)
                        Settings.outputDirectoryPath = val
                        self.outputFolderSelectMenu.itemAtIndex(3)!.title = Settings.outputDirectoryUrl.lastPathComponent!
                        self.outputFolderSelectMenu.selectItemAtIndex(3)
                    })
                }
            }
        }
    }
}

extension ViewController {
    func saveDataToPlist(){
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("Config.plist")
        if (!(NSFileManager.defaultManager().fileExistsAtPath(path))) {
            let bundle : NSString = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!
            try! NSFileManager.defaultManager().copyItemAtPath(bundle as String, toPath: path)
        }
        
        let dict: NSMutableDictionary = NSMutableDictionary()
        dict.removeAllObjects()
        
        dict.setObject(Settings.csoundLaunchPath, forKey: "CsoundLaunchPath")
        
        dict.setObject(Settings.source, forKey: "Source")
        dict.setObject(Settings.ignoreFlagsInFile, forKey: "IgnoreFlagsInFile")
        
        dict.setObject(Settings.outputFileType, forKey: "OutputFileType")
        dict.setObject(Settings.sampleType, forKey: "SampleFormat")
        
        dict.setObject(Settings.verboseDisplay, forKey: "VerboseDisplay")
        dict.setObject(Settings.suppressGraphics, forKey: "SuppressGraphics")
        dict.setObject(Settings.includeAmplitudeLevelMessages, forKey: "IncludeAmplitudeLevelMessages")
        dict.setObject(Settings.includeSamplesOutOfRangeMessages, forKey: "IncludeSamplesOutOfRangeMessages")
        dict.setObject(Settings.includeWarnings, forKey: "IncludeWarnings")
        dict.setObject(Settings.includeBenchmarkInformation, forKey: "SuppressGraphics")
        
        dict.setObject(Settings.playAlertSoundWhenFinished, forKey: "PlayAlertSoundWhenFinished")
        dict.setObject(Settings.closeProgramWhenFinished, forKey: "CloseProgramWhenFinished")

        
        dict.setObject(Settings.additionalFlags, forKey: "AdditionalFlags")

        
        dict.setObject(Settings.csdPath, forKey: "SourceCSD")
        dict.setObject(Settings.orcPath, forKey: "SourceORC")
        dict.setObject(Settings.scoPath, forKey: "SourceSCO")
        dict.setObject(Settings.outputDirectoryPath, forKey: "OutputDirectory")
        
        dict.writeToFile(path, atomically: false)
        
    }
}