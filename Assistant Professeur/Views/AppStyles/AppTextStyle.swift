//
//  AppTextStyle.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 08/07/2023.
//

import SwiftUI

public extension Text {
    enum AppTextStyle {
        case title
        case rowTitle
        case rowDescription
        case sectionHeader
    }

    func style(_ appStyle: AppTextStyle) -> Text {
        switch appStyle {
            case .title: return title()
            case .rowTitle: return rowTitle()
            case .sectionHeader: return sectionHeader()
            case .rowDescription: return rowDescription()
        }
    }
}

extension Text {
    private func title() -> Text {
        self.font(.title)
            .fontWeight(.bold)
            .foregroundColor(.title)
    }

    private func sectionHeader() -> Text {
        self.font(.callout)
            .fontWeight(.bold)
            .foregroundColor(.sectionHeader)
    }

    private func rowTitle() -> Text {
        self.font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.rowTitle)
    }

    private func rowDescription() -> Text {
        self.font(.subheadline)
            .foregroundColor(.rowDescription)
    }
}
