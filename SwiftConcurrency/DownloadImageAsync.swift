//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by Aleksandr Ataev on 12.07.2024.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {

    let url = URL(string: "https://picsum.photos/200")!

    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }

    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }

    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }

    func downloadImageWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {

    @Published var imageWithEscaping: UIImage? = nil
    @Published var imageWithCombine: UIImage? = nil
    @Published var imageWithAsync: UIImage? = nil

    let imageLoader = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()

    func fetchImageWithEscaping() {
        imageLoader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.imageWithEscaping = image
            }
        }
    }

    func fetchImageWithCombine() {
        imageLoader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] image in
                self?.imageWithCombine = image
            }
            .store(in: &cancellables)
    }

    func fetchImageWithAsync() async {
        let image = try? await imageLoader.downloadImageWithAsync()
        await MainActor.run {
            self.imageWithAsync = image
        }
    }
}

struct DownloadImageAsync: View {

    @StateObject private var viewModel = DownloadImageAsyncViewModel()

    var body: some View {
        VStack(spacing: 10) {
            if let imageWithEscaping = viewModel.imageWithEscaping {
                Image(uiImage: imageWithEscaping)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }

            if let imageWithCombine = viewModel.imageWithCombine {
                Image(uiImage: imageWithCombine)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }

            if let imageWithAsync = viewModel.imageWithAsync {
                Image(uiImage: imageWithAsync)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            viewModel.fetchImageWithEscaping()

            viewModel.fetchImageWithCombine()

            Task {
                await viewModel.fetchImageWithAsync()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
