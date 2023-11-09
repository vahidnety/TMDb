# TMDb: Movie Explorer App

Movie Explorer App is an iOS application that allows users to browse and explore information about movies, view details, and manage their favorites list. The app uses The Movie Database (TMDb) API to fetch movie information.

## Features

- **Now Playing List:** Browse a list of now playing movies with titles, release dates, and brief summaries.
- **Detailed Information:** View detailed information about each movie, including director, cast, and plot summary.
- **Favorites Functionality:** Add movies to your favorites list and view the list of favorited movies.
- **Search Functionality:** Search for movies by title.
- **Local Data Storage:** Store users' favorites lists locally on the device.
- **User Interface:** Engaging user interface with smooth operation on different screen sizes and orientations.
- **Image Loading Optimization:** Use image loading libraries for efficient loading and caching of movie cover images.

## Requirements

- Swift
- UIKit
- MVVM Design Pattern
- SOLID Principles with Protocols
- The Movie Database (TMDb) API Key

## API Endpoints

- Now Playing List: [TMDb Now Playing](https://api.themoviedb.org/3/movie/now_playing)
- Movie Details: [TMDb Movie Details](https://api.themoviedb.org/3/movie/{movie_id})
- Movie Images: [TMDb Movie Images](https://api.themoviedb.org/3/movie/{movie_id}/images)
- Search Movie: [TMDb Search Movie](https://api.themoviedb.org/3/search/movie)

## How to Use

1. Clone the repository.
2. Obtain a TMDb API Key by registering on [TMDb](https://www.themoviedb.org/).
3. Add your API Key to the appropriate places in the code.
4. Run the app on Xcode.

## Testing

- Unit and UI tests are included in the project.

## Contribution

Contributions are welcome! Feel free to submit issues and pull requests.

## License

This project is licensed under the [MIT License](LICENSE).
