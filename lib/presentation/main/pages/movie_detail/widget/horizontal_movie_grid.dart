import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HorizontalMoviesGrid extends StatelessWidget {
  final List<MovieEntity> movies;
  final bool isLoading;
  final String title;
  final VoidCallback? onSeeAll;
  final Function(MovieEntity)? onMovieTap;
  final double itemHeight;
  final double itemWidth;
  final bool showTitle;
  final bool showRating;
  final bool showYear;
  final int crossAxisCount;
  final double childAspectRatio;

  const HorizontalMoviesGrid({
    Key? key,
    required this.movies,
    this.isLoading = false,
    this.title = '',
    this.onSeeAll,
    this.onMovieTap,
    this.itemHeight = 220.0,
    this.itemWidth = 140.0,
    this.showTitle = true,
    this.showRating = true,
    this.showYear = true,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
  }) : super(key: key);

  factory HorizontalMoviesGrid.similarMovies({
    Key? key,
    required List<MovieEntity> movies,
    bool isLoading = false,
    Function(MovieEntity)? onMovieTap,
    VoidCallback? onSeeAll,
  }) {
    return HorizontalMoviesGrid(
      key: key,
      movies: movies,
      isLoading: isLoading,
      title: AppStrings.similarMovies,
      onMovieTap: onMovieTap,
      onSeeAll: onSeeAll,
      itemHeight: 240.0, // Increased height to accommodate content
      itemWidth: 140.0,
      showTitle: true,
      showRating: true,
      showYear: true,
      crossAxisCount: 2,
      childAspectRatio: 0.7,
    );
  }

  factory HorizontalMoviesGrid.recommended({
    Key? key,
    required List<MovieEntity> movies,
    bool isLoading = false,
    Function(MovieEntity)? onMovieTap,
    VoidCallback? onSeeAll,
  }) {
    return HorizontalMoviesGrid(
      key: key,
      movies: movies,
      isLoading: isLoading,
      title: AppStrings.recommended,
      onMovieTap: onMovieTap,
      onSeeAll: onSeeAll,
      itemHeight: 220.0, // Increased height
      itemWidth: 130.0,
      showTitle: true,
      showRating: true,
      showYear: false,
      crossAxisCount: 2,
      childAspectRatio: 0.7,
    );
  }

  factory HorizontalMoviesGrid.trending({
    Key? key,
    required List<MovieEntity> movies,
    bool isLoading = false,
    Function(MovieEntity)? onMovieTap,
    VoidCallback? onSeeAll,
  }) {
    return HorizontalMoviesGrid(
      key: key,
      movies: movies,
      isLoading: isLoading,
      title: AppStrings.trending,
      onMovieTap: onMovieTap,
      onSeeAll: onSeeAll,
      itemHeight: 270.0, // Increased height
      itemWidth: 160.0,
      showTitle: true,
      showRating: true,
      showYear: true,
      crossAxisCount: 2,
      childAspectRatio: 0.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) _buildSectionHeader(context),
        if (isLoading)
          _buildLoadingWidget()
        else if (movies.isEmpty)
          _buildEmptyWidget(context)
        else
          _buildMoviesGrid(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                AppStrings.seeAll,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorManager.primary,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.only(right: AppSize.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: itemWidth,
                  height: itemHeight * 0.65, // Reduced poster height ratio
                  decoration: BoxDecoration(
                    color: ColorManager.grey,
                    borderRadius: BorderRadius.circular(AppSize.s8),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.primary,
                      strokeWidth: AppSize.s2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s8),
                Container(
                  width: itemWidth * 0.8,
                  height: AppSize.s12,
                  decoration: BoxDecoration(
                    color: ColorManager.grey,
                    borderRadius: BorderRadius.circular(AppSize.s4),
                  ),
                ),
                const SizedBox(height: AppSize.s4),
                Container(
                  width: itemWidth * 0.5,
                  height: AppSize.s10,
                  decoration: BoxDecoration(
                    color: ColorManager.grey,
                    borderRadius: BorderRadius.circular(AppSize.s4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return  Container(
      height: itemHeight,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: AppSize.s48,
              color: ColorManager.grey,
            ),
            const SizedBox(height: AppSize.s8),
            Text(
              AppStrings.noMoviesFound,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorManager.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesGrid(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.only(right: AppSize.s12),
            child: _buildMovieCard(context, movie),
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, MovieEntity movie) {
    return InkWell(
      onTap: () => onMovieTap?.call(movie),
      borderRadius: BorderRadius.circular(AppSize.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoviePoster(movie),
          const SizedBox(height: AppSize.s8),
          _buildMovieInfo(context, movie),
        ],
      ),
    );
  }

  Widget _buildMoviePoster(MovieEntity movie) {
    // Calculate poster height to leave more space for info
    final posterHeight = itemHeight * 0.65; // Reduced from 0.7 to 0.65

    return Container(
      width: itemWidth,
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.s8),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black,
            blurRadius: AppSize.s4,
            offset: const Offset(0, AppSize.s2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.s8),
        child: _buildNetworkImage(
          imageUrl: movie.posterUrl,
          width: itemWidth,
          height: posterHeight,
        ),
      ),
    );
  }

  Widget _buildMovieInfo(BuildContext context, MovieEntity movie) {
    // Calculate available height for movie info
    final availableHeight = itemHeight - (itemHeight * 0.65) - AppSize.s8;

    return SizedBox(
      height: availableHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (showTitle)
            Flexible(
              child: Text(
                movie.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: AppSize.s4),
          // Use Flexible to prevent overflow
          Flexible(
            child: Row(
              children: [
                if (showYear && movie.releaseDate != null) ...[
                  Flexible(
                    child: Text(
                      '${movie.releaseDate!.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ColorManager.cardColor,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showRating) ...[
                    const SizedBox(width: AppSize.s4),
                    Text(
                      '•',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ColorManager.cardColor,
                          ),
                    ),
                    const SizedBox(width: AppSize.s4),
                  ],
                ],
                if (showRating) ...[
                  Icon(
                    Icons.star_rate_rounded,
                    color: ColorManager.star,
                    size: AppSize.s14,
                  ),
                  const SizedBox(width: AppSize.s2),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ColorManager.star,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage({
    required String? imageUrl,
    required double width,
    required double height,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: ColorManager.grey,
        child: const Icon(
          Icons.movie,
          size: AppSize.s40,
          color: Colors.white54,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: ColorManager.grey,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: AppSize.s2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: ColorManager.grey,
        child: const Icon(
          Icons.error,
          size: AppSize.s40,
          color: Colors.white54,
        ),
      ),
    );
  }
}
