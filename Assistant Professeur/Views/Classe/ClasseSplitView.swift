//
//  ClasseSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import SwiftUI

struct ClasseSplitView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var path = NavigationPath()

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navigationModel.columnVisibility
        ) {
            ClasseSidebarView()
        } detail: {
            NavigationStack(path: $path) {
                ClasseEditor()
                    .navigationDestination(for: ClasseNavigationRoute.self) { route in
                        switch route {
                            case let.room(classe):
                                RoomElevePlacement(classe: classe)

                            case let.liste(classe):
                                switch horizontalSizeClass {
                                    case .compact:
                                        ElevesListView(classe: classe)
                                    default:
                                        ElevesTableView(classe: classe)
                                }

                            case let.trombinoscope(classe):
                                TrombinoscopeView(classe : classe)

                            case let.groups(classe):
                                GroupsView(classe: classe)

                            case let.exam(classe, exam):
                                ExamEditor(classe: classe, exam: exam)
                        }
                    }
            }
        }
    }
}

//struct ClasseSplitView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            ClasseSplitView()
//                .environmentObject(NavigationModel())
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            ClasseSplitView()
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
