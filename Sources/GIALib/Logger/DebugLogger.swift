//
//  File.swift
//  
//
//  Created by admin on 13.03.2024.
//

import Foundation

public enum DebugLogger {
    enum LogLevel {
        case info
        case warning
        case error
        
        fileprivate var prefix: String {
            switch self {
            case .info:
                return "INFO ℹ️"
            case .warning:
                return "WARN ⚠️"
            case .error:
                return "ERR ⛔️"
            }
        }
    }
    
    struct Context {
        let file: String
        let function: String
        let line: Int
        var description: String {
            return "\((file as NSString).lastPathComponent):\(line) \(function)"
        }
    }
    
    public static func info(_ str: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        DebugLogger.handleLog(level: .info, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    
    public static func warning(_ str: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        DebugLogger.handleLog(level: .warning, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    
    public static func error(_ str: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        DebugLogger.handleLog(level: .error, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    fileprivate static func handleLog(level: LogLevel, str: String, shouldLogContext: Bool, context: Context) {
        let logComponents = ["[\(level.prefix)]", str]
        var fullString = logComponents.joined(separator: " ")
        if shouldLogContext {
            fullString += " + \(context.description)"
        }
        
        #if DEBUG
        print(fullString)
        #endif
    }
}

