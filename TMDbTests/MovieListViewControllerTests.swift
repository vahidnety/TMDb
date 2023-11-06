//
//  MovieListViewControllerTests.swift
//  TMDbTests
//
//  Created by Seyedvahid Dianat on 2023-10-28.
//


import XCTest
@testable import TMDb // Import your app module

class MovieListViewControllerTests: XCTestCase {
    var viewController: MovieListViewController!
    var viewModel: MockMovieListViewModel!
    var settingsViewModel: MockSettingsViewModel!

    override func setUp() {
        super.setUp()
        
        // Create a mock MovieListViewModel for testing
        viewModel = MockMovieListViewModel()
        settingsViewModel = MockSettingsViewModel()
        
        // Initialize the view controller with the mock viewModel
        viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "MovieListViewController") as? MovieListViewController
        viewController.viewModel = viewModel
        viewController.settingsViewModel = settingsViewModel
        
        // Load the view
        viewController.loadView()
    }
    
    override func tearDown() {
        viewController = nil
        viewModel = nil
        super.tearDown()
    }
    
    // Test if the table view is correctly configured in viewDidLoad
    func testTableViewConfiguration() {
        XCTAssertNotNil(viewController.tableView.delegate)
        XCTAssertNotNil(viewController.tableView.dataSource)
    }
    
    // Test fetchMovies method in the view controller
    func testFetchMovies() {
        // Mock a successful movie fetch
        viewModel.shouldSucceed = true
        viewController.fetchMovies()
        
        // Check if the table view gets reloaded after successful fetch
        XCTAssertTrue(viewModel.didFetchMovies)
        XCTAssertTrue(viewController.tableView.numberOfRows(inSection: 0) == viewModel.movies.count)
    }
    
    // Test that the UI is updated when the view appears
    func testViewWillAppear() {
        // Mock a change in sort or filter options
        viewModel.shouldUpdateOptions = true
        viewModel.shouldSucceed = true
        viewController.extractFilterSortOptionsUpdateTable()
        
        // Check if the table view gets reloaded after updating options
//        XCTAssertTrue(viewModel.didFetchMovies)
        XCTAssertTrue(viewController.tableView.numberOfRows(inSection: 0) == viewModel.movies.count)
    }
}

// Create a MockMovieListViewModel for testing
class MockMovieListViewModel: MovieListViewModelProtocol {
    var movies: [Movie] = []
    var errorDelegate: ErrorHandlingDelegate?
    
    var shouldSucceed = false // Simulate a successful fetch
    var shouldUpdateOptions = false // Simulate option updates
    var didFetchMovies = false
    
    func fetchNowPlayingMovies(sortOption: String?, filterOption: String?, completion: @escaping (Result<Void, AppError>) -> Void) {
        // Simulate a successful fetch
        if shouldSucceed {
            // Create valid JSON data for Movie instances
            let movie1Data = """
            {
            "title": "Movie 1"
            ,"posterPath": "https://www.pngall.com/wp-content/uploads/8/Sample-PNG-HD-Image.png"
            ,"adult": true
            , "backdropPath": ""
            , "genreIds": [1,2,3]
            , "id": 123
            , "originalLanguage": "en"
            , "originalTitle": " This is the original title1."
            , "overview": "This is sample test overview1."
            , "popularity": 1.0
            , "releaseDate": "1988.01.01"
            , "title": "Sample title1"
            , "video": true
            , "voteAverage": 1.0
            , "voteCount": 1
            }
            """.data(using: .utf8)!
            let movie2Data = """
            {
            "title": "Movie 2"
            ,"posterPath": "https://www.pngall.com/wp-content/uploads/8/Sample-PNG-Image.png"
            ,"adult": true
            , "backdropPath": ""
            , "genreIds": [1,2,3]
            , "id": 1234
            , "originalLanguage": "en"
            , "originalTitle": " This is the original title2."
            , "overview": "This is sample test overview2."
            , "popularity": 1.0
            , "releaseDate": "1988.01.01"
            , "title": "Sample title2"
            , "video": true
            , "voteAverage": 1.0
            , "voteCount": 1
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            do {
                let movie1 = try decoder.decode(Movie.self, from: movie1Data)
                let movie2 = try decoder.decode(Movie.self, from: movie2Data)
                movies = [movie1, movie2]
                didFetchMovies = true
                completion(.success(()))
            } catch {
                completion(.failure(AppError.parsingError))
                
            }
        } else {
            // Simulate an error
            completion(.failure(AppError.other("Fetch failed")))
        }
    }
    
    func loadImage(for movie: Movie, completion: @escaping (Result<UIImage, AppError>) -> Void) {
        // Simulate a successful image load
        if let image = UIImage(named: "Sample-PNG-HD-Image") {
            completion(.success(image))
        } else {
            // Simulate an error if the image cannot be found
            completion(.failure(AppError.dataNotFound))
        }
    }
}



class MovieListViewModelTests: XCTestCase {
    var viewModel: MovieListViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        
        // Create a real or mock MoviePlayingService and initialize the viewModel
        let moviePlayingService = MockMoviePlayingService()
        viewModel = MovieListViewModel(moviePlayingService: moviePlayingService)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // Test fetchNowPlayingMovies method in the view model
    func testFetchNowPlayingMovies() {
        // Mock a successful movie fetch
        viewModel.fetchNowPlayingMovies(sortOption: "Popularity", filterOption: "All") { result in
            switch result {
            case .success:
                XCTAssertTrue(self.viewModel.movies.count > 0)
            case .failure:
                XCTFail("Fetch failed")
            }
        }
    }
    
    // Test loadImage method in the view model
    func testLoadImage() {
        let movieData = """
            {
            "title": "Movie 1"
            ,"posterPath": "https://www.pngall.com/wp-content/uploads/8/Sample-PNG-HD-Image.png"
            ,"adult": true
            , "backdropPath": ""
            , "genreIds": [1,2,3]
            , "id": 123
            , "originalLanguage": "en"
            , "originalTitle": " This is the original title1."
            , "overview": "This is sample test overview1."
            , "popularity": 1.0
            , "releaseDate": "1988.01.01"
            , "title": "Sample title1"
            , "video": true
            , "voteAverage": 1.0
            , "voteCount": 1
            }
            """.data(using: .utf8)!
        
        
        let decoder = JSONDecoder()
        let movie = try! decoder.decode(Movie.self, from: movieData)
        let expectation = XCTestExpectation(description: "Image loaded successfully")
        
        viewModel.loadImage(for: movie) { result in
            switch result {
            case .success(let image):
                // Check if the image was loaded successfully
                XCTAssertNotNil(image)
                expectation.fulfill()
            case .failure(let error):
                // Image loading should not fail in this test
                XCTFail("Image loading failed with error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0) // Adjust the timeout as needed
    }
    
}

// Create a MockMoviePlayingService for testing
class MockMoviePlayingService: MoviePlayingServiceProtocol {
    
    func fetchNowPlayingMovies(sortOption: String?, filterOption: String?, completion: @escaping (Result<[Movie], AppError>) -> Void) {
        // Create valid JSON data for Movie instances
        let movie1Data = """
        {
        "title": "Movie 1"
        ,"posterPath": "https://www.pngall.com/wp-content/uploads/8/Sample-PNG-HD-Image.png"
        ,"adult": true
        , "backdropPath": ""
        , "genreIds": [1,2,3]
        , "id": 123
        , "originalLanguage": "en"
        , "originalTitle": " This is the original title1."
        , "overview": "This is sample test overview1."
        , "popularity": 1.0
        , "releaseDate": "1988.01.01"
        , "title": "Sample title1"
        , "video": true
        , "voteAverage": 1.0
        , "voteCount": 1
        }
        """.data(using: .utf8)!
        let movie2Data = """
        {
        "title": "Movie 2"
        ,"posterPath": "https://www.pngall.com/wp-content/uploads/8/Sample-PNG-Image.png"
        ,"adult": true
        , "backdropPath": ""
        , "genreIds": [1,2,3]
        , "id": 1234
        , "originalLanguage": "en"
        , "originalTitle": " This is the original title2."
        , "overview": "This is sample test overview2."
        , "popularity": 1.0
        , "releaseDate": "1988.01.01"
        , "title": "Sample title2"
        , "video": true
        , "voteAverage": 1.0
        , "voteCount": 1
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let movie1 = try decoder.decode(Movie.self, from: movie1Data)
            let movie2 = try decoder.decode(Movie.self, from: movie2Data)
            let movies = [movie1, movie2]
            completion(.success(movies))
        } catch {
            completion(.failure(AppError.parsingError))
        }
    }
    
    func downloadMovieImage(from endpointString: String?, completion: @escaping (Result<UIImage, TMDb.AppError>) -> Void) {
        // Simulate a successful image download
        let image = UIImage(named: "Sample-PNG-HD-Image")!
        completion(.success(image))
    }
}
