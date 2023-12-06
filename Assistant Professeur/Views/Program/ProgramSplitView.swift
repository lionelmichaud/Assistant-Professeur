//
//  ProgramSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import AppFoundation
import SwiftUI

// MARK: - State Machine de l'état de la colonne "détail"

enum ProgramDetailColumnState {
    case showProgramSteps
    case showSequenceSteps
    case showActivityDetail
}

// MARK: - View

/// Vues de Programmes / Séquences / Activités
struct ProgramSplitView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    @State
    private var preferredColumn = NavigationSplitViewColumn.sidebar

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility,
            preferredCompactColumn: $preferredColumn
        ) {
            // 1ère colonne
            ProgramSidebar()
                .navigationSplitViewColumnWidth(
                    min: 300,
                    ideal: 300,
                    max: 500
                )

        } content: {
            // 2nde colonne
            SequenceSidebar()
                .navigationSplitViewColumnWidth(
                    min: 400,
                    ideal: 500,
                    max: 800
                )

        } detail: {
            // 3ième colonne
            NavigationStack(path: $navig.programPath) {
                ActivitySideBar()
                    .navigationDestination(for: ProgramNavigationRoute.self) { route in
                        route.destination()
                    }
            }
        }
        .navigationSplitViewStyle(.balanced)

        // Désélectionner la séquence et l'activité quand on change de programme
        // Afficher la colonne du milieu sur iPhone
        .onChange(of: navig.selectedProgramMngObjId) {
            navig.changeSelectedProgram()
            if navig.selectedProgramMngObjId != nil {
                preferredColumn = .content
            }
        }

        // Désélectionner l'activité quand on change de séquence
        // Afficher la colonne détail sur iPhone
        .onChange(of: navig.selectedSequenceMngObjId) {
            navig.changeSelectedSequence()
            if navig.selectedSequenceMngObjId != nil {
                preferredColumn = .detail
            }
        }

        // Afficher l'activité quand on en sélectionne une
        // Afficher la colonne détail sur iPhone
        .onChange(of: navig.selectedActivityMngObjId, initial: true) {
            if navig.selectedActivityMngObjId != nil {
                preferredColumn = .detail
            }
        }
//        .onChange(of: preferredColumn) { old, new in
//            print(">> preferredColumn changed from \(old) to \(new)")
//        }
    }
}

// struct ProgramSplitView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramSplitView()
//    }
// }

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return ProgramSplitView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
