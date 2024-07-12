//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrency
//
//  Created by Ataev Aleksandr on 12.07.2024.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        self.dataArray.append("TITLE 1: \(Thread.current)")
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "TITLE 2: \(Thread.current)"
            
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = "TITLE 3: \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author 1: \(Thread())"
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author 2: \(Thread())"
        await MainActor.run {
            self.dataArray.append(author1)
            self.dataArray.append(author2)
            
            let author3 = "Author 3: \(Thread())"
            self.dataArray.append(author3)
        }
        
        await addSomething()
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let something1 = "Something 1: \(Thread())"
        await MainActor.run {
            self.dataArray.append(something1)
            
            let something2 = "Something 2: \(Thread())"
            self.dataArray.append(something2)
        }
    }
    
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject private var viewModel = AsyncAwaitBootcampViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                
                let finalText = "FINAL TEXT!: \(Thread())"
                viewModel.dataArray.append(finalText)
            }
            
            //            viewModel.addTitle1()
            //            viewModel.addTitle2()
        }
    }
}

#Preview {
    AsyncAwaitBootcamp()
}
