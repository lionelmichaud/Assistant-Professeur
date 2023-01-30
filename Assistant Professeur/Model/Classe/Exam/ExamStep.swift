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

public typealias StepsArray = [ExamStep]

/// Une étape d'évaluation
@objc
public class ExamStep: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true

    enum Key: String {
        case name
        case points
    }

    public var name: String = ""
    public var points: Int = 0

    // MARK: - Initializers

    public init(
        name: String = "",
        points: Int = 0
    ) {
        super.init()
        self.name = name
        self.points = points
    }

    public required convenience init?(coder: NSCoder) {
        let points = coder.decodeInteger(forKey: Key.points.rawValue)
        if let name = coder.decodeObject(forKey: Key.name.rawValue) as? String {
            self.init(name: name, points: points)
        } else {
            return nil
        }
    }

    // MARK: - Methods

    public func encode(with coder: NSCoder) {
        coder.encode(self.points, forKey: Key.points.rawValue)
        coder.encode(self.name, forKey: Key.name.rawValue)
    }
}

// MARK: - Transformer for StepsArray

class ExamStepsTransformer: NSSecureUnarchiveFromDataTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override class var allowedTopLevelClasses: [AnyClass] {
        return [ExamStep.self, NSArray.self, NSString.self]
    }

    /// Transformation from [ExamStep] to Data
    /// - Parameter value: [ExamStep]
    /// - Returns: Data
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let steps = value as? [ExamStep] else {
            customLog.log(level: .fault, "Wrong data type: value must be a [ExamStep] object; received \(type(of: value))")
            fatalError()
        }
        return super.reverseTransformedValue(steps)
    }

    /// Transformation from Data to [ExamStep]
    /// - Parameter value: Data
    /// - Returns: [ExamStep]
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            customLog.log(level: .fault, "Wrong data type: value must be a Data object; received \(type(of: value))")
            fatalError()
        }

        return super.transformedValue(data)
    }
}

extension NSValueTransformerName {
    static let examStepsTransformer = NSValueTransformerName(rawValue: "ExamStepsTransformer")
}
