import Cocoa

struct Defaults {
    static var csoundLaunchPath = "/usr/local/bin/csound"
    
    static var source = "csd"
    static var ignoreFlagsInFile = 1

    static var outputFileType = "wav"
    static var sampleType = "default"
    
    static var verboseDisplay = 0
    static var suppressGraphics = 1
    static var includeAmplitudeLevelMessages = 1
    static var includeSamplesOutOfRangeMessages = 1
    static var includeWarnings = 1
    static var includeBenchmarkInformation = 1
    
    static var playAlertSoundWhenFinished = 1
    static var closeProgramWhenFinished = 0
    
    static var additionalFlags = String()
}

struct Settings {
    static var csoundLaunchPath = Defaults.csoundLaunchPath
    
    static var source = Defaults.source
    static var ignoreFlagsInFile = Defaults.ignoreFlagsInFile
    
    static var outputFileType = Defaults.outputFileType
    static var sampleType = Defaults.sampleType
    
    static var verboseDisplay = Defaults.verboseDisplay
    static var suppressGraphics = Defaults.suppressGraphics
    static var includeAmplitudeLevelMessages = Defaults.includeAmplitudeLevelMessages
    static var includeSamplesOutOfRangeMessages = Defaults.includeSamplesOutOfRangeMessages
    static var includeWarnings = Defaults.includeWarnings
    static var includeBenchmarkInformation = Defaults.includeBenchmarkInformation
    
    static var playAlertSoundWhenFinished = Defaults.playAlertSoundWhenFinished
    static var closeProgramWhenFinished = Defaults.closeProgramWhenFinished
    
    static var additionalFlags = Defaults.additionalFlags
    
    static var csdPath = String()
    static var csdUrl = NSURL()
    static var orcPath = String()
    static var orcUrl = NSURL()
    static var scoPath = String()
    static var scoUrl = NSURL()
    static var outputDirectoryPath = String()
    static var outputDirectoryUrl = NSURL()
}