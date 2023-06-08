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
        List(selection: $navig.selectedCompetenceType) {
            // Compétences du socle
            NavigationLink(value: CompetencySelection.workedCompetencies) {
                label(CompetencySelection.workedCompetencies)
                // .badge(cardinal(type))
            }

            // Compétences disciplinaires
            Section {
                // Pour chaque discipline
                ForEach(Discipline.allCases) { discipline in
                    NavigationLink(
                        value: CompetencySelection.disciplineCompetencies(discipline: discipline)
                    ) {
                        label(CompetencySelection.disciplineCompetencies(discipline: discipline))
                    }
                }

            } header: {
                Text("Compétences disciplinaires")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            }
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

    @ViewBuilder
    private func label(_ type: CompetencySelection) -> some View {
        Label(
            title: {
                Text(type.label)
                    .fontWeight(.bold)
            },
            icon: {
                Image(systemName: WCompEntity.defaultImageName)
            }
        )
    }

    private func cardinal(_ type: CompetencySelection) -> Int {
        switch type {
            case .workedCompetencies:
                return WCompChapterEntity.cardinal()

            case .disciplineCompetencies:
                return 1
                // TODO: - Implémener cadrdinal de DThemeEntity
                // return DThemeEntity.cardinal()
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
                        CsvImportExportMng.exportCompetencies()
                        fileExportOperation = .exportCsvCompetencies
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
