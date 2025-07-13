import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
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
          Navigator.pushNamed(context, '/movie-details', arguments: movie);
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
