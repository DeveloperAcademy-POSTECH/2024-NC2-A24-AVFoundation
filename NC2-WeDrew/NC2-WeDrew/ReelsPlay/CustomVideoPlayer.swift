import SwiftUI
import AVKit

struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var player: AVPlayer?
    // SwiftUI 뷰가 생성될 때 호출
    func makeUIViewController(context: Context) -> some AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill
        controller.showsPlaybackControls = false
        
        return controller
    }
    // SwiftUI 뷰가 업데이트될 때마다 호출
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.player = player
    }
}
