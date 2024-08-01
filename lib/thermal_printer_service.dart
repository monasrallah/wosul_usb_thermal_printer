import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:usb_serial/usb_serial.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'receipt_data.dart';

class ThermalPrinterService {
  // Function to encode Arabic text
  Future<Uint8List> encodeArabicText(String text) async {
    List<int> bytes = await CharsetConverter.encode('windows-1256', text);
    return Uint8List.fromList(bytes);
  }

  Future<void> printReceipt(
      ReceiptData receipt, bool addLogo, int logoSize) async {
    try {
      final devices = await UsbSerial.listDevices();

      final thermalPrinter = devices.firstWhere(
        (device) =>
            (device.manufacturerName?.contains('POSIFLEX') ?? false) ||
            (device.productName?.startsWith('PP') ?? false) ||
            (device.productName?.contains('Thermal') ?? false),
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
      final generator =
          Generator(PaperSize.mm80, profile); // Use mm80 for 80mm paper width

      List<int> bytes = [];
      generator.feed(3);

      bytes += generator.text("NearPay Merchant Arabic",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("NearPay Merchant",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("4321",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("KAFD",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));

      bytes += generator.row([
        PosColumn(
            text: '1/8/2024',
            width: 6,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: '15:40:00\t\t',
            width: 5,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right)),
      ]);

      bytes += generator.row([
        PosColumn(
            text: 'INMA',
            width: 2,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: '123456789012345',
            width: 3,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '1234567890123456',
            width: 6,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.left)),
      ]);

      bytes += generator.row([
        PosColumn(
            text: '0763',
            width: 2,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: '000073',
            width: 2,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '1.1.1',
            width: 2,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '123456789012',
            width: 5,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.row([
        PosColumn(
            text: 'Visa',
            width: 6,
            styles: const PosStyles(
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            textEncoded: await encodeArabicText('ڤيزا'),
            width: 5,
            styles: const PosStyles(codeTable: 'PC850',
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);
      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.row([
        PosColumn(
            text: 'PURCHASE',
            width: 5,
            styles: const PosStyles(
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            textEncoded: await encodeArabicText('شراء'),
            width: 6,
            styles: const PosStyles(codeTable: 'PC850',
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);
      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.row([
        PosColumn(
            text: '4563 82** **** 1329',
            width: 6,
            styles: const PosStyles(
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '31/03',
            width: 5,
            styles: const PosStyles(
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);
      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.row([
        PosColumn(
            textEncoded: await encodeArabicText('١٩.٠٠ ر.س'),
            width: 6,
            styles: const PosStyles(codeTable: 'PC850',
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            textEncoded: await encodeArabicText('مبلغ الشراء'),
            width: 5,
            styles: const PosStyles(codeTable: 'PC850',
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);
      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.row([
        PosColumn(
            text: 'PURCHASE AMOUNT',
            width: 5,
            styles: const PosStyles(
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: 'SAR 19.00',
            width: 6,
            styles: const PosStyles(
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);

      bytes += generator.textEncoded(await encodeArabicText("مقبولة"),
          styles: const PosStyles(codeTable: 'PC850',
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("APPROVED",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.textEncoded(
          await encodeArabicText("تم التحقق من هوية حامل الجهاز"),
          styles: const PosStyles(codeTable: 'PC850',
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("Device OWNER IDENTITY VERIFIED",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));

      bytes += generator.row([
        PosColumn(
            textEncoded: await encodeArabicText('٧٣٠٠٢٣'),
            width: 6,
            styles: const PosStyles(codeTable: 'PC850',
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            textEncoded: await encodeArabicText('رمز الموافقة'),
            width: 5,
            styles: const PosStyles(codeTable: 'PC850',
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);

      bytes += generator.row([
        PosColumn(
            text: 'Approval Code',
            width: 5,
            styles: const PosStyles(
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '730023',
            width: 6,
            styles: const PosStyles(
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);

      bytes += generator.row([
        PosColumn(
            text: '1/8/2024',
            width: 5,
            styles: const PosStyles(
                align: PosAlign.left, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '15:40:00',
            width: 6,
            styles: const PosStyles(
                align: PosAlign.right, bold: true, height: PosTextSize.size2)),
        PosColumn(
            text: '', width: 1, styles: const PosStyles(align: PosAlign.right))
      ]);
      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));

      bytes += generator.textEncoded(
          await encodeArabicText("شكرا لاستخدامكم مدى"),
          styles: const PosStyles(codeTable: 'PC850',
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("Thank You For Using Mada",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.textEncoded(
          await encodeArabicText("يرجى الاحتفاظ بالفاتورة"),
          styles: const PosStyles(codeTable: 'PC850',
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("Please retain the receipt",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));

      bytes += generator.textEncoded(
          await encodeArabicText("*** نسخة العميل ***"),
          styles: const PosStyles(codeTable: 'PC850',
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("*** Customer Copy ***",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.text("CONTACTLESS 000 A000031999",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.text("0000 87777 9999 00 6",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.text("V00100197678546347543656",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size1));
      bytes += generator.cut();

      if (addLogo) {
        bytes += generator.text('\n',
            styles: const PosStyles(align: PosAlign.center));
        bytes += await _getLogoBytes(generator, logoSize);
        bytes += generator.text('\n',
            styles: const PosStyles(align: PosAlign.center));
      }

      await Future.delayed(const Duration(milliseconds: 200));

      bytes += generator.text("Main Bransh",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));

      bytes += generator.text('\n\n',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text("Tel : 05555555",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("Address",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("Welcome ",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("Simplified Tax Invoice ",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));
      bytes += generator.text("Printed At:",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));

      bytes += generator.text('----------------------------------------',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text("400",
          styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size7,
              width: PosTextSize.size7));
      bytes += generator.text('----------------------------------------',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.row([
        PosColumn(text: 'Qty', width: 3),
        PosColumn(text: 'Item', width: 3),
        PosColumn(
          text: 'Price',
          width: 3,
        ),
        PosColumn(text: 'Amount', width: 3),
      ]);
      bytes += generator.text('----------------------------------------',
          styles: const PosStyles(align: PosAlign.center));

      for (var item in receipt.items) {
        bytes += generator.row([
          PosColumn(text: item.quantity.toString(), width: 3),
          PosColumn(text: item.name, width: 3),
          PosColumn(text: item.price.toStringAsFixed(2), width: 3),
          PosColumn(
            text: item.price.toStringAsFixed(2),
            width: 3,
          ),
        ]);
      }

      bytes += generator.text('----------------------------------------',
          styles: const PosStyles(align: PosAlign.center));

      bytes += generator.row([
        PosColumn(
            text: 'Sub Total',
            width: 5,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: '18.00',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
          text: "",
          width: 1,
        ),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Discount',
            width: 5,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: '0.00',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
          text: "",
          width: 1,
        ),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Tax',
            width: 5,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: '10.20',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
          text: "",
          width: 1,
        ),
      ]);

      bytes += generator.row([
        PosColumn(
            text: 'Grand Total',
            width: 5,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: '78.20',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
          text: "",
          width: 1,
        ),
      ]);

      bytes += generator.text("\n",
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2));

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
