//
//  CoordinatorTests.swift
//  Game2048Tests
//
//  Created by Вадим Попов on 05.05.2023.
//

import XCTest


final class CoordinatorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUnique() throws {
        let a1 = TemplateTestClass<Int>(value: 1)
        let a2 = TemplateTestClass<String>(value: 2)
        let a3 = TemplateTestClass<Double>(value: 3)
        
        let coordinator = Coordinator()
        
        coordinator.setReference(with: a1)
        coordinator.setReference(with: a2)
        coordinator.setReference(with: a3)
        
        XCTAssertNotNil(coordinator.getReference(for: TemplateTestClass<Int>.self))
        XCTAssertNotNil(coordinator.getReference(for: TemplateTestClass<String>.self))
        XCTAssertNotNil(coordinator.getReference(for: TemplateTestClass<Double>.self))
        
        XCTAssertEqual(coordinator.getReference(for: TemplateTestClass<Int>.self).value, a1.value)
        XCTAssertEqual(coordinator.getReference(for: TemplateTestClass<String>.self).value, a2.value)
        XCTAssertEqual(coordinator.getReference(for: TemplateTestClass<Double>.self).value, a3.value)
    }

}

final class TemplateTestClass<T> {
    public let value: Int
    public var stType: T? = nil
    
    public init(value: Int) {
        self.value = value
    }
}
