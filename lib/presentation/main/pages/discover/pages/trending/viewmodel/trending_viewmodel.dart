import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_popular_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';

class TrendingViewmodel extends BaseMovieViewModel {
  final GetPopularUsecase _getPopularUsecase;

  TrendingViewmodel(this._getPopularUsecase);

  @override
  Future<Either<Failure, List<MovieEntity>>> executeUseCase(
      BaseMovieUseCaseInput input) async {
    return await _getPopularUsecase.execute(input as GetPopularUsecaseInput);
  }

  @override
  BaseMovieUseCaseInput createUseCaseInput(int page) {
    return GetPopularUsecaseInput(page: page);
  }
}
