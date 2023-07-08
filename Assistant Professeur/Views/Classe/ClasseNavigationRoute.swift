//
//  ClasseNavigationRoute.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import Foundation

enum ClasseNavigationRoute: Hashable, Codable {
    case infos(ClasseEntity)
    case room(ClasseEntity)
    case liste(ClasseEntity)
    case trombinoscope(ClasseEntity)
    case groups(ClasseEntity)
    case exam(ClasseEntity, ExamEntity)
    case activity(ClasseEntity)
    case progress(ClasseEntity)
    case nextSeances(ClasseEntity)

    static func == (lhs: ClasseNavigationRoute, rhs: ClasseNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case let (.infos(classel), .infos(classer)):
                return (classel.id == classer.id)

            case let (.room(classel), .room(classer)):
                return (classel.id == classer.id)

            case let (.liste(classel), .liste(classer)):
                return classel.id == classer.id

            case let (.trombinoscope(classel), .trombinoscope(classer)):
                return classel.id == classer.id

            case let (.groups(classel), .groups(classer)):
                return classel.id == classer.id

            case let (.exam(classel, examl), .exam(classer, examr)):
                return (classel.id == classer.id) &&
                    (examl == examr)

            case let (.activity(classel), .activity(classer)):
                return classel.id == classer.id

            case let (.progress(classel), .progress(classer)):
                return classel.id == classer.id

            case let (.nextSeances(classel), .nextSeances(classer)):
                return classel.id == classer.id

            default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case let .infos(classe):
                hasher.combine("infos")
                hasher.combine(classe.id)
            case let .room(classe):
                hasher.combine("room")
                hasher.combine(classe.id)
            case let .liste(classe):
                hasher.combine("liste")
                hasher.combine(classe.id)
            case let .trombinoscope(classe):
                hasher.combine("trombinoscope")
                hasher.combine(classe.id)
            case let .groups(classe):
                hasher.combine("groups")
                hasher.combine(classe.id)
            case let .exam(classe, exam):
                hasher.combine(classe.id)
                hasher.combine(exam.id)
            case let .activity(classe):
                hasher.combine("activity")
                hasher.combine(classe.id)
            case let .progress(classe):
                hasher.combine("progress")
                hasher.combine(classe.id)
            case let .nextSeances(classe):
                hasher.combine("nextSeances")
                hasher.combine(classe.id)
        }
    }
}
