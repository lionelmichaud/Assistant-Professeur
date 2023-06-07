//
//  CompetencySidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import HelpersView
import SwiftUI

struct CompetencySidebarView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isExportingModel = false

    @State
    private var fileExportOperation = FileExportOperation.none

    var body: some View {
        List(
            CompetencyTypeSelection.allCases,
            id: \.self,
            selection: $navig.selectedCompetenceType
        ) { type in
            Label(
                title: {
                    Text(type.rawValue)
                        .fontWeight(.bold)
                },
                icon: {
                    Image(systemName: WCompChapterEntity.defaultImageName)
                }
            )
            .badge(cardinal(type))
        }
        #if os(iOS)
        .navigationTitle("Compétences")
        #endif
        .toolbar(content: myToolBarContent)

        // Exporter des fichiers JSON pour le modèle
        .fileMover(
            isPresented: $isExportingModel,
            files: isExportingModel ? fileExportOperation.urls : []
        ) { _ in
        }
    }

    private func cardinal(_ type: CompetencyTypeSelection) -> Int {
        switch type {
            case .workedCompetencies:
                return WCompChapterEntity.cardinal()

            case .disciplineCompetencies:
                return 1
//                return DisciplineThemeEntity.cardinal()
        }
    }
}

// MARK: Toolbar Content

extension CompetencySidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Menu
        ToolbarItemGroup(placement: .automatic) {
            Menu {
                Menu("Exporter") {
                    Button {
                        CsvImportExportMng.exportPrograms()
                        fileExportOperation = .exportCsvPrograms
                        isExportingModel.toggle()
                    } label: {
                        Label(
                            "Exporter les compétences en CSV",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

struct CompetencySidebarView_Previews: PreviewProvider {
    static var previews: some View {
        CompetencySidebarView()
    }
}
