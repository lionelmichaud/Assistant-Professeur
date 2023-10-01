//
//  SchoolNavigationRoute.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import SwiftUI

enum SchoolNavigationRoute: Hashable, Codable {
    case infos(SchoolEntity.ID)
    case nextSeances(SchoolEntity.ID)
    case bonusMalus(SchoolEntity.ID)

    static func == (lhs: SchoolNavigationRoute, rhs: SchoolNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case let (.infos(schoollId), .infos(schoolrId)):
                return (schoollId == schoolrId)

            case let (.nextSeances(schoollId), .nextSeances(schoolrId)):
                return schoollId == schoolrId

            case let (.bonusMalus(schoollId), .bonusMalus(schoolrId)):
                return schoollId == schoolrId

            default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case let .infos(schoolId):
                hasher.combine("infos")
                hasher.combine(schoolId)

            case let .nextSeances(schoolId):
                hasher.combine("nextSeances")
                hasher.combine(schoolId)

            case let .bonusMalus(schoolId):
                hasher.combine("bonusMalus")
                hasher.combine(schoolId)
        }
    }

    func destination() -> some View {
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
            }
        }
    }
}
