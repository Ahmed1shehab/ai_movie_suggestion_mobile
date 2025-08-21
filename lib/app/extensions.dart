import 'package:ai_movie_suggestion/app/constants.dart';

import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';

extension NonNullString on String? {
  String orEmpty() {
    if (this == null) {
      return Constants.empty;
    } else {
      return this!;
    }
  }
}

extension NonNullInt on int? {
  int orZero() {
    if (this == null) {
      return Constants.zero;
    } else {
      return this!;
    }
  }
}

extension FlowStateExtension on FlowState {}
