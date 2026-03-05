/// Modelo que representa o estado atual da autoclave
class AutoclaveStatus {
  final double temperature;
  final double pressure;
  final String cycle;
  final String status;
  final DateTime lastUpdate;

  const AutoclaveStatus({
    required this.temperature,
    required this.pressure,
    required this.cycle,
    required this.status,
    required this.lastUpdate,
  });

  /// Estado inicial (quando app abre)
  factory AutoclaveStatus.initial() {
    return AutoclaveStatus(
      temperature: 0,
      pressure: 0,
      cycle: '--',
      status: 'Desconectado',
      lastUpdate: DateTime.now(),
    );
  }

  /// Mock para testes visuais
  factory AutoclaveStatus.mock() {
    return AutoclaveStatus(
      temperature: 134.5,
      pressure: 2.2,
      cycle: 'Classe B',
      status: 'Esterilizando',
      lastUpdate: DateTime.now(),
    );
  }

  /// Permite criar uma nova versão alterando só alguns campos
  AutoclaveStatus copyWith({
    double? temperature,
    double? pressure,
    String? cycle,
    String? status,
  }) {
    return AutoclaveStatus(
      temperature: temperature ?? this.temperature,
      pressure: pressure ?? this.pressure,
      cycle: cycle ?? this.cycle,
      status: status ?? this.status,
      lastUpdate: DateTime.now(),
    );
  }
}
