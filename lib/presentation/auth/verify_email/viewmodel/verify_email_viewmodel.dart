import 'dart:async';

import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/functions.dart';
import 'package:ai_movie_suggestion/domain/usecase/verify_email_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/freezed_data_classes.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:flutter/foundation.dart';

class VerifyEmailViewmodel extends BaseViewmodel
    implements VerifyEmailViewmodelInputs, VerifyEmailViewmodelOutputs {
  final StreamController<String> _emailStreamController =
      StreamController<String>.broadcast();
  final StreamController<String> _codeStreamController =
      StreamController<String>.broadcast();

  final StreamController<bool> _areAllInputsValidStreamController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _isEmailValidStreamController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _isCodeValidStreamController =
      StreamController<bool>.broadcast();
  final StreamController<bool> isUserVerifiedStreamController =
      StreamController<bool>.broadcast();

  final StreamController<String> _countdownStreamController =
      StreamController<String>.broadcast();

  var verifyEmailObject = VerifyEmailObject('', '');
  final VerifyEmailUsecase _verifyEmailUsecase;

  final AppPreferences _appPreferences;

  VerifyEmailViewmodel(this._verifyEmailUsecase, this._appPreferences);
  Duration _remainingTime = const Duration(minutes: 5);
  Timer? _countdownTimer;
  @override
  void dispose() {
    _emailStreamController.close();
    _codeStreamController.close();
    _areAllInputsValidStreamController.close();
    _isEmailValidStreamController.close();
    _isCodeValidStreamController.close();
    isUserVerifiedStreamController.close();
    _countdownTimer?.cancel();
    _countdownStreamController.close();
    super.dispose();
  }

  @override
  void start() {
    inputState.add(ContentState());
    final savedEmail = _appPreferences.getRegisterEmail();
    if (savedEmail != null) {
      verifyEmailObject = verifyEmailObject.copyWith(email: savedEmail);
      _emailStreamController.add(savedEmail);
    }
    startCountdown();
    
  }

  @override
  Sink get inputAreAllInputsValid => _areAllInputsValidStreamController.sink;

  @override
  Sink<String> get inputCode => _codeStreamController.sink;

  @override
  Sink<String> get inputEmail => _emailStreamController.sink;

  @override
  Stream<bool> get outputAreAllInputsValid =>
      _areAllInputsValidStreamController.stream;

  @override
  Stream<bool> get outputIsCodeValid =>
      _codeStreamController.stream.map((code) {
        return isCodeValid(code);
      });

  @override
  Stream<bool> get outputIsEmailValid =>
      _emailStreamController.stream.map((email) {
        return isEmailValid(email);
      });
  @override
  Stream<String> get outputCountdown => _countdownStreamController.stream;

  bool isCodeValid(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  @override
  setEmail(String email) {
    inputEmail.add(email);
    if (isEmailValid(email)) {
      //  update register view object
      verifyEmailObject = verifyEmailObject.copyWith(email: email);
    } else {
      // reset email value in register view object
      verifyEmailObject = verifyEmailObject.copyWith(email: "");
    }
    _validate();
  }

  @override
  setCode(String code) {
    inputCode.add(code);
    if (isCodeValid(code)) {
      verifyEmailObject = verifyEmailObject.copyWith(code: code);
    } else {
      verifyEmailObject = verifyEmailObject.copyWith(code: "");
    }
    _validate();
  }

  void _validate() {
    final isValid = isCodeValid(verifyEmailObject.code) &&
        isEmailValid(verifyEmailObject.email);
    inputAreAllInputsValid.add(isValid);
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    debugPrint("VerifyEmailViewModel => email: $email, code: $code");

    verifyEmailObject = verifyEmailObject.copyWith(email: email, code: code);

    inputState.add(
      LoadingState(stateRendererType: StateRendererType.popLoadingState),
    );

    final result = await _verifyEmailUsecase.execute(
      VerifyEmailUsecaseInput(email, code),
    );

    result.fold(
      (failure) {
        inputState.add(
          ErrorState(StateRendererType.popErrorState, failure.message),
        );
      },
      (data) async {
        inputState.add(ContentState());

        // Show success state
        inputState.add(
          SuccessState("Verified Successfully"),
        );

        // Wait for the dialog to show, then navigate
        await Future.delayed(const Duration(milliseconds: 500));

        // Clear state again before navigation
        inputState.add(ContentState());

        // Trigger navigation
        isUserVerifiedStreamController.add(true);
      },
    );
  }

  void startCountdown() {
    _countdownTimer?.cancel();
    _remainingTime = const Duration(minutes: 5);

    _countdownStreamController.add(_formatDuration(_remainingTime));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= const Duration(seconds: 1);
        _countdownStreamController.add(_formatDuration(_remainingTime));
      } else {
        timer.cancel();
        _countdownStreamController.add("00:00");
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

abstract class VerifyEmailViewmodelInputs {
  Sink<String> get inputEmail;
  Sink<String> get inputCode;
  Future<void> verifyEmail(String email, String code);
  setEmail(String email);
  setCode(String code);
  Sink get inputAreAllInputsValid;
}

abstract class VerifyEmailViewmodelOutputs {
  Stream<bool> get outputIsEmailValid;
  Stream<bool> get outputIsCodeValid;
  Stream<bool> get outputAreAllInputsValid;
  Stream<String> get outputCountdown;
}
