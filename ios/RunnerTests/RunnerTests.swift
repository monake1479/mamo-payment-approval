import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {

  func testPrivacyCoverIsOpaqueIdempotentAndRemovedWithoutReplacingContent() {
    let delegate = SceneDelegate()
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
    let content = UIView(frame: window.bounds)
    window.addSubview(content)
    delegate.window = window

    delegate.showPrivacyCover()
    delegate.showPrivacyCover()
    XCTAssertEqual(window.subviews.count, 2)
    let cover = window.subviews.last!
    XCTAssertEqual(cover.backgroundColor, .black)
    XCTAssertEqual(cover.frame, window.bounds)
    XCTAssertTrue(cover.accessibilityElementsHidden)
    XCTAssertTrue(cover.autoresizingMask.contains(.flexibleWidth))
    XCTAssertTrue(cover.autoresizingMask.contains(.flexibleHeight))

    delegate.hidePrivacyCover()
    delegate.hidePrivacyCover()
    XCTAssertEqual(window.subviews.count, 1)
    XCTAssertTrue(window.subviews.first === content)
  }

  func testPrivacyCoverBeforeWindowIsAvailableDoesNotBlockLaterUse() {
    let delegate = SceneDelegate()
    delegate.showPrivacyCover()
    delegate.hidePrivacyCover()
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
    delegate.window = window
    delegate.showPrivacyCover()
    XCTAssertEqual(window.subviews.count, 1)
    delegate.hidePrivacyCover()
    XCTAssertTrue(window.subviews.isEmpty)
  }

}
