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
import 'package:lottie/lottie.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
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

    _viewModel.outRememberMe.listen((rememberMe) {
      if (mounted) {
        setState(() {
          _rememberMe = rememberMe;
        });
      }
    });

    _viewModel.isUserLoggedInStreamController.stream.listen((isLoggedIn) {
      debugPrint('[LoginView] isUserLoggedInStream value: $isLoggedIn');
      if (isLoggedIn) {
        debugPrint('[LoginView] User logged in, navigating to main route');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.mainRoute);
        }
      }
    });

    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final hasRemembered = await _appPreferences.hasRememberedCredentials();
      if (hasRemembered) {
        final credentials = await _appPreferences.getRememberedCredentials();
        final email = credentials['email'] ?? '';
        final password = credentials['password'] ?? '';
        
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
          _rememberMe = true;
        });
        
        _viewModel.setRememberMe(true);
        debugPrint('[LoginView] Loaded remembered credentials');
      }
    } catch (e) {
      debugPrint('[LoginView] Error loading remembered credentials: $e');
    }
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
    _emailController.dispose();
    _passwordController.dispose();
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
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p40)),
                        
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
                              height: SizeConfig.scaleHeight(AppSize.s80),
                              width: SizeConfig.scaleWidth(AppSize.s80),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p36)),
                        
                        // Welcome text with better hierarchy
                        Text(
                          AppStrings.welcomeBack,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: SizeConfig.scaleText(FontSize.s28),
                            fontWeight: FontWeightManager.bold,
                          ),
                        ),
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p8)),
                        Text(
                          AppStrings.signToContinue,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: SizeConfig.scaleText(FontSize.s15),
                            color: ColorManager.grey,
                          ),
                        ),
                        
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p40)),

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
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p16)),

                        // Remember Me + Forgot Password with improved layout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: SizeConfig.scaleHeight(AppSize.s24),
                                  width: SizeConfig.scaleWidth(AppSize.s24),
                                  child: Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        SizeConfig.scaleSize(AppSize.s6),
                                      ),
                                    ),
                                    side: BorderSide(
                                      width: SizeConfig.scaleWidth(AppSize.s1_5),
                                      color: ColorManager.greyfield,
                                    ),
                                    value: _rememberMe,
                                    activeColor: ColorManager.primary,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                      _viewModel.setRememberMe(_rememberMe);
                                      debugPrint('[LoginView] Remember me set to: $_rememberMe');
                                    },
                                  ),
                                ),
                                SizedBox(width: SizeConfig.scaleWidth(AppSize.s8)),
                                Text(
                                  AppStrings.rememberMe,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: SizeConfig.scaleText(FontSize.s14),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.forgetPasswordRoute,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.scaleWidth(AppPadding.p8),
                                  vertical: SizeConfig.scaleHeight(AppPadding.p4),
                                ),
                              ),
                              child: Text(
                                AppStrings.forgotPasswrod,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ColorManager.primary,
                                  fontWeight: FontWeightManager.medium,
                                  fontSize: SizeConfig.scaleText(FontSize.s14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p28)),

                        // Sign In Button with improved design
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
                                          _viewModel.login();
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
                                        AppStrings.signIn,
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

                        // Sign Up Navigation with better styling
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.dontHaveAccount,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: SizeConfig.scaleText(FontSize.s15),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (kDebugMode) print('navigate to register');
                                  RouteGenerator.navigateAndRemoveUntil(
                                    context,
                                    Routes.registerRoute,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.scaleWidth(AppPadding.p8),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.signUp,
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