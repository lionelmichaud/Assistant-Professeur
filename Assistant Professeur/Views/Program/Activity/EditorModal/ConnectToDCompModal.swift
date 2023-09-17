//
//  ConnectToDCompModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/07/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct ConnectToDCompModal: View {
    @ObservedObject
    var activity: ActivityEntity

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var dThemes = [DThemeEntity]()

    @State
    private var selectedCompsObjId = Set<NSManagedObjectID>()

    @State
    private var isExpanded: Bool = true

    var body: some View {
        List(selection: $selectedCompsObjId) {
            ForEach(dThemes) { dTheme in
                ThemeDisclosure(
                    dTheme: dTheme
                )
            }
            .emptyListPlaceHolder(dThemes) {
                EmptyListMessage(
                    symbolName: DThemeEntity.defaultImageName,
                    title: "Aucun thème de compétences disciplinaires actuellement.",
                    message: "Les thèmes ajoutés apparaîtront ici.",
                    showAsGroupBox: true
                )
            }
        }
        .listStyle(.sidebar)
        .interactiveDismissDisabled()
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
                        let set = NSSet(array: dComps)
                        activity.addToCompetencies(set)
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
