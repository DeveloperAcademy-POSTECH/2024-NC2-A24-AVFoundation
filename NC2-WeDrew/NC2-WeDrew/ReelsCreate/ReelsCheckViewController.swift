//
//  VideoCheckViewController.swift
//  WeDrew
//
//  Created by 정상윤 on 6/19/24.
//

import UIKit
import SwiftData
import AVFoundation

final class ReelsCheckViewController: UIViewController {
    
    let reelsFileURL: URL
    
    private var player: AVQueuePlayer
    private var looper: AVPlayerLooper
    
    private var reelsTitle: String = ""
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        
        layer.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        layer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()
    
    private lazy var alertController: UIAlertController = {
        let alert = UIAlertController(title: "제목을 입력해주세요!", message: "", preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            guard let self else { return }
            
            textField.placeholder = "1글자 이상"
            textField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        alert.addAction(.init(title: "취소", style: .cancel))
        alert.addAction(confirmAction)
        
        return alert
    }()
    
    private lazy var confirmAction: UIAlertAction = {
        let action = UIAlertAction(title: "완료", style: .default) { [weak self] _ in
            self?.saveReels()
        }
        
        action.isEnabled = false
        
        return action
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
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .tertiarySystemBackground
        button.backgroundColor = .label
        button.layer.cornerRadius = 22.5
        button.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    init(reelsFileURL: URL) {
        self.reelsFileURL = reelsFileURL
        self.player = AVQueuePlayer(url: reelsFileURL)
        self.looper = AVPlayerLooper(player: player, templateItem: .init(url: reelsFileURL))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("should not be called! - storyboard not used in this project!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setLayoutConstraints()
        play()
    }
    
    private func play() {
        playerLayer.player = player
        player.play()
    }
    
    private func saveReels() {
        guard let container = try? ModelContainer(for: Reels.self) else { return }
  
        let id = ReelsFileManager.shared.getIDString(from: reelsFileURL)
        
        container.mainContext.insert(Reels(id: id, title: reelsTitle))
        
        navigationController?.dismiss(animated: true)
    }

}

@objc
private extension ReelsCheckViewController {
    
    func cancelButtonAction() {
        ReelsFileManager.shared.delete(url: reelsFileURL)
        
        self.navigationController?.popViewController(animated: false)
    }
    
    func continueButtonAction() {
        self.present(alertController, animated: true)
    }
    
    func titleTextFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        
        reelsTitle = text
        confirmAction.isEnabled = !text.isEmpty
    }
    
}

private extension ReelsCheckViewController {
    
    func configureUI() {
        view.layer.addSublayer(playerLayer)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(continueButton)
        view.addSubview(buttonStackView)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 45),
            cancelButton.heightAnchor.constraint(equalToConstant: 45),
            continueButton.widthAnchor.constraint(equalToConstant: 45),
            continueButton.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
    
}
