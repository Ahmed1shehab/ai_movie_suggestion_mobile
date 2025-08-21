import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/movie_details_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
abstract class WatchlistViewModelInputs {
  Future<void> loadLikedMovies();
  Future<void> removeFromWatchlist(int movieId);
  void refreshWatchlist();
  // Add this new input
  Future<void> addToLikedMovies(int movieId);

  // Sinks
  Sink<List<MovieDetail>> get inputLikedMovies;
  Sink<bool> get inputIsLoading;
}

abstract class WatchlistViewModelOutputs {
  // Streams
  Stream<List<MovieDetail>> get outputLikedMovies;
  Stream<bool> get outputIsLoading;
  Stream<String?> get outputErrorMessage;
}

class WatchlistViewModel extends BaseViewmodel
    implements WatchlistViewModelInputs, WatchlistViewModelOutputs {
  final AppPreferences _appPreferences;
  final MovieDetailsUseCase _movieDetailsUseCase;

  // Stream controllers
  final _likedMoviesStreamController = BehaviorSubject<List<MovieDetail>>.seeded([]);
  final _loadingStreamController = BehaviorSubject<bool>.seeded(false);
  final _errorMessageStreamController = BehaviorSubject<String?>();

  WatchlistViewModel(this._appPreferences, this._movieDetailsUseCase);

  @override
  void start() {
    loadLikedMovies();
  }

  @override
  void dispose() {
    _likedMoviesStreamController.close();
    _loadingStreamController.close();
    _errorMessageStreamController.close();
    super.dispose();
  }

  @override
  Future<void> loadLikedMovies() async {
    // ... (rest of the loadLikedMovies method is unchanged)
    if (!_loadingStreamController.isClosed) {
      inputIsLoading.add(true);
    }

    try {
      final List<int> likedMovieIds = await _appPreferences.getLikedMovieIds();
      
      if (likedMovieIds.isEmpty) {
        if (!_likedMoviesStreamController.isClosed) {
          inputLikedMovies.add([]);
        }
        inputState.add(ContentState());
        return;
      }

      List<MovieDetail> likedMovies = [];
      
      for (int movieId in likedMovieIds) {
        try {
          final result = await _movieDetailsUseCase.execute(
            MovieDetailsUseCaseInput(movieId),
          );
          
          result.fold(
            (failure) {
              debugPrint('Failed to load movie $movieId: ${failure.message}');
            },
            (movieDetail) {
              likedMovies.add(movieDetail);
            },
          );
        } catch (e) {
          debugPrint('Error loading movie $movieId: $e');
        }
      }

      if (!_likedMoviesStreamController.isClosed) {
        inputLikedMovies.add(likedMovies);
      }
      
      inputState.add(ContentState());

    } catch (e) {
      debugPrint('Error in loadLikedMovies: $e');
      _showErrorMessage('Failed to load watchlist: $e');
      inputState.add(ErrorState(StateRendererType.fullScreenErrorState, e.toString()));
    } finally {
      if (!_loadingStreamController.isClosed) {
        inputIsLoading.add(false);
      }
    }
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await _appPreferences.removeFromLikedMovies(movieId);
      final currentMovies = _likedMoviesStreamController.value;
      final updatedMovies = currentMovies.where((movie) => movie.id != movieId).toList();
      
      if (!_likedMoviesStreamController.isClosed) {
        inputLikedMovies.add(updatedMovies);
      }

      debugPrint('Movie $movieId removed from watchlist');

    } catch (e) {
      debugPrint('Error removing movie from watchlist: $e');
      _showErrorMessage('Failed to remove from watchlist: $e');
    }
  }
  
  // Implement the new method
  @override
  Future<void> addToLikedMovies(int movieId) async {
    try {
      await _appPreferences.addToLikedMovies(movieId);
      // Reload the entire list to ensure consistency
      loadLikedMovies(); 
    } catch (e) {
      debugPrint('Error adding movie to liked movies: $e');
      _showErrorMessage('Failed to add movie to liked movies: $e');
    }
  }

  @override
  void refreshWatchlist() {
    loadLikedMovies();
  }

  // Helper method to get watchlist count
  Future<int> getWatchlistCount() async {
    return await _appPreferences.getLikedMoviesCount();
  }

  void _showErrorMessage(String message) {
    if (!_errorMessageStreamController.isClosed) {
      _errorMessageStreamController.add(message);
    }
    debugPrint('Error: $message');
  }

  // Inputs
  @override
  Sink<List<MovieDetail>> get inputLikedMovies => _likedMoviesStreamController.sink;

  @override
  Sink<bool> get inputIsLoading => _loadingStreamController.sink;

  // Outputs
  @override
  Stream<List<MovieDetail>> get outputLikedMovies => _likedMoviesStreamController.stream;

  @override
  Stream<bool> get outputIsLoading => _loadingStreamController.stream;

  @override
  Stream<String?> get outputErrorMessage => _errorMessageStreamController.stream;
}