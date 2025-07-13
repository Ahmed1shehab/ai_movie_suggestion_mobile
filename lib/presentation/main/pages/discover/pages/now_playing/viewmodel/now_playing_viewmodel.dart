import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_now_playing_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';

class NowPlayingViewmodel extends BaseMovieViewModel {
  final GetNowPlayingMoviesUseCase _getNowPlayingMoviesUseCase;

  NowPlayingViewmodel(this._getNowPlayingMoviesUseCase);

  @override
  Future<Either<Failure, List<MovieEntity>>> executeUseCase(
      BaseMovieUseCaseInput input) async {
    return await _getNowPlayingMoviesUseCase
        .execute(input as GetNowPlayingMoviesUseCaseInput);
  }

  @override
  BaseMovieUseCaseInput createUseCaseInput(int page) {
    return GetNowPlayingMoviesUseCaseInput(page: page);
  }
}
