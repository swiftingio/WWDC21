//
//  SortSelectionView.swift
//  WWDC21
//
//  Created by Woronin Bartlomiej on 21/02/2022.
//

import APODYModel
import SwiftUI

struct SortSelectionView: View {
    // 1
    @Binding var selectedSortItem: ApodSort
    // 2
    let sorts: [ApodSort]
    var body: some View {
        // 1
        Menu {
            // 2
            Picker("Sort By", selection: $selectedSortItem) {
                // 3
                ForEach(sorts, id: \.self) { sort in
                    // 4
                    Text("\(sort.name)")
                }
            }
            // 5
        } label: {
            Label(
                "Sort",
                systemImage: "line.horizontal.3.decrease.circle"
            )
        }
        // 6
        .pickerStyle(.inline)
    }
}
