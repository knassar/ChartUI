//
//  ColorSet.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// A source for sequential access to a set of colors for use in categorized charts
public protocol ColorSet {

    /// Produce or return a color for a given index.
    ///
    /// This method must always return the same color for a given index, as it may be called more than once for a given index within a single chart render pass.
    /// This allows chart segments and legend swatches to share a common fill color, for example.
    ///
    /// Any implementation using a finite array as the color source must take measures to avoid trapping on overflows, since the size of chart data cannot be known in advance, which is why this protocol is not satisfied by a simple `Array<Color>`.
    /// - Parameters:
    ///   - index: An index.
    /// - Returns: A color consistently assigned to the given index
    func color(at index: Int) -> Color

}

/// A basic ColorSet which supplies a large set of randome colors based on a seed-string, which repeat eventually
public struct BasicColorSet: ColorSet {

    public func color(at index: Int) -> Color {
        let seed = "4a4df675f6932bcd5790d0956ce51a52b70ccf4e5ebdc84ac29f9aa1b5ff383f"
        return color(String(seed.dropFirst(index % (seed.count - 4)).prefix(3)))
    }

    private func color(_ hex: String) -> Color {
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r: UInt64 = (int >> 8) * 17
        let g: UInt64 = (int >> 4 & 0xF) * 17
        let b: UInt64 = (int & 0xF) * 17
        return Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }

}

/// A ColorSet which repeats over a finite set of colors supplied at initialization.
public struct RepeatingColorSet: ColorSet {

    public let colors: [Color]

    public init(colors: [Color]) {
        self.colors = colors
    }

    public func color(at index: Int) -> Color {
        colors[index % colors.count]
    }

}

struct ColorSet_Previews: PreviewProvider {
    static var previews: some View {
        let color = BasicColorSet()
        let ii = (0..<300).map { $0 }
        ScrollView {
            VStack(spacing: 1) {
                ForEach(ii, id: \.self) { index in
                    ZStack {
                        color.color(at: index)
                        HStack {
                            Text(color.color(at: index).description)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 20)
                }
            }
        }
    }
}
