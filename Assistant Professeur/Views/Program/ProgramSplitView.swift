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
    // MARK: - Properties

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var showProgramSteps: Bool = false

    @State
    private var showSequenceSteps: Bool = false

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
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
                SequenceSidebar(showProgramSteps: $showProgramSteps)
                    .navigationSplitViewColumnWidth(
                        min: 400,
                        ideal: 500,
                        max: 800
                    )
                    .navigationDestination(for: SequenceEntity.self) { sequence in
                        ActivitySideBar(
                            sequence: sequence,
                            showSequenceSteps: $showSequenceSteps
                        )
                    }
            }

        } detail: {
            // Détail dans la 3ième colonne
            switch navig.programDetailColumnState {
                case .none:
                    EmptyListMessage(
                        title: "Aucune activité sélectionnée.",
                        message: "Sélectionner une activité pour en visualiser le contenu.",
                        showAsGroupBox: true
                    )

                case .showProgramSteps:
                    ProgramTimeLine()

                case .showSequenceSteps:
                    SequenceTimeLine()

                case .showActivityDetail:
                    ActivityDetail()
            }
        }
        .navigationSplitViewStyle(.balanced)

        .onAppear {
            if navig.selectedSequenceMngObjId == nil {
                navig.columnVisibility = .all
            }
        }

        // désélectionner la séquence et l'activité quand on change de programme
        .onChange(of: navig.selectedProgramMngObjId) {
            navig.selectedSequenceMngObjId = nil
            navig.selectedActivityMngObjId = nil

            navig.columnVisibility = .all

            navig.programDetailColumnState = nil
        }

        // désélectionner l'activité quand on change de séquence
        .onChange(of: navig.selectedSequenceMngObjId) {
            navig.selectedActivityMngObjId = nil

            navig.columnVisibility = .all

            navig.programDetailColumnState = nil
        }

        // afficher l'activité quand on en sélectionne une
        .onChange(of: navig.selectedActivityMngObjId) {
            if navig.selectedActivityMngObjId != nil {
                navig.columnVisibility = .all

                navig.programDetailColumnState = .showActivityDetail
            }
        }

        // afficher la time-line du programme dans la colonne de droite (détail)
        .onChange(of: showProgramSteps) {
            if showProgramSteps {
                navig.selectedActivityMngObjId = nil

                navig.columnVisibility = .all

                navig.programDetailColumnState = .showProgramSteps

                showProgramSteps.toggle()
            }
        }

        // afficher la time-line de la séquence dans la colonne de droite (détail)
        .onChange(of: showSequenceSteps) {
            if showSequenceSteps {
                navig.selectedActivityMngObjId = nil

                navig.columnVisibility = .all

                navig.programDetailColumnState = .showSequenceSteps

                showSequenceSteps.toggle()
            }
        }
    }
}

// struct ProgramSplitView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramSplitView()
//    }
// }
