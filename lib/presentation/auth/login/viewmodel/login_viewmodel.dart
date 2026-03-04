import 'dart:async';
import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/functions.dart';
import 'package:ai_movie_suggestion/domain/usecase/login_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/freezed_data_classes.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class LoginViewmodel extends BaseViewmodel
    implements LoginViewmodelInputs, LoginViewmodelOutputs {
  final StreamController<String> _emailStreamController =
      StreamController<String>.broadcast();
  final StreamController<String> _passwordStreamController =
      StreamController<String>.broadcast();
  final StreamController<void> _areAllInputsValidStreamController =
      StreamController<void>.broadcast();
  final StreamController<bool> _rememberMeStreamController =
      StreamController<bool>.broadcast();

  final StreamController isUserLoggedInStreamController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _isLoadingController = StreamController<bool>();
  Stream<bool> get outIsLoading => _isLoadingController.stream;

  var loginObject = LoginObject("", "");
  bool _rememberMe = false;
  
  final LoginUsecase _loginUseCase;
  final AppPreferences _appPreferences;
  
  LoginViewmodel(this._loginUseCase, this._appPreferences);
  
  @override
  void dispose() {
    super.dispose();
    _emailStreamController.close();
    _passwordStreamController.close();
    _areAllInputsValidStreamController.close();
    _rememberMeStreamController.close();
    isUserLoggedInStreamController.close();
    _isLoadingController.close();
  }

  @override
  void start() {
    inputState.add(ContentState());
    _loadRememberedCredentials();
  }

  /// Load remembered credentials if available
  Future<void> _loadRememberedCredentials() async {
    try {
      final hasRemembered = await _appPreferences.hasRememberedCredentials();
      if (hasRemembered) {
        final credentials = await _appPreferences.getRememberedCredentials();
        final email = credentials['email'] ?? '';
        final password = credentials['password'] ?? '';
        
        // Update the login object and streams
        loginObject = loginObject.copyWith(email: email, password: password);
        setEmail(email);
        setPassword(password);
        setRememberMe(true);
        
        debugPrint('[LoginViewModel] Loaded remembered credentials for: $email');
      }
    } catch (e) {
      debugPrint('[LoginViewModel] Error loading remembered credentials: $e');
    }
  }

  @override
  Sink get inputAreAllInputsValid => _areAllInputsValidStreamController.sink;

  @override
  Sink<String> get inputEmail => _emailStreamController.sink;

  @override
  Sink<String> get inputPassword => _passwordStreamController.sink;

  @override
  Sink<bool> get inputRememberMe => _rememberMeStreamController.sink;

  @override
  Stream<bool> get outRememberMe => _rememberMeStreamController.stream;

  @override
  Future<void> login() async {
    _isLoadingController.add(true);

    try {
      final result = await _loginUseCase.execute(
        LoginUsecaseInput(loginObject.email, loginObject.password),
      );

      result.fold(
        (failure) {
          _isLoadingController.add(false);
          inputState.add(
            ErrorState(StateRendererType.popErrorState, failure.message),
          );
        },
        (data) async {
          _isLoadingController.add(false);

          // Save token
          await _appPreferences.deleteAccessToken();
          await _appPreferences.saveAccessToken(data.token);
          debugPrint('Token is saved successfully: ${data.token}');

          // Handle remember me functionality
          if (_rememberMe) {
            await _appPreferences.setRememberMe(
              true,
              email: loginObject.email,
              password: loginObject.password,
            );
            debugPrint('[LoginViewModel] Credentials saved for remember me');
          } else {
            await _appPreferences.setRememberMe(false);
            debugPrint('[LoginViewModel] Remember me disabled, credentials cleared');
          }

          // Set user as logged in
          await _appPreferences.setUserLoggedIn();

          // Signal successful login
          isUserLoggedInStreamController.add(true);
          inputState.add(ContentState());
        },
      );
    } catch (e) {
      _isLoadingController.add(false);
      inputState.add(ErrorState(StateRendererType.popErrorState, e.toString()));
    }
  }

  @override
  Stream<bool> get outAreAllInputsValid =>
      _areAllInputsValidStreamController.stream
          .map((_) => _areAllInputsValid());

  @override
  Stream<bool> get outIsEmailValid =>
      _emailStreamController.stream
          .debounceTime(const Duration(milliseconds: 500))
          .map((email) => isEmailValid(email));

  @override
  Stream<bool> get outIsPasswordValid =>
      _passwordStreamController.stream
          .debounceTime(const Duration(milliseconds: 500))
          .map((password) => isPasswordValid(password));

  @override
  void setEmail(String email) {
    inputEmail.add(email);
    loginObject = loginObject.copyWith(email: email);
    inputAreAllInputsValid.add(null);
  }

  @override
  void setPassword(String password) {
    inputPassword.add(password);
    loginObject = loginObject.copyWith(password: password);
    inputAreAllInputsValid.add(null);
  }

  @override
  void setRememberMe(bool rememberMe) {
    _rememberMe = rememberMe;
    inputRememberMe.add(rememberMe);
  }

  /// Get current remember me state
  bool get rememberMe => _rememberMe;

  /// Auto-login with remembered credentials
  Future<void> autoLoginWithRememberedCredentials() async {
    final hasRemembered = await _appPreferences.hasRememberedCredentials();
    if (hasRemembered) {
      debugPrint('[LoginViewModel] Auto-login with remembered credentials');
      await login();
    }
  }

  // Private helper method to check if all inputs are valid
  bool _areAllInputsValid() {
    return isEmailValid(loginObject.email) &&
        isPasswordValid(loginObject.password);
  }
}

abstract class LoginViewmodelInputs {
  void setEmail(String email);
  void setPassword(String password);
  void setRememberMe(bool rememberMe);
  Future<void> login();

  Sink<String> get inputEmail;
  Sink<String> get inputPassword;
  Sink<bool> get inputRememberMe;
  Sink get inputAreAllInputsValid;
}

abstract class LoginViewmodelOutputs {
  Stream<bool> get outIsEmailValid;
  Stream<bool> get outIsPasswordValid;
  Stream<bool> get outAreAllInputsValid;
  Stream<bool> get outRememberMe;
}