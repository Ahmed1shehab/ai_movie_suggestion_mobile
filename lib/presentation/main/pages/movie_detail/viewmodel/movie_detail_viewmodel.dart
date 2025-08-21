import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/movie_details_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/similar_movies_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/add_like_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class MovieDetailsViewModelInputs {
  Future<void> getMovieDetails(int movieId, {String? language});
  Future<void> getSimilarMovies(int movieId, {int? page, String? language});
  Future<void> toggleWatchlist(MovieDetail movie);
  Future<void> launchMovieUrl(String url);
  void updateNotificationDate(DateTime date);
  void updateNotificationTime(TimeOfDay time);
  void toggleNotification();

  // Sinks
  Sink<MovieDetail> get inputMovieDetail;
  Sink<bool> get inputIsInWatchlist;
  Sink<NotificationData> get inputNotificationData;
  Sink<bool> get inputNotificationEnabled;
  Sink<List<MovieEntity>> get inputSimilarMovies;
  Sink<bool> get inputSimilarMoviesLoading;
}

abstract class MovieDetailsViewModelOutputs {
  // Streams
  Stream<MovieDetail> get outputMovieDetail;
  Stream<bool> get outputIsInWatchlist;
  Stream<NotificationData> get outputNotificationData;
  Stream<bool> get outputNotificationEnabled;
  Stream<String?> get outputUrlLaunch;
  Stream<String?> get outputErrorMessage;
  Stream<List<MovieEntity>> get outputSimilarMovies;
  Stream<bool> get outputSimilarMoviesLoading;
}

class MovieDetailsViewModel extends BaseViewmodel
    implements MovieDetailsViewModelInputs, MovieDetailsViewModelOutputs {
  final MovieDetailsUseCase _movieDetailsUseCase;
  final SimilarMoviesUsecase _similarMoviesUsecase;
  final AddLikeUsecase _addLikeUsecase;
  final AppPreferences _appPreferences;

  // Stream controllers
  final _movieDetailStreamController = BehaviorSubject<MovieDetail>();
  final _watchlistStreamController = BehaviorSubject<bool>.seeded(false);
  final _notificationDataStreamController =
      BehaviorSubject<NotificationData>.seeded(NotificationData());
  final _notificationEnabledStreamController =
      BehaviorSubject<bool>.seeded(false);
  final _urlLaunchStreamController = BehaviorSubject<String?>();
  final _errorMessageStreamController = BehaviorSubject<String?>();
  final _similarMoviesStreamController =
      BehaviorSubject<List<MovieEntity>>.seeded([]);
  final _similarMoviesLoadingStreamController =
      BehaviorSubject<bool>.seeded(false);

  // Current movie reference
  MovieDetail? _currentMovie;

  // Updated constructor to include AppPreferences
  MovieDetailsViewModel(
    this._movieDetailsUseCase,
    this._similarMoviesUsecase,
    this._addLikeUsecase,
    this._appPreferences,
  );

  @override
  void start() {
    inputState.add(ContentState());
  }

  @override
  void dispose() {
    _movieDetailStreamController.close();
    _watchlistStreamController.close();
    _notificationDataStreamController.close();
    _notificationEnabledStreamController.close();
    _urlLaunchStreamController.close();
    _errorMessageStreamController.close();
    _similarMoviesStreamController.close();
    _similarMoviesLoadingStreamController.close();
    super.dispose();
  }

  @override
  Future<void> getMovieDetails(int movieId, {String? language}) async {
    // Only show loading state if the ViewModel is still active
    if (!isDisposed) {
      // Assuming `isDisposed` is a property from BaseViewmodel
      inputState.add(LoadingState(
          stateRendererType: StateRendererType.fullScreenLoadingState));
    }

    try {
      final result = await _movieDetailsUseCase.execute(
        MovieDetailsUseCaseInput(movieId, language: language),
      );

      result.fold(
        (failure) {
          if (!isDisposed) {
            inputState.add(ErrorState(
                StateRendererType.fullScreenErrorState, failure.message));
            // You might also want to clear previous movie details if an error occurs
            if (!_movieDetailStreamController.isClosed) {
              _movieDetailStreamController.addError(failure.message);
            }
          }
        },
        (movieDetail) {
          _currentMovie = movieDetail;
          if (!isDisposed) {
            inputState.add(ContentState());
            if (!_movieDetailStreamController.isClosed) {
              // <--- Added check
              inputMovieDetail.add(movieDetail);
            }

            // Check if movie is in watchlist AND liked movies using SharedPreferences
            _checkWatchlistStatus(movieDetail);

            // Load similar movies
            getSimilarMovies(movieId, language: language);
          }
        },
      );
    } catch (e) {
      if (!isDisposed) {
        inputState.add(
            ErrorState(StateRendererType.fullScreenErrorState, e.toString()));
        if (!_movieDetailStreamController.isClosed) {
          // <--- Added check
          _movieDetailStreamController.addError(e);
        }
      }
    }
  }

  @override
  Future<void> getSimilarMovies(int movieId,
      {int? page, String? language}) async {
    if (!_similarMoviesLoadingStreamController.isClosed) {
      // <--- Added check
      inputSimilarMoviesLoading.add(true);
    }

    try {
      final result = await _similarMoviesUsecase.execute(
        SimilarMoviesUsecaseInput(movieId, page: page, language: language),
      );

      result.fold(
        (failure) {
          _showErrorMessage(
              'Failed to load similar movies: ${failure.message}');
          if (!_similarMoviesStreamController.isClosed) {
            // <--- Added check
            inputSimilarMovies.add([]);
          }
        },
        (movies) {
          if (!_similarMoviesStreamController.isClosed) {
            // <--- Added check
            inputSimilarMovies.add(movies);
          }
        },
      );
    } catch (e) {
      _showErrorMessage('Error loading similar movies: $e');
      if (!_similarMoviesStreamController.isClosed) {
        // <--- Added check
        inputSimilarMovies.add([]);
      }
    } finally {
      if (!_similarMoviesLoadingStreamController.isClosed) {
        // <--- Added check
        inputSimilarMoviesLoading.add(false);
      }
    }
  }

 @override
Future<void> toggleWatchlist(MovieDetail movie) async {
  if (movie.id == null) {
    _showErrorMessage('Invalid movie data');
    return;
  }

  final currentStatus = _watchlistStreamController.value;
  final newStatus = !currentStatus;

  try {
    // Update UI immediately for better UX
    if (!_watchlistStreamController.isClosed) {
      inputIsInWatchlist.add(newStatus);
    }

    // Update local storage immediately (this is what the user sees)
    if (newStatus) {
      await _appPreferences.addToWatchlist(movie.id!);
      await _appPreferences.addToLikedMovies(movie.id!);
    } else {
      await _appPreferences.removeFromWatchlist(movie.id!);
      await _appPreferences.removeFromLikedMovies(movie.id!);
    }

    // Show success message immediately
    if (newStatus) {
      _showMessage('Added to watchlist and liked movies successfully');
      debugPrint('Movie ${movie.id} (${movie.title}) added to watchlist and liked movies locally');
    } else {
      _showMessage('Removed from watchlist and liked movies successfully');
      debugPrint('Movie ${movie.id} (${movie.title}) removed from watchlist and liked movies locally');
    }

    // Call the Like API in the background (don't block the UI)
    _callLikeAPIInBackground(movie.id!);

  } catch (e) {
    // If local storage fails, revert UI and show error
    if (!_watchlistStreamController.isClosed) {
      inputIsInWatchlist.add(currentStatus);
    }
    _showErrorMessage('Failed to update watchlist: $e');
    debugPrint('Error in toggleWatchlist: $e');
  }
}

// Helper method to call Like API in background
void _callLikeAPIInBackground(int movieId) async {
  try {
    debugPrint('Calling Like API for movie ID: $movieId');
    
    final result = await _addLikeUsecase.execute(
      AddLikeUsecaseInput(movieId.toString()),
    );

    result.fold(
      (failure) {
        // API failed, but local storage succeeded
        debugPrint('Like API call failed: ${failure.message}');
        // Optionally show a subtle notification that it will sync later
        // You could implement a retry mechanism here if needed
      },
      (addLikeModel) {
        // API succeeded
        debugPrint('Like API call succeeded: $addLikeModel');
        // Both local storage and API are now in sync
      },
    );
  } catch (apiError) {
    // API call threw an exception
    debugPrint('Like API call exception: $apiError');
    // Local storage is still updated, so the user experience is not affected
    // You could add this to a retry queue if needed
  }
}
  @override
  Future<void> launchMovieUrl(String url) async {
    if (url.isEmpty) {
      _showErrorMessage('No URL available');
      return;
    }

    try {
      // Clean and validate the URL
      String cleanUrl = url.trim();

      // Add https if no protocol is specified
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final Uri uri = Uri.parse(cleanUrl);

      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        bool launched = false;

        // Try different launch modes in order of preference
        try {
          // First try external application mode
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          debugPrint('External application launch failed: $e');
        }

        // If external app failed, try in-app web view
        if (!launched) {
          try {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.inAppWebView,
            );
          } catch (e) {
            debugPrint('In-app web view launch failed: $e');
          }
        }

        // If in-app web view failed, try platform default
        if (!launched) {
          try {
            launched = await launchUrl(uri);
          } catch (e) {
            debugPrint('Platform default launch failed: $e');
          }
        }

        if (launched) {
          if (!_urlLaunchStreamController.isClosed) {
            _urlLaunchStreamController.add(cleanUrl);
          }
          _showMessage('Opening movie page...');
        } else {
          _showErrorMessage('Unable to open the movie page');
        }
      } else {
        _showErrorMessage('Cannot launch this URL');
      }
    } catch (e) {
      _showErrorMessage('Error launching URL: $e');
    }
  }

  @override
  void updateNotificationDate(DateTime date) {
    if (_notificationDataStreamController.isClosed) return;
    final currentData = _notificationDataStreamController.value;
    final updatedData = currentData.copyWith(selectedDate: date);
    inputNotificationData.add(updatedData);
  }

  @override
  void updateNotificationTime(TimeOfDay time) {
    if (_notificationDataStreamController.isClosed) return;
    final currentData = _notificationDataStreamController.value;
    final updatedData = currentData.copyWith(selectedTime: time);
    inputNotificationData.add(updatedData);
  }

  @override
  void toggleNotification() {
    if (_notificationDataStreamController.isClosed ||
        _notificationEnabledStreamController.isClosed) return;

    final currentData = _notificationDataStreamController.value;
    final currentEnabled = _notificationEnabledStreamController.value;

    // Check if date and time are selected
    if (currentData.selectedDate == null || currentData.selectedTime == null) {
      _showErrorMessage('Please select both date and time');
      return;
    }

    final newEnabled = !currentEnabled;

    // Update notification enabled state
    inputNotificationEnabled.add(newEnabled);

    // Update notification data with new enabled state
    final updatedData = currentData.copyWith(isEnabled: newEnabled);
    inputNotificationData.add(updatedData);

    if (newEnabled) {
      _scheduleNotification(updatedData);
      _showMessage('Notification scheduled successfully');
    } else {
      _cancelNotification();
      _showMessage('Notification cancelled');
    }
  }

  // Private helper methods
  Future<void> _checkWatchlistStatus(MovieDetail movie) async {
    if (movie.id != null) {
      try {
        final bool isInWatchlist =
            await _appPreferences.isMovieInWatchlist(movie.id!);
        if (!_watchlistStreamController.isClosed) {
          // <--- Added check
          inputIsInWatchlist.add(isInWatchlist);
        }
      } catch (e) {
        debugPrint('Error checking watchlist status: $e');
        if (!_watchlistStreamController.isClosed) {
          // <--- Added check
          inputIsInWatchlist.add(false); // Default to false on error
        }
      }
    } else {
      if (!_watchlistStreamController.isClosed) {
        // <--- Added check
        inputIsInWatchlist.add(false);
      }
    }
  }

  void _scheduleNotification(NotificationData data) {
    // TODO: Implement actual notification scheduling
    // This would typically involve using a local notification plugin
    // like flutter_local_notifications

    if (data.selectedDate != null && data.selectedTime != null) {
      final notificationDateTime = DateTime(
        data.selectedDate!.year,
        data.selectedDate!.month,
        data.selectedDate!.day,
        data.selectedTime!.hour,
        data.selectedTime!.minute,
      );

      debugPrint('Scheduling notification for: $notificationDateTime');

      // Example implementation:
      // await _localNotificationService.scheduleNotification(
      //   id: _currentMovie?.id ?? 0,
      //   title: 'Movie Available',
      //   body: '${_currentMovie?.title} might be available for streaming now!',
      //   scheduledDate: notificationDateTime,
      // );
    }
  }

  void _cancelNotification() {
    // TODO: Implement actual notification cancellation
    debugPrint('Cancelling notification for movie: ${_currentMovie?.title}');

    // Example implementation:
    // await _localNotificationService.cancelNotification(_currentMovie?.id ?? 0);
  }

  void _showMessage(String message) {
    // TODO: Implement message display (e.g., SnackBar)
    debugPrint('Message: $message');
    // You might want to use a different approach for showing messages
    // depending on your app's architecture
  }

  void _showErrorMessage(String message) {
    if (!_errorMessageStreamController.isClosed) {
      // <--- Added check
      _errorMessageStreamController.add(message);
    }
    debugPrint('Error: $message');
  }

  // Public method to get watchlist count (useful for displaying in UI)
  Future<int> getWatchlistCount() async {
    return await _appPreferences.getWatchlistCount();
  }

  // Public method to get all watchlisted movie IDs
  Future<List<int>> getWatchlistMovieIds() async {
    return await _appPreferences.getWatchlistMovieIds();
  }

  // Inputs
  @override
  Sink<MovieDetail> get inputMovieDetail => _movieDetailStreamController.sink;

  @override
  Sink<bool> get inputIsInWatchlist => _watchlistStreamController.sink;

  @override
  Sink<NotificationData> get inputNotificationData =>
      _notificationDataStreamController.sink;

  @override
  Sink<bool> get inputNotificationEnabled =>
      _notificationEnabledStreamController.sink;

  @override
  Sink<List<MovieEntity>> get inputSimilarMovies =>
      _similarMoviesStreamController.sink;

  @override
  Sink<bool> get inputSimilarMoviesLoading =>
      _similarMoviesLoadingStreamController.sink;

  // Outputs
  @override
  Stream<MovieDetail> get outputMovieDetail =>
      _movieDetailStreamController.stream;

  @override
  Stream<bool> get outputIsInWatchlist => _watchlistStreamController.stream;

  @override
  Stream<NotificationData> get outputNotificationData =>
      _notificationDataStreamController.stream;

  @override
  Stream<bool> get outputNotificationEnabled =>
      _notificationEnabledStreamController.stream;

  @override
  Stream<String?> get outputUrlLaunch => _urlLaunchStreamController.stream;

  @override
  Stream<String?> get outputErrorMessage =>
      _errorMessageStreamController.stream;

  @override
  Stream<List<MovieEntity>> get outputSimilarMovies =>
      _similarMoviesStreamController.stream;

  @override
  Stream<bool> get outputSimilarMoviesLoading =>
      _similarMoviesLoadingStreamController.stream;
}

// Assuming BaseViewmodel has an isDisposed property to check if dispose has been called
// If not, you might need to add it or manage a boolean flag in this ViewModel.
// Example:
// class BaseViewmodel extends ChangeNotifier {
//   bool _isDisposed = false;
//   bool get isDisposed => _isDisposed;
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     super.dispose();
//   }
// }
