import 'dart:async';

import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseViewmodel extends BaseViewmodelInputs
    implements BaseViewmodelOutputs {
// shared variables and function that will be used through any view model.
  final StreamController _inputStreamController = BehaviorSubject<FlowState>();

  @override
  Sink get inputState => _inputStreamController.sink;

  @override
  Stream<FlowState> get outputState =>
      _inputStreamController.stream.map((flowState) => flowState);

  @override
  void dispose() {
    _inputStreamController.close();
  }
}

abstract class BaseViewmodelInputs {
  void start();
  void dispose();
  Sink get inputState;
}

abstract class BaseViewmodelOutputs {
  Stream<FlowState> get outputState;
}
