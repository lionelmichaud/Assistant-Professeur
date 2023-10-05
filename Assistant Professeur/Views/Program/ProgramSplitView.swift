//
//  ProgramSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import Stateful
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
                        ActivitySideBar(sequence: sequence,
                                        preferredColumn: $preferredColumn)
                    }
                    .navigationSplitViewColumnWidth(
                        min: 400,
                        ideal: 500,
                        max: 800
                    )
            }

        } detail: {
            // 3ième colonne
            ProgramDetailedColumn()
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

/// Détail dans la 3ième colonne de la Tab des Compétences
struct ProgramDetailedColumn: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass) 
    private var horizontalSizeClass

    var body: some View {
        switch navig.programDetailColumnState {
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
