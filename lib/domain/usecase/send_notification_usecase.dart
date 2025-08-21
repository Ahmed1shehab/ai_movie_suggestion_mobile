import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class SendNotificationUsecase
    implements
        BaseUseCase<SendNotificationUsecaseInput, SendNotificationEntity> {
  final Repository _repository;

  SendNotificationUsecase(this._repository);
  @override
  Future<Either<Failure, SendNotificationEntity>> execute(
      SendNotificationUsecaseInput input) async {
    return await _repository
        .sendNotifications(SendNotificationsRequest(input.message, input.date));
  }
}

@override
class SendNotificationUsecaseInput {
  String message;
  DateTime date;

  SendNotificationUsecaseInput(this.message, this.date);
}
