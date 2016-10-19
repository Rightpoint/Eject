//
//  EjectTests.swift
//  EjectTests
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import XCTest
func EJAssert(_ xml: String, _ expected: [String], file: StaticString = #file, line: UInt = #line) {
    do {
        let builder = try XIBParser(content: xml, documentBuilder: CocoaTouchBuilder())
        let references = builder.document.references
        guard references.count == 1 else {
            XCTFail("Expecting 1 object in document")
            return
        }
        let object = references[0]
        let lines = object.generateCodeForConfiguration(in: GenerationContext(document: builder.document, indentation: 0))
        XCTAssertEqual(lines, expected, file: file, line: line)
    }
    catch let error {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
class EjectTests: XCTestCase {

    func testViewPartsWithFrame() {
        let xml = "<view userLabel='test' clearsContextBeforeDrawing='NO' contentMode='scaleToFill' id='i5M-Pr-FkT'><rect key='frame' x='0.0' y='0.0' width='350' height='85'/></view>"
        EJAssert(xml, [
            "let test = UIView()",
            "test.clearsContextBeforeDrawing = false",
            "test.contentMode = .scaleToFill",
            "test.frame = CGRect(x: 0.0, y:0.0, width: 350.0, height: 85.0)"
            ]
        )
    }

    func testUserDefinedInt() {
        let xml = "<view userLabel='test' clearsContextBeforeDrawing='NO' contentMode='scaleToFill' id='i5M-Pr-FkT'><userDefinedRuntimeAttributes><userDefinedRuntimeAttribute type='number' keyPath='layer.cornerRadius'><integer key='value' value='25'/></userDefinedRuntimeAttribute></userDefinedRuntimeAttributes></view>"
        EJAssert(xml, [
            "let test = UIView()",
            "test.clearsContextBeforeDrawing = false",
            "test.contentMode = .scaleToFill",
            "test.layer.cornderRadius = 25"
            ]
        )
    }

    func testKeyContainedView() {
        let xml = "<view userLabel='test' clearsContextBeforeDrawing='NO' contentMode='scaleToFill' id='i5M-Pr-FkT'><userDefinedRuntimeAttributes><userDefinedRuntimeAttribute type='number' keyPath='layer.cornerRadius'><integer key='value' value='25'/></userDefinedRuntimeAttribute></userDefinedRuntimeAttributes></view>"
        EJAssert(xml, []
        )
    }

    func testLabelWithTextContent() {
        let xml = "<label userLabel='test' id='bPg-qz-5Ab'><mutableString key='text'>body</mutableString></label>"
        EJAssert(xml, [
            "let test = UIView()",
            "test.text = \"body\""
            ]
        )
    }

    func testButtonState() {
        let xml = "<button opaque='NO' contentMode='scaleToFill' contentHorizontalAlignment='center' contentVerticalAlignment='center' lineBreakMode='middleTruncation' translatesAutoresizingMaskIntoConstraints='NO' id='W6X-J3-pyJ'><state key='normal' title='Title' image='icon'><color key='titleColor' white='1' alpha='1' colorSpace='calibratedWhite'/><color key='titleShadowColor' white='0.0' alpha='0.0' colorSpace='calibratedWhite'/></state>"
        EJAssert(xml, [])
    }

    func testSegmentedControl() {
        let xml = "<segmentedControl segmentControlStyle='plain' selectedSegmentIndex='0' id='Lr8-3h-7XM'><segments><segment title='Overview'/><segment title='Description'/></segments></segmentedControl>"
        EJAssert(xml, [])
    }

    func testLabelFontDescription() {
        let xml = "<label userLabel='test' id='bPg-qz-5Ab'><fontDescription key='fontDescription' type='system' pointSize='17'/></label>"
        EJAssert(xml, [])
    }

    func testCollectionView() {
        let xml = "<collectionView clipsSubviews='YES' multipleTouchEnabled='YES' contentMode='scaleToFill' dataMode='none' translatesAutoresizingMaskIntoConstraints='NO' id='t0h-Fv-JAb'><collectionViewFlowLayout key='collectionViewLayout' minimumLineSpacing='10' minimumInteritemSpacing='10' id='sFl-c5-v9d'><size key='itemSize' width='50' height='50'/><size key='headerReferenceSize' width='0.0' height='0.0'/>                       <size key='footerReferenceSize' width='0.0' height='0.0'/><inset key='sectionInset' minX='0.0' minY='0.0' maxX='0.0' maxY='0.0'/>                   </collectionViewFlowLayout></collectionView>"
        EJAssert(xml, [])
    }

    func testImageView() {
        let xml = "<imageView contentMode='center' image='icon' translatesAutoresizingMaskIntoConstraints='NO' id='bwC-d3-Rvn'></imageView>"
        EJAssert(xml, [])
    }

    func testVisualEffectViewKey() {
        let xml = "<visualEffectView opaque='NO' contentMode='scaleToFill' translatesAutoresizingMaskIntoConstraints='NO' id='SSx-0V-8aJ' userLabel='Top Bar Blur Container'><view key='contentView' opaque='NO' id='u6B-MW-OWb'></view></visualEffectView>"
        EJAssert(xml, [])
    }

    func testButton() {
        let xml = "<button opaque='NO' contentMode='scaleToFill' contentHorizontalAlignment='center' contentVerticalAlignment='center' buttonType='roundedRect' lineBreakMode='middleTruncation' translatesAutoresizingMaskIntoConstraints='NO' id='ziF-Lo-Cdu' userLabel='Scroll To Live' customClass='MyButton'>                    <state key='normal' title='Title'><color key='titleColor' white='1' alpha='1' colorSpace='calibratedWhite'/><color key='titleShadowColor' white='0.5' alpha='1' colorSpace='calibratedWhite'/></state><connections><action selector='doThing:' destination='-1' eventType='touchUpInside' id='39P-Rs-7z2'/></connections></button>"
        EJAssert(xml, [])
    }

    func testXibResources() {
        for path in Bundle(for: type(of: self)).paths(forResourcesOfType: "xibtest", inDirectory: "") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let builder = try XIBParser(data: data, documentBuilder: CocoaTouchBuilder())
                let code = builder.document.generateCode()
                print(code)
            }
            catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
}
