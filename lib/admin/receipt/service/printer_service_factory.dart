import 'thermal_printer_service.dart';
import 'thermal_printer_service_stub.dart'
    if (dart.library.io) 'thermal_printer_service_io.dart' as platform;

/// Creates the platform-appropriate [ThermalPrinterService].
///
/// On platforms with `dart:io` this returns the Bluetooth implementation;
/// on Flutter Web it returns an unsupported stub so the mobile-only
/// Bluetooth plugin is never even imported (no web compile errors).
ThermalPrinterService createThermalPrinterService() =>
    platform.createThermalPrinterService();
