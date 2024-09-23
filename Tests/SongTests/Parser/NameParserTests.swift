import XCTest
import SongLang

class NameParserTests: XCTestCase {

    func test_shouldParse() {
        "_".makes(.ignore)
        "x".makes(.name("x"))
        "_x".makes(.name("_x"))
        "_private".makes(.name("_private"))
        "goodName".makes(.name("goodName"))
        "good_name".makes(.name("good_name"))
        "goodName99".makes(.name("goodName99"))
        "good_".makes(.name("good_"))
    }

    func test_shouldNotParse() {
        "GoodName".fails()
        "9bottles".fails()
    }
}
