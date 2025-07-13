// Updated trending_view.dart
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/trending/viewmodel/trending_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/widgets/movie_grid.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:flutter/material.dart';

class TrendingView extends StatefulWidget {
  const TrendingView({Key? key}) : super(key: key);

  @override
  State<TrendingView> createState() => _TrendingViewState();
}

class _TrendingViewState extends State<TrendingView> {
  final TrendingViewmodel _viewModel = instance<TrendingViewmodel>();
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
      backgroundColor: ColorManager.background,
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return StreamBuilder<List<MovieEntity>>(
      stream: _viewModel.outputMovies,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MoviesGridWidget(
            movies: snapshot.data!,
            scrollController: _scrollController,
            onRefresh: _viewModel.refresh,
            isLoadingStream: _viewModel.outputIsLoading,
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}
