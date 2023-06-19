//
//  WCompBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/06/2023.
//

import SwiftUI

struct WCompBrowserRow: View {
    @ObservedObject
    var workedComp: WCompEntity

    var showDisciplineCompetencies: Bool = false

    var description: some View {
        VStack(alignment: .leading) {
            Group {
                Text(workedComp.viewAcronym)
                    .fontWeight(.bold) +
                    Text(". ") +
                    Text(workedComp.viewDescription)
                    .foregroundColor(.secondary)
            }
            .lineLimit(5)
            .textSelection(.enabled)
            if showDisciplineCompetencies {
                DCompTagRow(disciplineComps: workedComp.disciplineCompSortedByAcronym)
            }
        }
    }

    var body: some View {
        Label(
            title: {
                description
            },
            icon: {
                Image(systemName: WCompEntity.defaultImageName)
            }
        )
    }
}

// struct WorkedCompBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompBrowserRow()
//    }
// }
