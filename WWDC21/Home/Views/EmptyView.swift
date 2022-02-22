//
//  EmptyView.swift
//  WWDC21
//
//  Created by mazurkk3 on 22/02/2022.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "star")
            Text("No favorites so far")
        }
    }
}
