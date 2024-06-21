//
//  ReelsThumbnailView.swift
//  NC2-WeDrew
//
//  Created by 정상윤 on 6/20/24.
//

import SwiftUI

struct ReelsThumbnailView: View {
    
    let id: String
    @State private var cgImage: CGImage? = nil
    
    var body: some View {
        ZStack {
            if let cgImage {
                Image(uiImage: UIImage(cgImage: cgImage))
                    .resizable()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.secondary)
            }
        }
        .task(priority: .background) {
            cgImage = await ReelsFileManager.shared.generateThumbnail(id: id)
        }
    }
    
}
