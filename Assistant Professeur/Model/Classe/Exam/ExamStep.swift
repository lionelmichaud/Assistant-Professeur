//
//  ExamStep.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/01/2023.
//

import Foundation
import os

private let customLog = Logger(subsystem : "com.michaud.lionel.Assistant-Professeur",
                               category  : "ExamStepTransformer")

public class ExamStep: NSObject {
    public var name: String = ""
    public var points: Int = 0

    init(
        name: String = "",
        points: Int = 0
    ) {
        self.name = name
        self.points = points
    }
}

class ExamStepTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let steps = value as? [ExamStep] else {
            return nil
        }
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: steps,
                requiringSecureCoding: true
            )
            return data
        } catch {
            customLog.log(level: .fault, "Failed to archive array with error: \(error)")
            fatalError("Failed to archive array with error: \(error)")
        }
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }

        do {
            if let steps = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSArray.self,
                from: data
            ) as? [ExamStep] {
                return steps
            } else {
                customLog.log(level: .fault, "Could not convert unarchive array to [ExamStep]")
                fatalError("Could not convert unarchive array to [ExamStep]")
            }
        } catch {
            customLog.log(level: .fault, "Could not unarchive array: \(error)")
            fatalError("Could not unarchive array: \(error)")
        }
    }
}
