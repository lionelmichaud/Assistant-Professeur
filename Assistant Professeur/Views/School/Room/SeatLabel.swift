//
//  SeatLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/10/2022.
//

import SwiftUI

struct SeatLabel: View {
    var label : String?
    var backgoundColor = Color.blue

    private let foregoundColor = Color.white

    var body: some View {
        Group {
            if let label {
                Text(label)
                    .foregroundColor(foregoundColor)
                    .font(.callout)
            } else {
                Text("Positionner")
                    .foregroundColor(foregoundColor)
                    .font(.callout)
            }
        }
        .padding(2)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(backgoundColor)
        }
    }
}

struct Place_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SeatLabel(label: "Une place")
                .previewLayout(.fixed(width: 400, height: 400))
            SeatLabel(label: nil)
                .previewLayout(.fixed(width: 400, height: 400))
        }
    }
}
