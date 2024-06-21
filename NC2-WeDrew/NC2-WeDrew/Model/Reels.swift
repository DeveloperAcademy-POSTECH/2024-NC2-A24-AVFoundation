//
//  WDVideo.swift
//  WeDrew
//
//  Created by 정상윤 on 6/19/24.
//

import Foundation
import SwiftData

@Model
final class Reels: Hashable {
    
    @Attribute(.unique) let id: String
    let title: String
    let createdDate: Date
    var isFavorite: Bool
    
    init(id: String, title: String, createdDate: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.createdDate = createdDate
        self.isFavorite = isFavorite
    }
    
}
