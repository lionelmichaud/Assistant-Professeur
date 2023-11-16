//
//  SequencePresentationView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/11/2023.
//

import HelpersView
import SwiftUI

struct SequencePresentationView: View {
    @ObservedObject
    var sequence: SequenceEntity

    let forPdfExport: Bool

    var level: LevelClasse? {
        sequence.program?.levelEnum
    }

    let titleFont: Font = .title2
    let subtitleFont: Font = .title2
    let headerFont: Font = .title3
    let bodyFont: Font = .body
    let subBodyFont: Font = .callout

    var body: some View {
        if forPdfExport {
            VStack {
                headerView
                objectifs
                evaluations
                competencies
            }
            .padding()

        } else {
            ScrollView(Axis.Set.vertical, showsIndicators: false) {
                headerView
                objectifs
                evaluations
                competencies
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Subviews

extension SequencePresentationView {
    // MARK: - Header

    var headerView: some View {
        VStack(alignment: .leading) {
            HStack {
                if let level {
                    Text("\(level.displayString) - ")
                }
                Text(sequence.viewName)
            }
            .font(titleFont)
            .bold()
            .foregroundStyle(.red)
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8).stroke(.red, lineWidth: 1)
        }
    }

    // MARK: - Objectifs

    var objectifs: some View {
        VStack {
            Text("Objectifs pédagogiques")
                .font(subtitleFont)
                .bold()
                .foregroundStyle(Color.blue4)
                .padding(.vertical, 4)
            problem
            connaissances
            competenceAMaitriser
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8).stroke(Color.blue4, lineWidth: 1)
        }
    }

    var problem: some View {
        VStack(alignment: .leading) {
            Text("Problème à résoudre:")
                .font(headerFont)
                .bold()
                .foregroundStyle(Color.blue4)
            Text(sequence.viewAnnotation)
                .font(bodyFont)
                .padding(.leading)
        }
        .padding(.bottom, 4)
        .horizontallyAligned(.leading)
    }

    var connaissances: some View {
        VStack(alignment: .leading) {
            Text("Connaissances à acquérir:")
                .font(headerFont)
                .bold()
                .foregroundStyle(Color.blue4)
            ForEach(sequence.disciplineCompSortedByAcronym) { comp in
                ForEach(comp.allKnowledgesSortedByNumber) { know in
                    Label {
                        Text("**\(know.viewAcronym)** - \(know.viewDescription)")
                            .font(subBodyFont)
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                }
            }
            .padding(.bottom, 4)
        }
        .horizontallyAligned(.leading)
    }

    var competenceAMaitriser: some View {
        VStack(alignment: .leading) {
            Text("Compétences à maîtriser:")
                .font(headerFont)
                .bold()
                .foregroundStyle(Color.blue4)
            ForEach(sequence.disciplineCompSortedByAcronym) { comp in
                Label {
                    Text("**\(comp.viewAcronym)** - \(comp.viewDescription)")
                        .font(subBodyFont)
                } icon: {
                    Image(systemName: "checkmark.seal.fill")
                }
            }
            .padding(.bottom, 4)
        }
        .horizontallyAligned(.leading)
    }

    // MARK: - Evaluation

    var evaluations: some View {
        VStack {
            Text("Évaluation")
                .font(subtitleFont)
                .bold()
                .foregroundStyle(Color.blue4)
                .padding(.vertical, 4)
            ForEach(sequence.allActivities) { activity in
                if activity.isEval {
                    Label {
                        Text("\(activity.viewAnnotation)")
                            .font(bodyFont)
                    } icon: {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .padding(.leading)
            .padding(.bottom, 4)
            .horizontallyAligned(.leading)
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8).stroke(Color.blue4, lineWidth: 1)
        }
    }

    // MARK: - Compétences

    var competencies: some View {
        VStack {
            Text("Compétences développées")
                .font(subtitleFont)
                .bold()
                .foregroundStyle(Color.blue4)
                .padding(.vertical, 4)
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(forPdfExport ? "Compétences du scole commun" : "Compétences scole")
                        .font(headerFont)
                        .bold()
                        .foregroundStyle(Color.blue4)
                        .padding(.bottom, 2)
                    ForEach(sequence.workedCompSortedByAcronym) { comp in
                        Label {
                            Text("**\(comp.viewAcronym)** - \(comp.viewDescription)")
                                .font(subBodyFont)
                        } icon: {
                            Image(systemName: "checkmark.seal")
                        }
                    }
                    .padding(.bottom, 4)
                }
                .horizontallyAligned(.leading)

                Divider()
                
                VStack(alignment: .leading) {
                    Text(forPdfExport ? "Compétences disciplinaires" : "Comp. disciplinaires")
                        .font(headerFont)
                        .bold()
                        .foregroundStyle(Color.blue4)
                        .padding(.bottom, 2)
                    ForEach(sequence.disciplineCompSortedByAcronym) { comp in
                        Label {
                            Text("**\(comp.viewAcronym)** - \(comp.viewDescription)")
                                .font(subBodyFont)
                        } icon: {
                            Image(systemName: "checkmark.seal.fill")
                        }
                    }
                    .padding(.bottom, 4)
                }
                .horizontallyAligned(.leading)
            }
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8).stroke(Color.blue4, lineWidth: 1)
        }
    }
}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return SequencePresentationView(
        sequence: SequenceEntity.all().first!,
        forPdfExport: false
    )
    .padding()
    .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
    .previewDevice("iPad mini (6th generation)")
}
