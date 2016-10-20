//
//  DocumentDefinition.swift
//  Eject
//
//  Created by Brian King on 10/18/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

func CocoaTouchBuilder() -> DocumentBuilder {
    let definition = DocumentBuilder()
    // Register all the configuration nodes. These do not create objects, but apply configuration to existing objects
    definition.register("rect", RectBuilder())
    definition.register("nil", KeyValueBuilder(value: "nil"))
    definition.register("dataDetectorType", OptionSetBuilder())
    definition.register("userDefinedRuntimeAttribute", UserDefinedAttributeBuilder())
    definition.register("size", SizeBuilder())
    definition.register("inset", InsetBuilder())
    definition.register("color", ColorBuilder())
    definition.register("state", ButtonStateBuilder())
    definition.register("subviews", SubviewBuilder())
    definition.register("fontDescription", FontBuilder())
    definition.register("outlet", OutletBuilder())
    definition.register("placeholder", PlaceholderBuilder())

    for type in ["integer", "real"] {
        definition.register(type, KeyValueBuilder())
    }
    for type in ["string", "mutableString"] {
        definition.register(type, KeyValueBuilder(format: .string))
    }

    // Register the UIKit view hierarchy
    let view = ObjectBuilder(
        className: "UIView",
        properties: [("clearsContextBeforeDrawing", .boolean), ("hidden", .boolean), ("opaque", .boolean), ("clipsToBounds", .boolean), ("translatesAutoresizingMaskIntoConstraints", .boolean), ("clipsSubviews", .boolean), ("multipleTouchEnabled", .boolean), ("contentMode", .enumeration)]
    )
    definition.register("view", view)
    definition.register("label", view.inherit(
        className: "UILabel", properties:  [("adjustsFontSizeToFit", .boolean), ("lineBreakMode", .enumeration), ("text", .string), ("minimumFontSize", .number), ("baselineAdjustment", .enumeration)])
    )

    definition.register("tableView", view.inherit(
        className: "UITableView",
        properties: [("frame", .injectDefault(".zero")), ("style", .inject(.enumeration)), ("alwaysBounceVertical", .boolean), ("separatorStyle", .enumeration), ("rowHeight", .number), ("sectionHeaderHeight", .number), ("sectionFooterHeight", .number)])
    )

    definition.register("visualEffectView", ObjectBuilder(className: "UIVisualEffect"))
    definition.register("webView", view.inherit(className: "UIWebView"))
    definition.register("collectionView", view.inherit(className: "UICollectionView"))
    definition.register("collectionViewFlowLayout", view.inherit(className: "UICollectionViewFlowLayout"))
    definition.register("button", view.inherit(className: "UIButton", properties: [("lineBreakMode", .enumeration)]))
    definition.register("segmentedControl", view.inherit(className: "UISegmentedControl"))
    definition.register("imageView", view.inherit(className: "UIImageView", properties: [("image", .image)]))

    return definition
}
