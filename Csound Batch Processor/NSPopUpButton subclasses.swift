import Cocoa

enum ResolveAliasError:ErrorType {
    case UnableToResolveAlias
    case UnableToGetType
    case Other
}

func resolveAlias(url:NSURL) throws -> NSURL{
    var myURL = url
    do {
        let types = try url.resourceValuesForKeys([NSURLTypeIdentifierKey])
        for (_, type) in types {
            if type as! String == String(kUTTypeAliasFile) {
                do {
                    try myURL = NSURL(byResolvingAliasFileAtURL: url, options: NSURLBookmarkResolutionOptions())
                    do {
                        return try resolveAlias(url)
                    }
                    catch _ as NSError {
                        throw ResolveAliasError.Other
                    }
                }
                catch _ as NSError {
                    throw ResolveAliasError.UnableToResolveAlias
                }
            }
        }
    }
    catch _ as NSError {
        throw ResolveAliasError.UnableToGetType
    }
    return myURL
}

class File1SelectPopUpButton:NSPopUpButton {
    
    private var draggedURL:NSURL?
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let draggedObjects = sender.draggingPasteboard().readObjectsForClasses([NSURL.classForCoder()], options: nil)
        if draggedObjects == nil {
            return NSDragOperation.None
        }
        if draggedObjects!.count > 1{
            return NSDragOperation.None
        }
        
        var url = draggedObjects![0] as! NSURL
        
        do {
            url = try resolveAlias(url)
        }
        catch _ as NSError {
            return NSDragOperation.None
        }
        
        if Settings.source == "csd" && url.pathExtension! != "csd" {
            return NSDragOperation.None
        }
        else if Settings.source != "csd" && url.pathExtension! != "orc" {
            return NSDragOperation.None
        }
        
        self.draggedURL = url

        return NSDragOperation.Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let url = draggedURL!
        dispatch_async(dispatch_get_main_queue(),{
            self.itemAtIndex(3)!.title = url.lastPathComponent!
            self.selectItemAtIndex(3)
            if Settings.source == "csd" {
                Settings.csdPath = url.path!
                Settings.csdUrl = url
                (NSApplication.sharedApplication().delegate as! AppDelegate).viewController!.readFile()
            }
            else{
                Settings.orcPath = url.path!
                Settings.orcUrl = url
                if Settings.orcPath != String() && Settings.scoPath != String() {
                    (NSApplication.sharedApplication().delegate as! AppDelegate).viewController!.readFile()
                }
            }
        })
        
        return true
    }
    
}

class File2SelectPopUpButton:NSPopUpButton {
    
    private var draggedURL:NSURL?
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let draggedObjects = sender.draggingPasteboard().readObjectsForClasses([NSURL.classForCoder()], options: nil)
        if draggedObjects == nil {
            return NSDragOperation.None
        }
        if draggedObjects!.count > 1{
            return NSDragOperation.None
        }
        
        var url = draggedObjects![0] as! NSURL
        
        do {
            url = try resolveAlias(url)
        }
        catch _ as NSError {
            return NSDragOperation.None
        }
        
        if url.pathExtension! != "sco" {
            return NSDragOperation.None
        }
        
        self.draggedURL = url

        return NSDragOperation.Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let url = draggedURL!
        dispatch_async(dispatch_get_main_queue(),{
            self.itemAtIndex(3)!.title = url.lastPathComponent!
            self.selectItemAtIndex(3)
            Settings.scoPath = url.path!
            Settings.scoUrl = url
            if Settings.orcPath != String() && Settings.scoPath != String() {
                (NSApplication.sharedApplication().delegate as! AppDelegate).viewController!.readFile()
            }
        })
        return true
    }
    
}

class OutputDirectorySelectPopUpButton:NSPopUpButton {
    
    private var draggedURL:NSURL? = nil
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let draggedObjects = sender.draggingPasteboard().readObjectsForClasses([NSURL.classForCoder()], options: nil)
        if draggedObjects == nil {
            return NSDragOperation.None
        }
        if draggedObjects!.count > 1{
            return NSDragOperation.None
        }
        
        var url = draggedObjects![0] as! NSURL
        
        do {
            url = try resolveAlias(url)
        }
        catch _ as NSError {
            return NSDragOperation.None
        }
        
        var types:[String:AnyObject]?
        do {
            types = try url.resourceValuesForKeys([NSURLTypeIdentifierKey])
        }
        catch _ as NSError {
            return NSDragOperation.None
        }
        
        for (_, type) in types! {
            if type as! String != "public.folder" {
                return NSDragOperation.None
            }
        }
        
        self.draggedURL = url
        
        return NSDragOperation.Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let url = draggedURL!
        dispatch_async(dispatch_get_main_queue(),{
            self.itemAtIndex(3)!.title = url.lastPathComponent!
            self.selectItemAtIndex(3)
            Settings.outputDirectoryPath = url.path!
            Settings.outputDirectoryUrl = url
        })
        return true
    }
    
}