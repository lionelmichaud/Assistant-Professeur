//
//  ProgramTimeLine.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/02/2023.
//

import SwiftUI

struct ProgramTimeLine: View {
    @EnvironmentObject
    private var navig: NavigationModel

    enum ViewMode: Int {
        case steps
        case planning
    }

    @State
    private var presentation: ViewMode = .steps

    var body: some View {
        VStack {
            if let programId = navig.selectedProgramMngObjId {
                if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                    switch presentation {
                        case .steps:
                            ProgramStepperView(program: program)
                        case .planning:
                            ProgramPlanningView(program: program)
                    }
                } else {
                    Text("Programme introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }

            } else {
                EmptyListMessage(
                    symbolName: ProgramEntity.defaultImageName,
                    title: "Aucun programme sélectionné.",
                    message: "Sélectionner un programme pour en visualiser les séquences.",
                    showAsGroupBox: true
                )
                .padding(.horizontal)
            }
        }
        #if os(iOS)
        .navigationTitle("Déroulement du programme")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

extension ProgramTimeLine {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Choix du style de présentation
        ToolbarItemGroup(placement: .automatic) {
            Picker("Présentation", selection: $presentation) {
                Image(systemName: "list.bullet").tag(ViewMode.steps)
                Image(systemName: "chart.bar.fill").tag(ViewMode.planning)
            }
            .pickerStyle(.segmented)
        }
    }
}

// struct ProgramTimeLine_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramTimeLine()
//    }
// }
