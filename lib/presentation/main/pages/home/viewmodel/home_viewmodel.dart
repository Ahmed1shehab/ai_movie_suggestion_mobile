import 'dart:async';
import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_top_rated_movies_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/search_movies_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

class TopRatedViewModel extends BaseMovieViewModel {
  final GetTopRatedMoviesUseCase _getTopRatedMoviesUseCase;
  final SearchMoviesUsecase _searchMoviesUsecase;

  // Search related streams
  final StreamController<String> _searchQueryStreamController = BehaviorSubject<String>();
  final StreamController<List<MovieEntity>> _searchResultsStreamController = BehaviorSubject<List<MovieEntity>>();
  final StreamController<bool> _isSearchingStreamController = BehaviorSubject<bool>();

  // Debounce timer
  Timer? _debounceTimer;
  String _currentSearchQuery = '';
  bool _isSearchMode = false;

  TopRatedViewModel(this._getTopRatedMoviesUseCase, this._searchMoviesUsecase);

  // Inputs
  @override // Assuming inputSearchQuery is part of BaseMovieViewModelInputs or specific TopRatedViewModelInputs
  Sink get inputSearchQuery => _searchQueryStreamController.sink;

  // Outputs
  Stream<String> get outputSearchQuery => _searchQueryStreamController.stream.map((query) => query);
  Stream<List<MovieEntity>> get outputSearchResults => _searchResultsStreamController.stream.map((results) => results);
  Stream<bool> get outputIsSearching => _isSearchingStreamController.stream.map((isSearching) => isSearching);

  void onSearchQueryChanged(String query) {
    if (isDisposed) return; // Add this check

    _currentSearchQuery = query.trim();
    if (!_searchQueryStreamController.isClosed) { // <--- Added check
      inputSearchQuery.add(_currentSearchQuery);
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (_currentSearchQuery.isEmpty) {
      _isSearchMode = false;
      if (!_isSearchingStreamController.isClosed) { // <--- Added check
        _isSearchingStreamController.add(false);
      }
      if (!_searchResultsStreamController.isClosed) { // <--- Added check
        _searchResultsStreamController.add([]);
      }
      return;
    }

    _isSearchMode = true;
    if (!_isSearchingStreamController.isClosed) { // <--- Added check
      _isSearchingStreamController.add(true);
    }


    // Debounce search for 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Ensure the search is only performed if the ViewModel is still active
      if (!isDisposed) { // <--- IMPORTANT: Check before initiating the async search
        _performSearch(_currentSearchQuery);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (isDisposed) return; // <--- IMPORTANT: Early exit if disposed

    if (query.isEmpty) return;

    if (!_isSearchingStreamController.isClosed) { // <--- Added check
      _isSearchingStreamController.add(true);
    }

    final result = await _searchMoviesUsecase.execute(
      SearchMoviesUsecaseInput(query, page: 1),
    );

    result.fold(
      (failure) {
        if (isDisposed) return; // <--- IMPORTANT: Check again inside fold
        if (!_isSearchingStreamController.isClosed) { // <--- Added check (this is the problematic line 73)
          _isSearchingStreamController.add(false);
        }
        if (!_searchResultsStreamController.isClosed) { // <--- Added check
          _searchResultsStreamController.add([]);
        }
        // You might want to show error state here (also add isClosed check if using a stream)
        // if (!outputErrorMessage.isClosed) { // Assuming an outputErrorMessage stream
        //   outputErrorMessage.add(failure.message);
        // }
      },
      (movies) {
        if (isDisposed) return; // <--- IMPORTANT: Check again inside fold
        if (!_isSearchingStreamController.isClosed) { // <--- Added check
          _isSearchingStreamController.add(false);
        }
        if (!_searchResultsStreamController.isClosed) { // <--- Added check
          _searchResultsStreamController.add(movies);
        }
      },
    );
  }

  void clearSearch() {
    if (isDisposed) return; // Add this check

    _currentSearchQuery = '';
    _isSearchMode = false;
    _debounceTimer?.cancel();

    if (!_searchQueryStreamController.isClosed) { // <--- Added check
      _searchQueryStreamController.add('');
    }
    if (!_searchResultsStreamController.isClosed) { // <--- Added check
      _searchResultsStreamController.add([]);
    }
    if (!_isSearchingStreamController.isClosed) { // <--- Added check
      _isSearchingStreamController.add(false);
    }
  }

  bool get isSearchMode => _isSearchMode;
  String get currentSearchQuery => _currentSearchQuery;

  @override
  Future<Either<Failure, List<MovieEntity>>> executeUseCase(
      BaseMovieUseCaseInput input) async {
    
    return await _getTopRatedMoviesUseCase
        .execute(input as GetTopRatedMoviesUseCaseInput);
  }

  @override
  BaseMovieUseCaseInput createUseCaseInput(int page) {
    return GetTopRatedMoviesUseCaseInput(page: page);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchQueryStreamController.close();
    _searchResultsStreamController.close();
    _isSearchingStreamController.close();
    super.dispose(); 
  }
}