//
//  AuthorizationChecker.swift
//  WeDrew
//
//  Created by 정상윤 on 6/18/24.
//

import Foundation
import AVFoundation

struct AuthorizationChecker {
    
    static func checkCaptureAuthorizationStatus() async -> Status {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .permitted
        case .notDetermined:
            let isPermissionGranted = await AVCaptureDevice.requestAccess(for: .video)
            if isPermissionGranted {
                return .permitted
            } else {
                fallthrough
            }
        case .denied, .restricted:
            fallthrough
        default:
            return .notPermitted
        }
    }
    
}

extension AuthorizationChecker {
    
    enum Status {
        case permitted
        case notPermitted
    }
    
}
