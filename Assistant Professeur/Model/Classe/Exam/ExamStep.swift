//
//  ExamStep.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/01/2023.
//

import Foundation

public class ExamStep: NSObject {
    public var name: String = ""
    public var points: Int = 0
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
            print("failed to archive array with error: \(error)")
            return nil
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
                print("could not convert unarchive array to [ExamStep]")
                return nil
            }
        } catch {
            print("could not unarchive array: \(error)")
            return nil
        }
    }
}
