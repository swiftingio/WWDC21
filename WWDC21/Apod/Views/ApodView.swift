//
//  ApodView.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import APODY
import SwiftUI

struct ApodView: View {
    let model: ApodModel
    @Binding var image: UIImage?
    let persistence: ApodPersistence

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            switch model.media_type {
            case .image:
                ZStack {
                    // Hide disclosure indicator.
                    NavigationLink {
                        DetailsView(model: model,
                                    image: $image)
                    } label: { EmptyView() }
                        .opacity(0)
                    makeImageView()
                }
                HStack {
                    makeTitleView()
                    Spacer()
                    makeButtonView()
                }
                .padding()
                .background(.thinMaterial)
                .zIndex(100)
            case .video:
                VideoWebView(request: URLRequest(url: URL(string: model.url)!))
                    .frame(maxWidth: .infinity, minHeight: 400)
                HStack {
                    makeTitleView()
                    Spacer()
                    makeButtonView()
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .background(.thickMaterial)
        .mask(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 8)
    }

    @ViewBuilder
    func makeImageView() -> some View {
        ZStack(alignment: .bottom) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ProgressView()
                }
            }
            .frame(minWidth: 0, minHeight: 400)
        }
    }

    @ViewBuilder
    func makeTitleView() -> some View {
        VStack(alignment: .leading) {
            Text(model.title)
            Text(dateFormatter.string(from: model.date))
                .font(.caption)
        }
    }

    @ViewBuilder
    func makeButtonView() -> some View {
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
}
