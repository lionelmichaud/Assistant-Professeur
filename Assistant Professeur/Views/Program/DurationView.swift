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
        Label {
            Text("\(duration.formatted(.number.precision(.fractionLength(1)))) séances")
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
