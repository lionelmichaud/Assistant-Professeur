//
//  SettingsView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import HelpersView
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
            ForEach(PrefScreen.allCases) { screen in
                screen.view
            }
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif
        .toolbarTitleMenu {
            CasePicker(
                pickedCase: $nav.selectedPrefTab.animation(),
                label: "Préférences"
            )
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Retour", systemImage: "xmark.circle.fill") {
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
                .environmentObject(UserPrefEntity())
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            SettingsView()
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
