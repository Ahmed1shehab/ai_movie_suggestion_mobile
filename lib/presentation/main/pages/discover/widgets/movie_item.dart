import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:flutter/material.dart';

class MovieItemWidget extends StatelessWidget {
  final MovieEntity movie;

  const MovieItemWidget({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
         initMovieDetailsModule();
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.movieDetailsRoute,
                      arguments: MovieDetailsArguments(
                        movieId: movie.id,
                        routeName: Routes.mainRoute,
                      ),
                    );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.scaleSize(8)),
          child: Image.network(
            movie.posterUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.movie,
              size: SizeConfig.scaleSize(50),
            ),
          ),
        ),
      ),
    );
  }
}
