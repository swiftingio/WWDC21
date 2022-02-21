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
    @StateObject var viewModel: ApodViewModel
    @Binding var showDetails: Bool
    @EnvironmentObject var presentedObject: PresentedView

    var isPresentedView: Bool {
        showDetails && presentedObject.presentedViewModel?.url == viewModel.url
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
        .onTapGesture {
            withAnimation {
                presentedObject.image = viewModel.image
                presentedObject.presentedViewModel = viewModel.apod
                showDetails.toggle()
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
        Text(viewModel.title)

//        if !isPresentedView {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
            }
        }
        .matchedGeometryEffect(id: "mainImage\(viewModel.title)", in: namespace)
        .frame(minWidth: 0, minHeight: 400)
//        }
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
