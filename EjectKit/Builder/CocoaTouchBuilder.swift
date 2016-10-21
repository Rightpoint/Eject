//
//  DocumentDefinition.swift
//  Eject
//
//  Created by Brian King on 10/18/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

extension DocumentBuilder {
    func registerCocoaTouch() {
        // Register all the configuration nodes. These do not create objects, but apply configuration to existing objects
        register("rect", RectBuilder())
        register("nil", KeyValueBuilder(value: "nil"))
        register("dataDetectorType", OptionSetBuilder())
        register("userDefinedRuntimeAttribute", UserDefinedAttributeBuilder())
        register("size", SizeBuilder())
        register("inset", InsetBuilder())
        register("color", ColorBuilder())
        register("state", ButtonStateBuilder())
        register("subviews", SubviewBuilder())
        register("constraint", AchorageConstraintBuilder())
        register("fontDescription", FontBuilder())
        register("outlet", OutletBuilder(collection: false))
        register("outletCollection", OutletBuilder(collection: true))
        register("action", ActionBuilder())
        register("placeholder", PlaceholderBuilder())
        for type in ["integer", "real"] {
            register(type, KeyValueBuilder())
        }
        for type in ["string", "mutableString"] {
            register(type, KeyValueBuilder(format: .string))
        }

        // Register the UIKit view hierarchy
        let view = ObjectBuilder(
            className: "UIView",
            properties: [("clearsContextBeforeDrawing", .boolean), ("hidden", .boolean), ("opaque", .boolean), ("clipsToBounds", .boolean), ("translatesAutoresizingMaskIntoConstraints", .boolean), ("clipsSubviews", .boolean), ("multipleTouchEnabled", .boolean), ("contentMode", .enumeration)]
        )
        register("view", view)
        register("label", view.inherit(
            className: "UILabel", properties:  [("adjustsFontSizeToFit", .boolean), ("lineBreakMode", .enumeration), ("text", .string), ("minimumFontSize", .number), ("baselineAdjustment", .enumeration)])
        )

        register("tableView", view.inherit(
            className: "UITableView",
            properties: [("frame", .injectDefault(".zero")), ("style", .inject(.enumeration)), ("alwaysBounceVertical", .boolean), ("separatorStyle", .enumeration), ("rowHeight", .number), ("sectionHeaderHeight", .number), ("sectionFooterHeight", .number)])
        )

        register("visualEffectView", ObjectBuilder(className: "UIVisualEffect"))
        register("webView", view.inherit(className: "UIWebView"))
        register("collectionView", view.inherit(className: "UICollectionView"))
        register("collectionViewFlowLayout", view.inherit(className: "UICollectionViewFlowLayout"))
        register("button", view.inherit(className: "UIButton", properties: [("lineBreakMode", .enumeration)]))
        register("segmentedControl", view.inherit(className: "UISegmentedControl"))
        register("imageView", view.inherit(className: "UIImageView", properties: [("image", .image)]))

        register("panGestureRecognizer", ObjectBuilder(className: "UIPanGestureRecognizer", properties: [("minimumNumberOfTouches", .number)]))
    }
}
