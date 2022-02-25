//
//  SortSelectionView.swift
//  WWDC21
//
//  Created by Woronin Bartlomiej on 21/02/2022.
//

import APODYModel
import SwiftUI

struct SortSelectionView: View {
    @Binding var selectedSortItem: ApodSort

    let sorts: [ApodSort]
    var body: some View {
        Menu {
            Picker("Sort By", selection: $selectedSortItem) {
                ForEach(sorts, id: \.self) { sort in
                    Text("\(sort.name)")
                }
            }
        } label: {
            Label(
                "Sort",
                systemImage: "line.horizontal.3.decrease.circle"
            )
        }
        .pickerStyle(.inline)
    }
}
