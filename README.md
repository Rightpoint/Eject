# Eject

Eject is a utility to transition from Interface Builder to programatic view layout. This is done by using code generation to create a `.swift` file to replace the view hierarchy managed by the `.xib` file. One common pain point with Interface Builder is that as a view becomes more dynamic and is managed more programatically, Interface Builder becomes less helpful. This tool lets developers use Interface Builder without that concern, giving them an Eject button to hit when Interace Builder starts getting in the way and provides an easy path to transition to full programatic view layout.

### But But
Yes, I understand that there a million ways why this is a bad idea.

### Does it work?
Conceptually? The [Unit Tests](EjectTests/EjectTests.swift#L134) show how much work is done, but it won't be of use until Stencil is incorporated to generate the high-level code containers. UIKit coverage is managed by the [CocoaTouchBuilder](Eject/CocoaTouchBuilder.swift) using various [Builders](Eject/Builders).

### Todo

- Enhance code generation approaches
- Stencil Support
- Complete UIKit
- AppKit
- Storyboards
