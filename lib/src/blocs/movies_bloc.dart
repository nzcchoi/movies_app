import 'dart:async';
import 'dart:convert';
import '../models/item_model.dart';
import 'package:http/http.dart' show Client;

class MoviesBloc {
  Client _httpClient = Client();
  Movies _movies;
  
  // Change the api Key to yours via https://www.themoviedb.org
  final _apiKey = 'dbd1e7c41a095944d4457fb1918be32c';

  final _moviesStreamController = StreamController<Movies>();
  final _movieThumbUpStreamController = StreamController<Movie>();
  final _movieThumbDownStreamController = StreamController<Movie>();

  Stream<Movies> get moviesStream => _moviesStreamController.stream;
  StreamSink<Movies> get moviesSink => _moviesStreamController.sink;
  StreamSink<Movie> get movieThumbUpSink => _movieThumbUpStreamController.sink;
  StreamSink<Movie> get movieThumbDownSink => _movieThumbDownStreamController.sink;

  MoviesBloc() {
    initData();
    _movieThumbUpStreamController.stream.listen(_thumbUp);
    _movieThumbDownStreamController.stream.listen(_thumbDown);
  }

  initData() async {
    _movies = await loadMovies();
    _moviesStreamController.sink.add(_movies);
  }

  Future<Movies> loadMovies() async {
    final response = await _httpClient
        .get("http://api.themoviedb.org/3/movie/popular?api_key=$_apiKey");
    //print(response.body.toString());
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return Movies.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  dispose() {
    _moviesStreamController.close();
    _movieThumbUpStreamController.close();
    _movieThumbDownStreamController.close();
  }

  _thumbUp(Movie movie) {
    var item = _movies.results.where((m) => m.id == movie.id).first;
    item.voteCount++;
    _moviesStreamController.sink.add(_movies);
  }

  _thumbDown(Movie movie) {
    var item = _movies.results.where((m) => m.id == movie.id).first;
    item.voteCount--;
    _moviesStreamController.sink.add(_movies);
  }
}

