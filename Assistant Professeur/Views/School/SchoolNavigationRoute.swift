//
//  SchoolNavigationRoute.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import SwiftUI

enum SchoolNavigationRoute: Hashable, Codable {
    case infos(SchoolEntity.ID)
    case previousSeances(SchoolEntity.ID)
    case currentSeances(SchoolEntity.ID)
    case nextSeances(SchoolEntity.ID)
    case bonusMalus(SchoolEntity.ID)
    case toDoList([Seance])

    static func == (lhs: SchoolNavigationRoute, rhs: SchoolNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case let (.infos(schoollId), .infos(schoolrId)):
                return (schoollId == schoolrId)

            case let (.previousSeances(schoollId), .previousSeances(schoolrId)):
                return schoollId == schoolrId

            case let (.currentSeances(schoollId), .currentSeances(schoolrId)):
                return schoollId == schoolrId

            case let (.nextSeances(schoollId), .nextSeances(schoolrId)):
                return schoollId == schoolrId

            case let (.bonusMalus(schoollId), .bonusMalus(schoolrId)):
                return schoollId == schoolrId

            case let (.toDoList(seancesl), .toDoList(seancesr)):
                return seancesl == seancesr

            default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case let .infos(schoolId):
                hasher.combine("infos")
                hasher.combine(schoolId)

            case let .previousSeances(schoolId):
                hasher.combine("previousSeances")
                hasher.combine(schoolId)

            case let .currentSeances(schoolId):
                hasher.combine("currentSeances")
                hasher.combine(schoolId)

            case let .nextSeances(schoolId):
                hasher.combine("nextSeances")
                hasher.combine(schoolId)

            case let .bonusMalus(schoolId):
                hasher.combine("bonusMalus")
                hasher.combine(schoolId)
                
            case let .toDoList(seances):
                hasher.combine(seances)
        }
    }

    func destination() -> some View {// swiftlint:disable:this cyclomatic_complexity
        var errorView: Text {
            Text("Erreur de routage")
                .font(.largeTitle)
        }

        return Group {
            switch self {
                case let .infos(schoolId):
                    if let school = SchoolEntity.byId(id: schoolId!) {
                        SchoolInfosView(school: school)
                    } else {
                        errorView
                    }

                case let .previousSeances(schoolId):
                    if let school = SchoolEntity.byId(id: schoolId!) {
                        SchoolPreviousSeancesView(school: school)
                    } else {
                        errorView
                    }

                case let .currentSeances(schoolId):
                    if let school = SchoolEntity.byId(id: schoolId!) {
                        SchoolCurrentSeanceView(school: school)
                    } else {
                        errorView
                    }

                case let .nextSeances(schoolId):
                    if let school = SchoolEntity.byId(id: schoolId!) {
                        SchoolNextSeancesView(school: school)
                    } else {
                        errorView
                    }

                case let .bonusMalus(schoolId):
                    if let school = SchoolEntity.byId(id: schoolId!) {
                        SchoolBonusMalusView(school: school)
                    } else {
                        errorView
                    }
                case let .toDoList(seances):
                    ToDoView(seances: seances)
            }
        }
    }
}
