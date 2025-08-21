import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/send_notification_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';
import 'package:ai_movie_suggestion/presentation/send_notifcations/service/notification_service.dart';
import 'package:rxdart/rxdart.dart';

class SendNotificationViewModel extends BaseViewmodel
    implements
        SendNotificationViewModelInputs,
        SendNotificationViewModelOutputs {
  final SendNotificationUsecase _sendNotificationUsecase;

  SendNotificationViewModel(this._sendNotificationUsecase);

  // Stream controllers
  final _messageStreamController = BehaviorSubject<String>();
  final _dateStreamController = BehaviorSubject<DateTime>();
  final _sendNotificationStreamController =
      BehaviorSubject<SendNotificationEntity>();
  final _isFormValidStreamController = BehaviorSubject<bool>();

  // Inputs
  @override
  void setMessage(String message) {
    inputMessage.add(message);
    _validateForm();
  }

  @override
  void setDate(DateTime date) {
    inputDate.add(date);
    _validateForm();
  }

  @override
  Future<void> sendNotification() async {
    inputState.add(
        LoadingState(stateRendererType: StateRendererType.popLoadingState));

    final message = _messageStreamController.valueOrNull ?? '';
    final date = _dateStreamController.valueOrNull ?? DateTime.now();

    try {
      // First, send notification to server
      final result = await _sendNotificationUsecase
          .execute(SendNotificationUsecaseInput(message, date));

      await result.fold(
        (failure) async {
          inputState
              .add(ErrorState(StateRendererType.popErrorState, failure.message));
        },
        (data) async {
          // Server request successful, now handle local notifications
          await _handleLocalNotifications(message, date, data);
          
          inputState.add(SuccessState('Notification sent successfully!'));
          inputSendNotification.add(data);
        },
      );
    } catch (e) {
      inputState.add(ErrorState(
          StateRendererType.popErrorState, 'Failed to send notification: $e'));
    }
  }

  Future<void> _handleLocalNotifications(
    String message, 
    DateTime scheduledDate, 
    SendNotificationEntity serverResponse
  ) async {
    try {
      final now = DateTime.now();
      
      if (scheduledDate.isAfter(now)) {
        // Schedule notification for future time
        await NotificationService.scheduleNotification(
          id: _generateNotificationId(),
          title: 'Movie Suggestion Reminder',
          body: message,
          scheduledDate: scheduledDate,
          payload: _createNotificationPayload(serverResponse),
        );
      } else {
        // Show immediate notification
        await NotificationService.showNotification(
          id: _generateNotificationId(),
          title: 'Movie Suggestion',
          body: message,
          payload: _createNotificationPayload(serverResponse),
        );
      }
    } catch (e) {
      // Log error but don't fail the main operation
      print('Failed to schedule local notification: $e');
    }
  }

  int _generateNotificationId() {
    // Generate unique ID based on timestamp
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  String _createNotificationPayload(SendNotificationEntity serverResponse) {
    // Create payload with relevant data for notification tap handling
    return 'movie_suggestion|${serverResponse.message}|${DateTime.now().toIso8601String()}';
  }

  void _validateForm() {
    final message = _messageStreamController.valueOrNull ?? '';
    final date = _dateStreamController.valueOrNull;

    final isValid = message.isNotEmpty && date != null;
    inputIsFormValid.add(isValid);
  }

  // Method to cancel scheduled notifications if needed
  Future<void> cancelScheduledNotifications() async {
    try {
      final pendingNotifications = await NotificationService.getPendingNotifications();
      for (final notification in pendingNotifications) {
        await NotificationService.cancelNotification(notification.id);
      }
    } catch (e) {
      print('Failed to cancel notifications: $e');
    }
  }

  // Outputs
  @override
  Stream<String> get outputMessage =>
      _messageStreamController.stream.map((message) => message);

  @override
  Stream<DateTime> get outputDate =>
      _dateStreamController.stream.map((date) => date);

  @override
  Stream<SendNotificationEntity> get outputSendNotification =>
      _sendNotificationStreamController.stream
          .map((notification) => notification);

  @override
  Stream<bool> get outputIsFormValid =>
      _isFormValidStreamController.stream.map((isValid) => isValid);

  // Inputs
  @override
  Sink get inputMessage => _messageStreamController.sink;

  @override
  Sink get inputDate => _dateStreamController.sink;

  @override
  Sink get inputSendNotification => _sendNotificationStreamController.sink;

  @override
  Sink get inputIsFormValid => _isFormValidStreamController.sink;

  @override
  void dispose() {
    super.dispose();
    _messageStreamController.close();
    _dateStreamController.close();
    _sendNotificationStreamController.close();
    _isFormValidStreamController.close();
  }

  @override
  void start() {}
}

abstract class SendNotificationViewModelInputs {
  void setMessage(String message);
  void setDate(DateTime date);
  Future<void> sendNotification();

  Sink get inputMessage;
  Sink get inputDate;
  Sink get inputSendNotification;
  Sink get inputIsFormValid;
}

abstract class SendNotificationViewModelOutputs {
  Stream<String> get outputMessage;
  Stream<DateTime> get outputDate;
  Stream<SendNotificationEntity> get outputSendNotification;
  Stream<bool> get outputIsFormValid;
}