//  Created by Code4Romania

import Foundation
import Firebase
import FirebaseCrashlytics

func DebugLog(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
    let filename = URL(fileURLWithPath: file.description).lastPathComponent
    let output = "\(filename):\(line) \(function) $ \(message)"
    
    #if targetEnvironment(simulator)
    NSLogv("%@", getVaList([output]))
    #elseif DEBUG
    Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([output]))
    #else
    Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([output]))
    #endif
}
