// // discover_usb.dart

// import 'package:usb_serial/usb_serial.dart';

// class UsbDiscovery {
//   static Future<List<UsbDevice>> discoverUsbDevices() async {
//     return await UsbSerial.listDevices();
//   }

//   static UsbDevice? findCompatiblePrinter(List<UsbDevice> devices) {
//     try {
//       return devices.firstWhere(
//         (device) => (device.manufacturerName?.contains('POSIFLEX') ?? false) || (device.productName?.startsWith('PP') ?? false) || (device.productName?.contains('Thermal') ?? false),
//       );
//     } catch (e) {
//       return null;
//     }
//   }
// }
