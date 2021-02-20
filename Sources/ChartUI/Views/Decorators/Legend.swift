//
//  Legend.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// A style descriptor for a chart legend
public protocol LegendStyle {

    /// A function to provide localized names for individual datums
    var nameMapper: LegendNameMapper? { get }

    /// The font to use for legend labels
    var font: Font? { get }

    /// The foreground color to use for legend labels
    var foregroundColor: Color? { get }

}

extension LegendStyle {

    func name(for datum: AnyCategorizedDatum) -> String? {
        switch (nameMapper, datum.id) {
        case let (.some(mapper), _):
            return mapper(datum)
        case let (.none, id as String):
            return id
        case let (.none, id as CustomStringConvertible):
            return id.description
        default:
            return nil
        }
    }

}

/// A function which takes a datum and returns a localized string suitable for use in a chart legend
/// - Parameter datum: An `AnyCategorizedDatum`
/// - Returns A localized string, or nil
public typealias LegendNameMapper = (_ datum: AnyCategorizedDatum) -> String?

/// A style descriptor for legends which are distinct from the chart data.
///
/// Typically rendered with a label for the data category, and color swatch matching the represented data segments
public protocol StandAloneLegendStyle: LegendStyle {

    /// Where to position the legend relative to the chart
    var position: Alignment { get }

    /// How to layout the legend items
    var orientation: LegendOrientation { get }

    /// The size of the color swatches
    var swatchSize: CGSize? { get }

}

/// The orientation of entries in a legend
public enum LegendOrientation {
    case horizontal, vertical
}

public struct DefaultLegendStyle: StandAloneLegendStyle {

    public var position: Alignment
    public var orientation: LegendOrientation
    public var font: Font?
    public var foregroundColor: Color?
    public var swatchSize: CGSize?
    public var nameMapper: LegendNameMapper?

    public init(position: Alignment = .leading,
                orientation: LegendOrientation = .vertical,
                font: Font? = nil,
                foregroundColor: Color? = nil,
                swatchSize: CGSize? = CGSize(width: 16, height: 16),
                nameMapper: LegendNameMapper? = nil
    ) {

        self.position = position
        self.orientation = orientation
        self.font = font
        self.foregroundColor = foregroundColor
        self.swatchSize = swatchSize
        self.nameMapper = nameMapper
    }
    
}

public struct InlineLegendStyle: LegendStyle {

    public var font: Font?
    public var foregroundColor: Color?
    public var nameMapper: LegendNameMapper?

    public init(
        font: Font? = nil,
        foregroundColor: Color? = nil,
        nameMapper: LegendNameMapper? = nil
        ) {
        self.font = font
        self.foregroundColor = foregroundColor
        self.nameMapper = nameMapper
    }

}

struct StandAloneLegend: View {

    var legendStyle: StandAloneLegendStyle

    @Environment(\.chartLayout)
    var chartLayout: ChartLayout

    @Environment(\.categorizedDataStyle)
    var style: CategorizedDataStyle

    var body: some View {
        ZStack(alignment: legendStyle.position) {
            switch legendStyle.orientation {
            case .vertical:
                vertical {
                    legendContent
                }
            case .horizontal:
                horizontal {
                    legendContent
                }
            }
        }
        .frame(width: chartLayout.localFrame.size.width, height: chartLayout.localFrame.size.height)
    }

    private var legendContent: some View {
        ForEach(style.data.categorizedData, id: \.index) { datum in
            row(for: datum)
        }
    }

    private func vertical<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        HStack {
            spacer(if: HorizontalAlignment.trailing)
            VStack(alignment: .leading, spacing: 2) {
                spacer(if: VerticalAlignment.bottom)
                content()
                spacer(if: VerticalAlignment.top)
            }
            spacer(if: HorizontalAlignment.leading)
        }
        .padding(.all, 8)
    }

    private func horizontal<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        VStack {
            spacer(if: VerticalAlignment.bottom)
            HStack(alignment: .center, spacing: 4) {
                spacer(if: HorizontalAlignment.trailing)
                content()
                spacer(if: HorizontalAlignment.leading)
            }
            spacer(if: VerticalAlignment.top)
        }
        .padding(.all, 8)
    }

    private func row(for datum: AnyCategorizedDatum) -> some View {
        HStack {
            if let swatchSize = legendStyle.swatchSize {
                style.fill(for: datum)
                    .frame(width: swatchSize.width, height: swatchSize.height)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(style.stroke(for: datum), lineWidth: 1))
            }
            if let name = legendStyle.name(for: datum) {
                Text(name)
                    .font(legendStyle.font ?? .caption)
                    .foregroundColor(legendStyle.foregroundColor ?? .black)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .font(.caption)
    }

    private func spacer(if alignment: Any) -> Spacer? {
        switch alignment {
        case let horizontal as HorizontalAlignment where legendStyle.position.horizontal == horizontal:
            return Spacer()
        case let vertical as VerticalAlignment where legendStyle.position.vertical == vertical:
            return Spacer()
        default:
            return nil
        }
    }

}

struct Legend_Previews: PreviewProvider {

    static let data = sampleQuarters

    static func legend(at position: Alignment = .leading, in orientation: LegendOrientation = .vertical) -> some View {
        GeometryReader { geometry in
            RadialChartLayoutComposer(data: data, geometry: geometry) {
                RadialLegend()
                    .chartLegend(style: DefaultLegendStyle(position: position, orientation: orientation, swatchSize: CGSize(width: 16, height: 16)))
            }
        }
        .border(Color.gray)
    }

    static var previews: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                legend(at: .topLeading)
                legend(at: .top)
                legend(at: .topTrailing)
            }
            HStack(spacing: 8) {
                legend(at: .leading)
                legend(at: .center)
                legend(at: .trailing)
            }
            HStack(spacing: 8) {
                legend(at: .bottomLeading)
                legend(at: .bottom)
                legend(at: .bottomTrailing)
            }
            VStack(spacing: 8) {
                legend(at: .topLeading, in: .horizontal)
                legend(at: .top, in: .horizontal)
                legend(at: .topTrailing, in: .horizontal)

                legend(at: .leading, in: .horizontal)
                legend(at: .center, in: .horizontal)
                legend(at: .trailing, in: .horizontal)

                legend(at: .bottomLeading, in: .horizontal)
                legend(at: .bottom, in: .horizontal)
                legend(at: .bottomTrailing, in: .horizontal)
            }
                .frame(height: 400)
        }
        .padding(.all)
    }
}
