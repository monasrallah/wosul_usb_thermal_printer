import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:usb_serial/usb_serial.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'receipt_data.dart';

class ThermalPrinterService {
  Future<void> printReceipt(ReceiptData receipt, bool addLogo, int logoSize) async {
    try {
      final devices = await UsbSerial.listDevices();

      final thermalPrinter = devices.firstWhere(
        (device) => (device.manufacturerName?.contains('POSIFLEX') ?? false) || (device.productName?.startsWith('PP') ?? false) || (device.productName?.contains('Thermal') ?? false),
        orElse: () => throw Exception('No compatible thermal printer found'),
      );

      final port = await thermalPrinter.create();
      if (port == null) {
        throw Exception('Failed to create port');
      }

      if (!await port.open()) {
        throw Exception('Failed to open port');
      }

      await port.setDTR(true);
      await port.setRTS(true);

      port.setPortParameters(
        9600,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile); // Use mm80 for 80mm paper width

      List<int> bytes = [];

      if (addLogo) {
        bytes += generator.text('\n', styles: const PosStyles(align: PosAlign.center));
        bytes += await _getLogoBytes(generator, logoSize);
        bytes += generator.text('\n', styles: const PosStyles(align: PosAlign.center));
      }

      await Future.delayed(const Duration(milliseconds: 200));

      bytes += generator.text(receipt.restaurantName, styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text(receipt.dateTime, styles: const PosStyles(align: PosAlign.left));

      bytes += generator.text('----------------------------------------', styles: const PosStyles(align: PosAlign.center));

      bytes += generator.row([
        PosColumn(text: 'Qty', width: 2),
        PosColumn(text: 'Item', width: 6),
        PosColumn(text: 'Price', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);

      for (var item in receipt.items) {
        bytes += generator.row([
          PosColumn(text: item.quantity.toString(), width: 2),
          PosColumn(text: item.name, width: 6),
          PosColumn(text: item.price.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }

      bytes += generator.text('----------------------------------------', styles: const PosStyles(align: PosAlign.center));

      bytes += generator.row([
        PosColumn(text: 'TOTAL', width: 8, styles: const PosStyles(width: PosTextSize.size2)),
        PosColumn(text: receipt.total.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      ]);

      bytes += generator.qrcode(receipt.qrData, size: QRSize.Size8);

      bytes += generator.cut();

      await Future.delayed(const Duration(milliseconds: 200));

      await port.write(Uint8List.fromList(bytes));
      await port.close();
    } catch (e) {
      throw Exception('Failed to print receipt: $e');
    }
  }

  Future<List<int>> _getLogoBytes(Generator generator, int width) async {
    try {
      final ByteData data = await rootBundle.load('assets/images/png_logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        final resizedImage = img.copyResize(image, width: width, height: width);
        return generator.image(resizedImage);
      } else {
        throw Exception('Failed to load logo image');
      }
    } catch (e) {
      throw Exception('Error processing logo: $e');
    }
  }
}
