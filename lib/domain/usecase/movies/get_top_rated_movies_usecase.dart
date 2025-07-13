// ignore_for_file: overridden_fields, annotate_overrides
import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class GetTopRatedMoviesUseCase
    implements BaseUseCase<GetTopRatedMoviesUseCaseInput, List<MovieEntity>> {
  final Repository _repository;

  GetTopRatedMoviesUseCase(this._repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> execute(
      GetTopRatedMoviesUseCaseInput input) async {
    debugPrint("🎯 GetTopRatedMoviesUseCase.execute called");
    debugPrint("📋 Input: page=${input.page}, language=${input.language}");
    return await _repository.topRatedMovies(
      page: input.page,
      language: input.language,
    );
  }
}

class GetTopRatedMoviesUseCaseInput extends BaseMovieUseCaseInput {
  final int? page;
  final String? language;

  GetTopRatedMoviesUseCaseInput({
    this.page,
    this.language,
  }) : super(page: page, language: language);
}
