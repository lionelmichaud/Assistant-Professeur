//
//  SequenceList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SequenceList: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @EnvironmentObject
    private var navigationModel : NavigationModel

    var body: some View {
        Group {
            if program.sequencesSortedByNumber.isNotEmpty {
                List(selection: $navigationModel.selectedSequenceId) {
                    ForEach(program.sequencesSortedByNumber, id: \.objectID) { sequence in
                        SequenceBrowserRow(sequence: sequence)
                    }
                    .onDelete(perform: deleteItems)
                }

            } else {
                Text("Aucune séquence dans ce programme")
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map {
                    program.sequencesSortedByNumber[$0]
                }
                .forEach {
                    // Supprimer et renuméroter les séquences restantes
                    ProgramManager.delete(
                        sequence : $0,
                        de       : program
                    )
                }

            try? EventEntity.saveIfContextHasChanged()
        }
    }
}

//struct SequenceList_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceList()
//    }
//}
