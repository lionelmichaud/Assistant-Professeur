//
//  ClassRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/04/2022.
//

import HelpersView
import SwiftUI

struct ClasseBrowserRow: View {
    @ObservedObject
    var classe: ClasseEntity

    private var regularRow: some View {
        HStack {
            // Nombre d'heures de cours
            Image(systemName: "clock")
                .padding(.leading)
            Text("\(classe.heures.formatted(.number.precision(.fractionLength(1)))) heures")
                .foregroundStyle(.secondary)
            Spacer()

            // Avertissements
            ClasseColleLabel(
                nbCollesNonNotifee: classe.nbOfColles(isConsignee: false),
                imageScale: .medium,
                withLabel: true
            )
            ClasseObservLabel(
                nbObservNonNotifee: classe.nbOfObservations(
                    isConsignee: false,
                    isVerified: false
                ),
                imageScale: .medium,
                withLabel: true
            )
        }
    }

    private var compactRow: some View {
        HStack {
            Spacer()

            // Avertissements
            ClasseColleLabel(
                nbCollesNonNotifee: classe.nbOfColles(isConsignee: false),
                imageScale: .medium,
                withLabel: false
            )
            ClasseObservLabel(
                nbObservNonNotifee: classe.nbOfObservations(
                    isConsignee: false,
                    isVerified: false
                ),
                imageScale: .medium,
                withLabel: false
            )
        }
    }

    var body: some View {
        HStack {
            // Classe
            Image(systemName: ClasseEntity.defaultImageName)
                .sfSymbolStyling()
                .foregroundColor(classe.levelEnum.imageColor)
            Text(classe.displayString)
                .fontWeight(.bold)
            if classe.isFlagged {
                Image(systemName: "flag.fill")
                    .imageScale(.small)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "flag.fill")
                    .imageScale(.small)
                    .foregroundColor(.orange)
                    .hidden()
            }

            // Nombre d'élèves
            Text("\(classe.nbOfEleves) élèves")
                .foregroundStyle(.secondary)
                .frame(width: 75)
                .padding(.leading)

            ViewThatFits {
                regularRow
                compactRow
            }
        }
    }
}

// struct ClassRow_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            List {
//                ClasseBrowserRow(classe: ClasseEntity.all().first!)
//            }
//            .padding()
//            .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//            .environment(\.managedObjectContext, CoreDataManager.shared.context)
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                ClasseBrowserRow(classe: ClasseEntity.all().first!)
//            }
//            .padding()
//            .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//            .environment(\.managedObjectContext, CoreDataManager.shared.context)
//            .previewDevice("iPhone 13")
//        }
//    }
// }

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return List {
        ClasseBrowserRow(classe: ClasseEntity.all().first!)
            .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }.padding(.horizontal)
}
