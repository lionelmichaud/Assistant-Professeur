//
//  ClassGlobalProgress.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import HelpersView
import SwiftUI

/// Situation de la progression d'une classe par Séquence / Activité
struct ClassProgressesView: View {
    @ObservedObject
    var classe: ClasseEntity

    private var progresses: [ActivityProgressEntity] {
        classe.allProgresses
    }

    /// Liste des séquences suivies par cette classe triées
    ///
    /// Ordre de tri des séquences:
    ///   1. Numéro de séquences
    private var sequences: [SequenceEntity] {
        let sortComparators = [
            SortDescriptor(\SequenceEntity.viewNumber, order: .forward)
        ]

        var sequences = [SequenceEntity]()

        progresses.forEach { progress in
            if let sequence = progress.activity?.sequence,
               !sequences.contains(sequence) {
                sequences.append(sequence)
            }
        }
        return sequences.sorted(using: sortComparators)
    }

    var body: some View {
        List {
            ProgressView(value: classe.progressInProgram())
                .tint(.mint)
            ForEach(sequences) { sequence in
                ClassSequenceProgressEditView(
                    sequence: sequence,
                    classe: classe
                )
            }
            .emptyListPlaceHolder(sequences) {
                Text("Aucune séquence suivie par cette classe")
            }
        }
        #if os(iOS)
        .navigationTitle("Progression en \(classe.discipline!)")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

struct ClassProgressesView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first { classe in
            classe.levelEnum == .n5ieme
        }!
        print(classe)
        return Group {
            List {
                ClassProgressesView(classe: classe)
            }
            .padding()
            .previewDevice("iPad mini (6th generation)")
            List {
                ClassProgressesView(classe: classe)
            }
            .padding()
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
