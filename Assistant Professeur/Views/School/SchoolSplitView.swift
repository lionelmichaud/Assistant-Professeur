//
//  SchoolSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import SwiftUI

struct SchoolSplitView: View {
    @EnvironmentObject private var navigationModel : NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navigationModel.columnVisibility
        ) {
            SchoolSidebarView()
        } detail: {
            Text("School Detail View")
            //SchoolEditor()
        }
    }
}

//struct SchoolSplitView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            SchoolSplitView()
//                .environmentObject(NavigationModel())
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            SchoolSplitView()
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
