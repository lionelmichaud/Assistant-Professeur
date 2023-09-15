//
//  SchoolBonusMalusList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/09/2023.
//

import SwiftUI

struct SchoolBonusMalusList: View {
    @ObservedObject
    var school: SchoolEntity

    var body: some View {
        ForEach(school.classesSortedByLevelNumber) { classe in
            BonusMalusGroupBox(
                minBonus: classe.minBonus,
                maxBonus: classe.maxBonus,
                averageBonus: classe.averageBonus,
                showClasse: classe
            )
        }
    }
}

//struct SchoolBonusMalusList_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolBonusMalusList()
//    }
//}
