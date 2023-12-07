//
//  SequenceList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct SequenceList: View {
    @ObservedObject
    var program: ProgramEntity

    var searchString: String = ""

    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        let filteredSequences = program.filteredSequencesSortedByNumber(searchString: searchString)

        Section {
            ForEach(filteredSequences, id: \.objectID) { sequence in
                SequenceBrowserRow(sequence: sequence)
                    .customizedListItemStyle(
                        isSelected: sequence.objectID == navig.selectedSequenceMngObjId
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // supprimer la séquence et tous ses descendants
                        Button(role: .destructive) {
                            withAnimation {
                                if navig.selectedSequenceMngObjId == sequence.objectID {
                                    navig.selectedSequenceMngObjId = nil
                                }
                                try? sequence.delete()
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
            .onMove(perform: moveItems)
            .emptyListPlaceHolder(filteredSequences) {
                ContentUnavailableView(
                    "Aucune séquence trouvée dans cette progression...",
                    systemImage: SequenceEntity.defaultImageName,
                    description: Text("Les séquences ajoutées apparaîtront ici.")
                )
            }
        } header: {
            HStack {
                Text("Séquences de cette progression (\(program.nbOfSequences))")
                    .style(.sectionHeader)
                Spacer()
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            source
                .map {
                    program.sequencesSortedByNumber[$0]
                }
                .forEach {
                    // Permuter et renuméroter les séquences restantes
                    ProgramManager.move(
                        sequence: $0,
                        de: program,
                        to: destination
                    )
                }

            try? EventEntity.saveIfContextHasChanged()
        }
    }
}

struct SequenceList_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            VStack {
                SequenceList(program: ProgramEntity.all().first!)
                    .padding()
                    .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPad mini (6th generation)")
            VStack {
                SequenceList(program: ProgramEntity.all().first!)
                    .padding()
                    .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPhone 13")
        }
    }
}
