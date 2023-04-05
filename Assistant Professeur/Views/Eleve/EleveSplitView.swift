//
//  EleveSplitView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/10/2022.
//

import SwiftUI

struct EleveSplitView: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navigationModel.columnVisibility
        ) {
            // 1ère colonne
            EleveSidebarView()
                .navigationSplitViewColumnWidth(min: 250,
                                                ideal: 350,
                                                max: 500)

        } detail: {
            // Détail dans la 2ième colonne
            EleveEditor()
        }
    }
}

//struct EleveSplitView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            EleveSplitView()
//                .environmentObject(NavigationModel())
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            EleveSplitView()
//                .environmentObject(NavigationModel())
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPhone 13")
//        }
//    }
//}
