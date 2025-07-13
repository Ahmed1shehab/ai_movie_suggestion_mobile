import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/auth/login/view/login_view.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/constants_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  final OnboardingViewmodel _viewmodel = OnboardingViewmodel();
  final AppPreferences _appPreferences = instance<AppPreferences>();

  _bind() {
      _appPreferences.setOnBoardingScreenViewed();
    _viewmodel.start();
    _appPreferences.deleteAccessToken();
  }

  @override
  void initState() {
    _bind();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SliderViewObject>(
      stream: _viewmodel.outputSliderViewObject,
      builder: (context, snapshot) {
        return _getContentWidget(snapshot.data);
      },
    );
  }

  Widget _getContentWidget(SliderViewObject? sliderViewObject) {
    if (sliderViewObject == null) return const SizedBox();

    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.scaleHeight(16),
                right: SizeConfig.scaleWidth(16),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, Routes.loginRoute);
                  },
                  child: Text(
                    AppStrings.skip,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: ColorManager.primary),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: sliderViewObject.numberOfSlides,
                onPageChanged: _viewmodel.onPageChanged,
                itemBuilder: (context, index) {
                  final slider = _viewmodel.list[index];
                  return _buildSlider(slider);
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                sliderViewObject.numberOfSlides,
                (index) => _buildIndicator(
                  isActive: index == sliderViewObject.currentIndex,
                ),
              ),
            ),

            SizedBox(height: SizeConfig.scaleHeight(24)),

            // Next/Finish Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.scaleWidth(24),
              ),
              child: SizedBox(
                width: double.infinity,
                height: SizeConfig.scaleHeight(AppHeight.h48),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SizeConfig.scaleWidth(24)),
                    ),
                  ),
                  onPressed: () {
                    final isLastPage =
                        _viewmodel.currentIndex == _viewmodel.totalPages - 1;

                    if (_pageController.hasClients) {
                      final nextIndex = _viewmodel.goNext();

                      _pageController
                          .animateToPage(
                        nextIndex,
                        duration: const Duration(
                            milliseconds: AppConstants.sliderAnimation),
                        curve: Curves.easeInOut,
                      )
                          .then((_) {
                        if (isLastPage) {
                          RouteGenerator.navigateAndRemoveUntil(
                              context, Routes.loginRoute);
                        }
                      });
                    }
                  },
                  child: Text(
                    _viewmodel.currentIndex == _viewmodel.totalPages - 1
                        ? AppStrings.finish
                        : AppStrings.next,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontSize: SizeConfig.scaleText(FontSize.s16),
                        ),
                  ),
                ),
              ),
            ),

            SizedBox(height: SizeConfig.scaleHeight(AppHeight.h30)),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppConstants.sliderAnimation),
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.scaleWidth(4)),
      width: isActive ? SizeConfig.scaleWidth(24) : SizeConfig.scaleWidth(8),
      height: SizeConfig.scaleHeight(8),
      decoration: BoxDecoration(
        color: isActive ? ColorManager.primary : ColorManager.secondaryWhite,
        borderRadius: BorderRadius.circular(SizeConfig.scaleWidth(4)),
      ),
    );
  }

  Widget _buildSlider(SliderObject slider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.scaleWidth(20)),
      child: Column(
        children: [
          SizedBox(height: SizeConfig.scaleHeight(8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(SizeConfig.scaleWidth(24)),
            child: Image.asset(slider.image),
          ),
          SizedBox(height: SizeConfig.scaleHeight(AppHeight.h60)),
          Text(
            slider.title,
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeConfig.scaleHeight(18)),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: SizeConfig.scaleWidth(24)),
            child: Text(
              slider.subTitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
