# CellsReloadable

[![CI Status](https://img.shields.io/travis/dankinsoid/CellsReloadable.svg?style=flat)](https://travis-ci.org/dankinsoid/CellsReloadable)
[![Version](https://img.shields.io/cocoapods/v/CellsReloadable.svg?style=flat)](https://cocoapods.org/pods/CellsReloadable)
[![License](https://img.shields.io/cocoapods/l/CellsReloadable.svg?style=flat)](https://cocoapods.org/pods/CellsReloadable)
[![Platform](https://img.shields.io/cocoapods/p/CellsReloadable.svg?style=flat)](https://cocoapods.org/pods/CellsReloadable)


## Description
This repository provides

## Example

```swift

```
## Usage

 
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/CellsReloadable.git", from: "0.0.1")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["CellsReloadable"])
  ]
)
```
```ruby
$ swift build
```

2.  [CocoaPods](https://cocoapods.org)

Add the following line to your Podfile:
```ruby
pod 'CellsReloadable'
```
and run `pod render` from the podfile directory first.

## Author

dankinsoid, voidilov@gmail.com

## License

CellsReloadable is available under the MIT license. See the LICENSE file for more info.
