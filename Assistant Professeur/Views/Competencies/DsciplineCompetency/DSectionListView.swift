//
//  DCompListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import CoreData
import HelpersView
import SwiftUI
import TipKit

struct DSectionListView: View {
    @ObservedObject
    var theme: DThemeEntity

    var discipline: Discipline

    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false
    @State
    private var editedSection: DSectionEntity?

    /// Create an instance of your tip content.
    var editItemTip = DSectionEditItemTip()

    // MARK: - Computed properties

    var body: some View {
        List(selection: $nav.selectedDiscSectionMngObjId) {
            let sections = theme.allSectionsSortedByNumber
            // Thème de compétences disciplinaires
            DThemeBrowserView(
                theme: theme,
                showIcon: false,
                showProgressivity: true
            )
            .customizedListItemStyle(
                isSelected: false
            )

            // Sections de compétences disciplinaires
            if sections.isNotEmpty {
                TipView(editItemTip, arrowEdge: .bottom)
                    .customizedTipKitStyle()
            }
            ForEach(sections, id: \.objectID) { section in
                // pour chaque section de compétences disciplinaires
                NavigationLink(value: section) {
                    DSectionBrowserView(
                        section: section,
                        showIcon: true,
                        showProgressivity: false
                    )
                    .badge(section.nbOfCompetencies)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // supprimer la compétence
                        Button(role: .destructive) {
                            withAnimation {
                                if nav.selectedDiscSectionMngObjId == section.objectID {
                                    nav.selectedDiscSectionMngObjId = nil
                                }
                                try? section.delete()
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        // modifier la compétence
                        Button {
                            editItemTip.invalidate(reason: .actionPerformed)
                            editedSection = section
                        } label: {
                            Label("Modifier", systemImage: "square.and.pencil")
                        }
                    }
                }
                .customizedListItemStyle(
                    isSelected: section.objectID == nav.selectedDiscSectionMngObjId
                )
            }
            .emptyListPlaceHolder(sections) {
                ContentUnavailableView(
                    "Aucune section de compétences disciplinaires actuellement...",
                    systemImage: DSectionEntity.defaultImageName,
                    description: Text("Les sections ajoutées apparaîtront ici.")
                )
            }
        }
        .onChange(of: nav.selectedDiscSectionMngObjId) {
            // si on change de section
            // => on reset les compétence et connaissance sélectionnées
            nav.selectedDiscCompMngObjId = nil
            nav.selectedDiscKnowMngObjId = nil
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
                    nextNumber: theme.nbOfSections + 1,
                    inTheme: theme,
                    isEditing: false
                )
            }
            .presentationDetents([.medium])
        }

        // Modal Sheet de modification d'un chapitre de compétence socle
        .sheet(
            item: $editedSection,
            onDismiss: didDismiss
        ) { section in
            NavigationStack {
                DSectionEditorModal(
                    section: section,
                    inTheme: theme,
                    isEditing: true
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedSection = nil
    }
}

// MARK: Toolbar Content

extension DSectionListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .status) {
            // Ajouter une séction au thème
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

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Modifier une séction du thème
            if let selectedSectionMngObjId = nav.selectedDiscSectionMngObjId {
                Button {
                    editedSection =
                        DSectionEntity
                            .byObjectId(MngObjID: selectedSectionMngObjId)
                } label: {
                    Label("Modifier", systemImage: "square.and.pencil")
                }
            }
        }
    }
}
