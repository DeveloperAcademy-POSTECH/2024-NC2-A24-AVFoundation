//
//  VideoRecordViewModel.swift
//  WeDrew
//
//  Created by 정상윤 on 6/13/24.
//

import AVFoundation
import Combine
import UIKit

final class ReelsRecordViewModel: NSObject {
    
    let captureSession = AVCaptureSession()
    
    let isRecording = CurrentValueSubject<Bool, Never>(false)
    let time = CurrentValueSubject<Float, Never>(0)
    let presentReelsCheckViewController = PassthroughSubject<URL, Never>()
    
    private var cameraPosition: AVCaptureDevice.Position = .back
    private var timer: Timer?
    
    private var videoOutput: AVCaptureMovieFileOutput? {
        captureSession.outputs.first as? AVCaptureMovieFileOutput
    }
    
    private var videoInput: AVCaptureDeviceInput? {
        captureSession.inputs.first as? AVCaptureDeviceInput
    }
    
    private var cancellableBag = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        Task(priority: .background) {
            switch await AuthorizationChecker.checkCaptureAuthorizationStatus() {
            case .permitted:
                setupSession()
            case .notPermitted:
                break
            }
        }
    }
    
    func handleInput(input: Input) {
        input.recordButtonTapped
            .sink { _ in
                guard let output = self.videoOutput else { return }
                
                if output.isRecording {
                    self.stopRecording()
                } else {
                    self.startRecording()
                }
            }
            .store(in: &cancellableBag)
        
        input.swapButtonTapped
            .sink { _ in
                self.swapCameraDevice()
            }
            .store(in: &cancellableBag)
    }
    
    private func setupSession() {
        do {
            captureSession.beginConfiguration()
            try addAudioInput()
            try addVideoInput(position: cameraPosition)
            try addMovieFileOutput()
            captureSession.commitConfiguration()
            captureSession.startRunning()
        } catch {
            dump(error)
        }
    }
    
    private func swapCameraDevice() {
        guard let input = captureSession.inputs.last else { return }
        
        cameraPosition = (cameraPosition == .front) ? .back : .front
        
        do {
            captureSession.removeInput(input)
            try addVideoInput(position: cameraPosition)
        } catch {
            dump(error)
        }
    }
    
    private func startRecording() {
        guard let output = videoOutput,
              let url = ReelsFileManager.shared.url(for: UUID().uuidString) else { return }
        
        isRecording.send(true)
        output.startRecording(to: url, recordingDelegate: self)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.time.send(self.time.value + 0.1)
        }
    }
    
    private func stopRecording() {
        guard let output = videoOutput else { return }
        
        isRecording.send(false)
        output.stopRecording()
        
        timer?.invalidate()
        time.send(0)
    }
    
    private func bestDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        return discoverySession.devices.first
    }
    
    private func addVideoInput(position: AVCaptureDevice.Position) throws {
        
        guard let videoDevice = bestDevice(position: position) else { throw SessionConfigureError.deviceNotFound(for: .video) }
        
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            throw SessionConfigureError.inputAddFailed(for: .video)
        }
    }
    
    private func addAudioInput() throws {
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { throw SessionConfigureError.deviceNotFound(for: .audio) }
        
        let audioInput = try AVCaptureDeviceInput(device: audioDevice)
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        } else {
            throw SessionConfigureError.inputAddFailed(for: .audio)
        }
    }
    
    private func addMovieFileOutput() throws {
        guard videoOutput == nil else { return }
        
        let fileOutput = AVCaptureMovieFileOutput()
        
        if captureSession.canAddOutput(fileOutput) {
            captureSession.addOutput(fileOutput)
        } else {
            throw SessionConfigureError.outputAddFailed(for: .video)
        }
    }
    
}

extension ReelsRecordViewModel: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        if let error {
            dump("Error recording movie: \(error)")
        } else {
            presentReelsCheckViewController.send(outputFileURL)
        }
    }
    
}

extension ReelsRecordViewModel {
    
    struct Input {
        let recordButtonTapped: PassthroughSubject<Void, Never>
        let swapButtonTapped: PassthroughSubject<Void, Never>
    }
    
}

enum SessionConfigureError: Error {
    
    case deviceNotFound(for: AVMediaType)
    case inputAddFailed(for: AVMediaType)
    case outputAddFailed(for: AVMediaType)
    
}
