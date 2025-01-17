//
//  FileHandler.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Foundation

protocol FileHandlerInterface {

    func createDirectory(atPath path: String,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey:Any]?) throws
    
    func moveItems(from source: URL,
                   to destination: URL) throws
    
    func removeItem(at path: URL) throws
    
    func write(string: String,
               to path: URL,
               atomically: Bool,
               encoding: String.Encoding) throws
    
}

struct FileHandler: FileHandlerInterface {
    
    enum FileError: Error {
        case failedToEnumerateDirectory
    }
    
    func createDirectory(atPath path: String,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey:Any]?) throws {
        if !FileManager.default.fileExists(atPath: path) {
            try FileManager.default.createDirectory(atPath: path,
                                                    withIntermediateDirectories: createIntermediates,
                                                    attributes: attributes)
        }
    }
    
    /// Moves files at the source directory to the destination directory. Replacing any duplicate files.
    func moveItems(from source: URL,
                   to destination: URL) throws {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: source, includingPropertiesForKeys: nil) else {
            throw FileError.failedToEnumerateDirectory
        }
        
        for case let fileURL as URL in enumerator {
            let destinationFile = destination.appending(component: fileURL.lastPathComponent)
            // Delete any duplicate file at the destination
            if fm.fileExists(atPath: destinationFile.path()) {
                try fm.removeItem(at: destinationFile)
            }
            // Move the file
            try fm.moveItem(at: fileURL,
                            to: destinationFile) // TODO: just log errors and keep trying?
        }
        
    }
    
    func removeItem(at path: URL) throws {
        try FileManager.default.removeItem(at: path)
    }
    
    func write(string: String,
               to path: URL,
               atomically: Bool,
               encoding: String.Encoding) throws {
        try string.write(to: path,
                         atomically: atomically,
                         encoding: encoding)
    }
    
}
