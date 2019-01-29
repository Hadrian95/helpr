//
//  FileHelpers.swift
//  helpr
//
//  Created by Hilmi Abou-Saleh on 2018-11-26.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//
import Foundation
import UIKit
class FileHelpers{
    private static var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func save(image: UIImage, path: String) -> String? {

        let fileURL = documentsUrl.appendingPathComponent(path)

        if let imageData = image.pngData() {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileURL.absoluteString // ----> Save fileName
        }
        print("Error saving image: " + fileURL.absoluteString)
        return nil
    }
    
    static func load(path: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(path)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
}
