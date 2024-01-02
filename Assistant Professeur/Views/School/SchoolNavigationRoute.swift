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
