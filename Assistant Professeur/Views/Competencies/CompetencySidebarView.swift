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
    private var nav: NavigationModel

    @State
    private var isExportingModel = false

    @State
    private var fileExportOperation = FileExportOperation.none

    var body: some View {
        List(selection: $nav.selectedCompetenceType) {
            // Compétences du socle
            NavigationLink(value: CompetencySelection.workedCompetencies) {
                label(CompetencySelection.workedCompetencies)
                    .badge(WCompChapterEntity.cardinal())
            }

            // Compétences disciplinaires
            Section {
                // Pour chaque discipline
                ForEach(Discipline.allCases) { discipline in
                    NavigationLink(
                        value: CompetencySelection.disciplineCompetencies(discipline: discipline)
                    ) {
                        label(CompetencySelection.disciplineCompetencies(discipline: discipline))
                            .badge(DThemeEntity.nbOfThemes(for: discipline))
                    }
                }

            } header: {
                Text("Compétences disciplinaires")
                    .style(.sectionHeader)
            }
        }
        .onChange(of: nav.selectedCompetenceType) { old, new in
                resetNavigCompetency(old, new)
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

    private func resetNavigCompetency(
        _ old: CompetencySelection?,
        _ new: CompetencySelection?
    ) {
        switch (old, new) {
            case (_, .none):
                // si on change de type de compétence ou de discipline
                nav.competencePath.removeLast(nav.competencePath.count)
                // => on reset les chapitres et compétences travaillées sélectionnées
                nav.selectedWorkedCompChapterMngObjId = nil
                nav.selectedWorkedCompMngObjId = nil
                // => on reset les thème, section, compétence et connaissance sélectionnées
                nav.selectedDiscThemeMngObjId = nil
                nav.selectedDiscSectionMngObjId = nil
                nav.selectedDiscCompMngObjId = nil
                nav.selectedDiscKnowMngObjId = nil

            case (_, .workedCompetencies):
                // si on change de type de compétence ou de discipline
                nav.competencePath.removeLast(nav.competencePath.count)
                // => on reset les thème, section, compétence et connaissance sélectionnées
                nav.selectedDiscThemeMngObjId = nil
                nav.selectedDiscSectionMngObjId = nil
                nav.selectedDiscCompMngObjId = nil
                nav.selectedDiscKnowMngObjId = nil

            case (.workedCompetencies, .disciplineCompetencies):
                break

            case (.none, .disciplineCompetencies):
                break

            case (.disciplineCompetencies(discipline: let oldDiscipline),
                .disciplineCompetencies(discipline: let newDiscipline)):
                if oldDiscipline != newDiscipline {
                    nav.selectedDiscCompMngObjId = nil
                }
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

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return CompetencySidebarView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
