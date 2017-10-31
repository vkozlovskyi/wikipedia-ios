import XCTest

class WikipediaUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        app.tabBars.buttons["Saved"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.links["Barack Obama\n44th President of the United States of America"]/*[[".cells.links[\"Barack Obama\\n44th President of the United States of America\"]",".links[\"Barack Obama\\n44th President of the United States of America\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Wikipedia, return to Saved"].buttons["Saved"].tap()
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.links["Geometry\nBranch of mathematics that measures the shape, size and position of objects"]/*[[".cells.links[\"Geometry\\nBranch of mathematics that measures the shape, size and position of objects\"]",".links[\"Geometry\\nBranch of mathematics that measures the shape, size and position of objects\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Wikipedia, return to Saved"].buttons["Saved"].tap()
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.links["Mercer Museum\nThe Mercer Museum is a museum located in Doylestown, Pennsylvania, United States. The Bucks County Historical Society operates the Mercer Museum, as well as the Research Library, and Fonthill Castle, former home of the museum's founder, archeologist Henry Chapman Mercer. The museum was individually listed on the National Register of Historic Places in 1972, and was later included in a National Historic Landmark District along with the Moravian Pottery and Tile Works and Fonthill."]/*[[".cells.links[\"Mercer Museum\\nThe Mercer Museum is a museum located in Doylestown, Pennsylvania, United States. The Bucks County Historical Society operates the Mercer Museum, as well as the Research Library, and Fonthill Castle, former home of the museum's founder, archeologist Henry Chapman Mercer. The museum was individually listed on the National Register of Historic Places in 1972, and was later included in a National Historic Landmark District along with the Moravian Pottery and Tile Works and Fonthill.\"]",".links[\"Mercer Museum\\nThe Mercer Museum is a museum located in Doylestown, Pennsylvania, United States. The Bucks County Historical Society operates the Mercer Museum, as well as the Research Library, and Fonthill Castle, former home of the museum's founder, archeologist Henry Chapman Mercer. The museum was individually listed on the National Register of Historic Places in 1972, and was later included in a National Historic Landmark District along with the Moravian Pottery and Tile Works and Fonthill.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Wikipedia, return to Saved"].buttons["Saved"].tap()
    }
    
}
