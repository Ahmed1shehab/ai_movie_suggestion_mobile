import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/styles_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum StateRendererType {
  //pop States (Dialog)
  popLoadingState,
  popErrorState,
  popSuccessState,
  popLoadingInChatState,
  //Full Screen States(Full Screen)
  fullScreenLoadingState,
  fullScreenErrorState,
  fullScreenEmptyState,
  //general
  contentState,
  fullScreenButtonLoadingState
}

// ignore: must_be_immutable
class StateRenderer extends StatelessWidget {
  StateRendererType stateRendererType;
  String message;
  String title;
  Function retryActionFunction;

  StateRenderer(
      {super.key,
      required this.stateRendererType,
      this.message = AppStrings.loading,
      this.title = "",
      required this.retryActionFunction});
  @override
  Widget build(BuildContext context) {
    return _getStateWidget(context);
  }

  Widget _getStateWidget(BuildContext context) {
    switch (stateRendererType) {
      case StateRendererType.popLoadingState:
        return _getpopDialog(context, [
          _getAnimatedImage(JsonAssets.loading),
        ]);
      case StateRendererType.popErrorState:
        return _getpopDialog(context, [
          _getAnimatedImage(JsonAssets.error),
          _getMessage(message),
          _getRetryButton(AppStrings.ok, context)
        ]);
      case StateRendererType.popSuccessState:
        return _getpopDialog(
            context,
            [
              _getImage(ImagesAssets.success),
              _getMessage(title),
              _getMessage(message),
              _getRetryButton(AppStrings.ok, context)
            ],
            isDismissible: false);
      case StateRendererType.fullScreenLoadingState:
        return _getItemsColumn(
            [_getAnimatedImage(JsonAssets.loading), _getMessage(message)]);
      case StateRendererType.fullScreenErrorState:
        return _getItemsColumn([
          _getAnimatedImage(JsonAssets.error),
          _getMessage(message),
          _getRetryButton(AppStrings.tryAgain, context)
        ]);
      case StateRendererType.fullScreenButtonLoadingState:
        return _getAnimatedImage(JsonAssets.loading);
      case StateRendererType.fullScreenEmptyState:
        return _getItemsColumn(
            [_getAnimatedImage(JsonAssets.success), _getMessage(message)]);
      case StateRendererType.popLoadingInChatState:
        return _getpopDialog(context, [
          _getAnimatedImage(JsonAssets.loadingDots),
        ]);
      case StateRendererType.contentState:
        return Container();
    }
  }

  Widget _getpopDialog(
    BuildContext context,
    List<Widget> children, {
    bool isDismissible = true,
  }) {
    return PopScope(
      canPop: isDismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s14),
        ),
        elevation: AppSize.s1_5,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: ColorManager.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(AppSize.s30),
            boxShadow: const [BoxShadow(color: Colors.black26)],
          ),
          child: _getDialogContent(context, children),
        ),
      ),
    );
  }

  Widget _getDialogContent(BuildContext context, List<Widget> children) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _getItemsColumn(List<Widget> children) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _getAnimatedImage(String animationName) {
    return SizedBox(
        height: AppSize.s150,
        width: AppSize.s150,
        child: Lottie.asset(animationName));
  }

  Widget _getImage(String animationName) {
    return SizedBox(
        height: AppSize.s150,
        width: AppSize.s150,
        child: Image.asset(animationName));
  }

  Widget _getMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p8),
        child: Text(
          message,
          style: getRegularStyle(
              color: ColorManager.white, fontSize: FontSize.s18),
        ),
      ),
    );
  }

  Widget _getRetryButton(String buttonTitle, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p18),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (stateRendererType == StateRendererType.fullScreenErrorState) {
                retryActionFunction.call();
              } else if (stateRendererType ==
                  StateRendererType.popSuccessState) {
                // Add delay to ensure dialog is dismissed before navigation
                Future.delayed(Duration(milliseconds: 300), () {
                  RouteGenerator.navigateAndRemoveUntil(
                      context, Routes.loginRoute);
                });
              }
            },
            child: Text(buttonTitle),
          ),
        ),
      ),
    );
  }
}
