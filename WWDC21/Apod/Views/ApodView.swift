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
    let model: ApodModel
    let image: UIImage?
    let persistence: ApodPersistence

    @Binding var showDetails: Bool
    @Binding var presentedModel: ApodModel?
    @Binding var presentedImage: UIImage?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            switch model.media_type {
            case .image:
                makeImageView()
            case .video:
                VideoWebView(request: URLRequest(url: URL(string: model.url)!))
                    .frame(maxWidth: .infinity, minHeight: 400)
                makeTitleView()
            }
        }
        .background(.thickMaterial)
        .mask(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 8)
    }

    @ViewBuilder
    func makeImageView() -> some View {
        if presentedImage != image && !showDetails {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ProgressView()
                }
            }
            .onTapGesture {
                withAnimation {
                    if model.media_type == .image {
                        presentedImage = image
                        presentedModel = model
                        showDetails.toggle()
                    }
                }
            }
            .matchedGeometryEffect(id: "mainImage\(model.title)", in: namespace)
            .frame(minWidth: 0, minHeight: 400)
        } else {
            ProgressView()
                .frame(minWidth: 0, minHeight: 400)
        }

        makeTitleView()
    }

    @ViewBuilder
    func makeTitleView() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.title)
                    .matchedGeometryEffect(id: "mainTitle\(model.title)", in: namespace)
                Text(dateFormatter.string(from: model.date))
                    .font(.caption)
            }
            Spacer()
            Button {
                Task {
                    try? await persistence.toggleFavorite(apod: model)
                }
            } label: {
                Image(systemName: model.favorite ? "star.fill" : "star")
                    .font(.title)
                    .foregroundColor(.yellow)
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
                 image: nil,
                 persistence: DefaultApodStorage(container: APODYPersistenceController.preview.container),
                 showDetails: .constant(false),
                 presentedModel: .constant(nil),
                 presentedImage: .constant(nil))
            .environment(\.managedObjectContext, APODYPersistenceController.preview.container.viewContext)
    }
}
