//
//  SequenceList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI
import HelpersView

struct SequenceList: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @EnvironmentObject
    private var navig : NavigationModel

    @State
    private var searchString: String = ""

    var body: some View {
        Section {
            if program.sequencesSortedByNumber.isNotEmpty {
                List(selection: $navig.selectedSequenceId) {
                    ForEach(
                        program.filteredSequencesSortedByNumber(searchString: searchString),
                        id: \.objectID) { sequence in
                            NavigationLink(value: sequence) {
                                SequenceBrowserRow(sequence: sequence)
                            }
                        }
                        .onMove(perform: moveItems)
                        .onDelete(perform: deleteItems)
                        .listRowSeparatorTint(.secondary)
                }
                .searchable(
                    text      : $searchString,
                    placement : .navigationBarDrawer(displayMode : .automatic),
                    //                    placement : .toolbar,
                    prompt    : "Nom de la séquence"
                )

            } else {
                GroupBox {
                    Text("Aucune séquence")
                        .bold()
                    Text("Les séquences ajoutées apparaîtront ici.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
                .verticallyAligned(.top)
            }
        } header: {
            HStack {
                Text("Séquences de ce Programme (\(program.nbOfSequences))")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map {
                    program.sequencesSortedByNumber[$0]
                }
                .forEach {
                    // Supprimer et renuméroter les séquences restantes
                    ProgramManager.delete(
                        sequence: $0,
                        de: program
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
