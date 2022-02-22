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
    let model: APODModel
    @StateObject var viewModel: ApodViewModel
    @Binding var showDetails: Bool
    @EnvironmentObject var presentedObject: PresentedView

    var isPresentedView: Bool {
        showDetails && presentedObject.model?.url == viewModel.url
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            switch viewModel.type {
            case .image:
                makeImageView()
            case .video:
                VideoWebView(request: URLRequest(url: URL(string: viewModel.url)!))
                    .frame(maxWidth: .infinity, minHeight: 400)
                makeTitleView()
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
        .onTapGesture {
            withAnimation {
                if viewModel.type == .image {
                    presentedObject.image = viewModel.image
                    presentedObject.model = model
                    showDetails.toggle()
                }
            }
        }
        .matchedGeometryEffect(id: "mainImage\(viewModel.title)", in: namespace)
        .frame(minWidth: 0, minHeight: 400)

        makeTitleView()
    }

    @ViewBuilder
    func makeTitleView() -> some View {
        HStack {
            Text(viewModel.title)
                .matchedGeometryEffect(id: "mainTitle\(viewModel.title)", in: namespace)
            Spacer()
            if model.favorite {
                Button {
                    Task {
                        try? await viewModel.toggleFavorite()
                    }
                } label: {
                    Image(systemName: "star.fill")
                }
            } else {
                Button {
                    Task {
                        try? await viewModel.toggleFavorite()
                    }
                } label: {
                    Image(systemName: "star")
                }
            }
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
                 model: model!,
                 viewModel: ApodViewModel(apod: model!,
                                          networking: DefaultApodNetworking(),
                                          imageCache: ImageCache(),
                                          persistence: DefaultApodStorage(container: APODYPersistenceController.preview.container)), showDetails: .constant(false))
            .environment(\.managedObjectContext, APODYPersistenceController.preview.container.viewContext)
    }
}
