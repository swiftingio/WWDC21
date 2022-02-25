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
    @Binding var image: UIImage?

    var body: some View {
        ZStack {
            BackgroundTimelineView(stars: BackgroundTimelineView.generateStars)
            ScrollView {
                VStack {
                    makeImageView()
                    Text(model.title)
                    Text(model.explanation)
                        .font(.body)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
        }
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
        .frame(maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
    }
}
