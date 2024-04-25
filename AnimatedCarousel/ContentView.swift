//
//  ContentView.swift
//  AnimatedCarousel
//
//  Created by Dmitrii Melnikov on 24.04.2024.
//

import SwiftUI

struct ContentView: View {
    @State var mockObjects = [
        SomeView(color: .red),
        SomeView(color: .green),
        SomeView(color: .blue),
        SomeView(color: .yellow)
    ]
    @State var actionInProcess = false
    @State var slotIndex = 0
    @State var offsetOfChosenElement = CGSize(width: 0, height: 0)
    @State var offsetOfPreviousElements = CGSize(width: 0, height: 0)
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                HStack {
                        ForEach(0...mockObjects.count - 1, id: \.self) { index in
                            mockObjects[index]
                                .frame(width: 130, height: 100)
                                .shadow(radius: getShadowRadius(index: index))
                                .offset(getOffset(index: index))
                            
                                .onTapGesture {
                                    Task {
                                        await transition(index: index, proxy: proxy)
                                    }
                                }
                                                
                        }
                    }
                .frame(height: 170)
            }
        }
    }
    
    @MainActor func transition(index: Int, proxy: ScrollViewProxy) async {
        if index != 0{
            slotIndex = index
            
            withAnimation(.easeInOut) {
                actionInProcess = true
                offsetOfChosenElement = CGSize(width: 0, height: -10)
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            withAnimation(.easeInOut) {
                offsetOfChosenElement = CGSize(width: -138 * index, height: -10)
                proxy.scrollTo(0)
            }
            
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            withAnimation(.easeInOut) {
                offsetOfPreviousElements = CGSize(width: 138, height: 0)
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            withAnimation(.easeInOut) {
                offsetOfChosenElement = CGSize(width: -138 * index, height: 0)
                actionInProcess = false
            }
            
            try? await Task.sleep(nanoseconds: 250_000_000)
            slotIndex = 0
            
            offsetOfPreviousElements = CGSize(width: 0, height: 0)
            offsetOfChosenElement = CGSize(width: 0, height: 0)
            
            mockObjects.insert(mockObjects.remove(at: index), at: 0)
        }
    }
    
    func getOffset(index: Int) -> CGSize {
        switch index {
        case slotIndex:
            return offsetOfChosenElement
        case 0..<slotIndex:
                return offsetOfPreviousElements
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func getShadowRadius(index: Int) -> CGFloat {
        actionInProcess && slotIndex == index ? 7 : 0
    }
}

#Preview {
    ContentView()
}

struct SomeView: View, Hashable {
    var color: Color
    var body: some View {
        color
    }
}

