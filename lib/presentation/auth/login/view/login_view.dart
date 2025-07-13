import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/auth/login/viewmodel/login_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/auth/widgets/authBuildTextField.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginViewmodel _viewModel = instance<LoginViewmodel>();
  final AppPreferences _appPreferences = instance<AppPreferences>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  _bind() {
    _viewModel.start();
    _emailController
        .addListener(() => _viewModel.setEmail(_emailController.text));
    _passwordController
        .addListener(() => _viewModel.setPassword(_passwordController.text));

    _viewModel.isUserLoggedInStreamController.stream.listen((isLoggedIn) {
      debugPrint('[LoginView] Received isLoggedIn = $isLoggedIn');
      if (isLoggedIn) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          debugPrint('[LoginView] Navigating to Main');
          _appPreferences.setUserLoggedIn();
          Navigator.of(context).pushReplacementNamed(Routes.mainRoute);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[LoginView] initState');
    _bind();
  }

  @override
  void dispose() {
    debugPrint('[LoginView] dispose');
    _viewModel.dispose();
    super.dispose();
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
                _viewModel.login();
              },
            ) ??
            _getContentWidget(context); // default content if no state
      },
    );
  }

  Widget _getContentWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Column(
        children: [
          SizedBox(height: SizeConfig.scaleHeight(AppPadding.p60)),
          Image.asset(
            ImagesAssets.appLogo,
            height: SizeConfig.scaleHeight(AppSize.s100),
            width: SizeConfig.scaleWidth(AppSize.s100),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.scaleWidth(AppPadding.p16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        AppStrings.welcomeBack,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p8)),
                    Center(
                      child: Text(
                        AppStrings.signToContinue,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: SizeConfig.scaleText(FontSize.s16)),
                      ),
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p50)),

                    /// Email Field
                    authBuildTextField(
                      controller: _emailController,
                      labelText: AppStrings.email,
                      hintText: AppStrings.enterYourEmail,
                      keyboardType: TextInputType.emailAddress,
                      validationStream: _viewModel.outIsEmailValid,
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p16)),

                    /// Password Field
                    authBuildTextField(
                      controller: _passwordController,
                      labelText: AppStrings.password,
                      hintText: AppStrings.enterYourPassword,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validationStream: _viewModel.outIsPasswordValid,
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p8)),

                    /// Remember Me + Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.scaleSize(AppSize.s4))),
                              side: BorderSide(
                                width: SizeConfig.scaleWidth(AppSize.s1),
                                color: ColorManager.greyfield,
                              ),
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(AppStrings.rememberMe),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, Routes.forgetPasswordRoute);
                          },
                          child: Text(
                            AppStrings.forgotPasswrod,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p8)),

                    /// Sign In Button
                    StreamBuilder<bool>(
                      stream: _viewModel.outIsLoading,
                      initialData: false,
                      builder: (context, snapshot) {
                        final isLoading = snapshot.data ?? false;

                        return SizedBox(
                          width: double.infinity,
                          height: SizeConfig.scaleHeight(AppHeight.h48),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _viewModel.login();
                                    }
                                  },
                            child: isLoading
                                ? SizedBox(
                                    height: SizeConfig.scaleHeight(AppSize.s40),
                                    width: SizeConfig.scaleWidth(AppSize.s40),
                                    child: Lottie.asset(
                                      JsonAssets.loading2,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const Text(AppStrings.signIn),
                          ),
                        );
                      },
                    ),
                    

                    /// OR Divider
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p36)),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.scaleWidth(8)),
                          child: Text(
                            AppStrings.or,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p14)),

                    /// Sign Up Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.dontHaveAccount,
                            style: Theme.of(context).textTheme.bodySmall),
                        TextButton(
                          onPressed: () {
                            if (kDebugMode) print('navigate to register');
                            RouteGenerator.navigateAndRemoveUntil(
                                context, Routes.registerRoute);
                          },
                          child: Text(
                            AppStrings.signUp,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: ColorManager.primary,
                                  fontSize: SizeConfig.scaleText(FontSize.s14),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
