import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/discover_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/home/view/home_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/profile_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/suggest_me/suggest_me_view.dart';
import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    initTopRatedModule();

    pages = [
      TopRatedView(),
      const SuggestMeView(),
      const DiscoverView(),
      const ProfileView(),
    ];
  }

  List<String> titles = [
    AppStrings.home,
    AppStrings.suggestMe,
    AppStrings.discover,
    AppStrings.profile,
  ];
  var _title = AppStrings.home;
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: ColorManager.background,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ColorManager.primary,
          unselectedItemColor: ColorManager.grey,
          selectedLabelStyle: TextStyle(color: ColorManager.primary),
          unselectedLabelStyle: TextStyle(color: ColorManager.grey),
          elevation: 0, // optional: removes shadow entirely
          currentIndex: _currentIndex,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                _currentIndex == 0
                    ? ImagesAssets.homeIconActive
                    : ImagesAssets.homeIcon,
                width: 24,
                height: 24,
              ),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _currentIndex == 1
                    ? ImagesAssets.suggestMeIconActive
                    : ImagesAssets.suggestMeIcon,
                width: 24,
                height: 24,
              ),
              label: AppStrings.suggestMe,
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _currentIndex == 2
                    ? ImagesAssets.discoverIconActive
                    : ImagesAssets.discoverIcon,
                width: 24,
                height: 24,
              ),
              label: AppStrings.discover,
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _currentIndex == 3
                    ? ImagesAssets.profileIconActive
                    : ImagesAssets.profileIcon,
                width: 24,
                height: 24,
              ),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }

  onTap(int index) {
    setState(() {
      _currentIndex = index;
      _title = titles[index];
    });
    if (index == 0) {
      initTopRatedModule();
    }
  }
}
