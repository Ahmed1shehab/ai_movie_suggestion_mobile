import 'dart:async';

import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/functions.dart';
import 'package:ai_movie_suggestion/domain/usecase/register_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/freezed_data_classes.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:flutter/material.dart';

class RegisterViewmodel extends BaseViewmodel
    implements RegisterViewmodelInputs, RegisterViewmodelOutputs {
  final StreamController<String> _fullNameStreamController =
      StreamController<String>.broadcast();
  final StreamController<String> _emailStreamController =
      StreamController<String>.broadcast();
  final StreamController<String> _passwordStreamController =
      StreamController<String>.broadcast();
  final StreamController<String> _confirmPasswordStreamController =
      StreamController<String>.broadcast();
  final StreamController<void> _areAllInputsValidStreamController =
      StreamController<void>.broadcast();
  final StreamController<bool> isUserRegisteredInStreamController =
      StreamController<bool>.broadcast();

  final StreamController<bool> _isLoadingController = StreamController<bool>();

  Stream<bool> get outIsLoading => _isLoadingController.stream;

  var registerObject = RegisterObject('', '', '', '');
  final RegisterUsecase _registerUsecase;
  final AppPreferences _appPreferences;

  RegisterViewmodel(this._registerUsecase, this._appPreferences);

  @override
  void dispose() {
    super.dispose();
    _fullNameStreamController.close();
    _emailStreamController.close();
    _passwordStreamController.close();
    _confirmPasswordStreamController.close();
    _areAllInputsValidStreamController.close();
    _isLoadingController.close();
  }

  @override
  void start() {
    inputState.add(ContentState());
  }

  // Inputs
  @override
  Sink<String> get inputFullName => _fullNameStreamController.sink;

  @override
  Sink<String> get inputEmail => _emailStreamController.sink;

  @override
  Sink<String> get inputPassword => _passwordStreamController.sink;

  @override
  Sink<String> get inputConfirmPassword =>
      _confirmPasswordStreamController.sink;

  @override
  Sink get inputAreAllInputsValid => _areAllInputsValidStreamController.sink;

  // Outputs
  @override
  Stream<bool> get outIsFullNameValid =>
      _fullNameStreamController.stream.map((name) {
        return name.isNotEmpty;
      });

  @override
  Stream<bool> get outIsEmailValid =>
      _emailStreamController.stream.map((email) {
        return isEmailValid(email);
      });

  @override
  Stream<bool> get outIsPasswordValid =>
      _passwordStreamController.stream.map((password) {
        return isPasswordValid(password);
      });

  @override
  Stream<bool> get outIsConfirmPasswordValid =>
      _confirmPasswordStreamController.stream.map((confirmPassword) {
        return confirmPassword == registerObject.password &&
            confirmPassword.isNotEmpty;
      });

  @override
  Stream<bool> get outAreAllInputsValid =>
      _areAllInputsValidStreamController.stream
          .map((_) => _areAllInputsValid());

  // Helper
  bool _areAllInputsValid() {
    return registerObject.fullName.isNotEmpty &&
        isEmailValid(registerObject.email) &&
        isPasswordValid(registerObject.password) &&
        registerObject.confirmPassword == registerObject.password;
  }

  @override
  void setEmail(String email) {
    inputEmail.add(email);
    registerObject = registerObject.copyWith(email: email);
    _validateInputs();
  }

  @override
  void setPassword(String password) {
    inputPassword.add(password);
    registerObject = registerObject.copyWith(password: password);
    _validateInputs();
  }

  void setFullName(String name) {
    inputFullName.add(name);
    registerObject = registerObject.copyWith(fullName: name);
    _validateInputs();
  }

  void setConfirmPassword(String confirmPassword) {
    inputConfirmPassword.add(confirmPassword);
    registerObject = registerObject.copyWith(confirmPassword: confirmPassword);
    _validateInputs();
  }

  void _validateInputs() {
    inputAreAllInputsValid.add(null);
  }

  @override
  Future<void> register() async {
    _isLoadingController.add(true);
    final result = await _registerUsecase.execute(RegisterUsecaseInput(
        registerObject.fullName,
        registerObject.email,
        registerObject.password,
        registerObject.confirmPassword));

    result.fold(
      (failure) {
        _isLoadingController.add(false);
        inputState
            .add(ErrorState(StateRendererType.popErrorState, failure.message));
      },
      (data) async {
        _isLoadingController.add(false);
        await _appPreferences.setRegisterEmail(registerObject.email);
        debugPrint('Email is saved successfully' + registerObject.email);
        isUserRegisteredInStreamController.add(true);
        inputState.add(ContentState());
      },
    );
  }
}

abstract class RegisterViewmodelInputs {
  void setEmail(String email);
  void setPassword(String password);
  Sink<String> get inputFullName;
  Sink<String> get inputEmail;
  Sink<String> get inputPassword;
  Sink<String> get inputConfirmPassword;
  Future<void> register();
  Sink get inputAreAllInputsValid;
}

abstract class RegisterViewmodelOutputs {
  Stream<bool> get outIsFullNameValid;
  Stream<bool> get outIsEmailValid;
  Stream<bool> get outIsPasswordValid;
  Stream<bool> get outIsConfirmPasswordValid;
  Stream<bool> get outAreAllInputsValid;
}
