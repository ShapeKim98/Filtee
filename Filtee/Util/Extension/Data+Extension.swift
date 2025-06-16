//
//  Data+Extension.swift
//  Filtee
//
//  Created by 김도형 on 6/11/25.
//

import Foundation
import UniformTypeIdentifiers

extension Data {
    func detectMimeType() -> String? {
        guard !isEmpty else { return nil }
        
        let firstFewBytes = self.prefix(8)
        
        // JPEG: FF D8
        if firstFewBytes.count >= 2 && firstFewBytes[0] == 0xFF && firstFewBytes[1] == 0xD8 {
            return "image/jpeg"
        }
        // PNG: 89 50 4E 47
        else if firstFewBytes.count >= 4 && firstFewBytes[0] == 0x89 && firstFewBytes[1] == 0x50 && firstFewBytes[2] == 0x4E && firstFewBytes[3] == 0x47 {
            return "image/png"
        }
        // GIF: 47 49 46 38
        else if firstFewBytes.count >= 4 && firstFewBytes[0] == 0x47 && firstFewBytes[1] == 0x49 && firstFewBytes[2] == 0x46 && firstFewBytes[3] == 0x38 {
            return "image/gif"
        }
        // PDF: 25 50 44 46
        else if firstFewBytes.count >= 4 && firstFewBytes[0] == 0x25 && firstFewBytes[1] == 0x50 && firstFewBytes[2] == 0x44 && firstFewBytes[3] == 0x46 {
            return "application/pdf"
        }
        // MP4: 'ftyp' at offset 4
        else if firstFewBytes.count >= 8 && String(data: self.subdata(in: 4..<8), encoding: .ascii) == "ftyp" {
            return "video/mp4"
        }
        return nil
    }
    
    func fileExtensionForMimeType(_ mimeType: String) -> String? {
        if let utType = UTType(mimeType: mimeType) {
            return utType.preferredFilenameExtension
        }
        return nil
    }

    func fileExtensionForData() -> String? {
        guard let mimeType = self.detectMimeType() else {
            return nil
        }
        return fileExtensionForMimeType(mimeType)
    }
}


