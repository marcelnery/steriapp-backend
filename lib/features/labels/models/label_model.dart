class LabelModel {

  final int cycleNumber;
  final int globalNumber;
  final String lotNumber;
  final String model;
  final String serialNumber;
  final String program;
  final String publicUrl;
  final String responsible;
  final String operator;
  final String clinicName;
  final DateTime sterilizationDate;
  final DateTime validityDate;

  LabelModel({
    required this.cycleNumber,
    required this.globalNumber,
    required this.lotNumber,
    required this.model,
    required this.serialNumber,
    required this.program,
    required this.publicUrl,
    required this.responsible,
    required this.operator,
    required this.clinicName,
    required this.sterilizationDate,
    required this.validityDate,
  });
}