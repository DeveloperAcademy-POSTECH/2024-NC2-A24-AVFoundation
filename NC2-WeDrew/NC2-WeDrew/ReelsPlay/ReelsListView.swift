import SwiftUI
import SwiftData

struct ReelsListView: View {
    
    @Query private var reels: [Reels]
    @Environment(\.presentationMode) var presentationMode
    
    private var reelsData: [Reels] {
        let sorted = reels.sorted(by: {$0.createdDate > $1.createdDate})
        let startIdx = sorted.firstIndex(where: {$0.id == startID})!
        return Array(sorted[startIdx..<sorted.endIndex])
    }
    
    var size: CGSize
    var safeArea: EdgeInsets
    let startID: String
    
    var body: some View {
        ScrollView(.vertical){
            ForEach(reelsData) { reel in
                ReelsView(reel: reel, size: size, safeArea: safeArea)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .containerRelativeFrame(.vertical)
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .background(.black)
        .overlay(alignment: .topLeading, content: {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
                    .padding()
            }
            .offset(y: 30)
        })
        .navigationBarHidden(true)
    }
}

