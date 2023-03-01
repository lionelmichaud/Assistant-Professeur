//
//  IndicatorImageView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 01/03/2023.
//

import SwiftUI

struct IndicatorImageView: View {
    var name: String
    var size: Int
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.white)
                .overlay(Image(name)
                    .resizable()
                    .frame(width: CGFloat(size) * 4 / 5, height: CGFloat(size) * 4 / 5))
                .frame(width: CGFloat(size), height: CGFloat(size))
        }
    }
}

struct IndicatorImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                IndicatorImageView(
                    name: "record.circle.fill",
                    size: 40
                )
                IndicatorImageView(
                    name: "record.circle.fill",
                    size: 30
                )
                IndicatorImageView(
                    name: "record.circle.fill",
                    size: 20
                )
            }
            HStack {
                IndicatorImageView(
                    name: "inProgress",
                    size: 40
                )
                IndicatorImageView(
                    name: "inProgress",
                    size: 30
                )
                IndicatorImageView(
                    name: "inProgress",
                    size: 20
                )
            }
            HStack {
                IndicatorImageView(
                    name: "checkmark.circle.fill",
                    size: 40
                )
                IndicatorImageView(
                    name: "checkmark.circle.fill",
                    size: 30
                )
                IndicatorImageView(
                    name: "checkmark.circle.fill",
                    size: 20
                )
            }
            HStack {
                IndicatorImageView(
                    name: "questionmark.circle.fill",
                    size: 40
                )
                IndicatorImageView(
                    name: "questionmark.circle.fill",
                    size: 30
                )
                IndicatorImageView(
                    name: "questionmark.circle.fill",
                    size: 20
                )
            }
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
        //        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
