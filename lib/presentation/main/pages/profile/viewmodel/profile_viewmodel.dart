import 'dart:async';
import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/get_user_data_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:rxdart/rxdart.dart';

class ProfileViewModel extends BaseViewmodel
    implements ProfileViewModelInputs, ProfileViewModelOutputs {
  
  final GetUserDataUsecase _getUserDataUsecase;
  
  // Stream controllers
  final _profileDataStreamController = BehaviorSubject<UserProfileModel?>();

  ProfileViewModel(this._getUserDataUsecase);

  // Inputs
  @override
  Sink get inputLoadProfile => _loadProfileStreamController.sink;
  final _loadProfileStreamController = StreamController<void>();

  @override
  Sink get inputRefreshProfile => _refreshProfileStreamController.sink;
  final _refreshProfileStreamController = StreamController<void>();

  // Outputs
  @override
  Stream<UserProfileModel?> get outputProfileData => 
      _profileDataStreamController.stream.map((data) => data);

  @override
  void start() {
    _bindInputs();
    loadUserProfile();
  }

  void _bindInputs() {
    // Bind load profile input
    _loadProfileStreamController.stream.listen((_) {
      loadUserProfile();
    });

    _refreshProfileStreamController.stream.listen((_) {
      refreshUserProfile();
    });
  }

  Future<void> loadUserProfile() async {
    if (isDisposed) return;

    // Show loading state
    inputState.add(LoadingState(
      stateRendererType: StateRendererType.fullScreenLoadingState,
      message: "Loading profile..."
    ));

    final result = await _getUserDataUsecase.execute(null);
    
    if (isDisposed) return;

    result.fold(
      (failure) {
        // Show error state
        inputState.add(ErrorState(
          StateRendererType.fullScreenErrorState, 
          _getErrorMessage(failure)
        ));
      },
      (userProfile) {
        // Set profile data and show content state
        _setProfileData(userProfile);
        inputState.add(ContentState());
      },
    );
  }

  Future<void> refreshUserProfile() async {
    if (isDisposed) return;

    // Show popup loading state for refresh
    inputState.add(LoadingState(
      stateRendererType: StateRendererType.popLoadingState,
      message: "Refreshing profile..."
    ));

    final result = await _getUserDataUsecase.execute(null);
    
    if (isDisposed) return;

    result.fold(
      (failure) {
        // Show popup error for refresh
        inputState.add(ErrorState(
          StateRendererType.popErrorState, 
          _getErrorMessage(failure)
        ));
      },
      (userProfile) {
        // Update profile data and show content state
        _setProfileData(userProfile);
        inputState.add(ContentState());
      },
    );
  }

  void _setProfileData(UserProfileModel data) {
    if (!_profileDataStreamController.isClosed) {
      _profileDataStreamController.add(data);
    }
  }

  String _getErrorMessage(Failure failure) {
    // You can customize this based on your Failure types
    return failure.message ?? 'An unexpected error occurred';
  }

  // Getter methods for easy access to current data
  UserProfileModel? get currentProfileData => 
      _profileDataStreamController.valueOrNull;

  @override
  void dispose() {
    _profileDataStreamController.close();
    _loadProfileStreamController.close();
    _refreshProfileStreamController.close();
    super.dispose();
  }
}

abstract class ProfileViewModelInputs {
  Sink get inputLoadProfile;
  Sink get inputRefreshProfile;
}

abstract class ProfileViewModelOutputs {
  Stream<UserProfileModel?> get outputProfileData;
}