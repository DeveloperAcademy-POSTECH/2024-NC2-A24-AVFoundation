//
//  VideoRecordView.swift
//  WeDrew
//
//  Created by 정상윤 on 6/13/24.
//

import SwiftUI
import UIKit

struct ReelsRecordView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: ReelsRecordViewController())
        
        navigationController.setNavigationBarHidden(true, animated: false)
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
}

#Preview {
    ReelsRecordView()
}
