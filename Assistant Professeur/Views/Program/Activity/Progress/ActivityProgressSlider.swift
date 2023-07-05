//
//  ActivityProgressSlider.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

struct ActivityProgressSlider: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    var body: some View {
        Slider(
            value: $progress.progress,
            in: 0 ... 1,
            step: 0.25
        ) {
            Text("Progression")
        } minimumValueLabel: {
            Text("")
        } maximumValueLabel: {
            Text("Fin")
        } onEditingChanged: { editing in
            if !editing {
                try? ActivityProgressEntity.saveIfContextHasChanged()
            }
        }
        .tint(.mint)
        .padding(6)
        .background(
            Capsule().stroke(Color.mint, lineWidth: 2)
        )
    }
}

struct ActivityProgressSlider_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    /// Liste des activités suivies par cette classe
    static func sequences(classe: ClasseEntity) -> [SequenceEntity] {
        let sortComparators = [
            SortDescriptor(\SequenceEntity.viewNumber, order: .forward)
        ]

        var sequences = [SequenceEntity]()

        classe.allProgresses.forEach { progress in
            if let sequence = progress.activity?.sequence,
               !sequences.contains(sequence) {
                sequences.append(sequence)
            }
        }
        return sequences.sorted(using: sortComparators)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first!
        let progress = classe.allProgresses.first!
        return Group {
            List {
                ActivityProgressSlider(progress: progress)
            }
            .padding()
            .previewDevice("iPad mini (6th generation)")
            List {
                ActivityProgressSlider(progress: progress)
            }
            .padding()
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
