# CellsReloadable

CellsReloadable revolutionizes how you interact with table, collection, and stack views in iOS. Say goodbye to the cumbersome process of subclassing `UITableViewCell` or `UICollectionViewCell`. This library offers a seamless method to reload your views, empowering you to use direct `UIView` or SwiftUI `View` instances. Streamline your UI implementation and enjoy a cleaner, more efficient approach with CellsReloadable.

## Some code examples
- Reload with array and homogeneous `UIView` cells:
```swift
reloader.reload(with: myData) { _ in
    MyCustomUIView()
} render: { view, data in
    view.render(with: data)
}
```
- Reload with array and homogeneous `View` cells:
```swift
reloader.reload(with: myData) { data in
    MyCustomSwiftUIView(data)
}
```
- Reload with array and homogeneous `RenderableView`:
```swift
reloader.reload(with: myData) { props in
    MyCustomRenderableView(props)
}
```
- Reload with static cells:
```swift
reloader.reload {
  ViewCell {
    MyCustomUIView()
  } update: { view in
    view.render(with: props)
  }
  if someCondition {
    ViewCell {
      MyCustomSwiftUIView()
    }
  }
  ViewCell {
    MyCustomUIView()
  }
}
```
- Reload with array and heterogeneous cells:
```swift
reloader.reload {
  for item in myData {
    switch item.type {
    case let .swiftUICell(props):
      ViewCell(id: props.id) {
        SomeSwiftUIView(props)
      }

    case let .uiKitUICell(props):
      ViewCell(id: props.id) {
        MyCustomUIView()
      } render: {
        $0.render(with: props)
      }
      .with(\.height, 72)
    }
  }
}
```
- Reload sections:
```swift
reloader.reloadSections {
  CellsSection(data: myData) { _ in
    MyCustomRenderableView()
  }
  .cellsWith(\.height, 72)

  CellsSection(data: myData) {
    SomeSwiftUIView($0)
  }
  .with(
    \.header,
    ViewCell {
      Text("Header").padding()
    }
  )
}
```

## Description

This library provides reloadable functionality for `UITableView`, `UIStackView`, and `UICollectionView`.

It introduces several types:
- **`ViewCell`**: An identifiable struct to represent a cell within a view.
- [**`UITableViewReloader`**](#UITableViewReloader): A class to bypass the traditional datasource methods when working with a `UITableView`.
- [**`UICollectionViewReloader`**](#UICollectionViewReloader): A class to bypass the traditional datasource methods when working with a `UICollectionView`.
- **`ViewCellsReloadable`**: A protocol to mark a view as having reloadable cells. Implemented by `UITableViewReloader`, `UIStackView`, and `UICollectionViewReloader`.
- [**`ViewCellConvertible`**](#ViewCellConvertible): An Identifiable struct to represent a cell within a view.
- **`ViewCellsBuilder`**: An enum to assist in building cells.
- **`CellsSectionsReloadable`**: A protocol for views that have reloadable sections. Implemented by `UITableViewReloader`, `UICollectionViewReloader` and `UIStackView`.
- **`CellsSection`**: An identifiable struct to represent a section of cells.
- [**`CellsSectionConvertable`**](#CellsSectionConvertable): A protocol to convert custom structs into `CellsSection` structures.
- **`CellsSectionsBuilder`**: An enum to aid in building sections of cells.
- [**`RenderableView`**](#RenderableView): A convenince protocol to denote views that are capable of rendering content dynamically.
- [**`ReuseableView`**](#ReuseableView): A protocol to streamline the process of preparing views for reuse.

These elements come together to provide powerful reloading capabilities to your views. These capabilities are provided through several `reload` functions which take in a closure to generate cells, along with optional parameters to define cell creation, reloading, sizing and identification.

Here are some of the functionalities provided:

- `reload { }`: Reloads the cells in a reloadable view using a closure that creates an array of `ViewCell`, `UIView` or `View`.
- `reload(with data:id:create:render:completion:)`: Reloads the cells in a reloadable view using data, a function to generate unique identifiers, closures for creating and reloading cells, and a closure for sizing cells. `completion` and `id` are optional. `id` parameter is needed only if you want to animate the reload. `render` parameter can be missied if it's a SwiftUI `View` or `RenderableView` view and the `data` is a collection of its `Props`.
- `reloadSections {}`: Reloads the sections in a reloadable view.

These `reload` functions use a variety of parameters to control the reloading of the cells in the view. By utilizing these functions, you can easily manage the cells within your views and ensure they are always up-to-date.

## UITableViewReloader

`UITableViewReloader` is a class that eliminates the need to work with the traditional datasource. It allows you to directly deal with the data and the cell that should be displayed. With this feature, you don't have to subclass `UITableViewCell`. Instead, you can directly use `UIView` instances and make your codebase simpler and cleaner.

Here’s an example:

```swift
lazy var tableSource = UITableViewReloader(tableView)
let tableView = UITableView()

tableSource.reload(with: myData) { _ in
    MyCustomView()
} render: { view, data in
    view.render(with: data)
}
```

It's recommend to make items `Identifiable` for correct animations.
This significantly reduces the boilerplate code traditionally associated with setting up table views.

## UICollectionViewReloader

Similar to `UITableViewReloader`, `UICollectionViewReloader` is an extension that allows you to bypass the traditional datasource and delegate methods when working with a `UICollectionView`. You don't have to subclass `UICollectionViewCell`. You can directly use `UIView` instances and simply bind them to the data you want to display.

Here’s an example:

```swift
lazy var collectionSource = UICollectionViewReloader(collectionView)
let collectionView = UICollectionView()

collectionSource.reload(with: myData) { _ in
    MyCustomView()
} render: { view, data in
    view.configure(with: data)
}
```

It's recommend to make items `Identifiable` for correct animations.

## ViewCell

`ViewCell` is a structure that acts as a representation of a cell within a view. The main purpose of `ViewCell` is to provide an abstraction layer over traditional cells, allowing you to work directly with `UIView` instances rather than dealing with the overhead of subclassing specific cell classes.

### ViewCell.Values:

A dynamic container that lets you add custom stored properties to the struct. This can be beneficial for adding extra functionalities like custom layouts, behaviors, or even metadata associated with the cell.\
Example of extending `ViewCell.Values`:
```swift
extension ViewCell.Values {
  
  var style: CellStyle {
    self[\.style] ?? .default
  }
}
```
Example of setting the style:
```swift
ViewCell {
  SomeCell()
}
.with(\.style, .warning)
```

## CellsSection

`CellsSection` is a structure designed to represent a section of cells within views that support sectioned layouts, like `UITableView` and `UICollectionView`. 

### CellsSection.Values:
Similar to the `ViewCell.Values`, this dynamic container allows you to add custom stored properties to the struct. This could be particularly useful when you want to introduce properties such as headers, footers, or specific layouts for a given section.

## RenderableView

The `RenderableView` protocol is used to denote views that are capable of rendering content dynamically.\
Views conforming to this protocol should implement a method to render their content based on the supplied data.

## ViewCellConvertible

The `ViewCellConvertible` protocol can be adopted by custom structs to provide a mechanism to convert them into `ViewCell` structures. This aids in integrating custom structs directly into reloadable views without the need for `ViewCell` wrapping.

## CellsSectionConvertible

Similar to the `ViewCellConvertible` protocol, the `CellsSectionConvertible` protocol allows custom structs representations to be converted directly into `CellsSection` structures. This can be extremely handy when you have predefined section models that you want to integrate seamlessly into your reloadable views.

## ReusableView

The `ReusableView` protocol is introduced to streamline the process of preparing views for reuse, especially in the context of `UITableView` and `UICollectionView`.\
Views that adopt this protocol need to implement the `prepareForReuse()` method. This method should reset the view to its default state and clear out any data or configurations that were set for the previous content.\
For `UICollectionView` there is a native `UICollectionReusableView` that can be used as well in `UICollectionViewReloader`.

## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/CellsReloadable.git", from: "1.1.1")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["CellsReloadable"])
  ]
)
```
```ruby
$ swift build
```

## Author

dankinsoid, voidilov@gmail.com

## License

CellsReloadable is available under the MIT license. See the LICENSE file for more info.
