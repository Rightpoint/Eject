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

    func registerPrimitives() {
        // Register all the configuration nodes. These do not create objects, but apply configuration to existing objects
        register("rect", RectBuilder())
        register("nil", KeyValueBuilder(value: "nil"))
        register("dataDetectorType", OptionSetBuilder())
        register("userDefinedRuntimeAttribute", UserDefinedAttributeBuilder())
        register("autoresizingMask", AutoresizingMaskBuilder())
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
        register("placeholder", ObjectBuilder(className: "", placeholder: true))
        register("blurEffect", BasicBuilder(key: "style", format: .enumeration))
        // These two tags are containers that do not need a builder
        for noopKey in ["userDefinedRuntimeAttributes", "connections", "constraints", "freeformSimulatedSizeMetrics", "simulatedMetricsContainer", "simulatedStatusBarMetrics", "simulatedOrientationMetrics", "simulatedScreenMetrics", "resources", "image"] {
            register(noopKey, NoOpBuilder())
        }

        for type in ["integer", "real"] {
            register(type, KeyValueBuilder())
        }
        for type in ["string", "mutableString"] {
            register(type, KeyValueBuilder(format: .string))
        }
    }

    func registerCocoaTouch() {
        let barItem = ObjectBuilder(
            className: "UIBarItem",
            properties: [
                .build("tag", ValueFormat.number), .build("enabled", .boolean),
                .build("imageInsetsTop", .number), .build("imageInsetsBottom", .number),
                .build("imageInsetsLeft", .number), .build("imageInsetsRight", .number)
            ]
        )
        register("barItem", barItem)

        let barButtonItem = barItem.inherit(
            className: "UIBarButtonItem",
            properties: [.build("style", .enumeration), .build("width", .number)]
        )
        register("barButtonItem", barButtonItem)

        let collectionViewFlowLayout = ObjectBuilder(
            className: "UICollectionViewFlowLayout",
            properties: [.build("scrollDirection", .enumeration), .build("minimumLineSpacing", .number), .build("minimumInteritemSpacing", .number)]
        )
        register("collectionViewFlowLayout", collectionViewFlowLayout)
        let collectionViewLayout = ObjectBuilder(
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
        let view = ObjectBuilder(
            className: "UIView",
            properties: [
                .build("contentMode", .enumeration, defaultValue: "scaleToFill"), .build("semanticContentAttribute", .enumeration),
                .build("tag", .number), .build("userInteractionEnabled", .boolean),
                .build("multipleTouchEnabled", .boolean), .build("alpha", .number),
                .build("opaque", .boolean), .build("hidden", .boolean),
                .build("clearsContextBeforeDrawing", .boolean), .build("clipsToBounds", .boolean),
                .build("inspectedInstalled", .boolean), .build("preservesSuperviewLayoutMargins", .boolean),
                .build("layoutMarginsFollowReadableWidth", .boolean), .build("simulatedAppContext", .enumeration),
                .build("translatesAutoresizingMaskIntoConstraints", .boolean), .build("clipsSubviews", .boolean),
                .build("horizontalHuggingPriority", .number, defaultValue: "250", context: .invocation(prefix: "setContentHuggingPriority(", suffix: ", for: .horizontal)")),
                .build("verticalHuggingPriority", .number, defaultValue: "250", context: .invocation(prefix: "setContentHuggingPriority(", suffix: ", for: .vertical)")),
                .build("horizontalCompressionResistancePriority", .number, defaultValue: "750", context: .invocation(prefix: "setContentCompressionResistancePriority(", suffix: ", for: .horizontal)")),
                .build("verticalCompressionResistancePriority", .number, defaultValue: "750", context: .invocation(prefix: "setContentCompressionResistancePriority(", suffix: ", for: .vertical)")),
            ]
        )
        register("view", view)
        registerCocoaTouchControls(view: view)
        let scrollView = view.inherit(
            className: "UIScrollView",
            properties: [.build("indicatorStyle", .enumeration), .build("showsHorizontalScrollIndicator", .boolean), .build("showsVerticalScrollIndicator", .boolean), .build("scrollEnabled", .boolean), .build("pagingEnabled", .boolean), .build("directionalLockEnabled", .boolean), .build("bounces", .boolean), .build("alwaysBounceHorizontal", .boolean), .build("alwaysBounceVertical", .boolean), .build("minimumZoomScale", .number), .build("maximumZoomScale", .number), .build("bouncesZoom", .boolean), .build("delaysContentTouches", .boolean), .build("canCancelContentTouches", .boolean), .build("keyboardDismissMode", .enumeration)]
        )
        register("scrollView", scrollView)

        let activityIndicatorView = view.inherit(
            className: "UIActivityIndicatorView",
            properties: [.build("style", .enumeration), .build("inspectedAnimating", .boolean), .build("inspectedHidesWhenStopped", .boolean)]
        )
        register("activityIndicatorView", activityIndicatorView)
        let collectionView = scrollView.inherit(
            className: "UICollectionView",
            properties: [.build("prefetchingEnabled", .boolean)]
        )
        register("collectionView", collectionView)
        let collectionViewCell = view.inherit(className: "UICollectionViewCell")
        register("collectionViewCell", collectionViewCell)

        let datePicker = view.inherit(
            className: "UIDatePicker",
            properties: [.build("inspectedDatePickerMode", .enumeration), .build("locale", .enumeration), .build("minuteInterval", .enumeration), .build("hasMinimumDate", .boolean), .build("hasMaximumDate", .boolean)]
        )
        register("datePicker", datePicker)
        let imageView = view.inherit(
            className: "UIImageView",
            properties: [.build("highlighted", .boolean), .build("image", .image)]
        )
        register("imageView", imageView)
        let label = view.inherit(
            className: "UILabel",
            properties: [.build("textAlignment", .enumeration), .build("adjustsFontSizeToFit", .boolean), .build("lineBreakMode", .enumeration), .build("numberOfLines", .number), .build("enabled", .boolean), .build("highlighted", .boolean), .build("baselineAdjustment", .enumeration), .build("minimumScaleFactor", .number), .build("minimumFontSize", .number), .build("preferredMaxLayoutWidth", .number), .build("text", .string)]
        )
        register("label", label)
        let navigationBar = view.inherit(
            className: "UINavigationBar",
            properties: [.build("barStyle", .enumeration), .build("translucent", .boolean)]
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
            properties: [.build("searchBarStyle", .enumeration), .build("barStyle", .enumeration), .build("translucent", .boolean), .build("showsSearchResultsButton", .boolean), .build("showsBookmarkButton", .boolean), .build("showsCancelButton", .boolean), .build("inspectedShowsScopeBar", .boolean)]
        )
        register("searchBar", searchBar)
        let stackView = view.inherit(
            className: "UIStackView",
            properties: [.build("axis", .enumeration), .build("alignment", .enumeration), .build("alignment", .enumeration), .build("alignment", .enumeration), .build("alignment", .enumeration), .build("distribution", .enumeration), .build("spacing", .number), .build("baselineRelativeArrangement", .boolean)]
        )
        register("stackView", stackView)
        let tabBar = view.inherit(
            className: "UITabBar",
            properties: [.build("barStyle", .enumeration), .build("translucent", .boolean), .build("itemWidth", .number), .build("itemSpacing", .number)]
        )
        register("tabBar", tabBar)
        let tableView = scrollView.inherit(
            className: "UITableView",
            properties: [.build("separatorStyle", .enumeration), .build("sectionIndexMinimumDisplayRowCount", .number), .build("rowHeight", .number), .build("sectionHeaderHeight", .number), .build("sectionFooterHeight", .number), .build("frame", .raw, defaultValue: ".zero", injected: true), .build("style", .enumeration, defaultValue: "plain", injected: true)]
        )
        register("tableView", tableView)
        let tableViewCell = view.inherit(
            className: "UITableViewCell",
            properties: [.build("selectionStyle", .enumeration), .build("accessoryType", .enumeration), .build("editingAccessoryType", .enumeration), .build("focusStyle", .enumeration), .build("indentationLevel", .number), .build("indentationWidth", .number), .build("shouldIndentWhileEditing", .boolean), .build("showsReorderControl", .boolean), .build("rowHeight", .number)]
        )
        register("tableViewCell", tableViewCell)
        var tableViewCellContentView = view
        tableViewCellContentView.className = "UITableViewCellContentView"
        tableViewCellContentView.placeholder = true
        register("tableViewCellContentView", tableViewCellContentView)

        let textView = view.inherit(
            className: "UITextView",
            properties: [
                .build("textAlignment", .enumeration), .build("allowsEditingTextAttributes", .boolean),
                .build("editable", .boolean), .build("selectable", .boolean), .build("dataDetectorTypes", .boolean),
                .build("autocapitalizationType", .enumeration), .build("autocorrectionType", .enumeration),
                .build("spellCheckingType", .enumeration), .build("keyboardType", .enumeration),
                .build("keyboardAppearance", .enumeration), .build("returnKeyType", .enumeration),
                .build("enablesReturnKeyAutomatically", .boolean), .build("secureTextEntry", .boolean),
                .build("text", .string), .build("keyboardDismissMode", .enumeration)]
        )
        register("textView", textView)
        let toolbar = view.inherit(
            className: "UIToolbar",
            properties: [.build("barStyle", .enumeration), .build("translucent", .boolean), .build("text", .string), .build("keyboardDismissMode", .enumeration)]
        )
        register("toolbar", toolbar)
        let visualEffectView = view.inherit(
            className: "UIVisualEffectView",
            properties: [.build("blurEffectStyle", .enumeration), .build("vibrancy", .boolean)]
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
        let window = ObjectBuilder(
            className: "UIWindow",
            properties: [.build("visibleAtLaunch", .boolean), .build("resizesToFullScreen", .boolean)]
        )
        register("window", window)
    }

    func registerCocoaTouchControls(view: ObjectBuilder) {
        let control = view.inherit(
            className: "UIControl",
            properties: [
                .build("contentHorizontalAlignment", .enumeration, defaultValue: "center"),
                .build("contentVerticalAlignment", .enumeration, defaultValue: "center"),
                .build("selected", .boolean), .build("enabled", .boolean), .build("highlighted", .boolean)]
        )
        let button = control.inherit(
            className: "UIButton",
            properties: [.build("reversesTitleShadowWhenHighlighted", .boolean), .build("showsTouchWhenHighlighted", .boolean),
                         .build("adjustsImageWhenHighlighted", .boolean), .build("adjustsImageWhenDisabled", .boolean),
                         .build("lineBreakMode", .enumeration)]
        )
        register("button", button)
        let pageControl = control.inherit(
            className: "UIPageControl",
            properties: [.build("numberOfPages", .number), .build("currentPage", .number), .build("hidesForSinglePage", .boolean), .build("defersCurrentPageDisplay", .boolean)]
        )
        register("pageControl", pageControl)
        let segmentedControl = control.inherit(
            className: "UISegmentedControl",
            properties: [.build("momentary", .boolean), .build("apportionsSegmentWidthsByContent", .enumeration), .build("selectedSegmentIndex", .number, defaultValue: "selectedSegmentIndex")]
        )
        register("segmentedControl", segmentedControl)
        let slider = control.inherit(
            className: "UISlider",
            properties: [.build("continuous", .boolean)]
        )
        register("slider", slider)
        let stepper = control.inherit(
            className: "UIStepper",
            properties: [.build("autorepeat", .boolean), .build("continuous", .boolean), .build("wraps", .boolean)]
        )
        register("stepper", stepper)
        let uiSwitch = control.inherit(
            className: "UISwitch",
            properties: [.build("on", .boolean)]
        )
        register("switch", uiSwitch)
        let textField = control.inherit(
            className: "UITextField",
            properties: [
                .build("textAlignment", .enumeration), .build("allowsEditingTextAttributes", .boolean),
                .build("borderStyle", .enumeration), .build("clearButtonMode", .enumeration),
                .build("clearsOnBeginEditing", .boolean), .build("minimumFontSize", .number),
                .build("adjustsFontSizeToFitWidth", .boolean), .build("autocapitalizationType", .enumeration),
                .build("autocorrectionType", .enumeration), .build("spellCheckingType", .enumeration),
                .build("keyboardType", .enumeration), .build("keyboardAppearance", .enumeration),
                .build("returnKeyType", .enumeration), .build("enablesReturnKeyAutomatically", .boolean),
                .build("secureTextEntry", .boolean), .build("text", .string), .build("placeholder", .string)]
        )
        register("textField", textField)
    }

    func registerCocoaTouchViewControllers() {
        let viewController = ObjectBuilder(
            className: "UIViewController",
            properties: [
                .build("automaticallyAdjustsScrollViewInsets", .boolean), .build("hidesBottomBarWhenPushed", .boolean),
                .build("autoresizesArchivedViewToFullSize", .boolean), .build("wantsFullScreenLayout", .boolean),
                .build("extendedLayoutIncludesOpaqueBars", .boolean), .build("modalTransitionStyle", .enumeration),
                .build("modalPresentationStyle", .enumeration), .build("definesPresentationContext", .boolean),
                .build("providesPresentationContextTransitionStyle", .boolean)]
        )
        register("viewController", viewController)

        let tableViewController = ObjectBuilder(
            className: "UITableViewController",
            properties: [.build("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("tableViewController", tableViewController)

        let imagePickerController = ObjectBuilder(
            className: "UIImagePickerController",
            properties: [.build("sourceType", .enumeration), .build("allowsImageEditing", .boolean)]
        )
        register("imagePickerController", imagePickerController)

        let collectionViewController = ObjectBuilder(
            className: "UICollectionViewController",
            properties: [.build("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("collectionViewController", collectionViewController)

        let navigationController = ObjectBuilder(
            className: "UINavigationController",
            properties: [.build("hidesBarsOnSwipe", .boolean), .build("hidesBarsOnTap", .boolean), .build("hidesBarsWhenKeyboardAppears", .boolean), .build("hidesBarsWhenVerticallyCompact", .boolean)]
        )
        register("navigationController", navigationController)

        let pageViewController = ObjectBuilder(
            className: "UIPageViewController",
            properties: [.build("navigationOrientation", .enumeration), .build("pageSpacing", .number), .build("doubleSided", .boolean)]
        )
        register("pageViewController", pageViewController)
    }

    func registerCocoaTouchGestureRecognizers() {
        let gestureRecognizer = ObjectBuilder(
            className: "UIGestureRecognizer",
            properties: [.build("enabled", .boolean), .build("cancelsTouchesInView", .boolean), .build("delaysTouchesBegan", .boolean), .build("delaysTouchesEnded", .boolean)]
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
        let aDBannerView = ObjectBuilder(
            className: "ADBannerView",
            properties: [.build("adType", .enumeration)]
        )
        register("aDBannerView", aDBannerView)

        let gLKView = ObjectBuilder(
            className: "GLKView",
            properties: [.build("drawableColorFormat", .enumeration), .build("drawableDepthFormat", .enumeration), .build("drawableStencilFormat", .enumeration), .build("drawableMultisample", .enumeration), .build("enableSetNeedsDisplay", .boolean)]
        )
        register("gLKView", gLKView)

        // Class: MKMapView
        let mKMapView = ObjectBuilder(
            className: "MKMapView",
            properties: [.build("mapType", .enumeration), .build("zoomEnabled", .boolean), .build("scrollEnabled", .boolean), .build("rotateEnabled", .boolean), .build("pitchEnabled", .boolean), .build("showsBuildings", .boolean), .build("showsCompass", .boolean), .build("showsScale", .boolean), .build("showsTraffic", .boolean), .build("showsPointsOfInterest", .boolean), .build("showsUserLocation", .boolean)]
        )
        register("mKMapView", mKMapView)

        // Class: MTKView
        let mTKView = ObjectBuilder(
            className: "MTKView",
            properties: [.build("clearDepth", .number), .build("clearStencil", .number), .build("colorPixelFormat", .enumeration), .build("depthStencilPixelFormat", .enumeration), .build("sampleCount", .number), .build("preferredFramesPerSecond", .number), .build("enableSetNeedsDisplay", .boolean), .build("paused", .boolean), .build("autoResizeDrawable", .boolean)]
        )
        register("mTKView", mTKView)

        // Class: SCNView
        let sCNView = ObjectBuilder(
            className: "SCNView",
            properties: [.build("allowsCameraControl", .boolean), .build("jitteringEnabled", .boolean), .build("autoenablesDefaultLighting", .boolean), .build("playing", .boolean), .build("loops", .boolean)]
        )
        register("sCNView", sCNView)

        let gLKViewController = ObjectBuilder(
            className: "GLKViewController",
            properties: [.build("preferredFramesPerSecond", .number), .build("pauseOnWillResignActive", .boolean), .build("resumeOnDidBecomeActive", .boolean)]
        )
        register("gLKViewController", gLKViewController)

        let aVPlayerViewController = ObjectBuilder(
            className: "AVPlayerViewController",
            properties: [.build("showsPlaybackControls", .boolean)]
        )
        register("aVPlayerViewController", aVPlayerViewController)
    }
}
