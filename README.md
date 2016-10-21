# Eject

Eject is a utility to transition from Interface Builder to programatic view layout. This is done by using code generation to create a `.swift` file to replace the view hierarchy managed by the `.xib` file.

## Why?
One common pain point with Interface Builder is that as a view becomes more dynamic and is managed more programatically, Interface Builder becomes less helpful. This tool lets developers use Interface Builder without that concern, giving them an Eject button to hit when Interace Builder starts getting in the way, and provides an easy path to transition to full programatic view layout.

### But But
Yes, I understand that this is probably a bad idea. But it might not be.

### Does it work?
Conceptually? The [Unit Tests](EjectKitTests/EjectKitTests.swift#L136###testCollectionView) show how much work is done, but it won't be of use until Stencil is incorporated to generate the high-level code containers. UIKit coverage is incomplete, but is configured by the [CocoaTouchBuilder](EjectKit/Builder/CocoaTouchBuilder.swift) using various [Builders](EjectKit/Builder).

Re-organization: Raizlabs/Eject@f89df0

### Todo

- Enhance code generation approaches (Stencil)
- Complete UIKit support
- AppKit support
- Storyboard support?
- Use default values to remove un-needed code
- Explore generating code as a method of diffing `.xib` files
