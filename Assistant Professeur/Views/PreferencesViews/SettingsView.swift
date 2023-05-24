//
//  SettingsView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        TabView(selection: $nav.selectedPrefTab) {
            SettingsGeneral()
                .tag(1)
            SettingsSchool()
                .tag(2)
            SettingsClasse()
                .tag(3)
            SettingsEleve()
                .tag(4)
            SettingsProgram()
                .tag(5)
            SettingsSequence()
                .tag(6)
            SettingsActivity()
                .tag(7)
            SettingsSchoolYear()
                .tag(8)
            // SettingsAgenda()
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif
        .toolbar {
            ToolbarItem {
                Button("Fermer") {
                    dismiss()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            SettingsView()
                .environmentObject(UserPreferences())
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            SettingsView()
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
