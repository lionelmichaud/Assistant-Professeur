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

    static func == (lhs: ClasseNavigationRoute, rhs: ClasseNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case let (.infos(classelId), .infos(classerId)):
                return (classelId == classerId)

            case let (.room(classelId), .room(classerId)):
                return (classelId == classerId)

            case let (.liste(classelId), .liste(classerId)):
                return classelId == classerId

            case let (.trombinoscope(classelId), .trombinoscope(classerId)):
                return classelId == classerId

            case let (.groups(classelId), .groups(classerId)):
                return classelId == classerId

            case let (.exam(classelId, examlId), .exam(classerId, examrId)):
                return (classelId == classerId) &&
                    (examlId == examrId)

            case let (.activity(classelId), .activity(classerId)):
                return classelId == classerId

            case let (.progress(classelId), .progress(classerId)):
                return classelId == classerId

            case let (.nextSeances(classelId), .nextSeances(classerId)):
                return classelId == classerId

            default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case let .infos(classeId):
                hasher.combine("infos")
                hasher.combine(classeId)
            case let .room(classeId):
                hasher.combine("room")
                hasher.combine(classeId)
            case let .liste(classeId):
                hasher.combine("liste")
                hasher.combine(classeId)
            case let .trombinoscope(classeId):
                hasher.combine("trombinoscope")
                hasher.combine(classeId)
            case let .groups(classeId):
                hasher.combine("groups")
                hasher.combine(classeId)
            case let .exam(classeId, examId):
                hasher.combine(classeId)
                hasher.combine(examId)
            case let .activity(classeId):
                hasher.combine("activity")
                hasher.combine(classeId)
            case let .progress(classeId):
                hasher.combine("progress")
                hasher.combine(classeId)
            case let .nextSeances(classeId):
                hasher.combine("nextSeances")
                hasher.combine(classeId)
        }
    }

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
