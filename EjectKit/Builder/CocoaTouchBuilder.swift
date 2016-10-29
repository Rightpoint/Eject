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
                .p("tag", ValueFormat.number), .p("enabled", .boolean),
                .p("imageInsetsTop", .number), .p("imageInsetsBottom", .number),
                .p("imageInsetsLeft", .number), .p("imageInsetsRight", .number)
            ]
        )
        register("barItem", barItem)

        let barButtonItem = barItem.inherit(
            className: "UIBarButtonItem",
            properties: [.p("style", .enumeration), .p("width", .number)]
        )
        register("barButtonItem", barButtonItem)

        let collectionViewFlowLayout = ObjectBuilder(
            className: "UICollectionViewFlowLayout",
            properties: [.p("scrollDirection", .enumeration), .p("minimumLineSpacing", .number), .p("minimumInteritemSpacing", .number)]
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

        registerCocoaTouchViews()
        registerCocoaTouchControls()
        registerCocoaTouchViewControllers()
        registerCocoaTouchGestureRecognizers()
        registerProbablyBrokenNamespaced()
    }

    func registerCocoaTouchViews() {
        let view = ObjectBuilder(
            className: "UIView",
            properties: [
                .p("contentMode", .enumeration, defaultValue: "scaleToFill"), .p("semanticContentAttribute", .enumeration),
                .p("tag", .number), .p("userInteractionEnabled", .boolean),
                .p("multipleTouchEnabled", .boolean), .p("alpha", .number),
                .p("opaqueForDevice", .boolean), .p("hidden", .boolean),
                .p("clearsContextBeforeDrawing", .boolean), .p("clipsToBounds", .boolean),
                .p("inspectedInstalled", .boolean), .p("preservesSuperviewLayoutMargins", .boolean),
                .p("layoutMarginsFollowReadableWidth", .boolean), .p("simulatedAppContext", .enumeration),
                .p("translatesAutoresizingMaskIntoConstraints", .boolean), .p("clipsSubviews", .boolean)
            ]
        )
        register("view", view)
        let scrollView = view.inherit(
            className: "UIScrollView",
            properties: [.p("indicatorStyle", .enumeration), .p("showsHorizontalScrollIndicator", .boolean), .p("showsVerticalScrollIndicator", .boolean), .p("scrollEnabled", .boolean), .p("pagingEnabled", .boolean), .p("directionalLockEnabled", .boolean), .p("bounces", .boolean), .p("alwaysBounceHorizontal", .boolean), .p("alwaysBounceVertical", .boolean), .p("minimumZoomScale", .number), .p("maximumZoomScale", .number), .p("bouncesZoom", .boolean), .p("delaysContentTouches", .boolean), .p("canCancelContentTouches", .boolean), .p("keyboardDismissMode", .enumeration)]
        )
        register("scrollView", scrollView)

        let activityIndicatorView = view.inherit(
            className: "UIActivityIndicatorView",
            properties: [.p("style", .enumeration), .p("inspectedAnimating", .boolean), .p("inspectedHidesWhenStopped", .boolean)]
        )
        register("activityIndicatorView", activityIndicatorView)
        let collectionView = scrollView.inherit(
            className: "UICollectionView",
            properties: [.p("prefetchingEnabled", .boolean)]
        )
        register("collectionView", collectionView)
        let collectionViewCell = view.inherit(className: "UICollectionViewCell")
        register("collectionViewCell", collectionViewCell)

        let datePicker = view.inherit(
            className: "UIDatePicker",
            properties: [.p("inspectedDatePickerMode", .enumeration), .p("locale", .enumeration), .p("minuteInterval", .enumeration), .p("hasMinimumDate", .boolean), .p("hasMaximumDate", .boolean)]
        )
        register("datePicker", datePicker)
        let imageView = view.inherit(
            className: "UIImageView",
            properties: [.p("highlighted", .boolean), .p("image", .image)]
        )
        register("imageView", imageView)
        let label = view.inherit(
            className: "UILabel",
            properties: [.p("textAlignment", .enumeration), .p("numberOfLines", .number), .p("enabled", .boolean), .p("highlighted", .boolean), .p("baselineAdjustment", .enumeration), .p("minimumScaleFactor", .number), .p("minimumFontSize", .number), .p("preferredMaxLayoutWidth", .number), .p("text", .string)]
        )
        register("label", label)
        let navigationBar = view.inherit(
            className: "UINavigationBar",
            properties: [.p("barStyle", .enumeration), .p("translucent", .boolean)]
        )
        register("navigationBar", navigationBar)
        let pickerView = view.inherit(
            className: "UIPickerView",
            properties: [.p("showsSelectionIndicator", .boolean)]
        )
        register("pickerView", pickerView)
        let progressView = view.inherit(
            className: "UIProgressView",
            properties: [.p("progressViewStyle", .enumeration), .p("progress", .number)]
        )
        register("progressView", progressView)
        let searchBar = view.inherit(
            className: "UISearchBar",
            properties: [.p("searchBarStyle", .enumeration), .p("barStyle", .enumeration), .p("translucent", .boolean), .p("showsSearchResultsButton", .boolean), .p("showsBookmarkButton", .boolean), .p("showsCancelButton", .boolean), .p("inspectedShowsScopeBar", .boolean)]
        )
        register("searchBar", searchBar)
        let stackView = view.inherit(
            className: "UIStackView",
            properties: [.p("axis", .enumeration), .p("alignment", .enumeration), .p("alignment", .enumeration), .p("alignment", .enumeration), .p("alignment", .enumeration), .p("distribution", .enumeration), .p("spacing", .number), .p("baselineRelativeArrangement", .boolean)]
        )
        register("stackView", stackView)
        let tabBar = view.inherit(
            className: "UITabBar",
            properties: [.p("barStyle", .enumeration), .p("translucent", .boolean), .p("itemWidth", .number), .p("itemSpacing", .number)]
        )
        register("tabBar", tabBar)
        let tableView = scrollView.inherit(
            className: "UITableView",
            properties: [.p("separatorStyle", .enumeration), .p("sectionIndexMinimumDisplayRowCount", .number), .p("rowHeight", .number), .p("sectionHeaderHeight", .number), .p("sectionFooterHeight", .number), .p("frame", .raw, defaultValue: ".zero", injected: true), .p("style", .enumeration, defaultValue: "plain", injected: true)]
        )
        register("tableView", tableView)
        let tableViewCell = view.inherit(
            className: "UITableViewCell",
            properties: [.p("selectionStyle", .enumeration), .p("accessoryType", .enumeration), .p("editingAccessoryType", .enumeration), .p("focusStyle", .enumeration), .p("indentationLevel", .number), .p("indentationWidth", .number), .p("shouldIndentWhileEditing", .boolean), .p("showsReorderControl", .boolean), .p("rowHeight", .number)]
        )
        register("tableViewCell", tableViewCell)
        var tableViewCellContentView = view
        tableViewCellContentView.className = "UITableViewCellContentView"
        tableViewCellContentView.placeholder = true
        register("tableViewCellContentView", tableViewCellContentView)

        let textView = view.inherit(
            className: "UITextView",
            properties: [.p("textAlignment", .enumeration), .p("allowsEditingTextAttributes", .boolean), .p("editable", .boolean), .p("selectable", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("autocapitalizationType", .enumeration), .p("autocorrectionType", .enumeration), .p("spellCheckingType", .enumeration), .p("keyboardType", .enumeration), .p("keyboardAppearance", .enumeration), .p("returnKeyType", .enumeration), .p("enablesReturnKeyAutomatically", .boolean), .p("secureTextEntry", .boolean)]
        )
        register("textView", textView)
        let toolbar = view.inherit(
            className: "UIToolbar",
            properties: [.p("barStyle", .enumeration), .p("translucent", .boolean)]
        )
        register("toolbar", toolbar)
        let visualEffectView = view.inherit(
            className: "UIVisualEffectView",
            properties: [.p("blurEffectStyle", .enumeration), .p("vibrancy", .boolean)]
        )
        register("visualEffectView", visualEffectView)
        let webView = view.inherit(
            className: "UIWebView",
            properties: [.p("scalesPageToFit", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("dataDetectorTypes", .boolean), .p("allowsInlineMediaPlayback", .boolean), .p("mediaPlaybackRequiresUserAction", .boolean), .p("mediaPlaybackAllowsAirPlay", .boolean), .p("suppressesIncrementalRendering", .boolean), .p("keyboardDisplayRequiresUserAction", .boolean), .p("paginationMode", .enumeration), .p("paginationBreakingMode", .enumeration), .p("pageLength", .number), .p("gapBetweenPages", .number)]
        )
        register("webView", webView)
        let window = ObjectBuilder(
            className: "UIWindow",
            properties: [.p("visibleAtLaunch", .boolean), .p("resizesToFullScreen", .boolean)]
        )
        register("window", window)
    }

    func registerCocoaTouchControls() {
        let control = ObjectBuilder(
            className: "UIControl",
            properties: [.p("contentHorizontalAlignment", .enumeration, defaultValue: "center"), .p("contentVerticalAlignment", .enumeration, defaultValue: "center"),
                         .p("selected", .boolean), .p("enabled", .boolean), .p("highlighted", .boolean)]
        )
        let button = control.inherit(
            className: "UIButton",
            properties: [.p("reversesTitleShadowWhenHighlighted", .boolean), .p("showsTouchWhenHighlighted", .boolean), .p("adjustsImageWhenHighlighted", .boolean), .p("adjustsImageWhenDisabled", .boolean), .p("lineBreakMode", .enumeration)]
        )
        register("button", button)
        let pageControl = control.inherit(
            className: "UIPageControl",
            properties: [.p("numberOfPages", .number), .p("currentPage", .number), .p("hidesForSinglePage", .boolean), .p("defersCurrentPageDisplay", .boolean)]
        )
        register("pageControl", pageControl)
        let segmentedControl = control.inherit(
            className: "UISegmentedControl",
            properties: [.p("momentary", .boolean), .p("apportionsSegmentWidthsByContent", .enumeration), .p("selectedSegmentIndex", .number, defaultValue: "selectedSegmentIndex")]
        )
        register("segmentedControl", segmentedControl)
        let slider = control.inherit(
            className: "UISlider",
            properties: [.p("continuous", .boolean)]
        )
        register("slider", slider)
        let stepper = control.inherit(
            className: "UIStepper",
            properties: [.p("autorepeat", .boolean), .p("continuous", .boolean), .p("wraps", .boolean)]
        )
        register("stepper", stepper)
        let uiSwitch = control.inherit(
            className: "UISwitch",
            properties: [.p("on", .enumeration)]
        )
        register("switch", uiSwitch)
        let textField = control.inherit(
            className: "UITextField",
            properties: [.p("textAlignment", .enumeration), .p("allowsEditingTextAttributes", .boolean), .p("borderStyle", .enumeration), .p("clearButtonMode", .enumeration), .p("clearsOnBeginEditing", .boolean), .p("minimumFontSize", .number), .p("adjustsFontSizeToFitWidth", .boolean), .p("autocapitalizationType", .enumeration), .p("autocorrectionType", .enumeration), .p("spellCheckingType", .enumeration), .p("keyboardType", .enumeration), .p("keyboardAppearance", .enumeration), .p("returnKeyType", .enumeration), .p("enablesReturnKeyAutomatically", .boolean), .p("secureTextEntry", .boolean)]
        )
        register("textField", textField)
    }

    func registerCocoaTouchViewControllers() {
        let viewController = ObjectBuilder(
            className: "UIViewController",
            properties: [.p("automaticallyAdjustsScrollViewInsets", .boolean), .p("hidesBottomBarWhenPushed", .boolean), .p("autoresizesArchivedViewToFullSize", .boolean), .p("wantsFullScreenLayout", .boolean), .p("extendedLayoutIncludesOpaqueBars", .boolean), .p("modalTransitionStyle", .enumeration), .p("modalPresentationStyle", .enumeration), .p("definesPresentationContext", .boolean), .p("providesPresentationContextTransitionStyle", .boolean)]
        )
        register("viewController", viewController)

        let tableViewController = ObjectBuilder(
            className: "UITableViewController",
            properties: [.p("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("tableViewController", tableViewController)

        let imagePickerController = ObjectBuilder(
            className: "UIImagePickerController",
            properties: [.p("sourceType", .enumeration), .p("allowsImageEditing", .boolean)]
        )
        register("imagePickerController", imagePickerController)

        let collectionViewController = ObjectBuilder(
            className: "UICollectionViewController",
            properties: [.p("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("collectionViewController", collectionViewController)

        let navigationController = ObjectBuilder(
            className: "UINavigationController",
            properties: [.p("hidesBarsOnSwipe", .boolean), .p("hidesBarsOnTap", .boolean), .p("hidesBarsWhenKeyboardAppears", .boolean), .p("hidesBarsWhenVerticallyCompact", .boolean)]
        )
        register("navigationController", navigationController)

        let pageViewController = ObjectBuilder(
            className: "UIPageViewController",
            properties: [.p("navigationOrientation", .enumeration), .p("pageSpacing", .number), .p("doubleSided", .boolean)]
        )
        register("pageViewController", pageViewController)
    }

    func registerCocoaTouchGestureRecognizers() {
        let gestureRecognizer = ObjectBuilder(
            className: "UIGestureRecognizer",
            properties: [.p("enabled", .boolean), .p("cancelsTouchesInView", .boolean), .p("delaysTouchesBegan", .boolean), .p("delaysTouchesEnded", .boolean)]
        )
        register("gestureRecognizer", gestureRecognizer)

        let longPressGestureRecognizer = gestureRecognizer.inherit(
            className: "UILongPressGestureRecognizer",
            properties: [.p("minimumPressDuration", .number), .p("numberOfTapsRequired", .number), .p("numberOfTouchesRequired", .number), .p("allowableMovement", .number)]
        )
        register("longPressGestureRecognizer", longPressGestureRecognizer)

        let panGestureRecognizer = gestureRecognizer.inherit(
            className: "UIPanGestureRecognizer",
            properties: [.p("minimumNumberOfTouches", .number), .p("maximumNumberOfTouches", .number)]
        )
        register("panGestureRecognizer", panGestureRecognizer)

        let pinchGestureRecognizer = gestureRecognizer.inherit(
            className: "UIPinchGestureRecognizer",
            properties: [.p("scale", .number)]
        )
        register("pinchGestureRecognizer", pinchGestureRecognizer)

        let rotationGestureRecognizer = gestureRecognizer.inherit(
            className: "UIRotationGestureRecognizer",
            properties: [.p("rotationInDegrees", .number)]
        )
        register("rotationGestureRecognizer", rotationGestureRecognizer)

        let screenEdgePanGestureRecognizer = panGestureRecognizer.inherit(
            className: "UIScreenEdgePanGestureRecognizer",
            properties: [.p("edges", .boolean)]
        )
        register("screenEdgePanGestureRecognizer", screenEdgePanGestureRecognizer)

        let swipeGestureRecognizer = gestureRecognizer.inherit(
            className: "UISwipeGestureRecognizer",
            properties: [.p("direction", .enumeration), .p("numberOfTouchesRequired", .number)]
        )
        register("swipeGestureRecognizer", swipeGestureRecognizer)

        let tapGestureRecognizer = gestureRecognizer.inherit(
            className: "UITapGestureRecognizer",
            properties: [.p("numberOfTapsRequired", .number), .p("numberOfTouchesRequired", .number)]
        )
        register("tapGestureRecognizer", tapGestureRecognizer)
    }

    func registerProbablyBrokenNamespaced() {
        let aDBannerView = ObjectBuilder(
            className: "ADBannerView",
            properties: [.p("adType", .enumeration)]
        )
        register("aDBannerView", aDBannerView)

        let gLKView = ObjectBuilder(
            className: "GLKView",
            properties: [.p("drawableColorFormat", .enumeration), .p("drawableDepthFormat", .enumeration), .p("drawableStencilFormat", .enumeration), .p("drawableMultisample", .enumeration), .p("enableSetNeedsDisplay", .boolean)]
        )
        register("gLKView", gLKView)

        // Class: MKMapView
        let mKMapView = ObjectBuilder(
            className: "MKMapView",
            properties: [.p("mapType", .enumeration), .p("zoomEnabled", .boolean), .p("scrollEnabled", .boolean), .p("rotateEnabled", .boolean), .p("pitchEnabled", .boolean), .p("showsBuildings", .boolean), .p("showsCompass", .boolean), .p("showsScale", .boolean), .p("showsTraffic", .boolean), .p("showsPointsOfInterest", .boolean), .p("showsUserLocation", .boolean)]
        )
        register("mKMapView", mKMapView)

        // Class: MTKView
        let mTKView = ObjectBuilder(
            className: "MTKView",
            properties: [.p("clearDepth", .number), .p("clearStencil", .number), .p("colorPixelFormat", .enumeration), .p("depthStencilPixelFormat", .enumeration), .p("sampleCount", .number), .p("preferredFramesPerSecond", .number), .p("enableSetNeedsDisplay", .boolean), .p("paused", .boolean), .p("autoResizeDrawable", .boolean)]
        )
        register("mTKView", mTKView)

        // Class: SCNView
        let sCNView = ObjectBuilder(
            className: "SCNView",
            properties: [.p("allowsCameraControl", .boolean), .p("jitteringEnabled", .boolean), .p("autoenablesDefaultLighting", .boolean), .p("playing", .boolean), .p("loops", .boolean)]
        )
        register("sCNView", sCNView)

        let gLKViewController = ObjectBuilder(
            className: "GLKViewController",
            properties: [.p("preferredFramesPerSecond", .number), .p("pauseOnWillResignActive", .boolean), .p("resumeOnDidBecomeActive", .boolean)]
        )
        register("gLKViewController", gLKViewController)

        let aVPlayerViewController = ObjectBuilder(
            className: "AVPlayerViewController",
            properties: [.p("showsPlaybackControls", .boolean)]
        )
        register("aVPlayerViewController", aVPlayerViewController)
    }
}
