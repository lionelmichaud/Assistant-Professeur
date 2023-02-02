//
//  StepsValidationView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/02/2023.
//

import SwiftUI

struct StepsValidationView: View {
    @ObservedObject
    var exam: ExamEntity

    let width: Int

    @State
    private var value: Double = 0.0

    var body: some View {
        VStack {
            HStack {
                Text("Étapes")
                Spacer()
                Text("Note totale: 10")
                    .padding(.top, 8)
                    .foregroundColor(.accentColor)
            }
            .font(.headline)
            .padding(.horizontal)

            List(exam.viewSteps) { step in
                HStack {
                    Text(step.name)
                        .frame(width: CGFloat(width), alignment: .leading)
                    Slider(
                        value: $value,
                        in: 0 ... step.points.double(),
                        step: 0.5
                    ) {
                        Text("Label")
                    } minimumValueLabel: {
                        Text("")
                    } maximumValueLabel: {
                        Text("\(valueSting(value: value))").foregroundColor(.accentColor) +
                        Text(" / \(maxValue(value: Double(step.points)))")
                    } onEditingChanged: { _ in
                    }
                }
            }
        }
    }

    private func maxValue(value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }

    private func valueSting(value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}

// struct StepsValidationView_Previews: PreviewProvider {
//    static var previews: some View {
//        StepsValidationView()
//    }
// }
