//
//  Service.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/12/2023.
//

import Foundation

/// Service disponible sur le Store
enum Service: CaseIterable {
    case unlocked
    case program
    case competency
    case pro

    /// Niveau d'un service (entier)
    /// - Warning: Les valeurs numériques doivent être cohérentes de celles
    ///            du fichier PList "Products.plist".
    var levelOfService: Int {
        switch self {
            case .unlocked: 1
            case .program: 2
            case .competency: 3
            case .pro: 10
        }
    }

    /// Service correspondant à un certain niveau (entier)
    static func service(forLevel level: Int) -> Self? {
        for service in Self.allCases where service.levelOfService == level {
            return service
        }
        return nil
    }
}

