//
//  ExamStep.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/01/2023.
//

import Foundation

typealias StepsArray = [ExamStep]

/// Une étape d'évaluation
struct ExamStep: Codable, Identifiable {
    //public static var supportsSecureCoding: Bool = true

    var id: UUID = UUID()
    var name: String = ""
    var points: Int = 1

    // MARK: - Initializers

    public init(
        name: String = "",
        points: Int = 0
    ) {
        self.name = name
        self.points = points
    }
}
