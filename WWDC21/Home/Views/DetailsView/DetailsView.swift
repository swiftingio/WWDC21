//
//  DetailsView.swift
//  WWDC21
//
//  Created by mazurkk3 on 21/02/2022.
//

import Foundation
import SwiftUI

struct DetailsView: View {
    @StateObject var viewModel: ApodViewModel
    @Binding var showDetails: Bool

    var namespace: Namespace.ID

    var body: some View {
        ZStack {
            Color(.white)
            ScrollView {
                VStack {
                    makeImageView()
                    Text(viewModel.title)
                        .matchedGeometryEffect(id: "mainTitle\(viewModel.title)", in: namespace)
                    Text(viewModel.description)
                }
            }
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
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
        .ignoresSafeArea()
    }

    @ViewBuilder
    func makeImageView() -> some View {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 400)
                    .clipped()
            } else {
                ProgressView()
            }
        }
        .matchedGeometryEffect(id: "mainImage\(viewModel.title)", in: namespace)
    }
}
