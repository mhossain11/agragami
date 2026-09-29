import 'dart:io';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'thermal_printer_service.dart';

/// [ThermalPrinterService] backed by the `print_bluetooth_thermal` plugin.
///
/// Only imported on platforms with `dart:io` (Android / iOS / macOS /
/// Windows) so the plugin's `dart:io` import never breaks Flutter Web.
class BluetoothThermalPrinterService implements ThermalPrinterService {
  @override
  Future<bool> isSupported() async =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isWindows;

  @override
  Future<bool> ensurePermission() async {
    if (!Platform.isAndroid) return true;
    try {
      // On Android 12+ this opens the BLUETOOTH_SCAN + BLUETOOTH_CONNECT
      // permission dialog and returns whether it was granted. On older
      // Android versions no runtime permission is needed and it returns true.
      return await PrintBluetoothThermal.isPermissionBluetoothGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<PrinterDeviceInfo>> getPairedPrinters() async {
    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices
          .map(
            (device) => PrinterDeviceInfo(
              name: device.name,
              address: device.macAdress,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> connect(String address) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: address);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      return await PrintBluetoothThermal.disconnect;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> printBytes(List<int> bytes) async {
    try {
      // Some printers drop the first bytes written right after a fresh
      // Bluetooth connection - the ticket would then start mid-way and the
      // header (organisation name) would be missing on the paper. Send two
      // harmless blank lines first and give the link a moment to settle,
      // then send the real ticket.
      await PrintBluetoothThermal.writeBytes(const [0x0A, 0x0A]);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (_) {
      return false;
    }
  }
}

ThermalPrinterService createThermalPrinterService() =>
    BluetoothThermalPrinterService();
