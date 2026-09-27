import 'thermal_printer_service.dart';

/// Fallback used where `dart:io` is unavailable (e.g. Flutter Web).
///
/// Every call reports "not available" so the UI can hide the printer
/// section gracefully instead of crashing.
class UnsupportedThermalPrinterService implements ThermalPrinterService {
  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> ensurePermission() async => false;

  @override
  Future<bool> isBluetoothEnabled() async => false;

  @override
  Future<List<PrinterDeviceInfo>> getPairedPrinters() async => const [];

  @override
  Future<bool> isConnected() async => false;

  @override
  Future<bool> connect(String address) async => false;

  @override
  Future<bool> disconnect() async => false;

  @override
  Future<bool> printBytes(List<int> bytes) async => false;
}

ThermalPrinterService createThermalPrinterService() =>
    UnsupportedThermalPrinterService();
