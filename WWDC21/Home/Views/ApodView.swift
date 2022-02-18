//
//  ApodView.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import APODY
import SwiftUI

struct ApodView: View {
    @StateObject var viewModel: ApodViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            switch viewModel.type {
            case .image:
                makeImageView()
            case .video:
                VideoWebView(request: URLRequest(url: URL(string: viewModel.url)!))
                    .frame(maxWidth: .infinity, minHeight: 400)
                HStack {
                    Text(viewModel.title)
                    Spacer()
                    Text(viewModel.date)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .background(.thickMaterial)
        .mask(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 8)
        .task {
            try? await viewModel.getApodContent()
        }
    }

    @ViewBuilder
    func makeImageView() -> some View {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
            }
        }
        .frame(minWidth: 0, minHeight: 400)
        HStack {
            Text(viewModel.title)
            Spacer()
            Text(viewModel.date)
        }
        .padding()
        .background(.thinMaterial)
    }
}

struct ApodView_Previews: PreviewProvider {
    static var previews: some View {
        let model = try? ApodyFixtures.example1().randomElement()
        ApodView(viewModel: ApodViewModel(apod: model!, networking: DefaultApodNetworking(), imageCache: ImageCache()))
            .environment(\.managedObjectContext, APODYPersistenceController.preview.container.viewContext)
    }
}
