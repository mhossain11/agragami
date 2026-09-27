/// Package-agnostic description of a paired Bluetooth printer.
class PrinterDeviceInfo {
  const PrinterDeviceInfo({required this.name, required this.address});

  final String name;

  /// Bluetooth MAC address (as used by the platform printer plugin).
  final String address;
}

/// Isolation layer between the app and the Bluetooth thermal printer plugin.
///
/// The controller and [ReceiptPrintService] only ever see this interface, so
/// the concrete plugin (`print_bluetooth_thermal`) never leaks into the UI.
abstract class ThermalPrinterService {
  /// Whether Bluetooth printing is possible on this platform.
  /// Always `false` on Flutter Web.
  Future<bool> isSupported();

  /// Requests the runtime Bluetooth permission (Android 12+ shows the
  /// BLUETOOTH_SCAN / BLUETOOTH_CONNECT dialog). Returns `true` when allowed.
  Future<bool> ensurePermission();

  /// `true` when the device Bluetooth radio is switched on.
  Future<bool> isBluetoothEnabled();

  /// Printers already paired in the system Bluetooth settings.
  Future<List<PrinterDeviceInfo>> getPairedPrinters();

  /// Current connection state of the printer.
  Future<bool> isConnected();

  /// Connects to the printer at [address].
  Future<bool> connect(String address);

  /// Closes the current printer connection.
  Future<bool> disconnect();

  /// Sends raw ESC/POS [bytes] to the connected printer.
  Future<bool> printBytes(List<int> bytes);
}
