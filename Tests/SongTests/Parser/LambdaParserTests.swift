import XCTest
@testable import SongLang

class LambdaParserTests: XCTestCase {

    func test_shouldParse() {
        "|x| x".makes(.lambda([.name("x")], .name("x")))
        "|x|x".makes(.lambda([.name("x")], .name("x")))
        "|x| (x)".makes(.lambda([.name("x")], .name("x")))
        "|x| x < 5".makes(.lambda([.name("x")], .call("<", [.name("x"), .int(5)])))
        "| x , y | x".makes(.function(Function(name: nil, patterns: [.name("x"), .name("y")], when: .yes, body: .name("x"))))
"""
 |
 x
 ,
 y
 |
 x
""".makes(.function(Function(name: nil, patterns: [.name("x"), .name("y")], when: .yes, body: .name("x"))))
        "|[x|xs], y| x".makes(.function(Function(name: nil, patterns: [.cons([.name("x")], .name("xs")), .name("y")], when: .yes, body: .name("x"))))
        "|_| 5".makes(.function(Function(name: nil, patterns: [.unnamed], when: .yes, body: .int(5))))
        "|| 5".makes(.function(Function(name: nil, patterns: [], when: .yes, body: .int(5))))
        "|[x, y], z| x".makes(.lambda([.list([.name("x"), .name("y")]), .name("z")], .name("x")))
    }

    func test_shouldNotParse() {
        "|(x)| x".fails()
        "|1| x".fails()
    }
}
