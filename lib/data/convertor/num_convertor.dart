// lib/data/converter/num_converter.dart
import 'package:json_annotation/json_annotation.dart';

class NumConverter implements JsonConverter<num, dynamic> {
  const NumConverter();

  @override
  num fromJson(dynamic json) {
    if (json is num) {
      return json;
    } else if (json is String) {
      return num.tryParse(json) ?? 0; // Default to 0 if parsing fails
    }
    return 0; // Default to 0 for other unexpected types, or throw an error if you want strictness
  }

  @override
  dynamic toJson(num object) {
    return object;
  }
}

class DoubleConverter implements JsonConverter<double, dynamic> {
  const DoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json is num) {
      return json.toDouble();
    } else if (json is String) {
      return double.tryParse(json) ?? 0.0;
    }
    return 0.0;
  }

  @override
  dynamic toJson(double object) {
    return object;
  }
}

class IntConverter implements JsonConverter<int, dynamic> {
  const IntConverter();

  @override
  int fromJson(dynamic json) {
    if (json is int) {
      return json;
    } else if (json is String) {
      return int.tryParse(json) ?? 0;
    } else if (json is double) {
      return json.toInt();
    }
    return 0;
  }

  @override
  dynamic toJson(int object) {
    return object;
  }
}