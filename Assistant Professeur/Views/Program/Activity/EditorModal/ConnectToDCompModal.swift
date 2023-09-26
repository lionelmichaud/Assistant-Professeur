//
//  ConnectToDCompModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/07/2023.
//

import CoreData
import HelpersView
import SwiftUI

/// Dialogue modal de connection d'une Activité pédagogique avec des Compétences Disciplinaires
struct ConnectToDCompModal: View {
    @ObservedObject
    var activity: ActivityEntity

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var dThemes = [DThemeEntity]()

    @State
    private var selectedCompsObjId = Set<NSManagedObjectID>()

    var body: some View {
        List(selection: $selectedCompsObjId) {
            ForEach(dThemes) { dTheme in
                ThemeDisclosure(
                    dTheme: dTheme
                )
            }
            .emptyListPlaceHolder(dThemes) {
                ContentUnavailableView(
                    "Aucun thème de compétences disciplinaires actuellement...",
                    systemImage: DThemeEntity.defaultImageName,
                    description: Text("Les thèmes ajoutés apparaîtront ici.")
                )
            }
        }
        .listStyle(.sidebar)
        .task {
            if let discipline = activity.sequence?.program?.viewDisciplineEnum,
               let level = activity.sequence?.program?.levelEnum {
                let cycle = level.cycle
                dThemes = DThemeEntity.sortedByTitle(
                    forCycle: cycle,
                    forDiscipline: discipline
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Compétence disciplinaire")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    ActivityEntity.rollback()
                    dismiss()
                }
            }
            if selectedCompsObjId.isNotEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Associer") {
                        let dComps = selectedCompsObjId.compactMap { dCompObjectId in
                            DCompEntity.byObjectId(MngObjID: dCompObjectId)
                        }
                        let setOfDcomps = NSSet(array: dComps)
                        activity.addToCompetencies(setOfDcomps)

                        try? ActivityEntity.saveIfContextHasChanged()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ThemeDisclosure: View {
    @ObservedObject
    var dTheme: DThemeEntity

    @State
    private var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded.animation()) {
            ForEach(dTheme.allSectionsSortedByNumber) { dSection in
                SectionDisclosure(
                    dSection: dSection
                )
            }
        } label: {
            DThemeBrowserView(
                theme: dTheme,
                showIcon: true,
                showProgressivity: false
            )
        }
    }
}

struct SectionDisclosure: View {
    @ObservedObject
    var dSection: DSectionEntity

    @State
    private var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded.animation()) {
            ForEach(dSection.allCompetenciesSortedByNumber, id: \.objectID) { dComp in
                DCompBrowserRow(
                    competency: dComp,
                    showIcon: true
                )
            }
        } label: {
            DSectionBrowserView(
                section: dSection,
                showIcon: true,
                showProgressivity: false
            )
        }
    }
}

// struct ConnectToDCompModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectToDCompModal()
//    }
// }
