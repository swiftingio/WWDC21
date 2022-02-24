//
//  DetailsView.swift
//  WWDC21
//
//  Created by mazurkk3 on 21/02/2022.
//

import APODY
import Foundation
import SwiftUI

struct DetailsView: View {
    let model: ApodModel
    @Binding var showDetails: Bool
    @Binding var presentedImage: UIImage?

    var image: UIImage?

    var namespace: Namespace.ID

    var body: some View {
        ZStack {
            BackgroundTimelineView(stars: BackgroundTimelineView.generateStars)
            ScrollView {
                VStack {
                    makeImageView()
                    Text(model.title)
                        .matchedGeometryEffect(id: "mainTitle\(model.title)", in: namespace)
                    Text(model.explanation)
                }
            }
            Button {
                withAnimation {
                    presentedImage = nil
                    showDetails.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.bold))
                    .foregroundColor(.secondary)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(30)
        }
        .colorScheme(.dark)
        .ignoresSafeArea()
    }

    @ViewBuilder
    func makeImageView() -> some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                ProgressView()
            }
        }
        .matchedGeometryEffect(id: "mainImage\(model.title)", in: namespace)
        .frame(maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
    }
}
