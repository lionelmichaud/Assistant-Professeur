//
//  DCompThemeListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 08/06/2023.
//

import HelpersView
import SwiftUI
import TipKit

struct DThemeListView: View {
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
    private var editedTheme: DThemeEntity?

    /// Create an instance of your tip content.
    var editItemTip = DThemeEditItemTip()

    var body: some View {
        TipView(editItemTip, arrowEdge: .bottom)
            .customizedTipKitStyle()
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
                            NavigationLink(value: theme) {
                                DThemeBrowserView(
                                    theme: theme,
                                    showIcon: true,
                                    showProgressivity: false
                                )
                                .badge(theme.nbOfSections)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
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
                                        editItemTip.invalidate(reason: .actionPerformed)
                                        editedTheme = theme
                                    } label: {
                                        Label("Modifier", systemImage: "square.and.pencil")
                                    }
                                }
                            }
                            .customizedListItemStyle(
                                isSelected: theme.objectID == nav.selectedDiscThemeMngObjId
                            )
                        }
                        .emptyListPlaceHolder(filteredThemes) {
                            ContentUnavailableView(
                                "Aucun thème de compétences disciplinaires actuellement...",
                                systemImage: DThemeEntity.defaultImageName,
                                description: Text("Les thèmes ajoutés apparaîtront ici.")
                            )
                        }
                    } header: {
                        Text("\(cycleThemes.id)")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    }
                } else {
                    ContentUnavailableView(
                        "Aucun thème actuellement pour \(discipline.rawValue)...",
                        systemImage: DThemeEntity.defaultImageName,
                        description: Text("Les thèmes de compétences disciplinaires ajoutés apparaîtront ici.")
                    )
                }
            }
        }
        .onChange(of: nav.selectedDiscThemeMngObjId) {
            // si on change de thème
            // => on reset les section, compétence et connaissance sélectionnées
            nav.selectedDiscSectionMngObjId = nil
            nav.selectedDiscCompMngObjId = nil
            nav.selectedDiscKnowMngObjId = nil
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
            item: $editedTheme,
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
        editedTheme = nil
    }
}

// MARK: Toolbar Content

extension DThemeListView {
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
                Button {
                    editedTheme =
                        DThemeEntity
                            .byObjectId(MngObjID: selectedObject)
                } label: {
                    Label("Modifier", systemImage: "square.and.pencil")
                }
            }
        }
    }
}

struct DCompThemeListView_Previews: PreviewProvider {
    static var previews: some View {
        DThemeListView(discipline: .technologie)
    }
}
