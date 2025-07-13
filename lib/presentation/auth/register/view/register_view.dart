import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/auth/register/viewmodel/register_viewmodel.dart';
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

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterViewmodel _viewModel = instance<RegisterViewmodel>();
  final AppPreferences _appPreferences = instance<AppPreferences>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _bind() {
    _viewModel.start();
    _fullNameController
        .addListener(() => _viewModel.setFullName(_fullNameController.text));
    _emailController
        .addListener(() => _viewModel.setEmail(_emailController.text));
    _passwordController
        .addListener(() => _viewModel.setPassword(_passwordController.text));
    _confirmPasswordController.addListener(
        () => _viewModel.setConfirmPassword(_confirmPasswordController.text));

    _viewModel.isUserRegisteredInStreamController.stream.listen((isRegistered) {
      debugPrint('[RegisterView] Received isRegistered = $isRegistered');
      if (isRegistered) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          debugPrint('[RegisterView] Navigating to Verify Email');
          Navigator.of(context).pushReplacementNamed(Routes.verifyEmailRoute);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _bind();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return StreamBuilder<FlowState>(
      stream: _viewModel.outputState,
      builder: (context, snapshot) {
        return snapshot.data?.getScreenWidget(
              context,
              _getContentWidget(context),
              () {
                _viewModel.register();
              },
            ) ??
            _getContentWidget(context);
      },
    );
  }

  Widget _getContentWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Column(
        children: [
          SizedBox(height: SizeConfig.scaleHeight(AppPadding.p12)),
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
                        AppStrings.createAccount,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p8)),
                    Center(
                      child: Text(
                        AppStrings.join,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: SizeConfig.scaleText(FontSize.s16)),
                      ),
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p20)),
                    authBuildTextField(
                      controller: _fullNameController,
                      labelText: AppStrings.fullName,
                      hintText: AppStrings.enterYourFullName,
                      keyboardType: TextInputType.text,
                      validationStream: _viewModel.outIsFullNameValid,
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(AppPadding.p16)),

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
                    authBuildTextField(
                      controller: _confirmPasswordController,
                      labelText: AppStrings.confirmPassword,
                      hintText: AppStrings.confirmYourPassword,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validationStream: _viewModel.outIsConfirmPasswordValid,
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
                                      _viewModel.register();
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
                                : const Text(AppStrings.createAccount),
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
                        Text(AppStrings.alreadyHaveAccount,
                            style: Theme.of(context).textTheme.bodySmall),
                        TextButton(
                          onPressed: () {
                            if (kDebugMode) print('navigate to Login');
                            RouteGenerator.navigateAndRemoveUntil(
                                context, Routes.loginRoute);
                          },
                          child: Text(
                            AppStrings.signIn,
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
