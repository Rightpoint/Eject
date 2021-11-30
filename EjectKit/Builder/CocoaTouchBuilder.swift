//
//  DocumentDefinition.swift
//  Eject
//
//  Created by Brian King on 10/18/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

// Class Hierarchy:     
// The property tags in here
// /Applications/Xcode.app/Contents/PlugIns/IDEInterfaceBuilderCocoaTouchIntegration.ideplugin/Contents/Resources

extension DocumentBuilder {

    static var ignoredElements = ["freeformSimulatedSizeMetrics", "simulatedMetricsContainer", "simulatedStatusBarMetrics", "simulatedOrientationMetrics", "simulatedScreenMetrics", "modalFormSheetSimulatedSizeMetrics", "simulatedNavigationBarMetrics", "simulatedTabBarMetrics", "simulatedBottomBarMetrics", "simulatedTopBarMetrics"]

    func registerPrimitives() {
        // Register all the configuration nodes. These do not create objects, but apply configuration to existing objects
        var ignored = DocumentBuilder.ignoredElements
        ignored.append("highlightedColor")
        register("rect", RectBuilder())
        register("nil", KeyValueBuilder(value: "nil", ignoredKeys: ignored))
        register("dataDetectorType", OptionSetBuilder())
        register("userDefinedRuntimeAttribute", UserDefinedAttributeBuilder())
        register("autoresizingMask", AutoresizingMaskBuilder())
        register("size", SizeBuilder())
        register("inset", InsetBuilder())
        register("edgeInsets", EdgeInsetBuilder())
        register("color", ColorBuilder())
        register("state", ButtonStateBuilder())
        register("subviews", SubviewBuilder())
        register("items", ItemsBuilder())
        register("constraint", ConstraintBuilder())
        register("fontDescription", FontBuilder())
        register("outlet", OutletBuilder(collection: false))
        register("outletCollection", OutletBuilder(collection: true))
        register("action", ActionBuilder())
        register("placeholder", ObjectDefinition(className: "", placeholder: true))
        register("customObject", ObjectDefinition(className: "NSObject"))
        register("blurEffect", BasicBuilder(key: "style", format: .enumeration))
        // These tags are containers that do not need a builder
        for noopElement in ["userDefinedRuntimeAttributes", "connections", "constraints", "resources", "image", "gestureRecognizers"] {
            register(noopElement, NoOpBuilder())
        }
        // These are leaf containers that should do nothing
        for noopElement in DocumentBuilder.ignoredElements {
            register(noopElement, NoOpBuilder())
        }
        // frame elements only supply a width and height and are set to `frameInset` on cells.
        // This doesn't translate to anything useful, so ignore here.
        register("frame", NoOpBuilder())


        for type in ["integer", "real"] {
            register(type, KeyValueBuilder())
        }
        for type in ["string", "mutableString"] {
            register(type, KeyValueBuilder(format: .string))
        }
    }

    func registerCocoaTouch() {
        let barItem = ObjectDefinition(
            className: "UIBarItem",
            properties: [
                .build("tag", .number), .build("enabled", .boolean),
                .build("imageInsetsTop", .number), .build("imageInsetsBottom", .number),
                .build("imageInsetsLeft", .number), .build("imageInsetsRight", .number)
            ]
        )
        register("barItem", barItem)

        let barButtonItem = barItem.inherit(
            className: "UIBarButtonItem",
            properties: [
                .build(.map("systemItem", "barButtonSystemItem"), .enumeration, "", .inject),
                .build("style", .enumeration, "plain"),
                .build("title", .string, ""),
                .build("width", .number),
                .build("target", .raw, "nil", .inject),
                .build("action", .raw, "nil", .inject),
            ]
        )
        register("barButtonItem", barButtonItem)

        let navigationItem = ObjectDefinition(
            className: "UINavigationItem",
            properties: [
                .build("title", .string),
                .build("prompt", .string),
                .build("hidesBackButton", .boolean),
                .build("leftItemsSupplementBackButton", .boolean),
            ],
            placeholder: true
        )
        register("navigationItem", navigationItem)

        let collectionViewFlowLayout = ObjectDefinition(
            className: "UICollectionViewFlowLayout",
            properties: [.build("scrollDirection", .enumeration), .build("minimumLineSpacing", .number), .build("minimumInteritemSpacing", .number)]
        )
        register("collectionViewFlowLayout", collectionViewFlowLayout)
        let collectionViewLayout = ObjectDefinition(
            className: "UICollectionViewLayout",
            properties: [],
            placeholder: true
        )
        register("collectionViewLayout", collectionViewLayout)
        register("segments", SegmentsBuilder())
        register("segment", SegmentsBuilder.Segment())
        let textInputTraits = PropertyBuilder(
            keysToRemove: ["key"],
            properties: [
                .build("autocapitalizationType", .enumeration), .build("autocorrectionType", .enumeration),
                .build("spellCheckingType", .enumeration), .build("keyboardType", .enumeration),
                .build("keyboardAppearance", .enumeration), .build("returnKeyType", .enumeration),
                .build("enablesReturnKeyAutomatically", .boolean), .build("secureTextEntry", .boolean)]
        )
        register("textInputTraits", textInputTraits)

        registerCocoaTouchViews()
        registerCocoaTouchViewControllers()
        registerCocoaTouchGestureRecognizers()
        registerProbablyBrokenNamespaced()
    }

    func registerCocoaTouchViews() {
        let translateContext: AssociationContext = document.configuration.constraint.useTranslateAutoresizingMask ? .assignment : .ignore
        var view = ObjectDefinition(
            className: "UIView",
            properties: [
                .build("autoresizesSubviews", .boolean, "YES"),
                .build("contentMode", .enumeration, "scaleToFill"),
                .build("semanticContentAttribute", .enumeration),
                .build("tag", .number),
                .build("fixedFrame", .boolean, "", .ignore),
                .build(.addIsPrefix("userInteractionEnabled"), .boolean, "YES"),
                .build(.addIsPrefix("multipleTouchEnabled"), .boolean, "NO"),
                .build("alpha", .number),
                .build(.addIsPrefix("opaque"), .boolean, "YES"),
                .build(.addIsPrefix("hidden"), .boolean, "NO"),
                .build("clearsContextBeforeDrawing", .boolean, "YES"),
                .build("preservesSuperviewLayoutMargins", .boolean),
                .build("layoutMarginsFollowReadableWidth", .boolean),
                .build("simulatedAppContext", .enumeration),
                .build("translatesAutoresizingMaskIntoConstraints", .boolean, "true", translateContext),
                .build("clipsToBounds", .boolean, "NO"),
                .build(.map("clipsSubviews", "clipsToBounds"), .boolean, "NO"),
                .build("horizontalHuggingPriority", .number, "250", .invocation(prefix: "setContentHuggingPriority(", suffix: ", for: .horizontal)", includeTag: false)),
                .build("verticalHuggingPriority", .number, "250", .invocation(prefix: "setContentHuggingPriority(", suffix: ", for: .vertical)", includeTag: false)),
                .build("horizontalCompressionResistancePriority", .number, "750", .invocation(prefix: "setContentCompressionResistancePriority(", suffix: ", for: .horizontal)", includeTag: false)),
                .build("verticalCompressionResistancePriority", .number, "750", .invocation(prefix: "setContentCompressionResistancePriority(", suffix: ", for: .vertical)", includeTag: false)),
            ]
        )
        // Only inject the frame if the configuration is using frames.
        if document.configuration.useFrames {
            view.properties.append(.build("frame", .raw, ".zero", .inject))
        }
        else {
            view.properties.append(.build("frame", .raw, ".zero"))
        }
        register("view", view)
        registerCocoaTouchControls(view: view)
        let scrollView = view.inherit(
            className: "UIScrollView",
            properties: [
                .build("indicatorStyle", .enumeration),
                .build("showsHorizontalScrollIndicator", .boolean, "YES"),
                .build("showsVerticalScrollIndicator", .boolean, "YES"),
                .build(.addIsPrefix("scrollEnabled"), .boolean, "YES"),
                .build(.addIsPrefix("pagingEnabled"), .boolean, "NO"),
                .build("directionalLockEnabled", .boolean),
                .build("bounces", .boolean),
                .build("alwaysBounceHorizontal", .boolean),
                .build("alwaysBounceVertical", .boolean),
                .build("minimumZoomScale", .number),
                .build("maximumZoomScale", .number),
                .build("bouncesZoom", .boolean),
                .build("delaysContentTouches", .boolean, "YES"),
                .build("canCancelContentTouches", .boolean, "YES"),
                .build("keyboardDismissMode", .enumeration)
            ]
        )
        register("scrollView", scrollView)

        let activityIndicatorView = view.inherit(
            className: "UIActivityIndicatorView",
            properties: [
                .build(.map("style", "activityIndicatorStyle"), .enumeration, "", .inject),
                .build(.addIsPrefix("animating"), .boolean, ""),
                .build("hidesWhenStopped", .boolean, "YES")]
        )
        register("activityIndicatorView", activityIndicatorView)
        let collectionView = scrollView.inherit(
            className: "UICollectionView",
            properties: [
                .build("prefetchingEnabled", .boolean),
                .build("dataMode", .enumeration, "none",
                       .withComment("dataMode has no code equivilent and I've only seen none. Please log an issue if you see this.", .assignment))
            ]
        )
        register("collectionView", collectionView)
        let collectionViewCell = view.inherit(className: "UICollectionViewCell")
        register("collectionViewCell", collectionViewCell)

        let imageView = view.inherit(
            className: "UIImageView",
            properties: [
                .build("highlighted", .boolean),
                .build("placeholderIntrinsicWidth", .number, "", .ignore), // Used by IB
                .build("placeholderIntrinsicHeight", .number, "", .ignore), // Used by IB
                .build("image", .image),
                .build(.addIsPrefix("userInteractionEnabled"), .boolean, "NO"),
            ]
        )
        register("imageView", imageView)
        let label = view.inherit(
            className: "UILabel",
            properties: [
                .build("textAlignment", .enumeration),
                .build(.map("adjustsFontSizeToFit", "adjustsFontSizeToFitWidth"), .boolean, "NO"),
                .build(.map("adjustsLetterSpacingToFitWidth", "allowsDefaultTighteningForTruncation"), .boolean, "NO"),
                .build(.addIsPrefix("userInteractionEnabled"), .boolean, "NO"),
                .build("lineBreakMode", .transformed(lineBreakMappings, .enumeration)),
                .build("numberOfLines", .number),
                .build("enabled", .boolean),
                .build(.map("fontDescription", "font"), .raw),
                .build("highlighted", .boolean),
                .build("baselineAdjustment", .enumeration),
                .build("minimumScaleFactor", .number),
                .build("minimumFontSize", .number),
                .build("preferredMaxLayoutWidth", .number),
                .build("text", .string)
            ]
        )
        register("label", label)
        let navigationBar = view.inherit(
            className: "UINavigationBar",
            properties: [
                .build("barStyle", .enumeration),
                .build("translucent", .boolean),
            ],
            placeholder: true
        )
        register("navigationBar", navigationBar)
        let pickerView = view.inherit(
            className: "UIPickerView",
            properties: [.build("showsSelectionIndicator", .boolean)]
        )
        register("pickerView", pickerView)
        let progressView = view.inherit(
            className: "UIProgressView",
            properties: [.build("progressViewStyle", .enumeration), .build("progress", .number)]
        )
        register("progressView", progressView)
        let searchBar = view.inherit(
            className: "UISearchBar",
            properties: [
                .build("searchBarStyle", .enumeration),
                .build("barStyle", .enumeration),
                .build("translucent", .boolean),
                .build("text", .string),
                .build("placeholder", .string),
                .build("showsSearchResultsButton", .boolean),
                .build("showsBookmarkButton", .boolean),
                .build("showsCancelButton", .boolean),
                .build("showsScopeBar", .boolean)
            ]
        )
        register("searchBar", searchBar)
        let stackView = view.inherit(
            className: "UIStackView",
            properties: [.build("axis", .enumeration), .build("alignment", .enumeration), .build("alignment", .enumeration), .build("alignment", .enumeration), .build("alignment", .enumeration), .build("distribution", .enumeration), .build("spacing", .number), .build("baselineRelativeArrangement", .boolean)]
        )
        register("stackView", stackView)
        let tabBar = view.inherit(
            className: "UITabBar",
            properties: [
                .build("barStyle", .enumeration),
                .build("translucent", .boolean),
                .build("itemWidth", .number),
                .build("itemSpacing", .number)
            ],
            placeholder: true
        )
        register("tabBar", tabBar)
        let tableView = scrollView.inherit(
            className: "UITableView",
            properties: [
                .build("separatorStyle", .transformed(["default": "singleLine"], .enumeration)),
                .build("sectionIndexMinimumDisplayRowCount", .number),
                .build("rowHeight", .number),
                .build("allowsSelectionDuringEditing", .boolean, "NO"),
                .build("sectionHeaderHeight", .number),
                .build("sectionFooterHeight", .number),
                .build("style", .enumeration, "plain", .inject)]
        )
        register("tableView", tableView)
        let tableViewCell = view.inherit(
            className: "UITableViewCell",
            properties: [
                .build("style", .transformed(cellStyleMappings, .enumeration), "default", .inject),
                .build("reuseIdentifier", .string, "", .inject),
                .build("selectionStyle", .enumeration),
                .build("accessoryType", .enumeration),
                .build("editingAccessoryType", .enumeration),
                .build("focusStyle", .enumeration),
                .build("indentationLevel", .number),
                .build("indentationWidth", .number),
                .build("shouldIndentWhileEditing", .boolean),
                .build("showsReorderControl", .boolean),
                .build("textLabel", .raw, "", .placeholder(property: "textLabel?")),
                .build("detailTextLabel", .raw, "", .placeholder(property: "detailTextLabel?")),
                .build("rowHeight", .number)
            ]
        )
        register("tableViewCell", tableViewCell)
        let tableViewCellContentView = view.inherit(
            className: "UITableViewCellContentView",
            properties: [
                .build("tableViewCell", .raw, "", .ignore) // Ignore the link to the containing cell.
            ],
            placeholder: true
        )
        register("tableViewCellContentView", tableViewCellContentView)

        let textView = scrollView.inherit(
            className: "UITextView",
            properties: [
                .build("textAlignment", .enumeration),
                .build("allowsEditingTextAttributes", .boolean, "NO"),
                .build(.addIsPrefix("editable"), .boolean, "YES"),
                .build(.addIsPrefix("selectable"), .boolean, "YES"),
                .build("dataDetectorTypes", .boolean),
                .build("autocapitalizationType", .enumeration),
                .build("autocorrectionType", .enumeration),
                .build(.map("fontDescription", "font"), .raw),
                .build("spellCheckingType", .enumeration),
                .build("keyboardType", .enumeration),
                .build("keyboardAppearance", .enumeration),
                .build("returnKeyType", .enumeration),
                .build("enablesReturnKeyAutomatically", .boolean),
                .build("secureTextEntry", .boolean),
                .build("text", .string),
                .build("keyboardDismissMode", .enumeration)]
        )
        register("textView", textView)
        let toolbar = view.inherit(
            className: "UIToolbar",
            properties: [
                .build("barStyle", .enumeration),
                .build("translucent", .boolean),
            ]
        )
        register("toolbar", toolbar)
        let visualEffectView = view.inherit(
            className: "UIVisualEffectView",
            properties: [
                .build("blurEffectStyle", .enumeration),
                .build("vibrancy", .boolean)
            ]
        )
        register("visualEffectView", visualEffectView)
        let webView = view.inherit(
            className: "UIWebView",
            properties: [
                .build("scalesPageToFit", .boolean), .build("dataDetectorTypes", .boolean),
                .build("allowsInlineMediaPlayback", .boolean), .build("mediaPlaybackRequiresUserAction", .boolean),
                .build("mediaPlaybackAllowsAirPlay", .boolean), .build("suppressesIncrementalRendering", .boolean),
                .build("keyboardDisplayRequiresUserAction", .boolean), .build("paginationMode", .enumeration),
                .build("paginationBreakingMode", .enumeration), .build("pageLength", .number), .build("gapBetweenPages", .number)]
        )
        register("webView", webView)
        let window = view.inherit(
            className: "UIWindow",
            properties: [
                .build("visibleAtLaunch", .boolean, "", .ignore),
                .build("resizesToFullScreen", .boolean, "", .ignore),
                ]
        )
        register("window", window)
    }

    func registerCocoaTouchControls(view: ObjectDefinition) {
        let control = view.inherit(
            className: "UIControl",
            properties: [
                .build("contentHorizontalAlignment", .enumeration, "center"),
                .build("contentVerticalAlignment", .enumeration, "center"),
                .build("selected", .boolean), .build("enabled", .boolean), .build("highlighted", .boolean)]
        )
        let button = control.inherit(
            className: "UIButton",
            properties: [
                .build("type", .enumeration, "custom", .inject),
                .build("reversesTitleShadowWhenHighlighted", .boolean),
                .build("showsTouchWhenHighlighted", .boolean),
                .build("adjustsImageWhenHighlighted", .boolean),
                .build(.map("fontDescription", "titleLabel?.font"), .raw),
                .build("adjustsImageWhenDisabled", .boolean),
                .build(.map("lineBreakMode", "titleLabel?.lineBreakMode"), .transformed(lineBreakMappings, .enumeration))
            ]
        )
        register("button", button)
        let datePicker = control.inherit(
            className: "UIDatePicker",
            properties: [
                .build("datePickerMode", .enumeration),
                .build("locale", .enumeration),
                .build("minuteInterval", .number),
                .build("hasMinimumDate", .boolean),
                .build("hasMaximumDate", .boolean)
            ]
        )
        register("datePicker", datePicker)
        let pageControl = control.inherit(
            className: "UIPageControl",
            properties: [.build("numberOfPages", .number), .build("currentPage", .number), .build("hidesForSinglePage", .boolean), .build("defersCurrentPageDisplay", .boolean)]
        )
        register("pageControl", pageControl)
        let segmentedControl = control.inherit(
            className: "UISegmentedControl",
            properties: [
                .build("momentary", .boolean),
                .build("apportionsSegmentWidthsByContent", .enumeration),
                .build("selectedSegmentIndex", .number, "selectedSegmentIndex"),
                .build("segmentControlStyle", .enumeration, "bar", .ignore), // Used by IB to determine appearance, implied by usage in code.
            ]
        )
        register("segmentedControl", segmentedControl)
        let slider = control.inherit(
            className: "UISlider",
            properties: [
                .build("continuous", .boolean),
                .build(.map("maxValue", "maximumValue"), .number, ""),
                .build(.map("minValue", "minimumValue"), .number, ""),
                .build("value", .number),
            ]
        )
        register("slider", slider)
        let stepper = control.inherit(
            className: "UIStepper",
            properties: [.build("autorepeat", .boolean), .build("continuous", .boolean), .build("wraps", .boolean)]
        )
        register("stepper", stepper)
        let uiSwitch = control.inherit(
            className: "UISwitch",
            properties: [.build(.addIsPrefix("on"), .boolean, "off")]
        )
        register("switch", uiSwitch)
        let textField = control.inherit(
            className: "UITextField",
            properties: [
                .build("textAlignment", .enumeration), .build("allowsEditingTextAttributes", .boolean),
                .build(.map("adjustsFontSizeToFit", "adjustsFontSizeToFitWidth"), .boolean, "NO"),
                .build(.map("adjustsLetterSpacingToFitWidth", "allowsDefaultTighteningForTruncation"), .boolean, "NO"),
                .build("borderStyle", .enumeration), .build("clearButtonMode", .enumeration),
                .build("clearsOnBeginEditing", .boolean), .build("minimumFontSize", .number),
                .build("autocapitalizationType", .enumeration),
                .build("autocorrectionType", .enumeration), .build("spellCheckingType", .enumeration),
                .build(.map("fontDescription", "font"), .raw),
                .build("keyboardType", .enumeration), .build("keyboardAppearance", .enumeration),
                .build("returnKeyType", .enumeration), .build("enablesReturnKeyAutomatically", .boolean),
                .build("secureTextEntry", .boolean), .build("text", .string), .build("placeholder", .string)]
        )
        register("textField", textField)

        // Class: MKMapView
        let mKMapView = view.inherit(
            className: "MKMapView",
            properties: [
                .build("mapType", .enumeration),
                .build(.addIsPrefix("zoomEnabled"), .boolean, "YES"),
                .build(.addIsPrefix("scrollEnabled"), .boolean, "YES"),
                .build(.addIsPrefix("rotateEnabled"), .boolean, "YES"),
                .build(.addIsPrefix("pitchEnabled"), .boolean, "YES"),
                .build("showsBuildings", .boolean, "YES"),
                .build("showsCompass", .boolean),
                .build("showsScale", .boolean, "NO"),
                .build("showsTraffic", .boolean, "NO"),
                .build("showsPointsOfInterest", .boolean, "YES"),
                .build("showsUserLocation", .boolean, "NO")
            ]
        )
        register("mapView", mKMapView)
    }

    func registerCocoaTouchViewControllers() {
        let viewController = ObjectDefinition(
            className: "UIViewController",
            properties: [
                .build("automaticallyAdjustsScrollViewInsets", .boolean),
                .build("hidesBottomBarWhenPushed", .boolean),
                .build("autoresizesArchivedViewToFullSize", .boolean),
                .build("wantsFullScreenLayout", .boolean),
                .build("extendedLayoutIncludesOpaqueBars", .boolean),
                .build("modalTransitionStyle", .enumeration),
                .build("modalPresentationStyle", .enumeration),
                .build("title", .string),
                .build("definesPresentationContext", .boolean, "NO"),
                .build("providesPresentationContextTransitionStyle", .boolean),
                // Ignored, only used by IB
                .build("simulatedBottomBarMetrics", .boolean, "", .ignore),
                .build("wantsFullScreenLayout", .boolean, "", .ignore),
            ]
        )
        register("viewController", viewController)

        let tableViewController = viewController.inherit(
            className: "UITableViewController",
            properties: [.build("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("tableViewController", tableViewController)

        let imagePickerController = viewController.inherit(
            className: "UIImagePickerController",
            properties: [.build("sourceType", .enumeration), .build("allowsImageEditing", .boolean)]
        )
        register("imagePickerController", imagePickerController)

        let collectionViewController = viewController.inherit(
            className: "UICollectionViewController",
            properties: [.build("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("collectionViewController", collectionViewController)

        let navigationController = viewController.inherit(
            className: "UINavigationController",
            properties: [.build("hidesBarsOnSwipe", .boolean), .build("hidesBarsOnTap", .boolean), .build("hidesBarsWhenKeyboardAppears", .boolean), .build("hidesBarsWhenVerticallyCompact", .boolean)]
        )
        register("navigationController", navigationController)

        let pageViewController = viewController.inherit(
            className: "UIPageViewController",
            properties: [.build("navigationOrientation", .enumeration), .build("pageSpacing", .number), .build("doubleSided", .boolean)]
        )
        register("pageViewController", pageViewController)
        let tabBarController = viewController.inherit(
            className: "UITabBarController",
            properties: [
                .build("selectedIndex", .number),
            ]
        )
        register("tabBarController", tabBarController)

    }

    func registerCocoaTouchGestureRecognizers() {
        let gestureRecognizer = ObjectDefinition(
            className: "UIGestureRecognizer",
            properties: [
                .build("enabled", .boolean),
                .build("cancelsTouchesInView", .boolean),
                .build("delaysTouchesBegan", .boolean),
                .build("delaysTouchesEnded", .boolean),
                .build("target", .raw, "nil", .inject),
                .build("action", .raw, "nil", .inject),
            ]
        )
        register("gestureRecognizer", gestureRecognizer)

        let longPressGestureRecognizer = gestureRecognizer.inherit(
            className: "UILongPressGestureRecognizer",
            properties: [.build("minimumPressDuration", .number), .build("numberOfTapsRequired", .number), .build("numberOfTouchesRequired", .number), .build("allowableMovement", .number)]
        )
        register("longPressGestureRecognizer", longPressGestureRecognizer)

        let panGestureRecognizer = gestureRecognizer.inherit(
            className: "UIPanGestureRecognizer",
            properties: [.build("minimumNumberOfTouches", .number), .build("maximumNumberOfTouches", .number)]
        )
        register("panGestureRecognizer", panGestureRecognizer)

        let pinchGestureRecognizer = gestureRecognizer.inherit(
            className: "UIPinchGestureRecognizer",
            properties: [.build("scale", .number)]
        )
        register("pinchGestureRecognizer", pinchGestureRecognizer)

        let rotationGestureRecognizer = gestureRecognizer.inherit(
            className: "UIRotationGestureRecognizer",
            properties: [.build("rotationInDegrees", .number)]
        )
        register("rotationGestureRecognizer", rotationGestureRecognizer)

        let screenEdgePanGestureRecognizer = panGestureRecognizer.inherit(
            className: "UIScreenEdgePanGestureRecognizer",
            properties: [.build("edges", .boolean)]
        )
        register("screenEdgePanGestureRecognizer", screenEdgePanGestureRecognizer)

        let swipeGestureRecognizer = gestureRecognizer.inherit(
            className: "UISwipeGestureRecognizer",
            properties: [.build("direction", .enumeration), .build("numberOfTouchesRequired", .number)]
        )
        register("swipeGestureRecognizer", swipeGestureRecognizer)

        let tapGestureRecognizer = gestureRecognizer.inherit(
            className: "UITapGestureRecognizer",
            properties: [.build("numberOfTapsRequired", .number), .build("numberOfTouchesRequired", .number)]
        )
        register("tapGestureRecognizer", tapGestureRecognizer)
    }

    func registerProbablyBrokenNamespaced() {
        let aDBannerView = ObjectDefinition(
            className: "ADBannerView",
            properties: [.build("adType", .enumeration)]
        )
        register("aDBannerView", aDBannerView)

        let gLKView = ObjectDefinition(
            className: "GLKView",
            properties: [.build("drawableColorFormat", .enumeration), .build("drawableDepthFormat", .enumeration), .build("drawableStencilFormat", .enumeration), .build("drawableMultisample", .enumeration), .build("enableSetNeedsDisplay", .boolean)]
        )
        register("gLKView", gLKView)

        // Class: MTKView
        let mTKView = ObjectDefinition(
            className: "MTKView",
            properties: [.build("clearDepth", .number), .build("clearStencil", .number), .build("colorPixelFormat", .enumeration), .build("depthStencilPixelFormat", .enumeration), .build("sampleCount", .number), .build("preferredFramesPerSecond", .number), .build("enableSetNeedsDisplay", .boolean), .build("paused", .boolean), .build("autoResizeDrawable", .boolean)]
        )
        register("mTKView", mTKView)

        // Class: SCNView
        let sCNView = ObjectDefinition(
            className: "SCNView",
            properties: [.build("allowsCameraControl", .boolean), .build("jitteringEnabled", .boolean), .build("autoenablesDefaultLighting", .boolean), .build("playing", .boolean), .build("loops", .boolean)]
        )
        register("sCNView", sCNView)

        let gLKViewController = ObjectDefinition(
            className: "GLKViewController",
            properties: [.build("preferredFramesPerSecond", .number), .build("pauseOnWillResignActive", .boolean), .build("resumeOnDidBecomeActive", .boolean)]
        )
        register("gLKViewController", gLKViewController)

        let aVPlayerViewController = ObjectDefinition(
            className: "AVPlayerViewController",
            properties: [.build("showsPlaybackControls", .boolean)]
        )
        register("aVPlayerViewController", aVPlayerViewController)
    }
}

let lineBreakMappings: [String: String]  = [
    "wordWrap": "byWordWrapping",
    "charWrap": "byCharWrapping",
    "clipping": "byClipping",
    "headTruncation": "byTruncatingHead",
    "tailTruncation": "byTruncatingTail",
    "middleTruncation": "byTruncatingMiddle",
]

let cellStyleMappings: [String: String]  = [
    "IBUITableViewCellStyleDefault": "default",
    "IBUITableViewCellStyleValue1": "value1",
    "IBUITableViewCellStyleValue2": "value2",
    "IBUITableViewCellStyleSubtitle": "subtitle",
]


