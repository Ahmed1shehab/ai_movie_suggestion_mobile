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
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterViewmodel _viewModel = instance<RegisterViewmodel>();
  final AppPreferences _appPreferences = instance<AppPreferences>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.scaleWidth(AppPadding.p28),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p32)),
                        
                        // Logo with modern styling
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig.scaleSize(AppPadding.p16)),
                            decoration: BoxDecoration(
                              color: ColorManager.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(SizeConfig.scaleSize(AppSize.s24)),
                            ),
                            child: Image.asset(
                              ImagesAssets.appLogo,
                              height: SizeConfig.scaleHeight(AppSize.s70),
                              width: SizeConfig.scaleWidth(AppSize.s70),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p32)),
                        
                        // Create Account text with better hierarchy
                        Text(
                          AppStrings.createAccount,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: SizeConfig.scaleText(FontSize.s28),
                            fontWeight: FontWeightManager.bold,
                          ),
                        ),
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p8)),
                        Text(
                          AppStrings.join,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: SizeConfig.scaleText(FontSize.s15),
                            color: ColorManager.grey,
                          ),
                        ),
                        
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p32)),

                        // Full Name Field
                        authBuildTextField(
                          controller: _fullNameController,
                          labelText: AppStrings.fullName,
                          hintText: AppStrings.enterYourFullName,
                          keyboardType: TextInputType.text,
                          validationStream: _viewModel.outIsFullNameValid,
                        ),
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p20)),

                        // Email Field
                        authBuildTextField(
                          controller: _emailController,
                          labelText: AppStrings.email,
                          hintText: AppStrings.enterYourEmail,
                          keyboardType: TextInputType.emailAddress,
                          validationStream: _viewModel.outIsEmailValid,
                        ),
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p20)),

                        // Password Field
                        authBuildTextField(
                          controller: _passwordController,
                          labelText: AppStrings.password,
                          hintText: AppStrings.enterYourPassword,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          validationStream: _viewModel.outIsPasswordValid,
                        ),
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p20)),

                        // Confirm Password Field
                        authBuildTextField(
                          controller: _confirmPasswordController,
                          labelText: AppStrings.confirmPassword,
                          hintText: AppStrings.confirmYourPassword,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          validationStream: _viewModel.outIsConfirmPasswordValid,
                        ),
                        
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p28)),

                        // Create Account Button with improved design
                        StreamBuilder<bool>(
                          stream: _viewModel.outIsLoading,
                          initialData: false,
                          builder: (context, snapshot) {
                            final isLoading = snapshot.data ?? false;

                            return Container(
                              width: double.infinity,
                              height: SizeConfig.scaleHeight(AppHeight.h56),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  SizeConfig.scaleSize(AppSize.s12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorManager.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          _viewModel.register();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      SizeConfig.scaleSize(AppSize.s12),
                                    ),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: SizeConfig.scaleHeight(AppSize.s36),
                                        width: SizeConfig.scaleWidth(AppSize.s36),
                                        child: Lottie.asset(
                                          JsonAssets.loading2,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Text(
                                        AppStrings.createAccount,
                                        style: TextStyle(
                                          fontSize: SizeConfig.scaleText(FontSize.s16),
                                          fontWeight: FontWeightManager.semiBold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        // OR Divider with better spacing
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p32)),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: ColorManager.greyfield.withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.scaleWidth(AppPadding.p16),
                              ),
                              child: Text(
                                AppStrings.or,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ColorManager.grey,
                                  fontSize: SizeConfig.scaleText(FontSize.s14),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: ColorManager.greyfield.withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p24)),

                        // Sign In Navigation with better styling
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.alreadyHaveAccount,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: SizeConfig.scaleText(FontSize.s15),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (kDebugMode) print('navigate to Login');
                                  RouteGenerator.navigateAndRemoveUntil(
                                    context,
                                    Routes.loginRoute,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.scaleWidth(AppPadding.p8),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.signIn,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: ColorManager.primary,
                                    fontSize: SizeConfig.scaleText(FontSize.s15),
                                    fontWeight: FontWeightManager.semiBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p20)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}