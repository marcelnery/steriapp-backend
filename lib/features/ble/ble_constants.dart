class BleConstants {
  BleConstants._(); // impede instancia

  // =========================
  // DEVICE
  // =========================
  static const String deviceName = 'SteriApp';

  // =========================
  // UUIDs
  // =========================
   static const String characteristicUUID =
      '12345678-90AB-CDEF-FEDC-BA0987654321';


   static const String  serviceUUID =
      '21436587-09BA-DCFE-EFCD-AB9078563412';
  // =========================
  // BLE CONFIG
  // =========================
  static const int mtu = 247;
  static const int scanTimeoutSeconds = 10;
}