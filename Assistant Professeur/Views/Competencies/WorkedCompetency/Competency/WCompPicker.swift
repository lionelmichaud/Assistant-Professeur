//
//  WCompPicker.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct WCompPicker: View {
    @Binding
    var selectedCompetency: WCompEntity

    let inCompetencies: [WCompEntity]

    var body: some View {
        Picker(
            "Compétence travaillée",
            selection: $selectedCompetency
        ) {
            ForEach(inCompetencies) { competency in
                HStack {
                    Text(competency.viewAcronym)
                        .fontWeight(.bold) +
                        Text(". ") +
                        Text(competency.viewDescription)
                        .foregroundColor(.secondary)
                }
                .lineLimit(5)
                .horizontallyAligned(.leading)
                .tag(competency)
            }
        }
        .pickerStyle(.wheel)
    }
}

// struct WCompPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompPicker()
//    }
// }
