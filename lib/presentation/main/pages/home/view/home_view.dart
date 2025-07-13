import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/home/viewmodel/home_viewmodel.dart';
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

  @override
  void initState() {
    _bind();
    super.initState();
  }

  void _bind() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _viewModel.loadMore();
      }
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
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: ColorManager.white,
            ),
            onPressed: () => _viewModel.refresh(),
          ),
        ],
      ),
      backgroundColor: ColorManager.background,
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return StreamBuilder(
      stream: _viewModel.outputMovies,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _getMoviesListWithHeader(snapshot.data!);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _getMoviesListWithHeader(List<MovieEntity> movies) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _getHeaderContent(),
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
        // Add loading indicator as a separate sliver
        StreamBuilder<bool>(
          stream: _viewModel.outputIsLoading,
          builder: (context, snapshot) {
            if (snapshot.data ?? false) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppPadding.p20),
                  child: Center(
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

  Widget _getHeaderContent() {
    return Column(
      children: [
        _getSearchBar(),
        const SizedBox(height: AppHeight.h22),
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
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final carouselMovies = snapshot.data!.skip(4).take(10).toList();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppHeight.h30),
            child: CarouselSlider.builder(
              itemCount: carouselMovies.length,
              itemBuilder: (context, index, realIndex) {
                final movie = carouselMovies[index];
                return InkWell(
                  onTap: () {
                    //todo
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(
                          AppConstants.imageURL + movie.posterUrl,
                        ),
                        fit: BoxFit.cover,
                      ),
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
                aspectRatio: 16 / 9,
                enableInfiniteScroll: false,
                padEnds: false,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _getMovieItem(MovieEntity movie) {
    return InkWell(
      onTap: () {
       RouteGenerator.navigateToMovieDetails(context, movie.id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          AppConstants.imageURL + movie.posterUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: ColorManager.grey,
            child: const Icon(
              Icons.movie,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}