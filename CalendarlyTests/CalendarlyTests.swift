import XCTest
@testable import Calendarly

class CalendarlyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBirthdayEvent() {
        let birthdayWOYear = BirthdayEvent(year: 0, month: 6, day: 30)
        let birthdayWYear = BirthdayEvent(year: 1987, month: 6, day: 30)

        let thirtiethBirthday = ISO8601DateFormatter().date(from: "2017-06-30T09:23:15+00:00")!

        XCTAssertEqual(birthdayWYear.nbrYearsTurned(today: thirtiethBirthday), .years(30))
        XCTAssertEqual(birthdayWOYear.nbrYearsTurned(today: thirtiethBirthday), .unknown)

        XCTAssertEqual(birthdayWYear.daysUntilBirthday(today: thirtiethBirthday), 0)
        XCTAssertEqual(birthdayWOYear.daysUntilBirthday(today: thirtiethBirthday), 0)

        XCTAssertEqual(birthdayWYear.daysUntilBirthday(), 247)
        XCTAssertEqual(birthdayWOYear.daysUntilBirthday(), 247)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
