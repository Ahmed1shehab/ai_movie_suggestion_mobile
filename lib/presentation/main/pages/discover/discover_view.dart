import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/widgets/category_selector.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/new_releases/view/new_releases_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/now_playing/view/now_playing_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/trending/view/trending_view.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';


class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  int _selectedCategoryIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // Define pages directly in DiscoverView
    initPopularModule();
    initNowPlayingModule();
    initNewReleaseModule();
    pages = [
      const TrendingView(),
      const NowPlayingView(),
      const NewReleasesView()
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig
    SizeConfig.init(context);

    return Padding(
        padding: EdgeInsets.all(SizeConfig.scaleSize(12)),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: ColorManager.background,
            toolbarHeight:
                SizeConfig.scaleHeight(60), // Responsive app bar height
            title: Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.scaleSize(AppSize.s10),
                  top: SizeConfig.scaleSize(AppSize.s5)),
              child: Text(
                AppStrings.discover,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize:
                          SizeConfig.scaleText(24), // Responsive text size
                    ),
              ),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: EdgeInsets.only(
                    right: SizeConfig.scaleSize(AppPadding.p16)),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: ColorManager.white,
                    size: SizeConfig.scaleSize(AppSize.s30),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          backgroundColor: ColorManager.background,
          body: Container(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.scaleHeight(20)),
                CategorySelector(
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),
                SizedBox(height: SizeConfig.scaleSize(AppSize.s10)),
                Expanded(
                  child: pages[_selectedCategoryIndex],
                ),
              ],
            ),
          ),
        ));
  }
}
