//
//  ReelsRecordViewController.swift
//  WeDrew
//
//  Created by 정상윤 on 6/18/24.
//

import UIKit
import Combine
import AVFoundation

final class ReelsRecordViewController: UIViewController {
    
    private let viewModel = ReelsRecordViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    private let reelsMaxTime: Float = 15
    private let recordButtonTapped = PassthroughSubject<Void, Never>()
    private let swapButtonTapped = PassthroughSubject<Void, Never>()
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
        
        previewLayer.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        previewLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .tertiarySystemBackground
        button.backgroundColor = .label
        button.layer.cornerRadius = 22.5
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var swapButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.tintColor = .tertiarySystemBackground
        button.backgroundColor = .label
        button.layer.cornerRadius = 22.5
        button.addTarget(self, action: #selector(swapButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.trackTintColor = .white
        view.progressTintColor = .systemPink
        view.progress = 0.0
        view.isHidden = true
        
        return view
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.tintColor = .systemPink
        button.layer.cornerRadius = 35
        button.addTarget(self, action: #selector(recordButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setLayoutConstraints()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.captureSession.stopRunning()
    }
    
    private func bind() {
        viewModel.handleInput(input: .init(
            recordButtonTapped: recordButtonTapped,
            swapButtonTapped: swapButtonTapped)
        )
        
        handleIsRecording()
        handleTime()
        handlePresentReelsCheckViewController()
    }
    
    private func handleIsRecording() {
        viewModel.isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                guard let self else { return }
                
                if isRecording {
                    let image = UIImage(
                        systemName: "stop.fill",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)
                    )
                    recordButton.setImage(image, for: .normal)
                    progressView.isHidden = false
                    buttonStackView.isHidden = true
                } else {
                    let image = UIImage(
                        systemName: "circle.fill",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)
                    )
                    recordButton.setImage(image, for: .normal)
                    progressView.isHidden = true
                    buttonStackView.isHidden = false
                }
            }
            .store(in: &cancellableBag)
    }
    
    private func handleTime() {
        viewModel.time
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self else { return }
                progressView.setProgress(time/reelsMaxTime, animated: true)
                
                if time >= reelsMaxTime {
                    recordButtonTapped.send()
                }
            }
            .store(in: &cancellableBag)
    }
    
    private func handlePresentReelsCheckViewController() {
        viewModel.presentReelsCheckViewController
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fileURL in
                let vc = ReelsCheckViewController(reelsFileURL: fileURL)
                self?.navigationController?.pushViewController(vc, animated: false)
            }
            .store(in: &cancellableBag)
    }
    
}

@objc
private extension ReelsRecordViewController {
    
    func recordButtonAction() {
        recordButtonTapped.send()
    }
    
    func swapButtonAction() {
        swapButtonTapped.send()
    }
    
    func cancelButtonAction() {
        dismiss(animated: true)
    }
    
}

private extension ReelsRecordViewController {
    
    func configureUI() {
        view.layer.addSublayer(previewLayer)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(swapButton)
        view.addSubview(buttonStackView)
        view.addSubview(recordButton)
        view.addSubview(progressView)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 45),
            cancelButton.heightAnchor.constraint(equalToConstant: 45),
            swapButton.widthAnchor.constraint(equalToConstant: 45),
            swapButton.heightAnchor.constraint(equalToConstant: 45),
        ])
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
}
