//
//  ProgramSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import SwiftUI
import AppFoundation

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
            NavigationStack(path: $navig.programPath) {
                SequenceSidebar(preferredColumn: $preferredColumn)
                    .navigationDestination(for: SequenceEntity.self) { sequence in
                        ActivitySideBar(
                            sequence: sequence,
                            preferredColumn: $preferredColumn
                        )
                    }
                    .navigationSplitViewColumnWidth(
                        min: 400,
                        ideal: 500,
                        max: 800
                    )
            }

        } detail: {
            // 3ième colonne
            ProgramDetailedColumn(
                content: navig.programDetailColumnState
            )
        }
        .navigationSplitViewStyle(.balanced)

        // désélectionner la séquence et l'activité quand on change de programme
        .onChange(of: navig.selectedProgramMngObjId) {
            navig.changeSelectedProgram()
        }

        // désélectionner l'activité quand on change de séquence
        .onChange(of: navig.selectedSequenceMngObjId) {
            navig.changeSelectedSequence()
        }

        // afficher l'activité quand on en sélectionne une
        .onChange(of: navig.selectedActivityMngObjId) {
            navig.showActivityDetails()
        }
    }
}

/// Détail dans la 3ième colonne de la Tab des Program
struct ProgramDetailedColumn: View {
    let content: ProgramDetailColumnState?

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        switch content {
            case .none:
                ContentUnavailableView(
                    "Aucune activité sélectionnée...",
                    systemImage: ActivityEntity.defaultImageName,
                    description: Text("Sélectionner une activité pour en visualiser le contenu.")
                )

            case .showProgramSteps:
                ProgramTimeLine()

            case .showSequenceSteps:
                SequenceTimeLine()

            case .showActivityDetail:
                ActivityDetail()
        }
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
