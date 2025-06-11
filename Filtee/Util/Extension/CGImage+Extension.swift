//
//  CGImage+Extension.swift
//  Filtee
//
//  Created by 김도형 on 6/10/25.
//

import ImageIO
import UIKit
import CoreGraphics

extension CGImage {
    /// EXIF 방향 정보를 기반으로 CGImage를 UIImage처럼 자동 회전 조절
    func oriented(_ orientation: CGImagePropertyOrientation) -> CGImage {
        guard orientation != .up else { return self }
        // 이미지 크기
        let width = CGFloat(self.width)
        let height = CGFloat(self.height)
        
        // 방향에 따른 변환 행렬 계산
        var transform = CGAffineTransform.identity
        var newSize = CGSize(width: width, height: height)
        
        switch orientation {
        case .up: // 1
            return self
        case .upMirrored: // 2
            transform = transform.translatedBy(x: width, y: 0).scaledBy(x: -1, y: 1)
        case .down: // 3
            transform = transform.translatedBy(x: width, y: height).rotated(by: .pi)
        case .downMirrored: // 4
            transform = transform.translatedBy(x: 0, y: height).scaledBy(x: 1, y: -1)
        case .leftMirrored: // 5
            newSize = CGSize(width: height, height: width)
            transform = transform.translatedBy(x: height, y: width).scaledBy(x: -1, y: 1).rotated(by: .pi/2)
        case .left: // 6
            newSize = CGSize(width: height, height: width)
            transform = transform.translatedBy(x: 0, y: width).rotated(by: .pi/2)
        case .rightMirrored: // 7
            newSize = CGSize(width: height, height: width)
            transform = transform.translatedBy(x: 0, y: 0).scaledBy(x: -1, y: 1).rotated(by: -.pi/2)
        case .right: // 8
            newSize = CGSize(width: height, height: width)
            transform = transform.translatedBy(x: height, y: 0).rotated(by: -.pi/2)
        }
        
        // 새로운 컨텍스트 생성
        guard let colorSpace = self.colorSpace,
              let context = CGContext(
                data: nil,
                width: Int(newSize.width),
                height: Int(newSize.height),
                bitsPerComponent: self.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: self.bitmapInfo.rawValue
              )
        else { return self }
        
        // 변환 적용
        context.concatenate(transform)
        
        // 이미지 그리기
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 변환된 CGImage 반환
        return context.makeImage() ?? self
    }
    
    func rotateCGImage(byAngleDegrees: CGFloat) -> CGImage? {
        let radians = byAngleDegrees * .pi / 180
        let transform = CGAffineTransform(rotationAngle: radians)
        
        let width = self.width
        let height = self.height
        let rotatedSize = CGRect(x: 0, y: 0, width: width, height: height)
            .applying(transform)
            .size
        
        let context = CGContext(
            data: nil,
            width: Int(rotatedSize.width),
            height: Int(rotatedSize.height),
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: 0,
            space: self.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: self.bitmapInfo.rawValue
        )
        
        guard let context = context else { return nil }
        
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        context.translateBy(x: -CGFloat(width) / 2, y: -CGFloat(height) / 2)
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()
    }
}
