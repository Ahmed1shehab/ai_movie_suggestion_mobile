import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/watchlist/viewmodel/watchlist_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

class WatchlistView extends StatefulWidget {
  const WatchlistView({super.key});

  @override
  State<WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<WatchlistView> {
  WatchlistViewModel? _viewModel;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  void _initializeViewModel() async {
    try {
      if (_isDisposed) return; // Don't initialize if already disposed
      
      _viewModel = instance<WatchlistViewModel>();
      _viewModel!.start();
      
      // Add a small delay to ensure proper initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!_isDisposed && mounted) {
        await _viewModel!.loadLikedMovies();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing WatchlistViewModel: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_isInitialized && _viewModel != null) {
      try {
        _viewModel!.dispose();
      } catch (e) {
        print('Error disposing WatchlistViewModel: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        title: Text(
          'Liked Movies',
          style: TextStyle(
            fontSize: FontSize.s20,
            fontWeight: FontWeightManager.bold,
            color: ColorManager.white,
          ),
        ),
        backgroundColor: ColorManager.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorManager.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isInitialized && _viewModel != null)
            IconButton(
              onPressed: () {
                if (!_isDisposed && mounted) {
                  _viewModel!.refreshWatchlist();
                }
              },
              icon: Icon(Icons.refresh, color: ColorManager.white),
            ),
        ],
      ),
      body: _isInitialized ? _buildContent() : _buildLoadingState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading liked movies...',
            style: TextStyle(
              color: ColorManager.white,
              fontSize: FontSize.s16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_isInitialized || _viewModel == null) {
      return _buildLoadingState();
    }

    return StreamBuilder<FlowState>(
      stream: _viewModel!.outputState,
      builder: (context, snapshot) {
        return snapshot.data?.getScreenWidget(
              context,
              _getContentWidget(),
              () {
                if (!_isDisposed && mounted && _viewModel != null) {
                  _viewModel!.refreshWatchlist();
                }
              },
            ) ??
            _getContentWidget();
      },
    );
  }

  Widget _getContentWidget() {
    if (!_isInitialized || _viewModel == null) {
      return _buildLoadingState();
    }

    return StreamBuilder<List<MovieDetail>>(
      stream: _viewModel!.outputLikedMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final likedMovies = snapshot.data ?? [];

        if (likedMovies.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (!_isDisposed && mounted && _viewModel != null) {
             _viewModel!.refreshWatchlist();
            }
          },
          backgroundColor: ColorManager.primary,
          color: ColorManager.white,
          child: Container(
            color: ColorManager.background,
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with count
                  _buildHeader(likedMovies.length),
                  const SizedBox(height: AppSize.s16),

                  // Movies list
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: AppSize.s12,
                        mainAxisSpacing: AppSize.s12,
                      ),
                      itemCount: likedMovies.length,
                      itemBuilder: (context, index) {
                        final movie = likedMovies[index];
                        return _buildMovieCard(movie);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppSize.s80,
            color: ColorManager.error,
          ),
          const SizedBox(height: AppSize.s20),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: FontSize.s24,
              fontWeight: FontWeightManager.bold,
              color: ColorManager.white,
            ),
          ),
          const SizedBox(height: AppSize.s12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p32),
            child: Text(
              'Please try refreshing or go back and try again',
              style: TextStyle(
                fontSize: FontSize.s16,
                color: ColorManager.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSize.s32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.grey,
                  foregroundColor: ColorManager.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p24,
                    vertical: AppPadding.p12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.s12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!_isDisposed && mounted && _viewModel != null) {
                    _viewModel!.refreshWatchlist();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: ColorManager.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p24,
                    vertical: AppPadding.p12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.s12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int movieCount) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSize.s12),
        border: Border.all(
          color: ColorManager.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Liked Movies',
                style: TextStyle(
                  fontSize: FontSize.s18,
                  fontWeight: FontWeightManager.bold,
                  color: ColorManager.white,
                ),
              ),
              const SizedBox(height: AppSize.s4),
              Text(
                '$movieCount ${movieCount == 1 ? 'movie' : 'movies'} liked',
                style: TextStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.grey,
                ),
              ),
            ],
          ),
          StreamBuilder<bool>(
            stream: _viewModel?.outputIsLoading,
            builder: (context, snapshot) {
              final isLoading = snapshot.data ?? false;
              if (isLoading) {
                return SizedBox(
                  width: AppSize.s24,
                  height: AppSize.s24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ColorManager.primary),
                  ),
                );
              }
              return Icon(
                Icons.favorite,
                color: Colors.red,
                size: AppSize.s24,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(MovieDetail movie) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.s12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: ColorManager.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12),
          side: BorderSide(
            color: ColorManager.white.withOpacity(0.1),
          ),
        ),
        child: InkWell(
          onTap: () => _navigateToMovieDetails(movie.id!),
          borderRadius: BorderRadius.circular(AppSize.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Movie poster
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSize.s12),
                      topRight: Radius.circular(AppSize.s12),
                    ),
                    color: ColorManager.secondaryBlack,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSize.s12),
                          topRight: Radius.circular(AppSize.s12),
                        ),
                        child: movie.posterUrl != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w500${movie.posterUrl}',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage();
                                },
                              )
                            : _buildPlaceholderImage(),
                      ),
                      // Liked indicator
                      Positioned(
                        top: AppSize.s8,
                        right: AppSize.s8,
                        child: Container(
                          padding: const EdgeInsets.all(AppPadding.p4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(AppSize.s20),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: AppSize.s16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Movie info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.p12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        movie.title ?? 'Unknown Title',
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeightManager.medium,
                          color: ColorManager.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSize.s4),

                      // Rating if available
                      if (movie.voteAverage != null && movie.voteAverage! > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: AppSize.s12,
                            ),
                            const SizedBox(width: AppSize.s4),
                            Text(
                              '${movie.voteAverage!.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.grey,
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Remove button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => _showRemoveDialog(movie),
                            borderRadius: BorderRadius.circular(AppSize.s16),
                            child: Container(
                              padding: const EdgeInsets.all(AppPadding.p8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSize.s16),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.remove_circle_outline,
                                size: AppSize.s16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: ColorManager.secondaryBlack,
      child: Center(
        child: Icon(
          Icons.movie,
          size: AppSize.s40,
          color: ColorManager.grey,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: ColorManager.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: AppSize.s80,
              color: ColorManager.grey,
            ),
            const SizedBox(height: AppSize.s20),
            Text(
              'No Liked Movies Yet',
              style: TextStyle(
                fontSize: FontSize.s24,
                fontWeight: FontWeightManager.bold,
                color: ColorManager.white,
              ),
            ),
            const SizedBox(height: AppSize.s12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p32),
              child: Text(
                'Start exploring movies and tap the heart icon to add them to your liked movies list',
                style: TextStyle(
                  fontSize: FontSize.s16,
                  color: ColorManager.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSize.s32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                foregroundColor: ColorManager.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p32,
                  vertical: AppPadding.p16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.explore),
                  const SizedBox(width: AppSize.s8),
                  const Text(
                    'Explore Movies',
                    style: TextStyle(
                      fontSize: FontSize.s16,
                      fontWeight: FontWeightManager.medium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMovieDetails(int movieId) {
    try {
      initMovieDetailsModule();
      Navigator.pushNamed(
        context,
        Routes.movieDetailsRoute,
        arguments: MovieDetailsArguments(
          movieId: movieId,
          routeName: Routes.mainRoute,
        ),
      );
    } catch (e) {
      print('Error navigating to movie details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error opening movie details'),
          backgroundColor: ColorManager.error,
        ),
      );
    }
  }

  void _showRemoveDialog(MovieDetail movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.secondaryBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12),
        ),
        title: Text(
          'Remove from Liked Movies',
          style: TextStyle(
            color: ColorManager.white,
            fontSize: FontSize.s18,
            fontWeight: FontWeightManager.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${movie.title}" from your liked movies?',
          style: TextStyle(
            color: ColorManager.grey,
            fontSize: FontSize.s16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ColorManager.grey,
                fontSize: FontSize.s16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromLikedMovies(movie);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Remove',
              style: TextStyle(
                color: Colors.red,
                fontSize: FontSize.s16,
                fontWeight: FontWeightManager.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromLikedMovies(MovieDetail movie) {
    try {
      if (!_isDisposed && mounted && _viewModel != null) {
        _viewModel!.removeFromWatchlist(movie.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${movie.title} removed from liked movies',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.s8),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                if (!_isDisposed && mounted && _viewModel != null) {
                  _viewModel!.addToLikedMovies(movie.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${movie.title} added back to liked movies'),
                      backgroundColor: ColorManager.primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSize.s8),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error removing movie from liked movies: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error removing movie. Please try again.'),
            backgroundColor: ColorManager.error,
          ),
        );
      }
    }
  }
}