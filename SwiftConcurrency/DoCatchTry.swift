//
//  DoCatchTry.swift
//  SwiftConcurrency
//
//  Created by Aleksandr Ataev on 10.07.2024.
//

import SwiftUI

// do-catch
// try
// throws

class DoCatchTryDataManager {

    let isActive: Bool = true

    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }

    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT 2 !!!")
        } else {
            return .failure(URLError(.unknown))
        }
    }

    func getTitle3() throws -> String {
//        if isActive {
//            return "NEW TEXT 3 !!!"
//        } else {
        throw URLError(.appTransportSecurityRequiresSecureConnection)
//        }
    }

    func getTitle4() throws -> String {
        if isActive {
            return "FINAL TEXT !!!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryViewModel: ObservableObject {

    @Published var text: String = "Starting text."
    let manager = DoCatchTryDataManager()

    func fetchTitle() {
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */

        /*
        let result = manager.getTitle2()

        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
         */

        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }

            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch {
            self.text = error.localizedDescription
        }
    }
}

struct DoCatchTry: View {

    @StateObject var viewModel = DoCatchTryViewModel()

    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTry()
}
