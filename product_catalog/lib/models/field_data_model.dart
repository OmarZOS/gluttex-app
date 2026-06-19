import 'package:flutter/material.dart';

// models/field_data_model.dart
enum DataSource {
  userInput,
  aiGenerated,
  databaseFetched,
  manualEntry,
}

class FieldData {
  final dynamic value;
  final DataSource source;
  final double confidence;
  final bool isEdited;
  final DateTime lastUpdated;
  final String? operationId;

  const FieldData({
    required this.value,
    required this.source,
    this.confidence = 1.0,
    this.isEdited = false,
    required this.lastUpdated,
    this.operationId,
  });

  FieldData copyWith({
    dynamic value,
    DataSource? source,
    double? confidence,
    bool? isEdited,
    DateTime? lastUpdated,
    String? operationId,
  }) {
    return FieldData(
      value: value ?? this.value,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      isEdited: isEdited ?? this.isEdited,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      operationId: operationId ?? this.operationId,
    );
  }

  String get sourceBadge {
    switch (source) {
      case DataSource.aiGenerated:
        return '🤖 AI';
      case DataSource.databaseFetched:
        return '📊 DB';
      case DataSource.manualEntry:
        return '✏️ Manual';
      case DataSource.userInput:
        return '👤 User';
    }
  }

  Color get sourceColor {
    switch (source) {
      case DataSource.aiGenerated:
        return Colors.purple;
      case DataSource.databaseFetched:
        return Colors.blue;
      case DataSource.manualEntry:
        return Colors.orange;
      case DataSource.userInput:
        return Colors.green;
    }
  }
}
