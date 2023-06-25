//
//  WCompBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/06/2023.
//

import AppFoundation
import SwiftUI
import TagKit

struct WCompBrowserRow: View {
    @ObservedObject
    var workedComp: WCompEntity

    var showDisciplineCompetencies: Bool = false
    var showSequences: Bool = false

    var cycle: Cycle? {
        workedComp.chapter?.cycleEnum
    }

    var associatedSequences: some View {
        Group {
            if let cycle {
                ForEach(cycle.associatedLevels) { level in
                    let levelSequences = workedComp.sequencesSortedByDisciplineLevelNumber(level: level)

                    // Tags des séquences pédagogiques par année dans le cycle
                    if showSequences && levelSequences.isNotEmpty {
                        HStack {
                            LevelTag(
                                level: level,
                                font: .footnote
                            )

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

            // Lien vers les critères de maîtrise de la compétences
            NavigationLink(value: workedComp) {
                Text("Critères de niveaux de maîtrise")
                    .padding([.top, .bottom])
            }

            // Tags des compétences disciplinaires associées
            if showDisciplineCompetencies {
                DCompTagList(
                    disciplineComps: workedComp.disciplineCompSortedByAcronym,
                    font: .footnote
                )
            }

            // Tags des Séquences pédadgogiques associées, par nieveau de classe
            associatedSequences
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
