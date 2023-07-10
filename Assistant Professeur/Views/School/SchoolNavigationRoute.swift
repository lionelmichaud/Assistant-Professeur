//
//  SchoolNavigationRoute.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import Foundation
enum SchoolNavigationRoute: Hashable, Codable {
    case infos(SchoolEntity)
    case nextSeances(SchoolEntity)

    static func == (lhs: SchoolNavigationRoute, rhs: SchoolNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case let (.infos(schooll), .infos(schoolr)):
                return (schooll.id == schoolr.id)

            case let (.nextSeances(schooll), .nextSeances(schoolr)):
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
        }
    }
}
