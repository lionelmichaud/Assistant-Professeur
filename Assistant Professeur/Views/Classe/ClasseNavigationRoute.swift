//
//  ClasseNavigationRoute.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import SwiftUI

enum ClasseNavigationRoute: Hashable, Codable {
    case infos(ClasseEntity.ID)
    case room(ClasseEntity.ID)
    case liste(ClasseEntity.ID)
    case trombinoscope(ClasseEntity.ID)
    case groups(ClasseEntity.ID)
    case exam(ClasseEntity.ID, ExamEntity.ID)
    case activity(ClasseEntity.ID)
    case progress(ClasseEntity.ID)
    case nextSeances(ClasseEntity.ID)

    func destination( // swiftlint:disable:this cyclomatic_complexity
        horizontalSizeClass: UserInterfaceSizeClass?
    ) -> some View {
        var errorView: Text {
            Text("Erreur de routage")
                .font(.largeTitle)
        }

        return Group {
            switch self {
                case let .infos(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        ClasseInfosView(classe: classe)
                    } else {
                        errorView
                    }

                case let .room(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        RoomElevePlacement(classe: classe)
                    } else {
                        errorView
                    }

                case let .liste(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        switch horizontalSizeClass {
                            case .compact:
                                ElevesListView(classe: classe)
                            default:
                                ElevesTableView(classe: classe)
                        }
                    } else {
                        errorView
                    }

                case let .trombinoscope(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        TrombinoscopeView(classe: classe)
                    } else {
                        errorView
                    }

                case let .groups(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        GroupsListView(classe: classe)
                    } else {
                        errorView
                    }

                case let .exam(classeId, examId):
                    if let classe = ClasseEntity.byId(id: classeId!),
                       let exam = ExamEntity.byId(id: examId!) {
                        ExamEditor(classe: classe, exam: exam)
                    } else {
                        errorView
                    }

                case let .activity(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        ClassCurrentActivityView(classe: classe)
                    } else {
                        errorView
                    }

                case let .progress(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        ClassProgressesView(classe: classe)
                    } else {
                        errorView
                    }

                case let .nextSeances(classeId):
                    if let classe = ClasseEntity.byId(id: classeId!) {
                        ClassNextSeancesView(classe: classe)
                    } else {
                        errorView
                    }
            }
        }
    }
}
