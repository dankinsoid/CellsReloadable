# CellsReloadable

CellsReloadable provides a streamlined approach to managing table, collection, and stack views in iOS. By eliminating the need for subclassing `UITableViewCell` or `UICollectionViewCell`, the library facilitates a more straightforward process for reloading views. With CellsReloadable, developers can directly use `UIView` or SwiftUI `View` instances, leading to a more modular and efficient UI implementation.

## Some code examples
- Reload with data and `UIView` cells:
```swift
reloader.reload(with: myData) { _ in
    MyCustomUIView()
} render: { view, data in
    view.render(with: data)
}
```
- Reload with props and `RenderableView`:
```swift
reloader.reload(with: myData) {
    MyCustomRenderableView()
}
```
- Reload with cells builder:
```swift
reloader.reload {
  MyCustomUIView.Cell(with: props)
  if someCondition {
    MyCustomSwiftUIView()
  }
  MyCustomStaticUIView.Cell()
}
```
```swift
reloader.reload(with: myData) { data in
    MyCustomSwiftUIView(data)
}
```
```swift
reloader.reload(with: myData) { item in
  switch item.type {
  case let .swiftUICell(props):
    SomeSwiftUIView(props)
      .asViewCell(id: props.id)

  case let .uiKitUICell(props):
    MyCustomUIView.Cell(with: props)
      .height(72)
  }
}
```
```swift
reloader.reload {
  for i in 0..<10 {
    UILabel.Cell(id: i) {
      $0.text = "Item \(i)"
    }
    .height(50)
  }
}
```
- Reload with sections builder:
```swift
reloader.reload {
  CellsSection(data: myData) {
    MyCustomRenderableView()
  }
  .cellsWith(\.height, 72)

  CellsSection(data: myData) {
    SomeSwiftUIView($0)
  }
  .header {
    Text("Header").padding()
  }
}
```

## Description

This library provides reloadable functionality for `UITableView`, `UIStackView`, and `UICollectionView`.

It introduces several types:

- **`ViewCell`**: An identifiable struct to represent a cell within a view.

- **`UIView.Cell` typealias**: A helper typealias to create `ViewCell` inline.
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

These elements come together to provide powerful reloading capabilities to your views. These capabilities are provided through several `reload` functions which take in a closure to generate cells, along with optional parameters to define cell creation, reloading, sizing and identification.

Here are some of the functionalities provided:

- `reload { }`: Reloads the cells in a reloadable view using a closure that creates an array of `ViewCell`, `UIView`, `View`  or`CellsSection`.
- `reload(with data:id:create:render:completion:)`: Reloads the cells in a reloadable view using data, a function to generate unique identifiers, closures for creating and reloading cells, and a closure for sizing cells. `completion` and `id` are optional. `id` parameter is needed only if you want to animate the reload. `render` parameter can be missied if it's a SwiftUI `View` or `RenderableView` view and the `data` is a collection of its `Props`.

These `reload` functions use a variety of parameters to control the reloading of the cells in the view. By utilizing these functions, you can easily manage the cells within your views and ensure they are always up-to-date.

It's recommend to specify an `id` for sections and cells or use `Identifiable` items for correct animations. For SwiftUI views there is a `asViewCell(id:)` method.

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
Example:
```swift
extension MyView.Props: ViewCellConvertible {

  public var asViewCell: ViewCell {
    ViewCell(props: self) {
      MyView()
    }
    .height(70)
    .willReuse(MyView.self) {
      $0.prepareForReuse()
    }
  }
}
```
```swift
reloader.reload {
  MyView.Props(.first)
  MyView.Props(.second)
}
```
```swift
reloader.reload(with: collectionOfProps)
```

## CellsSectionConvertible

Similar to the `ViewCellConvertible` protocol, the `CellsSectionConvertible` protocol allows custom structs representations to be converted directly into `CellsSection` structures. This can be extremely handy when you have predefined section models that you want to integrate seamlessly into your reloadable views.

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
