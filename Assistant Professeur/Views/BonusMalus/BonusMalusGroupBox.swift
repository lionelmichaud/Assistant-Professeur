//
//  BonusMalusView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/09/2023.
//

import SwiftUI

/// Affiche les statistiques de Bonus / Malus d'une classe avec ou sans le nom de la classe
struct BonusMalusGroupBox: View {
    let minBonus: Int
    let maxBonus: Int
    let averageBonus: Double
    let showClasse: ClasseEntity?

    var body: some View {
        LabeledContent {
            GroupBox {
                LabeledContent(
                    "Maximum",
                    value: maxBonus,
                    format: .number
                )
                LabeledContent(
                    "Moyenne",
                    value: averageBonus,
                    format: .number.precision(.fractionLength(2))
                )
                LabeledContent(
                    "Minimum",
                    value: minBonus,
                    format: .number
                )
            }
            .frame(maxWidth: 200)
        } label: {
            VStack {
                Label("Bonus / Malus", systemImage: "plusminus")
                    .bold()

                if let showClasse {
                    HStack {
                        Image(systemName: ClasseEntity.defaultImageName)
                            .sfSymbolStyling()
                            .foregroundColor(showClasse.levelEnum.imageColor)
                        Text(showClasse.displayString)
                            .fontWeight(.bold)
                        if showClasse.isFlagged {
                            Image(systemName: "flag.fill")
                                .imageScale(.small)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.top)
                }
            }
        }
    }
}

// struct BonusMalusView_Previews: PreviewProvider {
//    static var previews: some View {
//        BonusMalusView(minBonus: -4, maxBonus: 5, averageBonus: 2.54)
//    }
// }

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return BonusMalusGroupBox(
        minBonus: -4,
        maxBonus: 5,
        averageBonus: 2.54,
        showClasse: ClasseEntity.all().first!
    )
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
