import XCTest
@testable import RustSample

class RustSampleTests: XCTestCase {
    func testFind() {
        let rx = RustRegex(regex: "a..")!
        XCTAssertEqual(3, rx.find("oooabcd"), "Pass 1")
        XCTAssertEqual(1, rx.find("paappq"), "Pass 2")
        XCTAssertEqual(-1, rx.find("zzae"), "Pass 3")
    }
}
