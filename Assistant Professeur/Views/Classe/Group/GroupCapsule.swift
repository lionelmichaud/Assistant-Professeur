////
////  GroupCapsule.swift
////  Assistant Professeur
////
////  Created by Lionel MICHAUD on 31/03/2023.
////
//
//import HelpersView
//import SwiftUI
//
//struct GroupCapsule: View {
//    let group: GroupEntity
//
//    var body: some View {
//        Text("\(group.displayString)")
//            .filledCapsuleStyling(
//                withBackground: true,
//                withBorder: true,
//                fillColor: .blue4
//            )
//    }
//}
//
//struct GroupCapsule_Previews: PreviewProvider {
//    static func initialize() {
//        CoreDataManager.storeType = .inMemory
//        GroupEntity.create(numero: 16, dans: nil)
//    }
//
//    static var previews: some View {
//        initialize()
//        return GroupCapsule(group: GroupEntity.all().first!)
//            .environment(\.managedObjectContext, CoreDataManager.shared.context)
//    }
//}
