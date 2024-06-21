//
//  WDFileManager.swift
//  WeDrew
//
//  Created by 정상윤 on 6/19/24.
//

import Foundation
import AVFoundation

final class ReelsFileManager {
    
    static let shared = ReelsFileManager()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    func url(for id: String) -> URL? {
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        return path
            .appendingPathComponent(id)
            .appendingPathExtension("mp4")
    }
    
    func delete(url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            dump(error)
        }
    }
    
    func getIDString(from url: URL) -> String {
        let id = url.deletingPathExtension().lastPathComponent
        
        return id
    }
    
    func generateThumbnail(id: String) async -> CGImage? {
        guard let url = url(for: id) else { return nil }
        
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            return try await imageGenerator.image(at: CMTime(value: 0, timescale: 1)).image
        } catch {
            dump(error)
            return nil
        }
    }
    
}
