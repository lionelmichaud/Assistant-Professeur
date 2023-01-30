//
//  ExamStep.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/01/2023.
//

import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ExamStepsTransformer"
)

typealias StepsArray = [ExamStep]

/// Une étape d'évaluation
struct ExamStep: Codable, Identifiable {
    public static var supportsSecureCoding: Bool = true

    var id: UUID = UUID()
    var name: String = ""
    var points: Int = 0

    // MARK: - Initializers

    public init(
        name: String = "",
        points: Int = 0
    ) {
        self.name = name
        self.points = points
    }
}

// MARK: - Transformer for StepsArray

//class ExamStepsTransformer: NSSecureUnarchiveFromDataTransformer {
//    override class func allowsReverseTransformation() -> Bool {
//        return true
//    }
//
//    override class func transformedValueClass() -> AnyClass {
//        return NSArray.self
//    }
//
//    override class var allowedTopLevelClasses: [AnyClass] {
//        return [ExamStep.self, NSArray.self, NSString.self]
//    }
//
//    /// Transformation from [ExamStep] to Data
//    /// - Parameter value: [ExamStep]
//    /// - Returns: Data
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let steps = value as? [ExamStep] else {
//            customLog.log(level: .fault, "Wrong data type: value must be a [ExamStep] object; received \(type(of: value))")
//            fatalError()
//        }
//        return super.reverseTransformedValue(steps)
//    }
//
//    /// Transformation from Data to [ExamStep]
//    /// - Parameter value: Data
//    /// - Returns: [ExamStep]
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? Data else {
//            customLog.log(level: .fault, "Wrong data type: value must be a Data object; received \(type(of: value))")
//            fatalError()
//        }
//
//        return super.transformedValue(data)
//    }
//}
//
//extension NSValueTransformerName {
//    static let examStepsTransformer = NSValueTransformerName(rawValue: "ExamStepsTransformer")
//}
