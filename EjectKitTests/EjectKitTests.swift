//
//  EjectTests.swift
//  EjectTests
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import XCTest
@testable import EjectKit

func checkXML(_ xml: String, _ expected: [String], file: StaticString = #file, line: UInt = #line) {
    do {
        let document = try IBDocument.load(xml: xml)
        let references = document.references
            .map() { $0 as? IBObject }.flatMap() { $0 } // Only generate IBObjects
            .reversed() // Walk the list in reverse
        guard references.count > 0 else {
            XCTFail("No objects in the document", file: file, line: line - 1)
            return
        }
        let context = GenerationContext(document: document, indentation: 0)
        var lines = references.map() { $0.generateCodeForConfiguration(in: context)}.flatMap() { $0 }
        lines.append(contentsOf: references.map() { $0.generateCode(in: context, for: .subviews) }.flatMap() { $0 })
        lines.append(contentsOf: references.map() { $0.generateCode(in: context, for: .constraints) }.flatMap() { $0 })

        XCTAssertEqual(lines.count, expected.count, file: file, line:line)
        var i: UInt = 1
        for (actualLine, expectedLine) in zip(lines, expected) {
            XCTAssertEqual(actualLine, expectedLine, file: file, line: line + i)
            i += 1
        }
        if lines != expected {
            print(lines.joined(separator: "\n"))
        }
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
        let string = "Test String"
        XCTAssertEqual(string.snakeCased(), "testString")
    }

    func testViewPartsWithFrame() {
        let xml = wrap("<view userLabel='test' clearsContextBeforeDrawing='NO' contentMode='scaleToFill' id='i5M-Pr-FkT'><rect key='frame' x='0.0' y='0.0' width='350' height='85'/></view>")
        checkXML(xml, [
            "let test = UIView()",
            "test.clearsContextBeforeDrawing = false",
            "test.contentMode = .scaleToFill",
            "test.frame = CGRect(x: 0.0, y: 0.0, width: 350, height: 85)"
            ]
        )
    }

    // Method ordering is broken here, not sure if this is fatal to compile-out-of-the-box.
    func testGestureRecognizer() {
        let xml = wrap("<view userLabel='test' id='i5M-Pr-FkT'><connections><outletCollection property='gestureRecognizers' destination='fDa-KR-68j' appends='YES' id='7AV-8r-dYL'/></connections></view><panGestureRecognizer minimumNumberOfTouches='1' id='fDa-KR-68j'><connections>            <action selector='dimissTextField:' destination='-1' id='zAI-0B-Wyz'/><outlet property='delegate' destination='i5M-Pr-FkT' id='0eg-ac-TGD'/></connections></panGestureRecognizer>")
        checkXML(xml, [
            "let panGestureRecognizer = UIPanGestureRecognizer()",
            "panGestureRecognizer.minimumNumberOfTouches = 1",
            "panGestureRecognizer.delegate = test",
            "let test = UIView()",
            "test.gestureRecognizers.append(panGestureRecognizer)",
            "panGestureRecognizer.addTarget(fileOwner, action: #selector(TestClass.dimissTextField:))",
            ]
        )
    }

    func testUserDefinedInt() {
        let xml = wrap("<view userLabel='test' id='i5M-Pr-FkT'><userDefinedRuntimeAttributes><userDefinedRuntimeAttribute type='number' keyPath='layer.cornerRadius'><integer key='value' value='25'/></userDefinedRuntimeAttribute></userDefinedRuntimeAttributes></view>")
        checkXML(xml, [
            "let test = UIView()",
            "test.layer.cornerRadius = 25"
            ]
        )
    }

    func testLabelWithTextContent() {
        let xml = wrap("<label userLabel='test' id='i5M-Pr-FkT'><mutableString key='text'>body</mutableString></label>")
        checkXML(xml, [
            "let test = UILabel()",
            "test.text = \"body\""
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
            ]
        )
    }

    func testLabel() {
        let xml = wrap("<label baselineAdjustment='alignBaselines' minimumFontSize='13' userLabel='test' id='i5M-Pr-FkT'><fontDescription key='fontDescription' type='system' pointSize='17'/></label>")
        checkXML(xml, [
            "let test = UILabel()",
            "test.minimumFontSize = 13",
            "test.baselineAdjustment = .alignBaselines",
            "test.font = .systemFont(ofSize: 17)"
            ]
        )
    }

    func testCollectionView() {
        let xml = wrap("<collectionView contentMode='scaleToFill' dataMode='none' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><collectionViewFlowLayout key='collectionViewLayout' minimumLineSpacing='10' minimumInteritemSpacing='10' id='sFl-c5-v9d'><size key='itemSize' width='50' height='50'/><size key='headerReferenceSize' width='0.0' height='0.0'/><size key='footerReferenceSize' width='0.0' height='0.0'/><inset key='sectionInset' minX='0.0' minY='0.0' maxX='0.0' maxY='0.0'/></collectionViewFlowLayout><connections><outlet property='dataSource' destination='-1' id='0eg-ac-TGD'/><outlet property='delegate' destination='-1' id='jQ0-LG-WAK'/></connections></collectionView>")
        checkXML(xml, [
            "let collectionViewFlowLayout = UICollectionViewFlowLayout()",
            "collectionViewFlowLayout.itemSize = CGSize(width: 50, height: 50)",
            "collectionViewFlowLayout.headerReferenceSize = CGSize(width: 0.0, height: 0.0)",
            "collectionViewFlowLayout.footerReferenceSize = CGSize(width: 0.0, height: 0.0)",
            "collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)",
            "let collectionView = UICollectionView()",
            "collectionView.translatesAutoresizingMaskIntoConstraints = false",
            "collectionView.contentMode = .scaleToFill",
            "collectionView.frame = CGRect(x: 11, y: 11, width: 328, height: 578)",
            "collectionView.collectionViewLayout = collectionViewFlowLayout",
            "collectionView.dataSource = fileOwner",
            "collectionView.delegate = fileOwner",
            ])
    }

    func testTableView() {
        let xml = wrap("<tableView alwaysBounceVertical='YES' style='plain' separatorStyle='default' rowHeight='44' sectionHeaderHeight='28' sectionFooterHeight='28' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><color key='backgroundColor' white='1' alpha='1' colorSpace='calibratedWhite'/><inset key='separatorInset' minX='15' minY='0.0' maxX='15' maxY='0.0'/><connections><outlet property='dataSource' destination='-1' id='0eg-ac-TGD'/><outlet property='delegate' destination='-1' id='jQ0-LG-WAK'/></connections></tableView>")
        checkXML(xml, [
            "let tableView = UITableView(frame: .zero, style: .plain)",
            "tableView.translatesAutoresizingMaskIntoConstraints = false",
            "tableView.alwaysBounceVertical = true",
            "tableView.separatorStyle = .default",
            "tableView.rowHeight = 44",
            "tableView.sectionHeaderHeight = 28",
            "tableView.sectionFooterHeight = 28",
            "tableView.frame = CGRect(x: 11, y: 11, width: 328, height: 578)",
            "tableView.backgroundColor = UIColor(white: 1, alpha: 1)",
            "tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 30.0)",
            "tableView.dataSource = fileOwner",
            "tableView.delegate = fileOwner",
            ])
    }

    func testImageView() {
        let xml = wrap("<imageView contentMode='center' image='icon' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT'></imageView>")
        checkXML(xml, [
            "let imageView = UIImageView()",
            "imageView.translatesAutoresizingMaskIntoConstraints = false",
            "imageView.contentMode = .center",
            "imageView.image = UIImage(named: \"icon\")",
            ])
    }

    func testButton() {
        let xml = wrap("<button contentHorizontalAlignment='center' contentVerticalAlignment='center' lineBreakMode='middleTruncation' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><state key='normal' title='Title' image='icon'><color key='titleColor' white='1' alpha='1' colorSpace='calibratedWhite'/><color key='titleShadowColor' white='0.0' alpha='0.0' colorSpace='calibratedWhite'/></state><connections><action selector='doThing:' destination='-1' eventType='touchUpInside' id='39P-Rs-7z2'/></connections></button>")
        checkXML(xml, [
            "let button = UIButton()",
            "button.lineBreakMode = .middleTruncation", // This is deprecated and should be .titleLabel.lineBreakMode
            "button.frame = CGRect(x: 11, y: 11, width: 328, height: 578)",
            "button.setTitle(\"Title\", for: .normal)",
            "button.setImage(UIImage(named: \"icon\"), for: .normal)",
            "button.setTitlecolor(UIColor(white: 1, alpha: 1), for: .normal)",
            "button.setTitleshadowcolor(UIColor(white: 0, alpha: 0), for: .normal)",
            "button.addTarget(fileOwner, action: #selector(TestClass.doThing:), for: .touchUpInside)"
            ])
    }

    func testActions() {
        let xml = wrap("<view id='i5M-Pr-FkT'><subviews><view id='FUp-2k-EIR' userLabel='BorderView'><subviews><webView id='glB-HT-PdE'/></subviews></view><view id='aaa-bb-ccc' userLabel='OtherView'/></subviews></view>")
        checkXML(xml, [
            "let otherView = UIView()",
            "let webView = UIWebView()",
            "let borderView = UIView()",
            "let view = UIView()",
            "borderView.addSubview(webView)",
            "view.addSubview(borderView)",
            "view.addSubview(otherView)",
            ])
    }

    func testViewHierarchy() {
        let xml = wrap("<view id='i5M-Pr-FkT'><subviews><view id='FUp-2k-EIR' userLabel='BorderView'><subviews><webView id='glB-HT-PdE'/></subviews></view><view id='aaa-bb-ccc' userLabel='OtherView'/></subviews></view>")
        checkXML(xml, [
            "let otherView = UIView()",
            "let webView = UIWebView()",
            "let borderView = UIView()",
            "let view = UIView()",
            "borderView.addSubview(webView)",
            "view.addSubview(borderView)",
            "view.addSubview(otherView)",
            ])
    }

    func testAnchorageConstraints() {
        let xml = wrap("<view id='i5M-Pr-FkT'><rect key='frame' x='0.0' y='0.0' width='350' height='85'/><autoresizingMask key='autoresizingMask' widthSizable='YES' heightSizable='YES'/><subviews><view id='UX2-VG-eOo' customClass='CircularToggleView'><rect key='frame' x='0.0' y='29' width='28' height='28'/><color key='backgroundColor' white='1' alpha='1' colorSpace='calibratedWhite'/><constraints><constraint firstAttribute='height' constant='28' id='BqJ-XJ-eyz'/><constraint firstAttribute='width' constant='28' id='nMF-V2-XRU'/></constraints></view><label id='19u-jG-JIO'><rect key='frame' x='36' y='36' width='52' height='14'/><fontDescription key='fontDescription' name='Gotham-Book' family='Gotham' pointSize='14'/><color key='textColor' red='0.50196078430000002' green='0.50196078430000002' blue='0.50196078430000002' alpha='1' colorSpace='calibratedRGB'/><nil key='highlightedColor'/></label></subviews><color key='backgroundColor' white='0.0' alpha='0.0' colorSpace='calibratedWhite'/><constraints><constraint firstItem='UX2-VG-eOo' firstAttribute='leading' secondItem='i5M-Pr-FkT' secondAttribute='leading' id='5fR-oy-xvA'/><constraint firstItem='UX2-VG-eOo' firstAttribute='centerY' secondItem='i5M-Pr-FkT' secondAttribute='centerY' id='6Qn-oN-YHI'/><constraint firstAttribute='bottom' relation='greaterThanOrEqual' secondItem='19u-jG-JIO' secondAttribute='bottom' constant='20' symbolic='YES' id='BGy-u3-ENo'/><constraint firstAttribute='trailing' relation='greaterThanOrEqual' secondItem='19u-jG-JIO' secondAttribute='trailing' constant='20' symbolic='YES' id='Kgc-VK-hur'/><constraint firstItem='19u-jG-JIO' firstAttribute='centerY' secondItem='UX2-VG-eOo' secondAttribute='centerY' id='jSG-kc-EZ6'/><constraint firstItem='19u-jG-JIO' firstAttribute='top' relation='greaterThanOrEqual' secondItem='i5M-Pr-FkT' secondAttribute='top' constant='20' symbolic='YES' id='trv-aZ-Isd'/><constraint firstItem='19u-jG-JIO' firstAttribute='leading' secondItem='UX2-VG-eOo' secondAttribute='trailing' priority='100' constant='8' id='zMe-2W-nrz'/></constraints></view>")
        checkXML(xml, [
            "let label = UILabel()",
            "label.frame = CGRect(x: 36, y: 36, width: 52, height: 14)",
            "label.font = UIFont(name: \"Gotham-Book\", size: 14)",
            "label.textColor = UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1)",
            "label.highlightedColor = nil",
            "let circularToggleView = CircularToggleView()",
            "circularToggleView.frame = CGRect(x: 0.0, y: 29, width: 28, height: 28)",
            "circularToggleView.backgroundColor = UIColor(white: 1, alpha: 1)",
            "let view = UIView()",
            "view.frame = CGRect(x: 0.0, y: 0.0, width: 350, height: 85)",
            "view.backgroundColor = UIColor(white: 0, alpha: 0)",
            "view.addSubview(circularToggleView)",
            "view.addSubview(label)",
            "circularToggleView.height == 28",
            "circularToggleView.width == 28",
            "circularToggleView.leading == view.leading",
            "circularToggleView.centerY == view.centerY",
            "view.bottom == label.bottom + 20",
            "view.trailing == label.trailing + 20",
            "label.centerY == circularToggleView.centerY",
            "label.top == view.top + 20",
            "label.leading == circularToggleView.trailing + 8 ~ 100"
            ])
    }

    func testVisualEffectViewKey() {
        let xml = wrap("<visualEffectView opaque='NO' contentMode='scaleToFill' translatesAutoresizingMaskIntoConstraints='NO' id='i5M-Pr-FkT' userLabel='Top Bar Blur Container'><view key='contentView' opaque='NO' id='u6B-MW-OWb'></view></visualEffectView>")
        checkXML(xml, [])
    }

    func testSegmentedControl() {
        let xml = wrap("<segmentedControl segmentControlStyle='plain' selectedSegmentIndex='0' id='i5M-Pr-FkT'><rect key='frame' x='11' y='11' width='328' height='578'/><segments><segment title='Overview'/><segment title='Description'/></segments></segmentedControl>")
        checkXML(xml, [])
    }

    /// This test will validate the generation eventually. The hope is to have a directory full of xib files and the generated code and ensure things don't change.
    func testXibResources() {
        for path in Bundle(for: type(of: self)).paths(forResourcesOfType: "xibtest", inDirectory: "") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let builder = try XIBParser(data: data)
                let code = builder.document.generateCode()
                print(code)
            }
            catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
}
