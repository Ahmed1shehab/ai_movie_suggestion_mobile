  import 'package:ai_movie_suggestion/data/network/failure.dart';
  import 'package:ai_movie_suggestion/domain/model/models.dart';
  import 'package:ai_movie_suggestion/domain/usecase/movies/get_upcoming_usecase.dart';
  import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
  import 'package:dartz/dartz.dart';

  class NewReleasesViewmodel extends BaseMovieViewModel {
    final GetUpcomingUsecase _getUpcomingUsecase;
    NewReleasesViewmodel(this._getUpcomingUsecase);

    @override
    Future<Either<Failure, List<MovieEntity>>> executeUseCase(
        BaseMovieUseCaseInput input) async {
      return await _getUpcomingUsecase.execute(input as GetUpcomingUsecaseInput);
    }

    @override
    BaseMovieUseCaseInput createUseCaseInput(int page) {
      return GetUpcomingUsecaseInput(page: page);
    }
  }
