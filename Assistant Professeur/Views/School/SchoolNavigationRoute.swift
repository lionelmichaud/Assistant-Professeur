//
//  SchoolNavigationRoute.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import SwiftUI

enum SchoolNavigationRoute: Hashable, Codable {
    case infos(SchoolEntity)
    case nextSeances(SchoolEntity)
    case bonusMalus(SchoolEntity)

    static func == (lhs: SchoolNavigationRoute, rhs: SchoolNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case let (.infos(schooll), .infos(schoolr)):
                return (schooll.id == schoolr.id)

            case let (.nextSeances(schooll), .nextSeances(schoolr)):
                return schooll.id == schoolr.id

            case let (.bonusMalus(schooll), .bonusMalus(schoolr)):
                return schooll.id == schoolr.id

            default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case let .infos(school):
                hasher.combine("infos")
                hasher.combine(school.id)

            case let .nextSeances(school):
                hasher.combine("nextSeances")
                hasher.combine(school.id)

            case let .bonusMalus(school):
                hasher.combine("bonusMalus")
                hasher.combine(school.id)
        }
    }

    func destination() -> some View {
        Group {
            switch self {
                case let .infos(school):
                    SchoolInfosView(school: school)

                case let .nextSeances(school):
                    SchoolNextSeancesView(school: school)

                case let .bonusMalus(school):
                    SchoolBonusMalusView(school: school)
            }
        }
    }
}
