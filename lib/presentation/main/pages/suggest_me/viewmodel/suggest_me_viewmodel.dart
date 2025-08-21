import 'dart:async';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/domain/usecase/send_prompt_usecase.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class SuggestMeViewmodel extends BaseViewmodel
    implements SuggestMeViewmodelInputs, SuggestMeViewmodelOutputs {
  final SendPromptUsecase _sendPromptUsecase;
  final AppPreferences _appPreferences;

  // Stream controllers
  final _urlLaunchStreamController = BehaviorSubject<String?>();
  final _errorMessageStreamController = BehaviorSubject<String?>();
  final _promptStreamController = StreamController<String>.broadcast();
  final _isLoadingStreamController = StreamController<bool>.broadcast();
  final _movieDetailStreamController = StreamController<MovieDetail?>.broadcast();
  final _chatStateStreamController = StreamController<ChatState>.broadcast();
  final _watchlistStreamController = BehaviorSubject<bool>.seeded(false);
  final _errorResponseStreamController = StreamController<String?>.broadcast();

  // Disposal flag
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  SuggestMeViewmodel(this._sendPromptUsecase, this._appPreferences);

  @override
  void start() {
    inputState.add(ContentState());
    inputIsLoading.add(false);
    inputChatState.add(ChatState.initial);
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Close all stream controllers safely
    if (!_promptStreamController.isClosed) {
      _promptStreamController.close();
    }
    if (!_isLoadingStreamController.isClosed) {
      _isLoadingStreamController.close();
    }
    if (!_movieDetailStreamController.isClosed) {
      _movieDetailStreamController.close();
    }
    if (!_chatStateStreamController.isClosed) {
      _chatStateStreamController.close();
    }
    if (!_urlLaunchStreamController.isClosed) {
      _urlLaunchStreamController.close();
    }
    if (!_errorMessageStreamController.isClosed) {
      _errorMessageStreamController.close();
    }
    if (!_watchlistStreamController.isClosed) {
      _watchlistStreamController.close();
    }
    if (!_errorResponseStreamController.isClosed) {
      _errorResponseStreamController.close();
    }
    
    super.dispose();
  }

  // Inputs
  @override
  Sink get inputPrompt => _promptStreamController.sink;

  @override
  Sink get inputIsLoading => _isLoadingStreamController.sink;

  @override
  Sink get inputMovieDetail => _movieDetailStreamController.sink;

  @override
  Sink get inputChatState => _chatStateStreamController.sink;

  @override
  Sink get inputIsInWatchlist => _watchlistStreamController.sink;

  Sink get inputErrorResponse => _errorResponseStreamController.sink;

  // Outputs
  @override
  Stream<bool> get outIsLoading =>
      _isLoadingStreamController.stream.map((isLoading) => isLoading);

  @override
  Stream<MovieDetail?> get outMovieDetail =>
      _movieDetailStreamController.stream.map((movieDetail) => movieDetail);

  @override
  Stream<ChatState> get outChatState =>
      _chatStateStreamController.stream.map((chatState) => chatState);

  @override
  Stream<bool> get outputIsInWatchlist => _watchlistStreamController.stream;

  Stream<String?> get outErrorResponse => _errorResponseStreamController.stream;

  // Methods
  @override
  void setPrompt(String prompt) {
    if (!isDisposed && !_promptStreamController.isClosed) {
      inputPrompt.add(prompt);
    }
  }

  @override
  void sendPrompt(String prompt) async {
    if (prompt.trim().isEmpty || isDisposed) return;

    // Only set loading state for thinking animation, no pop-up loading
    if (!isDisposed) {
      inputState.add(ContentState()); // Keep content state
      if (!_isLoadingStreamController.isClosed) {
        inputIsLoading.add(true);
      }
      if (!_chatStateStreamController.isClosed) {
        inputChatState.add(ChatState.thinking);
      }
      // Clear previous movie detail and error
      if (!_movieDetailStreamController.isClosed) {
        inputMovieDetail.add(null);
      }
      if (!_errorResponseStreamController.isClosed) {
        inputErrorResponse.add(null);
      }
    }

    try {
      // Execute the prompt
      final result = await _sendPromptUsecase.execute(SendPromptUsecaseInput(prompt.trim()));
      
      if (isDisposed) return; // Check if disposed after async operation
      
      result.fold(
        (failure) {
          // Handle specific error messages
          String errorMessage = _getErrorMessage(failure.message);
          
          if (!isDisposed) {
            inputState.add(ContentState());
            if (!_isLoadingStreamController.isClosed) {
              inputIsLoading.add(false);
            }
            if (!_chatStateStreamController.isClosed) {
              inputChatState.add(ChatState.error);
            }
            if (!_movieDetailStreamController.isClosed) {
              inputMovieDetail.add(null);
            }
            if (!_errorResponseStreamController.isClosed) {
              inputErrorResponse.add(errorMessage);
            }
          }
        },
        (movieDetail) {
          if (!isDisposed) {
            inputState.add(ContentState());
            if (!_isLoadingStreamController.isClosed) {
              inputIsLoading.add(false);
            }
            if (!_chatStateStreamController.isClosed) {
              inputChatState.add(ChatState.received);
            }
            if (!_movieDetailStreamController.isClosed) {
              inputMovieDetail.add(movieDetail);
            }
            if (!_errorResponseStreamController.isClosed) {
              inputErrorResponse.add(null);
            }
            // Check watchlist status for the new movie
            if (movieDetail.id != null) {
              _checkWatchlistStatus(movieDetail.id!);
            }
          }
        },
      );
    } catch (e) {
      if (!isDisposed) {
        String errorMessage = _getErrorMessage(e.toString());
        
        inputState.add(ContentState());
        if (!_isLoadingStreamController.isClosed) {
          inputIsLoading.add(false);
        }
        if (!_chatStateStreamController.isClosed) {
          inputChatState.add(ChatState.error);
        }
        if (!_movieDetailStreamController.isClosed) {
          inputMovieDetail.add(null);
        }
        if (!_errorResponseStreamController.isClosed) {
          inputErrorResponse.add(errorMessage);
        }
      }
    }
  }

  // Helper method to determine appropriate error message
  String _getErrorMessage(String errorMessage) {
    // Check for "Not enough credits" error
    if (errorMessage.toLowerCase().contains('not enough credits') || 
        errorMessage.toLowerCase().contains('credits')) {
      return "Sorry, you don't have enough credits to get a movie suggestion right now. Please check your account or try again later.";
    } else {
      return "Oops! Something went wrong. Please try again later.";
    }
  }

  @override
  void resetChat() {
    if (!isDisposed) {
      inputState.add(ContentState());
      if (!_isLoadingStreamController.isClosed) {
        inputIsLoading.add(false);
      }
      if (!_chatStateStreamController.isClosed) {
        inputChatState.add(ChatState.initial);
      }
      if (!_movieDetailStreamController.isClosed) {
        inputMovieDetail.add(null);
      }
      if (!_watchlistStreamController.isClosed) {
        inputIsInWatchlist.add(false);
      }
      if (!_errorResponseStreamController.isClosed) {
        inputErrorResponse.add(null);
      }
    }
  }

  @override
  Future<void> launchMovieUrl(String url) async {
    if (url.isEmpty || isDisposed) {
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

        if (launched && !isDisposed) {
          if (!_urlLaunchStreamController.isClosed) {
            _urlLaunchStreamController.add(cleanUrl);
          }
          _showMessage('Opening movie page...');
        } else if (!isDisposed) {
          _showErrorMessage('Unable to open the movie page');
        }
      } else {
        _showErrorMessage('Cannot launch this URL');
      }
    } catch (e) {
      if (!isDisposed) {
        _showErrorMessage('Error launching URL: $e');
      }
    }
  }

  @override
  Future<void> toggleWatchlist(MovieDetail movie) async {
    if (movie.id == null || isDisposed) {
      _showErrorMessage('Invalid movie data');
      return;
    }

    try {
      final currentStatus = _watchlistStreamController.value;
      final newStatus = !currentStatus;

      // Update UI immediately for better UX
      if (!isDisposed && !_watchlistStreamController.isClosed) {
        inputIsInWatchlist.add(newStatus);
      }

      // Update local storage
      if (newStatus) {
        await _appPreferences.addToWatchlist(movie.id!);
        if (!isDisposed) {
          _showMessage('Added to watchlist');
        }
      } else {
        await _appPreferences.removeFromWatchlist(movie.id!);
        if (!isDisposed) {
          _showMessage('Removed from watchlist');
        }
      }
    } catch (e) {
      // Revert UI on error
      if (!isDisposed && !_watchlistStreamController.isClosed) {
        final currentStatus = _watchlistStreamController.value;
        inputIsInWatchlist.add(!currentStatus);
      }
      _showErrorMessage('Failed to update watchlist: $e');
      debugPrint('Error in toggleWatchlist: $e');
    }
  }

  // Private helper methods
  Future<void> _checkWatchlistStatus(int movieId) async {
    if (isDisposed) return;
    
    try {
      final bool isInWatchlist = await _appPreferences.isMovieInWatchlist(movieId);
      if (!isDisposed && !_watchlistStreamController.isClosed) {
        inputIsInWatchlist.add(isInWatchlist);
      }
    } catch (e) {
      debugPrint('Error checking watchlist status: $e');
      if (!isDisposed && !_watchlistStreamController.isClosed) {
        inputIsInWatchlist.add(false); // Default to false on error
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!isDisposed && !_errorMessageStreamController.isClosed) {
      _errorMessageStreamController.add(message);
    }
    debugPrint('Error: $message');
  }

  void _showMessage(String message) {
    // TODO: Implement message display (e.g., SnackBar)
    debugPrint('Message: $message');
    // You might want to use a different approach for showing messages
    // depending on your app's architecture
  }
}

// Chat states enum
enum ChatState {
  initial,
  thinking,
  received,
  error,
}

abstract class SuggestMeViewmodelInputs {
  void setPrompt(String prompt);
  void sendPrompt(String prompt);
  Future<void> launchMovieUrl(String url);
  Future<void> toggleWatchlist(MovieDetail movie);
  void resetChat();

  Sink get inputPrompt;
  Sink get inputIsLoading;
  Sink get inputMovieDetail;
  Sink get inputChatState;
  Sink get inputIsInWatchlist;
}

abstract class SuggestMeViewmodelOutputs {
  Stream<bool> get outIsLoading;
  Stream<MovieDetail?> get outMovieDetail;
  Stream<ChatState> get outChatState;
  Stream<bool> get outputIsInWatchlist;
}