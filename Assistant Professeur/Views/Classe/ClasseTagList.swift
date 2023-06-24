//
//  ClasseTagList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/06/2023.
//

import SwiftUI
import TagKit

struct LevelTag : View {
    let level: LevelClasse
    var font: Font = .callout

    var body: some View {
        TagCapsule(
            tag: level.displayString,
            style: .levelTagStyle(level: level)
        )
        .font(font)
        .bold()
    }
}

struct ClasseTag: View {
    let classe: ClasseEntity
    var font: Font = .callout

    var body: some View {
        TagCapsule(
            tag: classe.displayString,
            style: .classeTagStyle
        )
        .font(font)
    }
}

struct ClasseTagList: View {
    let classes: [ClasseEntity]
    var font: Font = .callout

    var body: some View {
        TagList(
            tags: classes.map { $0.displayString },
            container: .scrollView,
            horizontalSpacing: 4,
            verticalSpacing: 4,
            tagView: { tag in
                TagCapsule(
                    tag: tag,
                    style: .classeTagStyle
                )
                .font(font)
            }
        )
    }
}

struct ClasseTagList_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseTagList(classes: [ClasseEntity.all().first!])
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseTagList(classes: [ClasseEntity.all().first!])
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
