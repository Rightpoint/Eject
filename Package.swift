import PackageDescription

let package = Package(
  name: "Eject",
  targets: [
    Target(name: "EjectKit"),
    Target(name: "Eject",
      dependencies: [.Target(name: "EjectKit")]),
  ],
  exclude: ["EjectKitTests"]
)
