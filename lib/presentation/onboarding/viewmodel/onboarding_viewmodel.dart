import 'dart:async';

import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';

class OnboardingViewmodel extends BaseViewmodel
    implements OnboardingViewmodelInputs, OnboardingViewmodelOutputs {
  final StreamController _streamController =
      StreamController<SliderViewObject>();

  late final List<SliderObject> list;
  int currentIndex = 0;
  int totalPages = 3;
  @override
  void dispose() {
    _streamController.close();
  }

  @override
  void start() {
    //viewmodel start
    list = _getSliderObject();
    _postDataToView();
  }

  @override
  int goNext() {
    if (currentIndex < totalPages - 1) {
      currentIndex++;
    }
    return currentIndex;
  }

  @override
  int goPrevious() {
    int previousIndex = --currentIndex;
    if (previousIndex == -1) {
      previousIndex = list.length - 1;
    }
    return previousIndex;
  }

  @override
  void onPageChanged(int index) {
    currentIndex = index;
    _postDataToView();
  }

  @override
  Sink get inputSliderViewObject => _streamController.sink;

//onBoarding view outputs
  @override
  Stream<SliderViewObject> get outputSliderViewObject =>
      _streamController.stream.map((sliderViewObject) => sliderViewObject);
  void _postDataToView() {
    inputSliderViewObject
        .add(SliderViewObject(list[currentIndex], currentIndex, list.length));
  }

  List<SliderObject> _getSliderObject() => [
        SliderObject(
          ImagesAssets.onboarding1,
          AppStrings.onBoardingTitle1,
          AppStrings.onBoardingSubTitle1,
        ),
        SliderObject(
          ImagesAssets.onboarding2,
          AppStrings.onBoardingTitle2,
          AppStrings.onBoardingSubTitle2,
        ),
        SliderObject(
          ImagesAssets.onboarding3,
          AppStrings.onBoardingTitle3,
          AppStrings.onBoardingSubTitle3,
        ),
      ];
}

abstract class OnboardingViewmodelInputs {
  int goNext();
  int goPrevious();

  void onPageChanged(int index);

  //stream controller input
  Sink get inputSliderViewObject;
}

abstract class OnboardingViewmodelOutputs {
  Stream<SliderViewObject> get outputSliderViewObject;
}
