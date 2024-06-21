//
//  ContentView.swift
//  NC2-WeDrew
//
//  Created by LDW on 6/16/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var reelsCreateIsPresented = false
    
    var body: some View {
        NavigationStack{
            HomeListView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                
                            } label: {
                                
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("추가", systemImage: "plus") {
                            reelsCreateIsPresented = true
                        }
                        .fullScreenCover(isPresented: $reelsCreateIsPresented) {
                            ReelsRecordView()
                                .ignoresSafeArea()
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
