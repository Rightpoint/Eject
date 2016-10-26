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
        register("placeholder", PlaceholderBuilder())
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
            properties: [("tag", .number), ("enabled", .boolean), ("imageInsetsTop", .number), ("imageInsetsBottom", .number), ("imageInsetsLeft", .number), ("imageInsetsRight", .number)]
        )
        register("barItem", barItem)

        let barButtonItem = barItem.inherit(
            className: "UIBarButtonItem",
            properties: [("style", .enumeration), ("width", .number)]
        )
        register("barButtonItem", barButtonItem)

        let collectionViewFlowLayout = ObjectBuilder(
            className: "UICollectionViewFlowLayout",
            properties: [("scrollDirection", .enumeration)]
        )
        register("collectionViewFlowLayout", collectionViewFlowLayout)

        registerCocoaTouchViews()
        registerCocoaTouchControls()
        registerCocoaTouchViewControllers()
        registerCocoaTouchGestureRecognizers()
        registerProbablyBrokenNamespaced()
    }

    func registerCocoaTouchViews() {
        let view = ObjectBuilder(
            className: "UIView",
            properties: [("contentMode", .enumeration), ("semanticContentAttribute", .enumeration), ("tag", .number), ("userInteractionEnabled", .boolean), ("multipleTouchEnabled", .boolean), ("alpha", .number), ("opaqueForDevice", .boolean), ("hidden", .boolean), ("clearsContextBeforeDrawing", .boolean), ("clipsToBounds", .boolean), ("inspectedInstalled", .boolean), ("preservesSuperviewLayoutMargins", .boolean), ("layoutMarginsFollowReadableWidth", .boolean), ("simulatedAppContext", .enumeration), ("translatesAutoresizingMaskIntoConstraints", .boolean), ("clipsSubviews", .boolean)]
        )
        register("view", view)
        let scrollView = view.inherit(
            className: "UIScrollView",
            properties: [("indicatorStyle", .enumeration), ("showsHorizontalScrollIndicator", .boolean), ("showsVerticalScrollIndicator", .boolean), ("scrollEnabled", .boolean), ("pagingEnabled", .boolean), ("directionalLockEnabled", .boolean), ("bounces", .boolean), ("alwaysBounceHorizontal", .boolean), ("alwaysBounceVertical", .boolean), ("minimumZoomScale", .number), ("maximumZoomScale", .number), ("bouncesZoom", .boolean), ("delaysContentTouches", .boolean), ("canCancelContentTouches", .boolean), ("keyboardDismissMode", .enumeration)]
        )
        register("scrollView", scrollView)

        let activityIndicatorView = view.inherit(
            className: "UIActivityIndicatorView",
            properties: [("style", .enumeration), ("inspectedAnimating", .boolean), ("inspectedHidesWhenStopped", .boolean)]
        )
        register("activityIndicatorView", activityIndicatorView)
        let collectionView = scrollView.inherit(
            className: "UICollectionView",
            properties: [("prefetchingEnabled", .boolean)]
        )
        register("collectionView", collectionView)
        let collectionViewCell = view.inherit(className: "UICollectionViewCell")
        register("collectionViewCell", collectionViewCell)

        let datePicker = view.inherit(
            className: "UIDatePicker",
            properties: [("inspectedDatePickerMode", .enumeration), ("locale", .enumeration), ("minuteInterval", .enumeration), ("hasMinimumDate", .boolean), ("hasMaximumDate", .boolean)]
        )
        register("datePicker", datePicker)
        let imageView = view.inherit(
            className: "UIImageView",
            properties: [("highlighted", .boolean), ("image", .image)]
        )
        register("imageView", imageView)
        let label = view.inherit(
            className: "UILabel",
            properties: [("textAlignment", .enumeration), ("numberOfLines", .number), ("enabled", .boolean), ("highlighted", .boolean), ("baselineAdjustment", .enumeration), ("minimumScaleFactor", .number), ("minimumFontSize", .number), ("preferredMaxLayoutWidth", .number)]
        )
        register("label", label)
        let navigationBar = view.inherit(
            className: "UINavigationBar",
            properties: [("barStyle", .enumeration), ("translucent", .boolean)]
        )
        register("navigationBar", navigationBar)
        let pickerView = view.inherit(
            className: "UIPickerView",
            properties: [("showsSelectionIndicator", .boolean)]
        )
        register("pickerView", pickerView)
        let progressView = view.inherit(
            className: "UIProgressView",
            properties: [("progressViewStyle", .enumeration), ("progress", .number)]
        )
        register("progressView", progressView)
        let searchBar = view.inherit(
            className: "UISearchBar",
            properties: [("searchBarStyle", .enumeration), ("barStyle", .enumeration), ("translucent", .boolean), ("showsSearchResultsButton", .boolean), ("showsBookmarkButton", .boolean), ("showsCancelButton", .boolean), ("inspectedShowsScopeBar", .boolean)]
        )
        register("searchBar", searchBar)
        let stackView = view.inherit(
            className: "UIStackView",
            properties: [("axis", .enumeration), ("alignment", .enumeration), ("alignment", .enumeration), ("alignment", .enumeration), ("alignment", .enumeration), ("distribution", .enumeration), ("spacing", .number), ("baselineRelativeArrangement", .boolean)]
        )
        register("stackView", stackView)
        let tabBar = view.inherit(
            className: "UITabBar",
            properties: [("barStyle", .enumeration), ("translucent", .boolean), ("itemWidth", .number), ("itemSpacing", .number)]
        )
        register("tabBar", tabBar)
        let tableView = scrollView.inherit(
            className: "UITableView",
            properties: [("frame", .injectDefault(".zero")), ("style", .inject(.enumeration)), ("separatorStyle", .enumeration), ("sectionIndexMinimumDisplayRowCount", .number), ("rowHeight", .number), ("sectionHeaderHeight", .number), ("sectionFooterHeight", .number)]
        )
        register("tableView", tableView)
        let tableViewCell = view.inherit(
            className: "UITableViewCell",
            properties: [("selectionStyle", .enumeration), ("accessoryType", .enumeration), ("editingAccessoryType", .enumeration), ("focusStyle", .enumeration), ("indentationLevel", .number), ("indentationWidth", .number), ("shouldIndentWhileEditing", .boolean), ("showsReorderControl", .boolean), ("rowHeight", .number)]
        )
        register("tableViewCell", tableViewCell)
        let textView = view.inherit(
            className: "UITextView",
            properties: [("textAlignment", .enumeration), ("allowsEditingTextAttributes", .boolean), ("editable", .boolean), ("selectable", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("autocapitalizationType", .enumeration), ("autocorrectionType", .enumeration), ("spellCheckingType", .enumeration), ("keyboardType", .enumeration), ("keyboardAppearance", .enumeration), ("returnKeyType", .enumeration), ("enablesReturnKeyAutomatically", .boolean), ("secureTextEntry", .boolean)]
        )
        register("textView", textView)
        let toolbar = view.inherit(
            className: "UIToolbar",
            properties: [("barStyle", .enumeration), ("translucent", .boolean)]
        )
        register("toolbar", toolbar)
        let visualEffectView = view.inherit(
            className: "UIVisualEffectView",
            properties: [("blurEffectStyle", .enumeration), ("vibrancy", .boolean)]
        )
        register("visualEffectView", visualEffectView)
        let webView = view.inherit(
            className: "UIWebView",
            properties: [("scalesPageToFit", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("dataDetectorTypes", .boolean), ("allowsInlineMediaPlayback", .boolean), ("mediaPlaybackRequiresUserAction", .boolean), ("mediaPlaybackAllowsAirPlay", .boolean), ("suppressesIncrementalRendering", .boolean), ("keyboardDisplayRequiresUserAction", .boolean), ("paginationMode", .enumeration), ("paginationBreakingMode", .enumeration), ("pageLength", .number), ("gapBetweenPages", .number)]
        )
        register("webView", webView)
        let window = ObjectBuilder(
            className: "UIWindow",
            properties: [("visibleAtLaunch", .boolean), ("resizesToFullScreen", .boolean)]
        )
        register("window", window)
    }

    func registerCocoaTouchControls() {
        let control = ObjectBuilder(
            className: "UIControl",
            properties: [("contentHorizontalAlignment", .enumeration), ("contentVerticalAlignment", .enumeration), ("selected", .boolean), ("enabled", .boolean), ("highlighted", .boolean)]
        )
        let button = control.inherit(
            className: "UIButton",
            properties: [("reversesTitleShadowWhenHighlighted", .boolean), ("showsTouchWhenHighlighted", .boolean), ("adjustsImageWhenHighlighted", .boolean), ("adjustsImageWhenDisabled", .boolean), ("lineBreakMode", .enumeration)]
        )
        register("button", button)
        let pageControl = control.inherit(
            className: "UIPageControl",
            properties: [("numberOfPages", .number), ("currentPage", .number), ("hidesForSinglePage", .boolean), ("defersCurrentPageDisplay", .boolean)]
        )
        register("pageControl", pageControl)
        let segmentedControl = control.inherit(
            className: "UISegmentedControl",
            properties: [("momentary", .boolean), ("apportionsSegmentWidthsByContent", .enumeration)]
        )
        register("segmentedControl", segmentedControl)
        let slider = control.inherit(
            className: "UISlider",
            properties: [("continuous", .boolean)]
        )
        register("slider", slider)
        let stepper = control.inherit(
            className: "UIStepper",
            properties: [("autorepeat", .boolean), ("continuous", .boolean), ("wraps", .boolean)]
        )
        register("stepper", stepper)
        let uiSwitch = control.inherit(
            className: "UISwitch",
            properties: [("on", .enumeration)]
        )
        register("switch", uiSwitch)
        let textField = control.inherit(
            className: "UITextField",
            properties: [("textAlignment", .enumeration), ("allowsEditingTextAttributes", .boolean), ("borderStyle", .enumeration), ("clearButtonMode", .enumeration), ("clearsOnBeginEditing", .boolean), ("minimumFontSize", .number), ("adjustsFontSizeToFitWidth", .boolean), ("autocapitalizationType", .enumeration), ("autocorrectionType", .enumeration), ("spellCheckingType", .enumeration), ("keyboardType", .enumeration), ("keyboardAppearance", .enumeration), ("returnKeyType", .enumeration), ("enablesReturnKeyAutomatically", .boolean), ("secureTextEntry", .boolean)]
        )
        register("textField", textField)
    }

    func registerCocoaTouchViewControllers() {
        let viewController = ObjectBuilder(
            className: "UIViewController",
            properties: [("automaticallyAdjustsScrollViewInsets", .boolean), ("hidesBottomBarWhenPushed", .boolean), ("autoresizesArchivedViewToFullSize", .boolean), ("wantsFullScreenLayout", .boolean), ("extendedLayoutIncludesOpaqueBars", .boolean), ("modalTransitionStyle", .enumeration), ("modalPresentationStyle", .enumeration), ("definesPresentationContext", .boolean), ("providesPresentationContextTransitionStyle", .boolean)]
        )
        register("viewController", viewController)

        let tableViewController = ObjectBuilder(
            className: "UITableViewController",
            properties: [("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("tableViewController", tableViewController)

        let imagePickerController = ObjectBuilder(
            className: "UIImagePickerController",
            properties: [("sourceType", .enumeration), ("allowsImageEditing", .boolean)]
        )
        register("imagePickerController", imagePickerController)

        let collectionViewController = ObjectBuilder(
            className: "UICollectionViewController",
            properties: [("clearsSelectionOnViewWillAppear", .boolean)]
        )
        register("collectionViewController", collectionViewController)

        let navigationController = ObjectBuilder(
            className: "UINavigationController",
            properties: [("hidesBarsOnSwipe", .boolean), ("hidesBarsOnTap", .boolean), ("hidesBarsWhenKeyboardAppears", .boolean), ("hidesBarsWhenVerticallyCompact", .boolean)]
        )
        register("navigationController", navigationController)

        let pageViewController = ObjectBuilder(
            className: "UIPageViewController",
            properties: [("navigationOrientation", .enumeration), ("pageSpacing", .number), ("doubleSided", .boolean)]
        )
        register("pageViewController", pageViewController)
    }

    func registerCocoaTouchGestureRecognizers() {
        let gestureRecognizer = ObjectBuilder(
            className: "UIGestureRecognizer",
            properties: [("enabled", .boolean), ("cancelsTouchesInView", .boolean), ("delaysTouchesBegan", .boolean), ("delaysTouchesEnded", .boolean)]
        )
        register("gestureRecognizer", gestureRecognizer)

        let longPressGestureRecognizer = gestureRecognizer.inherit(
            className: "UILongPressGestureRecognizer",
            properties: [("minimumPressDuration", .number), ("numberOfTapsRequired", .number), ("numberOfTouchesRequired", .number), ("allowableMovement", .number)]
        )
        register("longPressGestureRecognizer", longPressGestureRecognizer)

        let panGestureRecognizer = gestureRecognizer.inherit(
            className: "UIPanGestureRecognizer",
            properties: [("minimumNumberOfTouches", .number), ("maximumNumberOfTouches", .number)]
        )
        register("panGestureRecognizer", panGestureRecognizer)

        let pinchGestureRecognizer = gestureRecognizer.inherit(
            className: "UIPinchGestureRecognizer",
            properties: [("scale", .number)]
        )
        register("pinchGestureRecognizer", pinchGestureRecognizer)

        let rotationGestureRecognizer = gestureRecognizer.inherit(
            className: "UIRotationGestureRecognizer",
            properties: [("rotationInDegrees", .number)]
        )
        register("rotationGestureRecognizer", rotationGestureRecognizer)

        let screenEdgePanGestureRecognizer = panGestureRecognizer.inherit(
            className: "UIScreenEdgePanGestureRecognizer",
            properties: [("edges", .boolean), ("edges", .boolean), ("edges", .boolean), ("edges", .boolean)]
        )
        register("screenEdgePanGestureRecognizer", screenEdgePanGestureRecognizer)

        let swipeGestureRecognizer = gestureRecognizer.inherit(
            className: "UISwipeGestureRecognizer",
            properties: [("direction", .enumeration), ("numberOfTouchesRequired", .number)]
        )
        register("swipeGestureRecognizer", swipeGestureRecognizer)

        let tapGestureRecognizer = gestureRecognizer.inherit(
            className: "UITapGestureRecognizer",
            properties: [("numberOfTapsRequired", .number), ("numberOfTouchesRequired", .number)]
        )
        register("tapGestureRecognizer", tapGestureRecognizer)
    }

    func registerProbablyBrokenNamespaced() {
        let aDBannerView = ObjectBuilder(
            className: "ADBannerView",
            properties: [("adType", .enumeration)]
        )
        register("aDBannerView", aDBannerView)

        let gLKView = ObjectBuilder(
            className: "GLKView",
            properties: [("drawableColorFormat", .enumeration), ("drawableDepthFormat", .enumeration), ("drawableStencilFormat", .enumeration), ("drawableMultisample", .enumeration), ("enableSetNeedsDisplay", .boolean)]
        )
        register("gLKView", gLKView)

        // Class: MKMapView
        let mKMapView = ObjectBuilder(
            className: "MKMapView",
            properties: [("mapType", .enumeration), ("zoomEnabled", .boolean), ("scrollEnabled", .boolean), ("rotateEnabled", .boolean), ("pitchEnabled", .boolean), ("showsBuildings", .boolean), ("showsCompass", .boolean), ("showsScale", .boolean), ("showsTraffic", .boolean), ("showsPointsOfInterest", .boolean), ("showsUserLocation", .boolean)]
        )
        register("mKMapView", mKMapView)

        // Class: MTKView
        let mTKView = ObjectBuilder(
            className: "MTKView",
            properties: [("clearDepth", .number), ("clearStencil", .number), ("colorPixelFormat", .enumeration), ("depthStencilPixelFormat", .enumeration), ("sampleCount", .number), ("preferredFramesPerSecond", .number), ("enableSetNeedsDisplay", .boolean), ("paused", .boolean), ("autoResizeDrawable", .boolean)]
        )
        register("mTKView", mTKView)

        // Class: SCNView
        let sCNView = ObjectBuilder(
            className: "SCNView",
            properties: [("allowsCameraControl", .boolean), ("jitteringEnabled", .boolean), ("autoenablesDefaultLighting", .boolean), ("playing", .boolean), ("loops", .boolean)]
        )
        register("sCNView", sCNView)

        let gLKViewController = ObjectBuilder(
            className: "GLKViewController",
            properties: [("preferredFramesPerSecond", .number), ("pauseOnWillResignActive", .boolean), ("resumeOnDidBecomeActive", .boolean)]
        )
        register("gLKViewController", gLKViewController)

        let aVPlayerViewController = ObjectBuilder(
            className: "AVPlayerViewController",
            properties: [("showsPlaybackControls", .boolean)]
        )
        register("aVPlayerViewController", aVPlayerViewController)
    }
}
