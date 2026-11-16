
class Measurement {
  final double value;
  final DateTime timestamp;
  final MeasurementType measurementType;

  const Measurement({
    required this.value,
    required this.timestamp,
    required this.measurementType,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      value: (json['valeur'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['date_prise']),
      measurementType: MeasurementType.temperature, // Assuming a default value for typeMeasurement, adjust as needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valeur': value,
      'date_prise': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Measurement(value: $value, timestamp: $timestamp)';
  }
}

class MeasurementType {
  final String name;

  const MeasurementType._(this.name);

  static const temperature = MeasurementType._('Temperature');
  static const humidity = MeasurementType._('Humidity');
  static const pressure = MeasurementType._('Pressure');

  @override
  String toString() => name;
}