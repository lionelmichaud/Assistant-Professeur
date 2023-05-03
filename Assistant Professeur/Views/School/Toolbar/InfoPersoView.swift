//
//  InfoPersoView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/05/2023.
//

import SwiftUI
import HelpersView

struct InfoPersoView: View {
    var body: some View {
        GroupBox {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        } label: {
            Text("Infos personnelles")
                .textCase(.uppercase)
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue4))
        }
        .padding()
        .verticallyAligned(.top)
    }
}

struct InfoPersoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InfoPersoView()
                .previewDevice("iPad mini (6th generation)")
            InfoPersoView()
                .previewDevice("iPhone 13")
        }
    }
}
