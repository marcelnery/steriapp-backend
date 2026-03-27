// MODELO DE AUTOCLAVES

class AutoclaveModel {

  final String brand;
  final String model;
  final String serial;

  AutoclaveModel({
    required this.brand,
    required this.model,
    required this.serial,
  });

  factory AutoclaveModel.fromJson(Map<String,dynamic> json){

    return AutoclaveModel(
      brand: json["brand"] ?? "",
      model: json["model"] ?? "",
      serial: json["serial"] ?? "",
    );

  }

  Map<String,dynamic> toJson(){

    return {
      "brand": brand,
      "model": model,
      "serial": serial,
    };

  }

}