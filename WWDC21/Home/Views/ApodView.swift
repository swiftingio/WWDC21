//
//  ApodView.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import APODY
import SwiftUI

struct ApodView: View {
    var namespace: Namespace.ID
    @ObservedObject var viewModel: ApodViewModel
    @Binding var showDetails: Bool
    @EnvironmentObject var presentedObject: PresentedView

    var isPresentedView: Bool {
        showDetails && presentedObject.presentedViewModel == viewModel
    }

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
                    .matchedGeometryEffect(id: "mainImage\(viewModel.title)", in: namespace)
            } else {
                ProgressView()
            }
        }
        .frame(minWidth: 0, minHeight: 400)
        HStack {
            Text(viewModel.title)
                .matchedGeometryEffect(id: "mainTitle\(viewModel.title)", in: namespace)
            Spacer()
            Text(viewModel.date)
        }
        .padding()
        .background(.thinMaterial)
    }
}

struct ApodView_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        let model = try? ApodyFixtures.example1().randomElement()
        ApodView(namespace: namespace,
                 viewModel: ApodViewModel(apod: model!,
                                          networking: DefaultApodNetworking(),
                                          imageCache: ImageCache()), showDetails: .constant(false))
            .environment(\.managedObjectContext, APODYPersistenceController.preview.container.viewContext)
    }
}
