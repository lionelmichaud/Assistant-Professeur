//
//  DurationView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import SwiftUI

struct DurationView: View {
    var duration: Double
    var withMargin: Bool

    var body: some View {
        let remainder = duration.remainder(dividingBy: 1.0)

        Label {
            Text("\(duration.formatted(.number.precision(.fractionLength(remainder == 0.0 ? 0 : 1)))) séances")
        } icon: {
            if withMargin {
                Image(systemName: "hourglass.badge.plus")
            } else {
                Image(systemName: "hourglass")
            }
        }
    }
}

struct DurationSquareView: View {
    var duration: Double
    var withMargin: Bool
    var margin: Int

    var body: some View {
        let q = duration.rounded(.towardZero)
        let r = duration - q

        Label {
            if duration == 0 {
                Text("0 séance")
            } else {
                HStack(spacing: 3) {
                    Text("\(duration.formatted(.number.precision(.fractionLength(r == 0.0 ? 0 : 1))))")
                    if q >= 1 {
                        ForEach(1 ... Int(q), id: \.self) { _ in
                            Rectangle()
                                .fill(Color.blue5)
                                .frame(width: 10, height: 10, alignment: .center)
                        }
                    }
                    if r > 0.0 {
                        Rectangle()
                            .fill(Color.blue5)
                            .frame(width: 10 * r, height: 10, alignment: .center)
                    }
                    if withMargin && margin != 0 {
                        Text("+\(margin)")
                    }
                }
            }
        } icon: {
            if withMargin {
                Image(systemName: "hourglass.badge.plus")
            } else {
                Image(systemName: "hourglass")
            }
        }
    }
}

struct DurationView_Previews: PreviewProvider {
    static var previews: some View {
        DurationView(duration: 12.5, withMargin: true)
    }
}

struct DurationSquareView_Previews: PreviewProvider {
    static var previews: some View {
        DurationSquareView(duration: 12.5, withMargin: true, margin: 2)
    }
}
