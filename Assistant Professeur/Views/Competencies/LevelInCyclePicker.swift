//
//  CyclePicker.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI

struct LevelInCyclePicker: View {
    @Binding
    var selectedLevel: LevelClasse

    let inCycle: Cycle

    var body: some View {
        Picker(
            "Niveau",
            selection: $selectedLevel
        ) {
            ForEach(inCycle.associatedLevels, id: \.self) { level in
                Text(level.pickerString)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct CyclePicker_Previews: PreviewProvider {
    static var previews: some View {
        LevelInCyclePicker(
            selectedLevel: .constant(.n4ieme),
            inCycle: .cycle4
        )
    }
}
