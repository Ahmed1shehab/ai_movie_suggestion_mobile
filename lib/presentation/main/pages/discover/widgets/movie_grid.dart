// movies_grid_widget.dart
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/widgets/movie_item.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

class MoviesGridWidget extends StatelessWidget {
  final List<MovieEntity> movies;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final Stream<bool> isLoadingStream;

  const MoviesGridWidget({
    Key? key,
    required this.movies,
    required this.scrollController,
    required this.onRefresh,
    required this.isLoadingStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig
    SizeConfig.init(context);

    // Calculate responsive grid properties
    final screenWidth = SizeConfig.screenWidth;
    final crossAxisCount =
        screenWidth > 600 ? 3 : 2; // 3 columns on tablets, 2 on phones
    final aspectRatio =
        screenWidth > 600 ? 0.75 : 0.7; // Slightly taller items on tablets

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(SizeConfig.scaleSize(AppPadding.p8)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: SizeConfig.scaleSize(AppPadding.p8),
          mainAxisSpacing: SizeConfig.scaleSize(AppPadding.p8),
          childAspectRatio: aspectRatio,
        ),
        itemCount: movies.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          if (index < movies.length) {
            return MovieItemWidget(movie: movies[index]);
          } else {
            return StreamBuilder<bool>(
              stream: isLoadingStream,
              builder: (context, snapshot) {
                if (snapshot.data ?? false) {
                  return Center(
                    child: SizedBox(
                      width: SizeConfig.scaleSize(24),
                      height: SizeConfig.scaleSize(24),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          }
        },
      ),
    );
  }
}
