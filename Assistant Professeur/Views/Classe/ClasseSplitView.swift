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

    @EnvironmentObject private var navigationModel : NavigationModel
    @State private var path = NavigationPath()

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
                            case .room(let classe):
                                RoomElevePlacement(classe: classe)

                            case .liste(let classe):
                                switch horizontalSizeClass {
                                    case .compact:
                                        ElevesListView(classe: classe)
                                    default:
                                        ElevesTableView(classe: classe)
                                }

                            case .trombinoscope(let classe):
                                TrombinoscopeView(classe : classe)

                            case .groups(let classe):
                                GroupsView(classe: classe)

                            case .exam(let classe, let examId):
                                ExamEditor(classe: classe,
                                           examId: examId)
                        }
                    }
            }
        }
    }
}

struct ClasseSplitView_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvir.createFakes()
        return Group {
            ClasseSplitView()
                .environmentObject(NavigationModel())
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPad mini (6th generation)")

            ClasseSplitView()
                .environmentObject(NavigationModel())
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPhone 13")
        }
    }
}
