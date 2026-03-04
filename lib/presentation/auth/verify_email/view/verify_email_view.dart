import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/auth/verify_email/viewmodel/verify_email_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/auth/widgets/authBuildTextField.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/constants_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final VerifyEmailViewmodel _viewModel = instance<VerifyEmailViewmodel>();
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _bind() async {
    _viewModel.start();
    _viewModel.startCountdown();
    _codeController.addListener(() {
      _viewModel.isCodeValid(_codeController.text);
    });

    final email = await _appPreferences.getRegisterEmail();
    debugPrint("Email loaded from AppPreferences in _bind(): $email");

    if (email != null) {
      _viewModel.setEmail(email);
    }
    _viewModel.isUserVerifiedStreamController.stream.listen((isVerified) {
      if (isVerified && mounted) {
        RouteGenerator.navigateAndRemoveUntil(context, Routes.loginRoute);
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
    _codeController.dispose();
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
              () async {
                String? email = _appPreferences.getRegisterEmail();
                if (email != null) {
                  _viewModel.verifyEmail(email, _codeController.text);
                }
              },
            ) ??
            _getContentWidget(context);
      },
    );
  }

  Widget _getContentWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: SizeConfig.scaleSize(AppSize.s20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.back,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: SizeConfig.scaleText(FontSize.s18),
            fontWeight: FontWeightManager.semiBold,
          ),
        ),
        centerTitle: false,
        backgroundColor: ColorManager.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.scaleWidth(AppPadding.p28),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p24)),
                  
                  // Email Icon with modern styling
                  Container(
                    padding: EdgeInsets.all(SizeConfig.scaleSize(AppPadding.p20)),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      ImagesAssets.mail,
                      height: SizeConfig.scaleHeight(AppSize.s80),
                      width: SizeConfig.scaleWidth(AppSize.s80),
                    ),
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p28)),
                  
                  // Title
                  Text(
                    AppStrings.verifyYourEmail,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: SizeConfig.scaleText(FontSize.s28),
                      fontWeight: FontWeightManager.bold,
                    ),
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p12)),
                  
                  // Description
                  Text(
                    AppStrings.verifyYourEmailDesc,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: SizeConfig.scaleText(FontSize.s15),
                      color: ColorManager.grey,
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p36)),
                  
                  // Verification Code Field
                  authBuildTextField(
                    controller: _codeController,
                    labelText: AppStrings.verifyCode,
                    hintText: AppStrings.enterCode,
                    keyboardType: TextInputType.number,
                    validationStream: _viewModel.outputIsCodeValid,
                    onChanged: (value) {
                      _viewModel.setCode(value);
                    },
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p24)),
                  
                  // Verify Button
                  StreamBuilder(
                    stream: _viewModel.outputAreAllInputsValid,
                    builder: (context, snapshot) {
                      final areInputsValid = snapshot.data ?? false;
                      return Container(
                        width: double.infinity,
                        height: SizeConfig.scaleHeight(AppHeight.h56),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            SizeConfig.scaleSize(AppSize.s12),
                          ),
                          boxShadow: areInputsValid
                              ? [
                                  BoxShadow(
                                    color: ColorManager.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: areInputsValid
                              ? () {
                                  final email = _appPreferences.getRegisterEmail();
                                  if (email == null || email.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(AppStrings.emailNotFound),
                                        backgroundColor: ColorManager.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            SizeConfig.scaleSize(AppSize.s8),
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _viewModel.verifyEmail(email, _codeController.text);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SizeConfig.scaleSize(AppSize.s12),
                              ),
                            ),
                          ),
                          child: Text(
                            AppStrings.verifyEmail,
                            style: TextStyle(
                              fontSize: SizeConfig.scaleText(FontSize.s16),
                              fontWeight: FontWeightManager.semiBold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p24)),
                  
                  // Timer Section
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.scaleWidth(AppPadding.p16),
                      vertical: SizeConfig.scaleHeight(AppPadding.p12),
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        SizeConfig.scaleSize(AppSize.s12),
                      ),
                      border: Border.all(
                        color: ColorManager.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: ColorManager.error,
                          size: SizeConfig.scaleSize(AppSize.s20),
                        ),
                        SizedBox(width: SizeConfig.scaleWidth(AppSize.s8)),
                        Text(
                          "Code expires in: ",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ColorManager.error,
                            fontWeight: FontWeightManager.medium,
                            fontSize: SizeConfig.scaleText(FontSize.s14),
                          ),
                        ),
                        StreamBuilder<String>(
                          stream: _viewModel.outputCountdown,
                          initialData: AppConstants.initalCodeExpiry,
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? AppConstants.initalCodeExpiry,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ColorManager.error,
                                fontWeight: FontWeightManager.bold,
                                fontSize: SizeConfig.scaleText(FontSize.s14),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p24)),
                  
                  // Resend Code
                  Text.rich(
                    TextSpan(
                      text: AppStrings.didntReceive,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: SizeConfig.scaleText(FontSize.s15),
                      ),
                      children: [
                        TextSpan(
                          text: AppStrings.resendCode,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: ColorManager.primary,
                            fontSize: SizeConfig.scaleText(FontSize.s15),
                            fontWeight: FontWeightManager.semiBold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: Resend code logic
                            },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p28)),
                  
                  // Important Information Card
                  Container(
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(
                        SizeConfig.scaleSize(AppSize.s16),
                      ),
                      border: Border.all(
                        color: ColorManager.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(SizeConfig.scaleSize(AppPadding.p20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(SizeConfig.scaleSize(AppSize.s8)),
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_rounded,
                            color: ColorManager.primary,
                            size: SizeConfig.scaleSize(AppSize.s20),
                          ),
                        ),
                        SizedBox(width: SizeConfig.scaleWidth(AppPadding.p12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.importantInfo,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeightManager.bold,
                                  fontSize: SizeConfig.scaleText(FontSize.s16),
                                ),
                              ),
                              SizedBox(height: SizeConfig.scaleHeight(AppSize.s12)),
                              _buildInfoPoint(context, AppStrings.importantInfoDesc1),
                              SizedBox(height: SizeConfig.scaleHeight(AppSize.s6)),
                              _buildInfoPoint(context, AppStrings.importantInfoDesc2),
                              SizedBox(height: SizeConfig.scaleHeight(AppSize.s6)),
                              _buildInfoPoint(context, AppStrings.importantInfoDesc3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: SizeConfig.scaleHeight(AppPadding.p28)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: SizeConfig.scaleHeight(AppSize.s6)),
          height: SizeConfig.scaleSize(AppSize.s6),
          width: SizeConfig.scaleSize(AppSize.s6),
          decoration: BoxDecoration(
            color: ColorManager.primary.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: SizeConfig.scaleWidth(AppSize.s8)),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: SizeConfig.scaleText(FontSize.s14),
              color: ColorManager.secondaryBlack,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}