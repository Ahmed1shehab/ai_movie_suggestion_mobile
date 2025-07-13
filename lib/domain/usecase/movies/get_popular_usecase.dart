// ignore_for_file: overridden_fields, annotate_overrides

import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';

class GetPopularUsecase
    implements BaseUseCase<GetPopularUsecaseInput, List<MovieEntity>> {
  final Repository _repository;

  GetPopularUsecase(this._repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> execute(
      GetPopularUsecaseInput input) async {
    return await _repository.popularMovies(
      page: input.page,
      language: input.language,
    );
  }
}

class GetPopularUsecaseInput extends BaseMovieUseCaseInput {
  final int? page;
  final String? language;

  GetPopularUsecaseInput({
    this.page,
    this.language,
  }) : super(page: page, language: language);
}
