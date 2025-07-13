// ignore_for_file: overridden_fields, annotate_overrides
import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';

class GetNowPlayingMoviesUseCase
    implements BaseUseCase<GetNowPlayingMoviesUseCaseInput, List<MovieEntity>> {
  final Repository _repository;

  GetNowPlayingMoviesUseCase(this._repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> execute(
      GetNowPlayingMoviesUseCaseInput input) async {
    return await _repository.nowPlaying(
      page: input.page,
      language: input.language,
    );
  }
}

class GetNowPlayingMoviesUseCaseInput extends BaseMovieUseCaseInput {
  final int? page;
  final String? language;

  GetNowPlayingMoviesUseCaseInput({
    this.page,
    this.language,
  }) : super(page: page, language: language);
}
