//
//  EjectTests.swift
//  EjectTests
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import XCTest
import Foundation
@testable import EjectKit

func checkXML(_ xml: String, _ expected: [String], warnings: [String] = [], file: StaticString = #file, line: UInt = #line) {
    do {
        let document = try XIBDocument.load(xml: xml)
        guard document.references.count > 0 else {
            XCTFail("No objects in the document", file: file, line: line - 1)
            return
        }
        let lines = try document.generateCode(disableComments: true)
        document.scanForDuplicateVariableNames()

        XCTAssertEqual(lines.count, expected.count, file: file, line:line)
        var i: UInt = 1
        for (actualLine, expectedLine) in zip(lines, expected) {
            XCTAssertEqual(actualLine, expectedLine, file: file, line: line + i)
            i += 1
        }
        if lines != expected {
            print(lines.map() { "\"\($0.replacingOccurrences(of: "\"", with: "\\\""))\","}.joined(separator: "\n"))
        }
        let messages = document.warnings.map() { $0.message }
        if messages !=  warnings {
            print(messages.joined(separator: "\n"))
        }
        XCTAssertEqual(messages, warnings)
    }
    catch let error {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}

func wrap(_ xml: String) -> String {
    return ["<?xml version='1.0' encoding='UTF-8' standalone='no'?>",
            "<document type='com.apple.InterfaceBuilder3.CocoaTouch.XIB' version='3.0' toolsVersion='10116' systemVersion='15F34' targetRuntime='iOS.CocoaTouch' propertyAccessControl='none' useAutolayout='YES' useTraitCollections='YES'>",
            "<dependencies>",
            "<deployment identifier='iOS'/>",
            "<plugIn identifier='com.apple.InterfaceBuilder.IBCocoaTouchPlugin' version='10085'/>",
            "</dependencies>",
            "<objects>",
            "<placeholder placeholderIdentifier='IBFilesOwner' id='-1' userLabel='FileOwner' customClass='TestClass' customModule='' customModuleProvider='target'>",
            "<connections>",
            "<outlet property='view' destination='i5M-Pr-FkT' id='sfx-zR-JGt'/>",
            "</connections>",
            "</placeholder>",
            "<placeholder placeholderIdentifier='IBFirstResponder' id='-2' customClass='UIResponder'/>",
            xml,
            "</objects>",
            "</document>"
        ].joined(separator: "\n")
}

class EjectTests: XCTestCase {

    func testString() {
        XCTAssertEqual("Test StringToCamel Case".snakeCased(), "testStringToCamelCase")
        XCTAssertEqual("Test     StringToCamel Case".snakeCased(), "testStringToCamelCase")
    }

    func testViewPartsWithFrame() {
        let xml = wrap("<view userLabel='test' clearsContextBeforeDrawing='NO' contentMode='scaleToFill' id='i5M-Pr-FkT'><rect key='frame' x='0.0' y='0.0' width='350' height='85'/></view>")
        checkXML(xml, [
            "let test = UIView()",
            "test.clearsContextBeforeDrawing = false",
            "",
            "self.view = test",
            ]
        )
    }

    // Method ordering is broken here, not sure if this is fatal to compile-out-of-the-box.
    func testGestureRecognizer() {
        let xml = wrap("<view userLabel='test' id='i5M-Pr-FkT'><connections><outletCollection property='gestureRecognizers' destination='fDa-KR-68j' appends='YES' id='7AV-8r-dYL'/></connections></view><panGestureRecognizer minimumNumberOfTouches='1' id='fDa-KR-68j'><connections><action selector='dimissTextField:' destination='-1' id='zAI-0B-Wyz'/><outlet property='delegate' destination='i5M-Pr-FkT' id='0eg-ac-TGD'/></connections></panGestureRecognizer>")
        checkXML(xml, [
            "let test = UIView()",
            "let panGestureRecognizer = UIPanGestureRecognizer()",
            "panGestureRecognizer.minimumNumberOfTouches = 1",
            "",
            "panGestureRecognizer.delegate = test",
            "panGestureRecognizer.addTarget(self, action: #selector(TestClass.dimissTextField(_:)))",
            "test.gestureRecognizers.append(panGestureRecognizer)",
            "self.view = test",
            ]
        )
    }

    func testLabel() {
        let xml = wrap("<label baselineAdjustment='alignBaselines' minimumFontSize='13' userLabel='test' id='i5M-Pr-FkT'><fontDescription key='fontDescription' type='system' pointSize='17'/></label>")
        checkXML(xml, [
            "let test = UILabel()",
            "test.baselineAdjustment = .alignBaselines",
            "test.minimumFontSize = 13",
            "test.font = .systemFont(ofSize: 17)",
            "",
            "self.view = test",
            ]
        )
    }

    func testUserDefined() {
        let xml = wrap("<view userLabel='test' id='i5M-Pr-FkT'><userDefinedRuntimeAttributes><userDefinedRuntimeAttribute type='number' keyPath='layer.cornerRadius'><integer key='value' value='25'/></userDefinedRuntimeAttribute><userDefinedRuntimeAttribute type='boolean' keyPath='clipsToBounds' value='YES'/></userDefinedRuntimeAttributes></view>")
        checkXML(xml, [
            "let test = UIView()",
            "test.layer.cornerRadius = 25",
            "test.clipsToBounds = true",
            "",
            "self.view = test",
            ]
        )
    }

    func testLabelWithTextContent() {
        let xml = wrap("<label userLabel='test' id='i5M-Pr-FkT'><mutableString key='text'>body</mutableString></label>")
        checkXML(xml, [
            "let test = UILabel()",
            "test.text = \"body\"",
            "",
            "self.view = test",
            ]
        )
    }

    func testLabelWithTextArgument() {
        let xml = wrap("<label userLabel='test' text='body' id='i5M-Pr-FkT'/>")
        checkXML(xml, [
            "let test = UILabel()",
            "test.text = \"body\"",
            "",
            "self.view = test",
            ]
        )
    }

    func testColor() {
        let xml = wrap("<view userLabel='test' id='i5M-Pr-FkT'><color key='a' red='0.97254908084869385' green='0.97254908084869385' blue='0.90196084976196289' alpha='1' colorSpace='deviceRGB'/><color key='b' red='0.84705882352941175' green='0.16078431372549021' blue='0.18431372549019609' alpha='1' colorSpace='calibratedRGB'/><color key='c' white='1' alpha='1' colorSpace='custom' customColorSpace='calibratedWhite'/><color key='d' white='0.5' alpha='1' colorSpace='calibratedWhite'/></view>")
        checkXML(xml, [
            "let test = UIView()",
            "test.a = UIColor(red: 0.973, green: 0.973, blue: 0.902, alpha: 1)",
            "test.b = UIColor(red: 0.847, green: 0.161, blue: 0.184, alpha: 1)",
            "test.c = UIColor(white: 1, alpha: 1)",
            "test.d = UIColor(white: 0.5, alpha: 1)",
            "",
            "self.view = test",
            ]
        )
    }

    func testAutoResizingMask() {
        let xml = wrap("<view userLabel='test' id='i5M-Pr-FkT'><autoresizingMask key='autoresizingMask' widthSizable='YES' heightSizable='YES' flexibleMaxX='YES' flexibleMaxY='YES' flexibleMinX='YES' flexibleMinY='YES'/></view>")
        checkXML(xml, [
            "let test = UIView()",
            "test.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight]",

            "",
            "self.view = test",
            ]
        )
    }

    func crashTestAttributedText() {
        let xml = wrap("<attributedString key='attributedText'><fragment content='Get $50 bonus!'><attributes><color key='NSColor' red='0.42745098040000001' green='0.42745098040000001' blue='0.42745098040000001' alpha='1' colorSpace='calibratedRGB'/><font key='NSFont' metaFont='system' size='19'/>                                        <paragraphStyle key='NSParagraphStyle' alignment='center' lineBreakMode='truncatingTail' baseWritingDirection='natural' lineSpacing='5' tighteningFactorForTruncation='0.0'/></attributes></fragment></attributedString>")
        checkXML(xml, [])
    }

    func testFont() {
        let xml = wrap("<view userLabel='test' id='i5M-Pr-FkT'><fontDescription key='a' name='Gotham-Bold' family='Gotham' pointSize='32'/><fontDescription key='b' type='system' pointSize='17'/></view>")
        checkXML(xml, [
            "let test = UIView()",
            "test.a = UIFont(name: \"Gotham-Bold\", size: 32)",
            "test.b = .systemFont(ofSize: 17)",
            "",
            "self.view = test",
            ]
        )
    }

    func testCollectionView() {
        let xml = wrap("<collectionView contentMode='scaleToFill' dataMode='none' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><collectionViewFlowLayout key='collectionViewLayout' minimumLineSpacing='10' minimumInteritemSpacing='10' id='sFl-c5-v9d'><size key='itemSize' width='50' height='50'/><size key='headerReferenceSize' width='0.0' height='0.0'/><size key='footerReferenceSize' width='0.0' height='0.0'/><inset key='sectionInset' minX='0.0' minY='0.0' maxX='0.0' maxY='0.0'/></collectionViewFlowLayout><connections><outlet property='dataSource' destination='-1' id='0eg-ac-TGD'/><outlet property='delegate' destination='-1' id='jQ0-LG-WAK'/></connections></collectionView>")
        checkXML(xml, [
            "let collectionView = UICollectionView()",
            "let collectionViewFlowLayout = UICollectionViewFlowLayout()",
            "collectionViewFlowLayout.minimumLineSpacing = 10",
            "collectionViewFlowLayout.minimumInteritemSpacing = 10",
            "collectionViewFlowLayout.itemSize = CGSize(width: 50, height: 50)",
            "collectionViewFlowLayout.headerReferenceSize = CGSize(width: 0, height: 0)",
            "collectionViewFlowLayout.footerReferenceSize = CGSize(width: 0, height: 0)",
            "collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)",
            "",
            "collectionView.delegate = self",
            "collectionView.dataSource = self",
            "collectionView.collectionViewLayout = collectionViewFlowLayout",
            "self.view = collectionView",
            ], warnings: [
            ])
    }

    func testTableView() {
        let xml = wrap("<tableView alwaysBounceVertical='YES' style='plain' separatorStyle='default' rowHeight='44' sectionHeaderHeight='28' sectionFooterHeight='28' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><color key='backgroundColor' white='1' alpha='1' colorSpace='calibratedWhite'/><inset key='separatorInset' minX='15' minY='0.0' maxX='15' maxY='0.0'/><connections><outlet property='dataSource' destination='-1' id='0eg-ac-TGD'/><outlet property='delegate' destination='-1' id='jQ0-LG-WAK'/></connections></tableView>")
        checkXML(xml, [
            "let tableView = UITableView(style: .plain)",
            "tableView.separatorStyle = .singleLine",
            "tableView.rowHeight = 44",
            "tableView.sectionHeaderHeight = 28",
            "tableView.sectionFooterHeight = 28",
            "tableView.alwaysBounceVertical = true",
            "tableView.backgroundColor = UIColor(white: 1, alpha: 1)",
            "tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 30)",
            "",
            "tableView.delegate = self",
            "tableView.dataSource = self",
            "self.view = tableView",
            ])
    }

    func testImageView() {
        let xml = wrap("<imageView contentMode='center' image='icon' userInteractionEnabled='NO' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'></imageView>")
        checkXML(xml, [
            "let imageView = UIImageView()",
            "imageView.image = UIImage(named: \"icon\")",
            "imageView.contentMode = .center",
            "",
            "self.view = imageView",
            ])
    }

    func testButton() {
        let xml = wrap("<button contentHorizontalAlignment='center' contentVerticalAlignment='center' lineBreakMode='middleTruncation' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><state key='normal' title='Title' image='icon'><color key='titleColor' white='1' alpha='1' colorSpace='calibratedWhite'/><color key='titleShadowColor' white='0.0' alpha='0.0' colorSpace='calibratedWhite'/></state><connections><action selector='doThing:' destination='-1' eventType='touchUpInside' id='39P-Rs-7z2'/></connections></button>")
        checkXML(xml, [
            "let button = UIButton()",
            "button.titleLabel?.lineBreakMode = .byTruncatingMiddle",
            "button.setTitle(\"Title\", for: .normal)",
            "button.setImage(UIImage(named: \"icon\"), for: .normal)",
            "button.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)",
            "button.setTitleShadowColor(UIColor(white: 0, alpha: 0), for: .normal)",
            "",
            "button.addTarget(self, action: #selector(TestClass.doThing(_:)), for: .touchUpInside)",
            "self.view = button",
            ])
    }

    func testActions() {
        let xml = wrap("<view id='i5M-Pr-FkT'><subviews><view id='FUp-2k-EIR' userLabel='BorderView'><subviews><webView id='glB-HT-PdE'/></subviews></view><view id='aaa-bb-ccc' userLabel='OtherView'/></subviews></view>")
        checkXML(xml, [
            "let view = UIView()",
            "let borderView = UIView()",
            "let webView = UIWebView()",
            "let otherView = UIView()",
            "view.addSubview(otherView)",
            "view.addSubview(borderView)",
            "borderView.addSubview(webView)",
            "",
            "self.view = view",
            ])
    }

    func testViewHierarchy() {
        let xml = wrap("<view id='i5M-Pr-FkT'><subviews><view id='FUp-2k-EIR' userLabel='BorderView'><subviews><webView id='glB-HT-PdE'/></subviews></view><view id='aaa-bb-ccc' userLabel='OtherView'/></subviews></view>")
        checkXML(xml, [
            "let view = UIView()",
            "let borderView = UIView()",
            "let webView = UIWebView()",
            "let otherView = UIView()",
            "view.addSubview(otherView)",
            "view.addSubview(borderView)",
            "borderView.addSubview(webView)",
            "",
            "self.view = view",
            ])
    }

    func testHugging() {
        let xml = wrap("<view id='i5M-Pr-FkT' horizontalHuggingPriority='251' horizontalCompressionResistancePriority='751' verticalCompressionResistancePriority='751' verticalHuggingPriority='251'></view>")
        checkXML(xml, [
            "let view = UIView()",
            "view.setContentHuggingPriority(251, for: .horizontal)",
            "view.setContentHuggingPriority(251, for: .vertical)",
            "view.setContentCompressionResistancePriority(751, for: .horizontal)",
            "view.setContentCompressionResistancePriority(751, for: .vertical)",
            "",
            "self.view = view",
            ])
    }

    func testAnchorageConstraints() {
        let xml = wrap("<view id='i5M-Pr-FkT'><rect key='frame' x='0.0' y='0.0' width='350' height='85'/><subviews><view id='UX2-VG-eOo' customClass='CircularToggleView'><rect key='frame' x='0.0' y='29' width='28' height='28'/><color key='backgroundColor' white='1' alpha='1' colorSpace='calibratedWhite'/><constraints><constraint firstAttribute='height' constant='28' id='BqJ-XJ-eyz'/><constraint firstAttribute='width' constant='28' id='nMF-V2-XRU'/></constraints></view><label id='19u-jG-JIO'><rect key='frame' x='36' y='36' width='52' height='14'/><fontDescription key='fontDescription' name='Gotham-Book' family='Gotham' pointSize='14'/><color key='textColor' red='0.50196078430000002' green='0.50196078430000002' blue='0.50196078430000002' alpha='1' colorSpace='calibratedRGB'/><nil key='highlightedColor'/></label></subviews><color key='backgroundColor' white='0.0' alpha='0.0' colorSpace='calibratedWhite'/><constraints><constraint firstItem='UX2-VG-eOo' firstAttribute='leading' secondItem='i5M-Pr-FkT' secondAttribute='leading' id='5fR-oy-xvA'/><constraint firstItem='UX2-VG-eOo' firstAttribute='centerY' secondItem='i5M-Pr-FkT' secondAttribute='centerY' id='6Qn-oN-YHI'/><constraint firstAttribute='bottom' relation='greaterThanOrEqual' secondItem='19u-jG-JIO' secondAttribute='bottom' constant='20' symbolic='YES' id='BGy-u3-ENo'/><constraint firstAttribute='trailing' relation='greaterThanOrEqual' secondItem='19u-jG-JIO' secondAttribute='trailing' constant='20' symbolic='YES' id='Kgc-VK-hur'/><constraint firstItem='19u-jG-JIO' firstAttribute='centerY' secondItem='UX2-VG-eOo' secondAttribute='centerY' id='jSG-kc-EZ6'/><constraint firstItem='19u-jG-JIO' firstAttribute='top' relation='greaterThanOrEqual' secondItem='i5M-Pr-FkT' secondAttribute='top' constant='20' symbolic='YES' id='trv-aZ-Isd'/><constraint firstItem='19u-jG-JIO' firstAttribute='leading' secondItem='UX2-VG-eOo' secondAttribute='trailing' priority='100' constant='8' id='zMe-2W-nrz'/></constraints></view>")
        checkXML(xml, [
            "let view = UIView()",
            "view.backgroundColor = UIColor(white: 0, alpha: 0)",
            "",
            "let circularToggleView = CircularToggleView()",
            "circularToggleView.backgroundColor = UIColor(white: 1, alpha: 1)",
            "",
            "let label = UILabel()",
            "label.font = UIFont(name: \"Gotham-Book\", size: 14)",
            "label.textColor = UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1)",
            "",
            "view.addSubview(label)",
            "view.addSubview(circularToggleView)",
            "",
            "label.leadingAnchor == circularToggleView.trailingAnchor + 8 ~ 100",
            "label.topAnchor >= view.topAnchor + 20",
            "label.centerYAnchor == circularToggleView.centerYAnchor",
            "view.trailingAnchor >= label.trailingAnchor + 20",
            "view.bottomAnchor >= label.bottomAnchor + 20",
            "circularToggleView.centerYAnchor == view.centerYAnchor",
            "circularToggleView.leadingAnchor == view.leadingAnchor",
            "circularToggleView.widthAnchor == 28",
            "circularToggleView.heightAnchor == 28",
            "",
            "self.view = view"
            ])
    }

    func testVisualEffectViewKey() {
        let xml = wrap("<visualEffectView id='i5M-Pr-FkT' userLabel='Blur View'><rect key='frame' x='0.0' y='0.0' width='600' height='600'/><blurEffect style='extraLight'/><view key='contentView' id='F01-5F-ger' userLabel='Content View'></view></visualEffectView>")
        checkXML(xml, [
            "let blurView = UIVisualEffectView()",
            "blurView.style = .extraLight",
            "",
            "let contentView = UIView()",
            "blurView.contentView = contentView",
            "self.view = blurView",
            ])
    }

    // This is an instance where the sax parser is a bit of a pain. The numberOfSegments property is set by the number of segment elements.
    func testSegmentedControl() {
        let xml = wrap("<segmentedControl segmentControlStyle='plain' selectedSegmentIndex='0' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><segments><segment title='Overview'/><segment title='Description'/></segments></segmentedControl>")
        checkXML(xml, [
            "let segmentedControl = UISegmentedControl()",
            "segmentedControl.selectedSegmentIndex = 0",
            "segmentedControl.setTitle(\"Overview\", forSegmentAt: 0)",
            "segmentedControl.setTitle(\"Description\", forSegmentAt: 1)",
            "",
            "self.view = segmentedControl",
            ], warnings: [])

    }

    func testUserLabelToVariableMapping() {
        let xml = wrap("<label userLabel='test(Arbitrary.user    String[]is a Valid&V^A%RI!A@B-L=E)' id='i5M-Pr-FkT'></label>")
        checkXML(xml, [
            "let testArbitraryUserStringIsAValidVARIABLE = UILabel()",
            "self.view = testArbitraryUserStringIsAValidVARIABLE",
            ])
    }

    func testMissingAttributes() {
        let xml = wrap("<imageView contentMode='center' thisattribute='isnotdefined' image='icon' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'><unknown/></imageView>")
        checkXML(xml, [
            "let imageView = UIImageView()",
            "imageView.image = UIImage(named: \"icon\")",
            "imageView.contentMode = .center",
            "",
            "self.view = imageView",
            ], warnings: [
                "document.objects.imageView: thisattribute='isnotdefined'",
                "Can not configure XML nodes 'unknown'",
            ])
    }

    func testSwitch() {
        let xml = wrap("<switch opaque='NO' clipsSubviews='YES' multipleTouchEnabled='YES' contentMode='scaleToFill' contentHorizontalAlignment='center' contentVerticalAlignment='center' on='YES' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'><rect key='frame' x='263' y='8' width='51' height='31'/><constraints><constraint firstAttribute='width' constant='49' id='XYJ-oE-Z6H'/><constraint firstAttribute='height' constant='31' id='sv1-aq-Ftb'/></constraints><connections><action selector='snoozeSwitchValueChanged:' destination='-1' eventType='valueChanged' id='-1'/></connections></switch>")
        checkXML(xml, [
            "let switch = UISwitch()",
            "switch.isOn = true",
            "switch.isMultipleTouchEnabled = true",
            "switch.isOpaque = false",
            "switch.clipsToBounds = true",
            "",
            "switch.heightAnchor == 31",
            "switch.widthAnchor == 49",
            "",
            "switch.addTarget(self, action: #selector(TestClass.snoozeSwitchValueChanged(_:)), for: .valueChanged)",
            "self.view = switch",
            ])
    }

    func testTableViewCell() {
        let xml = wrap("<tableViewCell clearsContextBeforeDrawing='NO' contentMode='scaleToFill' selectionStyle='none' indentationWidth='10' reuseIdentifier='snoozeToggleCellId' id='i5M-Pr-FkT' userLabel='Table View Cell (Snooze Toggle)'><rect key='frame' x='0.0' y='0.0' width='320' height='44'/><autoresizingMask key='autoresizingMask' flexibleMaxX='YES' flexibleMaxY='YES'/><tableViewCellContentView key='contentView' opaque='NO' clipsSubviews='YES' multipleTouchEnabled='YES' contentMode='center' tableViewCell='27' id='20C-qx-qiB'><rect key='frame' x='0.0' y='0.0' width='320' height='43'/><autoresizingMask key='autoresizingMask'/><subviews><label opaque='NO' clipsSubviews='YES' userInteractionEnabled='NO' contentMode='scaleToFill' fixedFrame='YES' text='Snooze' lineBreakMode='tailTruncation' minimumFontSize='10' useAutomaticPreferredMaxLayoutWidth='YES' translatesAutoresizingMaskIntoConstraints='NO' id='29'><rect key='frame' x='20' y='13' width='135' height='21'/>                        <fontDescription key='fontDescription' type='system' pointSize='17'/><color key='textColor' cocoaTouchSystemColor='darkTextColor'/><nil key='highlightedColor'/></label></subviews></tableViewCellContentView><color key='backgroundColor' red='1' green='1' blue='1' alpha='1' colorSpace='calibratedRGB'/><point key='canvasLocation' x='-46' y='552'/></tableViewCell>")
        checkXML(xml, [
            "let tableViewCellSnoozeToggle = UITableViewCell(reuseIdentifier: \"snoozeToggleCellId\")",
            "tableViewCellSnoozeToggle.selectionStyle = .none",
            "tableViewCellSnoozeToggle.indentationWidth = 10",
            "tableViewCellSnoozeToggle.clearsContextBeforeDrawing = false",
            "tableViewCellSnoozeToggle.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]",
            "tableViewCellSnoozeToggle.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)",
            "",
            "let label = UILabel()",
            "label.lineBreakMode = .byTruncatingTail",
            "label.minimumFontSize = 10",
            "label.text = \"Snooze\"",
            "label.isOpaque = false",
            "label.clipsToBounds = true",
            "label.font = .systemFont(ofSize: 17)",
            "label.textColor = UIColor.darkText",
            "",
            "tableViewCellSnoozeToggle.contentView.addSubview(label)",
            "",
            "tableViewCellSnoozeToggle.contentView.autoresizingMask = []",
            "tableViewCellSnoozeToggle.contentView.clipsToBounds = true",
            "tableViewCellSnoozeToggle.contentView.isOpaque = false",
            "tableViewCellSnoozeToggle.contentView.isMultipleTouchEnabled = true",
            "tableViewCellSnoozeToggle.contentView.contentMode = .center",
            "self.view = tableViewCellSnoozeToggle",
            ], warnings: [
                "document.objects.tableViewCell.tableViewCellContentView.subviews.label: useAutomaticPreferredMaxLayoutWidth='YES'",
                "Can not configure XML nodes 'point'",
            ])
    }

    /// This test will validate the generation eventually. The hope is to have a directory full of xib files and the generated code and ensure things don't change.
    func testXibResources() {
        let path = URL(fileURLWithPath: "/Users/brianking/sandbox/Eject/.nonPublicXIBs")
        let files = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])            
        let xibs = (files ?? []).filter() { $0.pathExtension == "xib" }
        for path in xibs {
            do {
                guard path.lastPathComponent == "InformationDetailView.xib" else {
                    continue
                }
                print("File: \(path.lastPathComponent)")
                let data = try Data(contentsOf: path)
                let builder = try XIBParser(data: data)
                let code = try builder.document.generateCode()
                if "print" == "print"{
                    print(code.joined(separator: "\n"))
                }
                else {
                    builder.document.warnings.forEach({ (warning) in
                        switch warning {
                        case let .unknownAttribute(message):
                            print(message)
                        case let .unknownElementName(message):
                            print(message)
                        default:
                            break
                        }
                    })
                }

            }
            catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }

}

extension EjectTests {

    static var allTests = [
        ("testString", testString),
        ("testViewPartsWithFrame", testViewPartsWithFrame),
        ("testGestureRecognizer", testGestureRecognizer),
        ("testLabel", testLabel),
        ("testUserDefined", testUserDefined),
        ("testLabelWithTextContent", testLabelWithTextContent),
        ("testLabelWithTextArgument", testLabelWithTextArgument),
        ("testColor", testColor),
        ("testAutoResizingMask", testAutoResizingMask),
        ("testFont", testFont),
        ("testCollectionView", testCollectionView),
        ("testTableView", testTableView),
        ("testImageView", testImageView),
        ("testButton", testButton),
        ("testActions", testActions),
        ("testViewHierarchy", testViewHierarchy),
        ("testHugging", testHugging),
        ("testAnchorageConstraints", testAnchorageConstraints),
        ("testVisualEffectViewKey", testVisualEffectViewKey),
        ("testSegmentedControl", testSegmentedControl),
        ("testMissingAttributes", testMissingAttributes),
        ]
}

