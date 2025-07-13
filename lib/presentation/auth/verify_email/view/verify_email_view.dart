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
    super.dispose();
  }

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
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          AppStrings.back,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: false,
        backgroundColor: ColorManager.white,
        elevation: 0,
      ),
      backgroundColor: ColorManager.white,
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(height: 12),
        Image.asset(
          ImagesAssets.mail,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.verifyYourEmail,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(fontSize: SizeConfig.scaleText(FontSize.s28)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.scaleWidth(AppPadding.p26)),
          child: Text(
            AppStrings.verifyYourEmailDesc,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontSize: SizeConfig.scaleText(FontSize.s16)),
          ),
        ),
        const SizedBox(height: 30),
        authBuildTextField(
          controller: _codeController,
          labelText: AppStrings.verifyCode,
          hintText: AppStrings.enterCode,
          keyboardType: TextInputType.number,
          validationStream: _viewModel.outputIsCodeValid,
          onChanged: (value) {
            _viewModel.setCode(value); // <-- this is CRITICAL
          },
        ),
        SizedBox(height: SizeConfig.scaleHeight(AppPadding.p16)),
        StreamBuilder(
          stream: _viewModel.outputAreAllInputsValid,
          builder: (context, snapshot) {
            final areInputsValid = snapshot.data ?? false;
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.scaleWidth(AppPadding.p26)),
              child: SizedBox(
                width: double.infinity,
                height: SizeConfig.scaleHeight(AppHeight.h48),
                child: ElevatedButton(
                  onPressed: areInputsValid
                      ? () {
                          final email = _appPreferences.getRegisterEmail();
                          if (email == null || email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(AppStrings.emailNotFound),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          _viewModel.verifyEmail(email, _codeController.text);
                        }
                      : null,
                  child: const Text(AppStrings.verifyEmail),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: Colors.red, size: 18),
            const SizedBox(width: 4),
            Text(
              "Code expires in: ",
              style: TextStyle(color: Colors.red.shade700),
            ),
            StreamBuilder<String>(
              stream: _viewModel.outputCountdown,
              initialData: AppConstants.initalCodeExpiry,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? AppConstants.initalCodeExpiry,
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
        Divider(
            color: ColorManager.error, thickness: 4, indent: 50, endIndent: 50),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: AppStrings.didntReceive,
            children: [
              TextSpan(
                text: AppStrings.resendCode,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: ColorManager.primary,
                      fontSize: SizeConfig.scaleText(FontSize.s14),
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // TODO: Resend code logic
                  },
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: ColorManager.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.importantInfo,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(AppStrings.importantInfoDesc1),
                        const Text(AppStrings.importantInfoDesc2),
                        const Text(AppStrings.importantInfoDesc3),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ]),
    );
  }
}

// class _VerifyEmailViewState extends State<VerifyEmailView> {

//   final TextEditingController _codeController = TextEditingController();
//   Duration _remainingTime = const Duration(minutes: 59, seconds: 42);
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startCountdown();
//   }

//   void _startCountdown() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingTime.inSeconds > 0) {
//         setState(() {
//           _remainingTime -= const Duration(seconds: 1);
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   String _formatDuration(Duration d) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _codeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         backgroundColor: ColorManager.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(26.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.deepPurple),
//             const SizedBox(height: 16),
//             const Text(
//               "Verify Your Email",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               "We've sent a 6-digit verification code to your email address. Enter the code below to complete your registration.",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//             const SizedBox(height: 24),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Verification Code",
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _codeController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: InputDecoration(
//                 hintText: 'Enter 6-digit code',
//                 counterText: '',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // TODO: Implement verification logic
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text("Verify Email", style: TextStyle(color: Colors.white)),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.timer, color: Colors.red, size: 18),
//                 const SizedBox(width: 4),
//                 Text(
//                   "Code expires in: ",
//                   style: TextStyle(color: Colors.red.shade700),
//                 ),
//                 Text(
//                   _formatDuration(_remainingTime),
//                   style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             Divider(color: ColorManager.error, thickness: 4, indent: 50, endIndent: 50),
//             const SizedBox(height: 12),
//             Text.rich(
//               TextSpan(
//                 text: "Didn't receive the code? ",
//                 children: [
//                   TextSpan(
//                     text: "Resend Code",
//                     style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         // TODO: Resend code logic
//                       },
//                   ),
//                 ],
//               ),
//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }
//             // const SizedBox(height: 24),

// Container(
//   decoration: BoxDecoration(
//     color: Colors.grey.shade100,
//     borderRadius: BorderRadius.circular(12),
//   ),
//   padding: const EdgeInsets.all(16),
//   child: const Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         "Important Information",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       SizedBox(height: 8),
//       Text("◦ Check your spam/junk folder if you don't see the email"),
//       Text("◦ The verification code expires after 1 hour"),
//       Text("◦ You can request a new code if this one expires"),
//     ],
//   ),
// ),
