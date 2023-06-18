//
//  ClasseProgressionSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import SwiftUI

struct ClasseProgressSection: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        if let progresses = classe.progresses,
           progresses.count != 0 {
            Section {
                // Activité actuelle
                currentActivityView

                // Progression glogale
                progressView
            } header: {
                Text("Progession")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            }
        }
    }
}

// MARK: - Subviews

extension ClasseProgressSection {
    private var currentActivityView: some View {
        NavigationLink(value: ClasseNavigationRoute.activity(classe)) {
            HStack {
                Label(hClass == .compact ? "Activité" : "Activité en cours", systemImage: "book.fill")
                    .fontWeight(.bold)
                if let activity = classe.currentActivity,
                   let sequence = activity.sequence {
                    let currentActivityProgress =
                        classe
                            .sortedProgressesInSequence(sequence)
                            .first(where: { $0.activity == activity })
                    Spacer()
                    if hClass == .compact {
                        Text("Seq \(sequence.viewNumber) - Act \(activity.viewNumber) (\(currentActivityProgress!.progress, format: .percent))")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Séquence \(sequence.viewNumber) - Activité \(activity.viewNumber) (\(currentActivityProgress!.progress, format: .percent))")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var progressView: some View {
        NavigationLink(value: ClasseNavigationRoute.progress(classe)) {
            Label("Progression", systemImage: ProgramEntity.defaultImageName)
                .fontWeight(.bold)
        }
    }
}

struct ClasseProgressionSection_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseProgressSection(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseProgressSection(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
