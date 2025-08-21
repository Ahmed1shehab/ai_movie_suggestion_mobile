import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dartz/dartz.dart';
import 'package:ai_movie_suggestion/data/network/failure.dart';

// Base input class for movie use cases
abstract class BaseMovieUseCaseInput {
  final int? page;
  final String? language;

  BaseMovieUseCaseInput({
    this.page,
    this.language,
  });
}

// Base view model for movie-related screens
abstract class BaseMovieViewModel extends BaseViewmodel
    implements BaseMovieViewModelInput, BaseMovieViewModelOutput {
  final _moviesStreamController = BehaviorSubject<List<MovieEntity>>();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isDisposed = false;

  // Abstract method that child classes must implement
  Future<Either<Failure, List<MovieEntity>>> executeUseCase(
      BaseMovieUseCaseInput input);

  // -- Inputs --
  @override
  void start() {
    if (!_isDisposed) {
      _loadMovies();
    }
  }

  @override
  void loadMore() {
    if (!_isLoading && !_isDisposed) {
      _currentPage++;
      _loadMovies();
    }
  }

  @override
  void refresh() {
    if (!_isDisposed) {
      _currentPage = 1;
      _loadMovies(refresh: true);
    }
  }

  // Abstract method to create input - each child implements their specific input type
  BaseMovieUseCaseInput createUseCaseInput(int page);

  Future<void> _loadMovies({bool refresh = false}) async {
    if (_isDisposed) return;
    
    _isLoading = true;

    if (refresh || _currentPage == 1) {
      inputState.add(LoadingState(
        stateRendererType: StateRendererType.fullScreenLoadingState,
      ));
    }

    final input = createUseCaseInput(_currentPage);
    final result = await executeUseCase(input);

    if (_isDisposed) return;

    result.fold(
      (failure) {
        if (!_isDisposed) {
          inputState.add(ErrorState(
              StateRendererType.fullScreenErrorState, failure.message));
        }
      },
      (movies) {
        if (_isDisposed) return;

        if (refresh) {
          inputMovies.add(movies);
        } else {
          final currentMovies = _moviesStreamController.valueOrNull ?? [];
          inputMovies.add([...currentMovies, ...movies]);
        }

        inputState.add(ContentState());
      },
    );

    _isLoading = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _moviesStreamController.close();
    super.dispose();
  }

  @override
  Sink get inputMovies => _moviesStreamController.sink;

  // -- Outputs --
  @override
  Stream<List<MovieEntity>> get outputMovies =>
      _moviesStreamController.stream.map((movies) => movies);

  @override
  Stream<bool> get outputIsLoading => outputMovies.map((movies) => _isLoading);
}

// Base interfaces
abstract class BaseMovieViewModelInput {
  void loadMore();
  void refresh();
  Sink get inputMovies;
}

abstract class BaseMovieViewModelOutput {
  Stream<List<MovieEntity>> get outputMovies;
  Stream<bool> get outputIsLoading;
}