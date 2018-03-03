import XCTest
@testable import Song

class NumberTests: XCTestCase {

    func test_plus() {
        XCTAssertEqual(Number.int(13), Number.int(9).plus(Number.int(4)))
        XCTAssertEqual(Number.float(13.0), Number.int(9).plus(Number.float(4.0)))
        XCTAssertEqual(Number.float(13.0), Number.float(9.0).plus(Number.int(4)))
        XCTAssertEqual(Number.float(13.0), Number.float(9.0).plus(Number.float(4.0)))
    }

    func test_minus() {
        XCTAssertEqual(Number.int(5), Number.int(9).minus(Number.int(4)))
        XCTAssertEqual(Number.float(5.0), Number.int(9).minus(Number.float(4.0)))
        XCTAssertEqual(Number.float(5.0), Number.float(9.0).minus(Number.int(4)))
        XCTAssertEqual(Number.float(5.0), Number.float(9.0).minus(Number.float(4.0)))
    }

    func test_times() {
        XCTAssertEqual(Number.int(36), Number.int(9).times(Number.int(4)))
        XCTAssertEqual(Number.float(36.0), Number.int(9).times(Number.float(4.0)))
        XCTAssertEqual(Number.float(36.0), Number.float(9.0).times(Number.int(4)))
        XCTAssertEqual(Number.float(36.0), Number.float(9.0).times(Number.float(4.0)))
    }

    func test_integerDividedBy() {
        XCTAssertEqual(Number.int(2), try Number.int(9).integerDividedBy(Number.int(4)))
        XCTAssertThrowsError(try Number.int(9).integerDividedBy(Number.float(4.0)))
        XCTAssertThrowsError(try Number.float(9.0).integerDividedBy(Number.int(4)))
        XCTAssertThrowsError(try Number.float(9.0).integerDividedBy(Number.float(4.0)))
    }

    func test_floatDividedBy() {
        XCTAssertEqual(Number.float(2.0), Number.int(8).floatDividedBy(Number.int(4)))
        XCTAssertEqual(Number.float(2.0), Number.float(8.0).floatDividedBy(Number.int(4)))
        XCTAssertEqual(Number.float(2.0), Number.int(8).floatDividedBy(Number.float(4.0)))
        XCTAssertEqual(Number.float(2.0), Number.float(8.0).floatDividedBy(Number.float(4.0)))
    }

    func test_modulo() {
        XCTAssertEqual(Number.int(1), try Number.int(9).modulo(Number.int(4)))
        XCTAssertThrowsError(try Number.int(9).modulo(Number.float(4.0)))
        XCTAssertThrowsError(try Number.float(9.0).modulo(Number.int(4)))
        XCTAssertThrowsError(try Number.float(9.0).modulo(Number.float(4.0)))
    }

    func test_equalTo() {
        XCTAssertTrue(try Number.int(9).equalTo(Number.int(9)))
        XCTAssertThrowsError(try Number.int(9).equalTo(Number.float(4.0)))
        XCTAssertThrowsError(try Number.float(9.0).equalTo(Number.int(4)))
        XCTAssertThrowsError(try Number.float(9.0).equalTo(Number.float(4.0)))
    }

    func test_lessThan() {
        XCTAssertFalse(Number.int(9).lessThan(Number.int(4)))
        XCTAssertFalse(Number.int(9).lessThan(Number.float(4.0)))
        XCTAssertFalse(Number.float(9.0).lessThan(Number.int(4)))
        XCTAssertFalse(Number.float(9.0).lessThan(Number.float(4.0)))
        XCTAssertTrue(Number.int(9).lessThan(Number.int(14)))
        XCTAssertTrue(Number.int(9).lessThan(Number.float(14.0)))
        XCTAssertTrue(Number.float(9.0).lessThan(Number.int(14)))
        XCTAssertTrue(Number.float(9.0).lessThan(Number.float(14.0)))
    }

    func test_greaterThan() {
        XCTAssertTrue(Number.int(9).greaterThan(Number.int(4)))
        XCTAssertTrue(Number.int(9).greaterThan(Number.float(4.0)))
        XCTAssertTrue(Number.float(9.0).greaterThan(Number.int(4)))
        XCTAssertTrue(Number.float(9.0).greaterThan(Number.float(4.0)))
        XCTAssertFalse(Number.int(9).greaterThan(Number.int(14)))
        XCTAssertFalse(Number.int(9).greaterThan(Number.float(14.0)))
        XCTAssertFalse(Number.float(9.0).greaterThan(Number.int(14)))
        XCTAssertFalse(Number.float(9.0).greaterThan(Number.float(14.0)))
    }

    func test_lessThanOrEqualTo() {
        XCTAssertFalse(Number.int(9).lessThanOrEqualTo(Number.int(4)))
        XCTAssertFalse(Number.int(9).lessThanOrEqualTo(Number.float(4.0)))
        XCTAssertFalse(Number.float(9.0).lessThanOrEqualTo(Number.int(4)))
        XCTAssertFalse(Number.float(9.0).lessThanOrEqualTo(Number.float(4.0)))
        XCTAssertTrue(Number.int(9).lessThanOrEqualTo(Number.int(9)))
        XCTAssertTrue(Number.int(9).lessThanOrEqualTo(Number.float(9.0)))
        XCTAssertTrue(Number.float(9.0).lessThanOrEqualTo(Number.int(9)))
        XCTAssertTrue(Number.float(9.0).lessThanOrEqualTo(Number.float(9.0)))
        XCTAssertTrue(Number.int(9).lessThanOrEqualTo(Number.int(14)))
        XCTAssertTrue(Number.int(9).lessThanOrEqualTo(Number.float(14.0)))
        XCTAssertTrue(Number.float(9.0).lessThanOrEqualTo(Number.int(14)))
        XCTAssertTrue(Number.float(9.0).lessThanOrEqualTo(Number.float(14.0)))
    }

    func test_greaterThanOrEqualTo() {
        XCTAssertTrue(Number.int(9).greaterThanOrEqualTo(Number.int(4)))
        XCTAssertTrue(Number.int(9).greaterThanOrEqualTo(Number.float(4.0)))
        XCTAssertTrue(Number.float(9.0).greaterThanOrEqualTo(Number.int(4)))
        XCTAssertTrue(Number.float(9.0).greaterThanOrEqualTo(Number.float(4.0)))
        XCTAssertTrue(Number.int(9).greaterThanOrEqualTo(Number.int(9)))
        XCTAssertTrue(Number.int(9).greaterThanOrEqualTo(Number.float(9.0)))
        XCTAssertTrue(Number.float(9.0).greaterThanOrEqualTo(Number.int(9)))
        XCTAssertTrue(Number.float(9.0).greaterThanOrEqualTo(Number.float(9.0)))
        XCTAssertFalse(Number.int(9).greaterThanOrEqualTo(Number.int(14)))
        XCTAssertFalse(Number.int(9).greaterThanOrEqualTo(Number.float(14.0)))
        XCTAssertFalse(Number.float(9.0).greaterThanOrEqualTo(Number.int(14)))
        XCTAssertFalse(Number.float(9.0).greaterThanOrEqualTo(Number.float(14.0)))
    }

    func test_intFloatEquality() {
        XCTAssertNotEqual(Number.int(5), Number.float(5.0))
        XCTAssertNotEqual(Number.float(5.0), Number.int(5))
    }

    func test_truncate_float() {
        XCTAssertEqual(Number.int(5), Number.float(5.1).truncate())
        XCTAssertEqual(Number.int(5), Number.float(5.9).truncate())
        XCTAssertEqual(Number.int(-5), Number.float(-5.1).truncate())
        XCTAssertEqual(Number.int(-5), Number.float(-5.9).truncate())
    }

    func test_truncate_int() {
        XCTAssertEqual(Number.int(5), Number.int(5).truncate())
    }
}
