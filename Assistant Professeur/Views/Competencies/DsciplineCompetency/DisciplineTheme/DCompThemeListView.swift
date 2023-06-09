//
//  DCompThemeListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 08/06/2023.
//

import HelpersView
import SwiftUI

struct DCompThemeListView: View {
    var discipline: Discipline

    @EnvironmentObject
    private var nav: NavigationModel

    @SectionedFetchRequest<String, DThemeEntity>(
        fetchRequest: DThemeEntity.requestAllSortedByDiscCycleAcronym,
        sectionIdentifier: \.cycleString,
        animation: .default
    )
    private var compThemeSections: SectionedFetchResults<String, DThemeEntity>

    @State
    private var isAddingObject = false
    @State
    private var editedCompTheme: DThemeEntity?

    var body: some View {
        List(selection: $nav.selectedDiscThemeMngObjId) {
            // pour chaque Cycle
            ForEach(compThemeSections) { cycleThemes in
                let filteredThemes = cycleThemes.filter {
                    $0.disciplineEnum == discipline
                }
                if filteredThemes.isNotEmpty {
                    Section {
                        // pour chaque Thème
                        ForEach(filteredThemes, id: \.objectID) { theme in
                            DThemeBrowserView(theme: theme)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    // supprimer le thème
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if nav.selectedDiscThemeMngObjId == theme.objectID {
                                                nav.selectedDiscThemeMngObjId = nil
                                            }
                                            try? theme.delete()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    // modifier le thème
                                    Button {
                                        editedCompTheme = theme
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }
                                }
                        }
                    } header: {
                        Text("\(cycleThemes.id)")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    }
                } else {
                    EmptyListMessage(
                        symbolName: DThemeEntity.defaultImageName,
                        title: "Aucun thème actuellement pour \(discipline).",
                        message: "Les thèmes de compétences disciplinaires ajoutés apparaîtront ici.",
                        showAsGroupBox: true
                    )
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Thèmes")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'un chapitre de compétence socle
        .sheet(
            isPresented: $isAddingObject
            //            onDismiss: ProgramEntity.rollback()
        ) {
            NavigationStack {
                let theme = DThemeEntity()
                DThemeEditorModal(
                    theme: theme,
                    discipline: discipline,
                    isEditing: false
                )
                .presentationDetents([.medium])
            }
        }

        // Modal Sheet de modification d'un chapitre de compétence socle
        .sheet(
            item: $editedCompTheme,
            onDismiss: didDismiss
        ) { theme in
            NavigationStack {
                DThemeEditorModal(
                    theme: theme,
                    discipline: discipline,
                    isEditing: true
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedCompTheme = nil
    }
}

// MARK: Toolbar Content

extension DCompThemeListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .status) {
            // Ajouter un chapitre de compétences du socle commun
            Button {
                isAddingObject = true
            } label: {
                Label(
                    "Ajouter un thème",
                    systemImage: "plus.circle.fill"
                )
                .labelStyle(.titleAndIcon)
            }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Modifier un chapitre de compétences du socle commun
            if let selectedObject = nav.selectedDiscThemeMngObjId {
                Button("Modifier") {
                    editedCompTheme =
                        DThemeEntity
                            .byObjectId(MngObjID: selectedObject)
                }
            }
        }
    }
}

struct DCompThemeListView_Previews: PreviewProvider {
    static var previews: some View {
        DCompThemeListView(discipline: .technologie)
    }
}
