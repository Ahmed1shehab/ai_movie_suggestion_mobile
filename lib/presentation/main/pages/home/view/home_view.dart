import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/home/viewmodel/home_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/home/widgets/image_widget.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/constants_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class TopRatedView extends StatefulWidget {
  const TopRatedView({Key? key}) : super(key: key);

  @override
  State<TopRatedView> createState() => _TopRatedViewState();
}

class _TopRatedViewState extends State<TopRatedView> {
  final TopRatedViewModel _viewModel = instance<TopRatedViewModel>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    _bind();
    super.initState();
  }

  void _bind() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Only load more if not in search mode
        if (!_viewModel.isSearchMode) {
          _viewModel.loadMore();
        }
      }
    });

    // Listen to search controller changes
    _searchController.addListener(() {
      _viewModel.onSearchQueryChanged(_searchController.text);
    });

    _viewModel.start();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FlowState>(
      stream: _viewModel.outputState,
      builder: (context, snapshot) {
        return snapshot.data?.getScreenWidget(
              context,
              _getContentWidget(context),
              () {
                _viewModel.start();
              },
            ) ??
            _getContentWidget(context);
      },
    );
  }

  Widget _getContentWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(AppPadding.p8),
          child: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: ColorManager.background,
        actions: [
          StreamBuilder<String>(
            stream: _viewModel.outputSearchQuery,
            builder: (context, snapshot) {
              final hasSearchQuery = (snapshot.data ?? '').isNotEmpty;
              return hasSearchQuery
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: ColorManager.white,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _viewModel.clearSearch();
                        _searchFocusNode.unfocus();
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: ColorManager.white,
                      ),
                      onPressed: () => _viewModel.refresh(),
                    );
            },
          ),
        ],
      ),
      backgroundColor: ColorManager.background,
      body: _getBody(), // Call the refactored _getBody
    );
  }

  Widget _getBody() {
    return Column( // Use a Column to hold the search bar stably at the top
      children: [
        _getSearchBar(), // The search bar is now always here

        Expanded( // The content below the search bar will change
          child: StreamBuilder<String>(
            stream: _viewModel.outputSearchQuery,
            builder: (context, searchSnapshot) {
              final isSearchMode = (searchSnapshot.data ?? '').isNotEmpty;

              if (isSearchMode) {
                // Only show search results content
                return _getSearchResultsContent();
              } else {
                // Only show main movie list content
                return StreamBuilder<List<MovieEntity>>(
                  stream: _viewModel.outputMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _getMoviesListContent(snapshot.data!);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // Refactored from _getSearchResults to _getSearchResultsContent
  // This no longer contains the search bar itself, just the results display
  Widget _getSearchResultsContent() {
    return StreamBuilder<bool>(
      stream: _viewModel.outputIsSearching,
      builder: (context, loadingSnapshot) {
        final isSearching = loadingSnapshot.data ?? false;

        if (isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<MovieEntity>>(
          stream: _viewModel.outputSearchResults,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final searchResults = snapshot.data!;

            if (searchResults.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: ColorManager.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No movies found',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: ColorManager.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ColorManager.grey,
                          ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppPadding.p16,
                  mainAxisSpacing: AppPadding.p20,
                  childAspectRatio: 0.6,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return _getMovieItem(searchResults[index]);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Refactored from _getMoviesListWithHeader to _getMoviesListContent
  // This no longer contains the search bar itself, just the movie list
  Widget _getMoviesListContent(List<MovieEntity> movies) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _getHeaderNonSearchBarContent(), // New method for header without search bar
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppPadding.p16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppPadding.p16,
              mainAxisSpacing: AppPadding.p20,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _getMovieItem(movies[index]);
              },
              childCount: movies.length,
            ),
          ),
        ),
        // Fixed loading indicator
        StreamBuilder<bool>(
          stream: _viewModel.outputIsLoading,
          builder: (context, snapshot) {
            if (snapshot.data ?? false) {
              return SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppPadding.p20),
                  height: 80, // Fixed height prevents overflow
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else {
              return const SliverToBoxAdapter(
                child: SizedBox(height: AppPadding.p20),
              );
            }
          },
        ),
      ],
    );
  }

  // New method: _getHeaderNonSearchBarContent
  // This contains all the elements of the header *except* the search bar.
  Widget _getHeaderNonSearchBarContent() {
    return Column(
      children: [
        const SizedBox(height: AppHeight.h22), // Add spacing if needed
        _getTitle(AppStrings.forYou),
        _getCarouselMovieitem(),
        const SizedBox(height: AppHeight.h60),
        _getTitle(AppStrings.topRated),
      ],
    );
  }

Widget _getSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(AppPadding.p20),
    child: TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: ColorManager.white,
            fontSize: FontSize.s16,
          ),
      decoration: InputDecoration(
        hintText: AppStrings.search,
        hintStyle: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(fontSize: FontSize.s16),
        fillColor: ColorManager.searchColor,
        filled: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSize.s10),
          child: Icon(
            Icons.search,
            color: ColorManager.greyfield,
            size: 32,
          ),
        ),
        suffixIcon: StreamBuilder<String>(
          stream: _viewModel.outputSearchQuery,
          builder: (context, snapshot) {
            final hasText = (snapshot.data ?? '').isNotEmpty;
            return hasText
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: ColorManager.greyfield,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _viewModel.clearSearch();
                    },
                  )
                : const SizedBox.shrink();
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s30),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s30),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSize.s20,
          vertical: AppSize.s16,
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        // This is already covered by the TextEditingController listener in _bind()
      },
    ),
  );
}

  Widget _getTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSize.s30, bottom: AppSize.s14),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }

  Widget _getCarouselMovieitem() {
    return StreamBuilder<List<MovieEntity>>(
      stream: _viewModel.outputMovies,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 200);
        }

        final carouselMovies = snapshot.data!.skip(4).take(10).toList();
        return Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: CarouselSlider.builder(
            itemCount: carouselMovies.length,
            itemBuilder: (context, index, realIndex) {
              final movie = carouselMovies[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                  child: RobustNetworkImage(
                    imageUrl: AppConstants.imageURL + movie.posterUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              viewportFraction: 1.0,
              enlargeCenterPage: true,
              enableInfiniteScroll: carouselMovies.length > 1,
              padEnds: false,
            ),
          ),
        );
      },
    );
  }

  Widget _getMovieItem(MovieEntity movie) {
    return InkWell(
      onTap: () {
        initMovieDetailsModule();
        Navigator.pushReplacementNamed(context, Routes.movieDetailsRoute,
            arguments: MovieDetailsArguments(
              movieId: movie.id,
              routeName: Routes.mainRoute,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorManager.grey.withOpacity(0.3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 0.6, // Maintain consistent aspect ratio
            child: buildNetworkImage(
              imageUrl: movie.posterUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}