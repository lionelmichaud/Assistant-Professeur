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

    var body: some View {
        Label(
            title: {
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
                        Text("Critères de maîtrise")
                            .foregroundColor(.primary)
                            .padding([.top, .bottom])
                    }

                    // Description des compétences disciplinaires et séquences associées
                    let dicoPerDisciplineLevel = workedComp.sequencesPerDiscipleSortedByDisciplineNumber()
                    let dicoPerDiscipline = workedComp.disciplineCompSortedByDisciplineAcronym()
                    ScrollView(.horizontal) {
                        HStack(alignment: .top) {
                            ForEach(dicoPerDisciplineLevel.keys) { discipline in
                                AssociatedDCompSequencesView(
                                    dicoSequencesPerLevel: dicoPerDisciplineLevel[discipline]!,
                                    associatedDComps: dicoPerDiscipline[discipline],
                                    discipline: discipline,
                                    showDisciplineCompetencies: showDisciplineCompetencies,
                                    showSequences: showSequences
                                )
                            }
                        }
                    }
                }
            },
            icon: {
                Image(systemName: WCompEntity.defaultImageName)
            }
        )
    }
}

struct AssociatedDCompSequencesView: View {
    let dicoSequencesPerLevel: DicoSequencesPerLevel
    let associatedDComps: [DCompEntity]?
    let discipline: Discipline
    let showDisciplineCompetencies: Bool
    let showSequences: Bool

    var body: some View {
        GroupBox {
            VStack {
                // Tags des compétences disciplinaires associées
                associatedDCompsView

                // Tags des Séquences pédadgogiques associées, par nieveau de classe
                associatedSequencesView
            }
        } label: {
            Text(discipline.acronym)
                .font(.callout)
                .foregroundColor(.secondary)

        }
        .frame(minWidth: 250)
        .compositingGroup()
        .shadow(radius: 8)
        .padding(8)
    }

    // MARK: - Subviews

    var associatedDCompsView: some View {
        Group {
            if showDisciplineCompetencies,
               let associatedDComps {
                DCompTagList(
                    disciplineComps: associatedDComps,
                    font: .footnote
                )
            }
        }
    }

    var associatedSequencesView: some View {
        Group {
            ForEach(dicoSequencesPerLevel.keys) { level in
                if showSequences,
                   let levelSequences = dicoSequencesPerLevel[level],
                   levelSequences.isNotEmpty {
                    // Tags des séquences pédagogiques par année dans le cycle
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

// struct WorkedCompBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompBrowserRow()
//    }
// }
