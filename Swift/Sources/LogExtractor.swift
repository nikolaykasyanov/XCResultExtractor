//
//  LogExtractor.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 26/10/2024.
//

import Foundation

struct LogExtractor {
    
    let xcResultTool: XCResultToolInterface
    let shell: ShellInterface
    let graphParser: GraphParserInterface
    let fileHandler: FileHandlerInterface
    let logger: LoggerInterface
    
    enum ExtractError: Error {
        case createOutputDirectoryFailed(Error)
    }
    
    func extractLogs(xcResultPath: String,
                     outputPath: String?) throws {
        logger.log("Generating .xcresult graph...")
        
        // Determine output path, either passed in or taken from .xcresult path
        var outputPathBase: String
        if let outputPath {
            outputPathBase = outputPath
            // Create the directory if it doesn't exist
            do {
                try fileHandler.createDirectory(atPath: outputPathBase,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                throw ExtractError.createOutputDirectoryFailed(error)
            }
        } else {
            let pathURL = URL(filePath: xcResultPath)
            outputPathBase = pathURL
                .deletingLastPathComponent()
                .path(percentEncoded: true)
        }
        
        // TODO: optional graph output, or just commented out unless debugging?
        let graph = try xcResultTool.extractGraph(from: xcResultPath,
                                                  outputPath: URL(filePath: outputPathBase))
        
        logger.log("Parsing graph...")
        let logs = try graphParser.parseLogs(from: graph)
        logger.log("Found \(logs.count) log(s)")
        
        try xcResultTool.export(logs: logs,
                                from: xcResultPath,
                                to: outputPathBase)
    }
    
}
