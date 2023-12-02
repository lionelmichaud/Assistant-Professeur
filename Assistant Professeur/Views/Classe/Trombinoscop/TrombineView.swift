//
//  TrombineView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/02/2023.
//

import SwiftUI

struct TrombineView: View {
    @ObservedObject
    var eleve: EleveEntity

    var body: some View {
        if eleve.hasImageTrombine {
            Trombine(eleve: eleve)
        } else {
            ZStack(alignment: .center) {
                Text("Glisser une photo ici.")
                    .multilineTextAlignment(.center)
                    .bold()
                Trombine(eleve: eleve)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// struct TrombineView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrombineView()
//    }
// }
