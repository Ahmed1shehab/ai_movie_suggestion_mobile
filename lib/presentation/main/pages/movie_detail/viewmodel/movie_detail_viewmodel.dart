import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/movie_details_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';

class MovieDetailsViewModel extends BaseDetailsViewModel<MovieDetail> {
  final MovieDetailsUseCase _movieDetailsUseCase;

  MovieDetailsViewModel(this._movieDetailsUseCase);

  @override
  Future<Either<Failure, MovieDetail>> executeUseCase(
      BaseMovieUseCaseInput input) async {
    // Safe cast with error handling
    try {
      final detailsInput = input as MovieDetailsUseCaseInput;
      final result = await _movieDetailsUseCase.execute(detailsInput);
      
      return result.map((list) {
        if (list.isEmpty) {
          return MovieDetail.empty();
        }
        return list.first;
      });
    } catch (e) {
      return Left(Failure(ApiInternalStatus.failure, e.toString()));
    }
  }

  Future<void> loadMovieDetails(int movieId, {String? language}) async {
    final input = MovieDetailsUseCaseInput(movieId, language: language);
    await loadData(input);
  }

  @override
  void start() {
    // Optional initialization logic can go here
  }
}