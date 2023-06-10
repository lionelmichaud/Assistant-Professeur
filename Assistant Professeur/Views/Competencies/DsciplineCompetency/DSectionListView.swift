//
//  DCompListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct DSectionListView: View {
    var discipline: Discipline

    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false
    @State
    private var editedDisciplineSection: DSectionEntity?

    // MARK: - Computed properties

    private var selectedThemeId: NSManagedObjectID? {
        nav.selectedDiscThemeMngObjId
    }

    private var selectedTheme: DThemeEntity? {
        guard let selectedThemeId else {
            return nil
        }
        return DThemeEntity.byObjectId(MngObjID: selectedThemeId)
    }

    private var selectedThemeExists: Bool {
        selectedTheme != nil
    }

    var body: some View {
        Group {
            if selectedThemeExists {
                List(
                    selectedTheme!.allSectionsSortedByNumber,
                    selection: $nav.selectedDiscSectionMngObjId
                ) { disciplineSection in
                    // pour chaque section de compétences disciplinaires
                    NavigationStack {
                        NavigationLink(destination: DComListView()) {
                            DSectionBrowserView(disciplineSection: disciplineSection)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // supprimer la compétence
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if nav.selectedDiscSectionMngObjId == disciplineSection.objectID {
                                                nav.selectedDiscSectionMngObjId = nil
                                            }
                                            try? disciplineSection.delete()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    // modifier la compétence
                                    Button {
                                        editedDisciplineSection = disciplineSection
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }
                                }
                        }
                    }
                }
                .emptyListPlaceHolder(selectedTheme!.allSectionsSortedByNumber) {
                    EmptyListMessage(
                        symbolName: DSectionEntity.defaultImageName,
                        title: "Aucune section de compétences disciplinaires actuellement.",
                        message: "Les sections ajoutées apparaîtront ici.",
                        showAsGroupBox: true
                    )
                }

            } else {
                EmptyListMessage(
                    symbolName: DSectionEntity.defaultImageName,
                    title: "Aucune section de compétences disciplinaires sélectionnée.",
                    message: "Sélectionner une section de compétences pour en visualiser le contenu.",
                    showAsGroupBox: true
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Sections")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'un chapitre de compétence socle
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                let section = DSectionEntity()
                DSectionEditorModal(
                    section: section,
                    inTheme: selectedTheme!,
                    isEditing: false
                )
                .presentationDetents([.medium])
            }
        }

        // Modal Sheet de modification d'un chapitre de compétence socle
        .sheet(
            item: $editedDisciplineSection,
            onDismiss: didDismiss
        ) { section in
            NavigationStack {
                DSectionEditorModal(
                    section: section,
                    inTheme: selectedTheme!,
                    isEditing: true
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedDisciplineSection = nil
    }
}

// MARK: Toolbar Content

extension DSectionListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        if selectedThemeExists {
            ToolbarItemGroup(placement: .status) {
                // Ajouter une compétence au chapitre
                Button {
                    isAddingObject = true
                } label: {
                    Label(
                        "Ajouter une section",
                        systemImage: "plus.circle.fill"
                    )
                    .labelStyle(.titleAndIcon)
                }
            }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Modifier une compétence du chapitre
            if let selectedSectionMngObjId = nav.selectedDiscSectionMngObjId {
                Button("Modifier") {
                    editedDisciplineSection =
                        DSectionEntity
                            .byObjectId(MngObjID: selectedSectionMngObjId)
                }
            }
        }
    }
}
