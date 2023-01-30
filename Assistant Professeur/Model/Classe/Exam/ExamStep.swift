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

/// Un tableau d'étapes d'évaluation
@objc
public class ExamSteps: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true

    enum Key: String {
        case steps
    }

    public var steps: StepsArray = []

    // MARK: - Initializers

    public init(steps: StepsArray = []) {
        super.init()
        self.steps = steps
    }

    public required convenience init?(coder: NSCoder) {
        if let steps = coder.decodeObject(forKey: Key.steps.rawValue) {
            if steps is StepsArray {
                self.init(steps: steps as! StepsArray)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    // MARK: - Methods

    public func encode(with coder: NSCoder) {
        coder.encode(steps, forKey: Key.steps.rawValue)
    }
}

/// Une étape d'évaluation
@objc
public class ExamStep: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true

    enum Key: String {
        case ExamStep
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
        if let step = coder.decodeObject(of: ExamStep.self, forKey: Key.ExamStep.rawValue) {
            self.init(name: step.name, points: step.points)
        } else {
            return nil
        }
    }

    // MARK: - Methods

    public func encode(with coder: NSCoder) {
        coder.encode(self, forKey: Key.ExamStep.rawValue)
    }
}

// MARK: - Transformer for StepsArray
class ExamStepsTransformer: NSSecureUnarchiveFromDataTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return ExamSteps.self
    }

    override class var allowedTopLevelClasses: [AnyClass] {
        return [ExamSteps.self]
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let steps = value as? ExamSteps else {
            customLog.log(level: .fault, "Wrong data type: value must be a ExamSteps object; received \(type(of: value))")
            fatalError()
        }
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: steps,
                requiringSecureCoding: true
            )
            return data
        } catch {
            customLog.log(level: .fault, "Failed to archive array with error: \(error)")
            fatalError()
        }
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            customLog.log(level: .fault, "Wrong data type: value must be a Data object; received \(type(of: value))")
            fatalError()
        }

        do {
            if let steps = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: ExamSteps.self,
                from: data
            ) {
                return steps
            } else {
                customLog.log(level: .fault, "Could not convert unarchive array to [ExamStep]")
                fatalError()
            }
        } catch {
            customLog.log(level: .fault, "Could not unarchive array: \(error)")
            return nil
            //fatalError()
        }
    }
}

extension NSValueTransformerName {
    static let examStepsTransformer = NSValueTransformerName(rawValue: "ExamStepsTransformer")
}
