//  NC2-WeDrew
//
//  Created by LDW on 6/17/24.
//

import SwiftUI
import AVFoundation

struct ReelsView: View {
    @State private var showImage: Bool = false
    @State private var player: AVPlayer?
    @State private var looper: AVPlayerLooper?
    @State private var isPlay: Bool = false
    @Bindable var reel: Reels
    var size: CGSize
    var safeArea: EdgeInsets
    
    var body: some View {
        GeometryReader{
            let rect = $0.frame(in: .scrollView(axis: .vertical))
            // 하위 뷰 위치를 key를 이용해서 상위뷰에 전달
            CustomVideoPlayer(player: $player)
                .preference(key: OffsetKey.self, value: rect)
                .onPreferenceChange(OffsetKey.self ,perform: { value in
                    playPause(value)
                })
                .overlay(alignment: .topTrailing,content: {
                    ReelDetailsView()
                        .offset(y: 57)
                })
                .onTapGesture(count: 2) { pos in
                    reel.isFavorite.toggle()
                }
                .onTapGesture(count: 1) {
                    withAnimation {
                        self.isPlay.toggle()
                        self.showImage = true
                    }
                    // 이미지가 1초 후에 사라지도록 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            self.showImage = false
                        }
                    }
                }
                .onChange(of: isPlay) { oldValue, newValue in
                    if newValue{
                        player?.pause()
                    } else {
                        player?.play()
                    }
                }
                .onAppear {
                    guard let videoURL = ReelsFileManager.shared.url(for: reel.id) else { return }
                    let playerItem = AVPlayerItem(url: videoURL)
                    let queue = AVQueuePlayer(playerItem: playerItem)
                    looper = AVPlayerLooper(player: queue, templateItem: playerItem)
                    player = queue
                }
                .onDisappear {
                    player = nil
                }
                .overlay(alignment: .center) {
                    if showImage {
                        Image(systemName: isPlay ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.5), value: showImage)
                            .opacity(0.75)
                    }
                }
            
        }
    }
    
    private func playPause(_ rect: CGRect){
        // rect에 따라서 영상을 멈추거나 재생시킴
        if -rect.minY < (rect.height * 0.5) && rect.minY < (rect.height * 0.5){
            player?.play()
        }else{
            player?.pause()
        }
        // 화면을 벗어났다면 비디오의 재생 위치 초기화
        if rect.minY >= size.height || -rect.minY >= size.height{
            player?.seek(to: .zero)
        }
    }
    
    @ViewBuilder
    private func ReelDetailsView() -> some View {
        HStack {
            Button {
                reel.isFavorite.toggle()
                //MARK: - SwiftData로 해당 id를 찾아서 바뀐 값을 저장해주는 로직 필요
            } label: {
            Image(systemName: reel.isFavorite ? "suit.heart.fill" : "suit.heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
            }
            .symbolEffect(.bounce, value: reel.isFavorite)
            .foregroundStyle(reel.isFavorite ? .red : .white)
            .padding(.trailing, 16)
            
            Button {
                print("ellipsis button tapped")
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .rotationEffect(.degrees(90))
                    .scaledToFit()
                    .frame(width: 30)
            }
        }
        .font(.title2)
        .foregroundStyle(.white)
        .padding(.leading, 15)
        .padding(.trailing, 10)
    }
}


