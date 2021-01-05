//
//  DownloaderService.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/5/21.
//

import Foundation

enum DownloadbleFileTypes {
    case database
    case image
    case unknown
    
    var downloadURL: URL {
        switch self {
        case .database:
            return URL(string: "https://sqlite-experiments.herokuapp.com/")!
        default:
            return URL(string: "")!
        }
    }
}

class FileDownloader {
    
    var downloadURL: URL
    
    init(intentdedFileType: DownloadbleFileTypes) {
        self.downloadURL = intentdedFileType.downloadURL
    }
    
    func downloadFileFromURL(completion: @escaping(Result<Bool, ApplicationError>)->Void) {
        
        NetworkService.shared.download(.init(url: downloadURL)) { [self] (result) in
            switch result {
            case .success(let downloadedURL):
                do {
                    
                    try saveFile(from: downloadedURL)
                    completion(.success(true))
                    
                } catch {
                    print ("file error: \(error)")
                    completion(.failure(.fileNotFound(reason: error)))
                }
            case .failure(let error):
                completion(.failure(.fileNotFound(reason: error)))
            }
        }
    }
    
    func saveFile(from downlodedPath: URL) throws {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let savedURL = documentsURL.appendingPathComponent(downlodedPath.lastPathComponent)
        
        try FileManager.default.moveItem(at: downlodedPath, to: savedURL)
        
        
    }
    
    
    
    
}
