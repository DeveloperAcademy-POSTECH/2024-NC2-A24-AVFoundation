import SwiftUI
import SwiftData
import AVFoundation

struct HomeListView: View {
    
    @Query private var reelsData: [Reels]
    
    private var sortedReels: [Reels] {
        reelsData.sorted(by: {$0.createdDate > $1.createdDate})
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 100)),
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                ScrollView {
                    Divider()
                        .padding(.vertical, 8)
                    LazyVGrid(columns: columns, alignment: .center, content: {
                        ForEach(sortedReels) { reels in
                            NavigationLink {
                                ReelsListView(size: size, safeArea: safeArea, startID: reels.id)
                                    .ignoresSafeArea(.container, edges: .all)
                                    .navigationBarHidden(true)
                            } label: {
                                VStack {
                                    ReelsThumbnailView(id: reels.id)
                                        .aspectRatio(CGSize(width: 1, height: 1.6), contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    Text(reels.title)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    })
                    .padding()
                }
            }
        }
        .navigationTitle("나의 추억들")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

extension HomeListView {
    
    enum ThumbnailError: Error {
        case invalidURL
        case imageGenerationFailed
    }
    
}

#Preview {
    HomeListView()
}
