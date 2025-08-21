import 'dart:async';

import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseViewmodel extends BaseViewmodelInputs
    implements BaseViewmodelOutputs {
  // shared variables and function that will be used through any view model.
  final StreamController _inputStreamController = BehaviorSubject<FlowState>();

  // Add this private flag to track disposal status
  bool _isDisposed = false;

  // Public getter to check if the ViewModel has been disposed
  bool get isDisposed => _isDisposed; // <--- Added isDisposed getter

  @override
  Sink get inputState => _inputStreamController.sink;

  @override
  Stream<FlowState> get outputState =>
      _inputStreamController.stream.map((flowState) => flowState);

  @override
  void dispose() {
    _inputStreamController.close();
    _isDisposed = true; // <--- Set the flag to true on dispose
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