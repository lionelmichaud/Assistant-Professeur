//
//  WCompBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/06/2023.
//

import SwiftUI
import TagKit
import AppFoundation

struct WCompBrowserRow: View {
    @ObservedObject
    var workedComp: WCompEntity

    var showDisciplineCompetencies: Bool = false
    var showSequences: Bool = false

    var cycle: Cycle? {
        workedComp.chapter?.cycleEnum
    }

    var description: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Description de la compétence travaillée
            Group {
                Text(workedComp.viewAcronym)
                    .fontWeight(.bold) +
                    Text(". ") +
                    Text(workedComp.viewDescription)
                    .foregroundColor(.secondary)
            }
            .lineLimit(5)
            .textSelection(.enabled)

            // Tags des compétences disciplinaires associées
            if showDisciplineCompetencies {
                DCompTagList(
                    disciplineComps: workedComp.disciplineCompSortedByAcronym,
                    font: .footnote
                )
            }

            if let cycle {
                ForEach(cycle.associatedLevels) { level in
                    let levelSequences = workedComp.sequencesSortedByDisciplineLevelNumber(level: level)

                    // Tags des séquences pédagogiques par année dans le cycle
                    if showSequences && levelSequences.isNotEmpty {
                        HStack {
                            TagCapsule(
                                tag: level.displayString,
                                style: .levelTagStyle(level: level)
                            )
                            .font(.footnote)
                            .bold()
                            Image(systemName: "arrowshape.right.fill")
                                .foregroundColor(level.imageColor)
                            SequenceTagList(
                                sequences: levelSequences,
                                font: .footnote
                            )
                        }
                    }
                }
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
