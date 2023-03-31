//
//  ClassCapsule.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/03/2023.
//

import SwiftUI

struct ClassCapsule: View {
    let classe: ClasseEntity

    var body: some View {
        Text("\(classe.displayString)")
            .filledCapsuleStyling(
                withBackground: true,
                withBorder: true,
                fillColor: .blue1
            )
    }
}

//struct ClassCapsule_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassCapsule()
//    }
//}
