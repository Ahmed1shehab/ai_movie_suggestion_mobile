import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/movie_detail/viewmodel/movie_detail_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

class MovieDetailsView extends StatefulWidget {
  final int movieId;
  final String? language;

  const MovieDetailsView({
    Key? key,
    required this.movieId,
    this.language,
  }) : super(key: key);

  @override
  State<MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<MovieDetailsView> {
  final MovieDetailsViewModel _viewModel = instance<MovieDetailsViewModel>();

  @override
  void initState() {
    _bind();
    super.initState();
  }

  void _bind() {
    _viewModel.start();
    _viewModel.loadMovieDetails(widget.movieId, language: widget.language);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        title: const Text('Movie Details'),
        backgroundColor: ColorManager.primary,
        elevation: AppSize.s0,
      ),
      body: StreamBuilder<FlowState>(
        stream: _viewModel.outputState,
        builder: (context, snapshot) {
          return snapshot.data?.getScreenWidget(
                context,
                _getContentWidget(),
                () => _viewModel.loadMovieDetails(widget.movieId,
                    language: widget.language),
              ) ??
              _getContentWidget();
        },
      ),
    );
  }

  Widget _getContentWidget() {
    return StreamBuilder<MovieDetail?>(
      stream: _viewModel.outputData,
      builder: (context, snapshot) {
        final movie = snapshot.data;
        if (movie == null || movie == MovieDetail.empty()) {
          return Container(); // Loading handled by state renderer
        }
        return _buildMovieDetailsContent(movie);
      },
    );
  }

  Widget _buildMovieDetailsContent(MovieDetail movie) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMovieHeader(movie),
          const SizedBox(height: AppSize.s20),
          _buildMovieInfo(movie),
          const SizedBox(height: AppSize.s20),
          if (movie.overview?.isNotEmpty ?? false) ...[
            _buildOverview(movie),
            const SizedBox(height: AppSize.s20),
          ],
          if (movie.genres.isNotEmpty) ...[
            _buildGenres(movie),
            const SizedBox(height: AppSize.s20),
          ],
          if (movie.productionCompanies.isNotEmpty ||
              movie.productionCountries.isNotEmpty)
            _buildProductionInfo(movie),
        ],
      ),
    );
  }

  Widget _buildMovieHeader(MovieDetail movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Movie Poster
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSize.s12),
          child: movie.posterPath != null
              ? Image.network(
                  'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                  width: AppSize.s120,
                  height: AppSize.s180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPosterPlaceholder();
                  },
                )
              : _buildPosterPlaceholder(),
        ),

        const SizedBox(width: AppSize.s16),

        // Movie Basic Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title ?? 'Unknown Title',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorManager.grey,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (movie.originalTitle != null &&
                  movie.originalTitle != movie.title)
                Padding(
                  padding: const EdgeInsets.only(top: AppPadding.p4),
                  child: Text(
                    movie.originalTitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: ColorManager.grey,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: AppSize.s12),
              _buildRatingRow(movie),
              const SizedBox(height: AppSize.s8),
              if (movie.releaseDate != null)
                _buildInfoChip(
                    Icons.calendar_today, _formatDate(movie.releaseDate!)),
              const SizedBox(height: AppSize.s4),
              if (movie.runtime != null)
                _buildInfoChip(Icons.access_time, '${movie.runtime} min'),
              const SizedBox(height: AppSize.s4),
              if (movie.originalLanguage != null)
                _buildInfoChip(
                    Icons.language, movie.originalLanguage!.toUpperCase()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      width: AppSize.s120,
      height: AppSize.s180,
      decoration: BoxDecoration(
        color: ColorManager.grey,
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Icon(
        Icons.movie,
        size: AppSize.s40,
        color: ColorManager.grey,
      ),
    );
  }

  Widget _buildRatingRow(MovieDetail movie) {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: AppSize.s20,
        ),
        const SizedBox(width: AppSize.s4),
        Text(
          movie.voteAverage?.toStringAsFixed(1) ?? 'N/A',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorManager.grey,
              ),
        ),
        const SizedBox(width: AppSize.s8),
        Text(
          '(${movie.voteCount ?? 0})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColorManager.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppSize.s16,
          color: ColorManager.grey,
        ),
        const SizedBox(width: AppSize.s4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColorManager.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildMovieInfo(MovieDetail movie) {
    return Card(
      elevation: AppSize.s2,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movie Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.grey,
                  ),
            ),
            const SizedBox(height: AppSize.s12),
            if (movie.budget != null && movie.budget! > 0)
              _buildInfoRow('Budget', '\$${movie.budget!.toString()}'),
            if (movie.revenue != null && movie.revenue! > 0)
              _buildInfoRow('Revenue', '\$${movie.revenue!.toString()}'),
            if (movie.popularity != null)
              _buildInfoRow('Popularity', movie.popularity!.toStringAsFixed(1)),
            if (movie.isAdult == true)
              _buildInfoRow('Classification', 'Adult Content'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSize.s100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorManager.grey,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorManager.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(MovieDetail movie) {
    if (movie.overview == null || movie.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: AppSize.s2,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.grey,
                  ),
            ),
            const SizedBox(height: AppSize.s12),
            Text(
              movie.overview!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorManager.grey,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenres(MovieDetail movie) {
    if (movie.genres == null || movie.genres!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: AppSize.s2,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genres',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.grey,
                  ),
            ),
            const SizedBox(height: AppSize.s12),
            Wrap(
              spacing: AppSize.s8,
              runSpacing: AppSize.s8,
              children: movie.genres!.map((genre) {
                return Chip(
                  label: Text(
                    genre.name ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: ColorManager.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionInfo(MovieDetail movie) {
    final hasProductionCompanies = movie.productionCompanies != null &&
        movie.productionCompanies!.isNotEmpty;
    final hasProductionCountries = movie.productionCountries != null &&
        movie.productionCountries!.isNotEmpty;

    if (!hasProductionCompanies && !hasProductionCountries) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: AppSize.s2,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Production',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.grey,
                  ),
            ),
            const SizedBox(height: AppSize.s12),
            if (hasProductionCompanies) ...[
              Text(
                'Production Companies:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorManager.grey,
                    ),
              ),
              const SizedBox(height: AppSize.s8),
              ...movie.productionCompanies!.map((company) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p4),
                  child: Text(
                    '• ${company.name ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ColorManager.grey,
                        ),
                  ),
                );
              }).toList(),
              const SizedBox(height: AppSize.s12),
            ],
            if (hasProductionCountries) ...[
              Text(
                'Production Countries:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorManager.grey,
                    ),
              ),
              const SizedBox(height: AppSize.s8),
              ...movie.productionCountries!.map((country) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p4),
                  child: Text(
                    '• ${country.name ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ColorManager.grey,
                        ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
