//
//  SettingsView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        TabView {
            SettingsGeneral()
            SettingsSchool()
            SettingsClasse()
            SettingsEleve()
            SettingsProgram()
            SettingsSequence()
            SettingsActivity()
            SettingsSchoolYear()
            SettingsAgenda()
        }
        #if os(iOS)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
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
    static var previews: some View {
        SettingsView()
    }
}
