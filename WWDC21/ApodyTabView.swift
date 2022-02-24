//
//  TabView.swift
//  WWDC21
//
//  Created by mazurkk3 on 22/02/2022.
//

import Foundation
import SwiftUI

struct ApodyTabView: View {
    let viewModel: ApodViewModel

    var body: some View {
        TabView {
            ListView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "globe.europe.africa")
                    Text("Browse")
                }

            FavoritesView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "star")
                    Text("Favorites")
                }

            FormView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Feedback")
                }
        }
        .colorScheme(.dark)
        .font(.headline)
        .onAppear {
            if #available(iOS 15.0, *) {
                let appearance = UITabBarAppearance()
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
