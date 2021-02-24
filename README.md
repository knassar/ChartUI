# ChartUI

A pure-SwiftUI lightweight charting library.

This project has the following goals:

1. **Adhere to SwiftUI API paradigms**: Be as "SwiftUI-native" as possible, not just in implementation purity, but also in "feel". Supports discoverability through Xcode Library.
2. **Customization via Composition**: Provide a rich toolbox of highly-composable elements.
3. **Maximize Type-fidelity throughout the API**: Specify chart properties in data-terms, to minimize conversions from data-space to chart-space  
4. **Make Pretty (and Useful!) Charts** 

Currently supports 4 chart types: 
    
|                  | Rectangular | Radial                 |
|------------------|-------------|------------------------|
| Categorized data | `BarChart`  | `PieChart` <br> `RingChart` |
| Ordered data     | `LineChart` |                        |

Categorized data charts gracefully animate value changes when you replace their data series, as long as the category Ids remain consistent.

Ordered data charts gracefully animate changes to their visible X boundaries.

## Data

At the heart of each chart is a `DataSeries`, which is initialized with an array of values conforming to either `OrderedDatum`, or `CategorizedDatum` protocols. The datum protocol determines which charts are available.

ChartUI preserves the original types of the supplied data as deeply as possible, allowing charts to be defined in terms of the underlying types. For example, if creating a chart of "Temperature over Time", you can create a `LineChart` whose x-axis is of type `Date` and y-axis is `Temperature`. This allows you to specify visual elements such as the axes grids, visualization ranges, etc, in terms of `Date` and `Temperature` and the chart will automatically scale appropriately based on its computed SwiftUI layout. 

### Conforming to `Datum`-related Protocols 

Consuming code should never conform types directly to `Datum`, instead, chose one of `OrderedDatum` or `CategorizedDatum` to conform to. The specific protocol chosen depends on the nature of the data involved and the desired visualization.

- `OrderedDatum` holds an X & Y value, suitable for plotting Ys over Xs. This type can be visualized in a `LineChart` 
- `CategorizedDatum` holds a Value indexed by an Id, suitable for plotting Values by Index. This type can be visualized in a `BarChart`, `PieChart`, or `RingChart`.

Certain use-cases of both `OrderedDatum` and `CategorizedDatum` are so common, that ChartUI has two built-in concrete conformances of these protocols made to be very easy to use out of the box:

- `TimeSeriesDatum` is an `OrderedDatum`-conforming concrete type providing a `Date` X-axis and a generic Y axis, designed for graphing some `DataValue` over time in a `LineChart`
- `IdentifiedValueDatum` is a `CategorizedDatum`-conforming concrete type generic over `Id` and `DataValue` properties in any categorized data chart such as a `BarChart` or `PieChart`

While you are certainly free to build your own conformances to either datum type, these should be sufficient for most uses.

### Example: "Temperature over Time"

Suppose we want to display a `LineChart` titled "Temperature over Time". Because we're charting a Y over an X, we want an `OrderedDatum`. We could create our own conforming type with `Date` & `Temperature` as `X` and `Y` types respectively, but `TimeSeriesDatum` already provides everything we need. We'll plug our `Temperature` type into this to build our data series.  

The first step is to conform our data types to `DataValue`. Suppose we have a `Temperature` value type:

```
struct Temperature {
    var celsius: Double
    var fahrenheit: Double {
        celsius * 1.8 + 32
    }
}
```

To conform to `DataValue`, we need to specify the type's `dataSeriesValue` (as a `CGFloat`) and an absolute min and max. For the `dataSeriesValue`, we could choose either `celsius` or `fahrenheit`, or even make that choice dependent on some input (an exercise left to the reader).

```
extension Temperature: DataValue {
    var dataSeriesValue: CGFloat { 
        CGFloat(celsius) 
    }
    static var absoluteMinimum: Self { 
        Temperature(celsius: -273.15) // absolute zero
    }
    static var absoluteMaximum: Self { 
        Temperature(celsius: .greatestFiniteMagnitude) 
    }
}
```

And since `DataValue` requires `Comparable` conformance, we need to add that too:

```
extension Temperature: Comparable {
    static func < (lhs: Temperature, rhs: Temperature) -> Bool {
        lhs.celsius < rhs.celsius
    }
}
```

Once `Temperature` conforms to `DataValue` we can use it as the `Value` in `TimeSeriesDatum`:

```
func dataSeries(for timeTemp: [Date: Temperature]) -> DataSeries<TimeSeriesDatum<Temperature>> {

    DataSeries(data: timeTemp.map { TimeSeriesDatum.point($0.value, at: $0.key) } )

}
```

And we can now create a `LineChart` in our view displaying our "temperature over time" data:

```
var tempsOverTime: [Date: Temperature]

var body: some View {
    VStack {
        Text("Temperature Over Time")
        LineChart(data: dataSeries(for: tempsOverTime))
    }
}
```

## Decorators 

ChartUI provides a variety of views called _Decorators_ which, when composed with a given chart, can create rich visualizations.  In ChartUI, a `Decorator` is a SwiftUI `View` which gains access to the computed chart-specific layout during rendering, allowing it to position highlights, annotations, and other "decorations" in alignment to data points represented by the chart.

Decorators are declared in either the `underlay` or `overlay` initialization arguments of the chart view, and can be configured via modifiers either directly, or through standard SwiftUI modifier inheritance rules. As the names imply, "underlay" decorators are rendered in a `ZStack` below the chart, and "overlay" decorators are rendered over the chart, allowing you direct control over the final look of your chart.

Some built-in decorators available are:

- `Origin` marks either or both of the X & Y origins within a rectangular chart 
- `PointHighlight` for indicating data points of interest in a `LineChart`
- X & Y axis markers (`XAxisMarker`, `YAxisMarker`) for indicating data points of interest in a rectangular chart along the axes
- X & Y range markers (`XAxisRange`, `YAxisRange`) for indicating value regions of interest in a rectangular chart

The Decorators API is also public and extensible, so you can create your own decorators, if needed.

### Note

Markings for X & Y grids for rectangular charts, and chart Legends for categorized charts are actually implemented internally as decorators. They are special-cased because it generally doesn't make sense to include multiples of these in a single chart, so they are activated & configured by dedicated modifier methods. 

### Using Decorators

To continue on with our example, suppose we want to highlight certain ranges of temperatures in our chart, and also any points which fall within these ranges. We can do this by adding decorators. For this example, we'll add `YAxisRange` and `PointHighlight` decorators to our chart. We'll also use some of ChartUI's view modifiers to add grids and insets to refine our presentation: 

```
var tempsOverTime: [Date: Temperature]

let tooHot = Temperature(celsius: 32) 

let tooCold = Temperature(celsius: 18) 

var data: DataSeries<TimeSeriesDatum<Temperature>> {
    dataSeries(for: tempsOverTime)
}

var body: some View {
    VStack {
        Text("Temperature Over Time")
        LineChart(data: data, underlay: ZStack {
            // mark the range below which is too cold for comfort
            YAxisRange(...tooCold)
                .rectChartRange(fill: Color.blue.opacity(0.2))
                .rectChartRange(stroke: .blue)
            
            // mark the range above which is too hot for comfort
            YAxisRange(tooHot...)
                .rectChartRange(fill: Color.orange.opacity(0.2))
                .rectChartRange(stroke: .orange)
        }, overlay: ZStack {
            // mark all points in the dataset with a dot
            PointHighlight(appliesTo: .all)
        
            // circle all points in the "comfort" zone in green
            PointHighlight(appliesTo: data.allY(where: { (tooCold...tooHot).contains($0) }))
                .chartPointHighlight(radius: 8)
                .chartPointHighlight(fill: nil)
                .chartPointHighlight(stroke: .green)
                .chartPointHighlight(strokeWidth: 2)
        })
        // set an X grid with a line for each day, "zero"-ed on today
        .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
        
        // set a Y grid with a line for every 10 degrees
        .rectChart(yAxisGrid: YAxisGrid(spacing: Temperature(celsius: 10)))
        
        // inset all edges of the chart by 20 points
        .chartInsets(.all, 20)
    }
}
```

If this is starting too look too complicated, remember that all Decorators and modifiers in ChartUI follow SwiftUI patterns, so you can use the same strategies for extracting to subviews, scoping of modifiers, and bundling modifiers into custom methods that you would use with any SwiftUI view. 

## Interactions

`LineChart` supports an interactive scroll over the absolute extents of the data. Activate scrolling using either the `lineChart(scrollEnabled:)` or `lineChart(scrollOffset:enabled:)` modifiers. The first activates and deactivates scrolling. With the second, you can activate scrolling in a line chart and bind the scroll offset to the provided `scrollOffset` binding. This can be used to observe the scroll position, or integrate the scroll interaction with other views, including the `MiniMap` interactive view, as in the following example:

```
@State
var xRange: Range<Date> = .previousWeek

@State
var scroll: CGFloat = 1

var body: some View {
    VStack {
        
        // Read-out the scroll position in real-time
        Text("scrolled to: \(scroll)")
            .font(.caption)

        // Creates a mini-map interactive navigation with a "scroll thumb" linked to the main chart below
        MiniMap(data: myDataSeries, xRange: xRange, scrollOffset: $scroll) 
            .frame(height: 24)

        LineChart(data: myDataSeries, trimmedTo: xRange)
        
            // Activates scrolling and associates with the scroll state property
            .lineChart(scrollOffset: $scroll)
    
            .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
            .rectChart(yAxisGrid: YAxisGrid(origin: 0, spacing: 10))
            .frame(height: 160)
    }
}
```

## Future Goals

Some things I want to achieve (and/or have plans for), in no particular order: 

* Performant "lazy" rendering of very large data sets in `LineChart`
* Multiple-DataSet support for all chart types
* Interactions
  - Data Loupe
  - Navigation Links
  - Custom Actions
* Unit testing for the Data & Layout layers

I welcome pull-requests for improvements and bug-fixes, but please reach out to me or discuss in the Issues thread prior to diving in to something to make sure it's not something I'm actively working on.
