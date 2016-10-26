# Eject

Eject is a utility to transition from Interface Builder to programatic view layout. This is done by using code generation to create a `.swift` file to replace the view hierarchy managed by the `.xib` file.

## Why?
One common pain point with Interface Builder is that as a view becomes more dynamic and is managed more programatically, Interface Builder becomes less helpful. This tool lets developers use Interface Builder without that concern, giving them an Eject button to hit when Interace Builder starts getting in the way, and provides an easy path to transition to full programatic view layout.

### But But
Yes, I understand that this is probably a bad idea. But it might not be.


### Features

 - UIKit `.xib` support
 - Constraints (using [Anchorage](https://github.com/Raizlabs/Anchorage/))
 - Outlet and OutletCollection support
 - Good variable names
   - Use the user entered "user label" if present
   - Snake case of the className with the namespace removed
   - Constraint variable names are long, but descriptive, (labelBottomEqualToButtonTop)
 - Code that compiles out of the box is a non-goal
   - Will not generate `view1`, `view2` variable names to avoid compile errors. Supply user labels and re-generate.

### Does it work?
The [Unit Tests](EjectKitTests/EjectKitTests.swift#L136###testCollectionView) show how much work is done. UIKit coverage is configured by the [CocoaTouchBuilder](EjectKit/Builder/CocoaTouchBuilder.swift) using various [Builders](EjectKit/Builder). Some configuration is [generated](EjectKitTests/InspectorPropertyConfigurationTests.swift#34) from Interface Builder `.inspector` files.

This should still be considered an Alpha quality tool. Given the undocumented scope of Interface Builder XML, I really need your help to make things better!

### Usage

Download the repository and build the `Eject` target. The binary `eject-cli` should be copied into the current directory.
```
./eject-cli --file /path/to/MassiveViewController.xib
```

- Open an [Issue](https://github.com/Raizlabs/Eject/issues) with any bugs or ideas.

### Todo

- Enhance code generation approaches
- AppKit support
- Storyboard support?
- Use default values to remove un-needed code
- Better error reporting of un-interpreted flags
- Explore generating code as a method of diffing `.xib` files
- Homebrew recipie
