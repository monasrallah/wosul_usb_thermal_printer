import 'package:flutter/material.dart';
import 'thermal_printer_service.dart';
import 'receipt_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _addLogo = false;
  final TextEditingController _logoSizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showConfigDialog(context),
          child: const Text('Config'),
        ),
      ),
    );
  }

  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool addLogo = _addLogo;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Configuration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Do you want to add logo?'),
                    value: addLogo,
                    onChanged: (bool? value) {
                      setState(() {
                        addLogo = value ?? false;
                      });
                    },
                  ),
                  if (addLogo)
                    TextField(
                      controller: _logoSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Enter logo width',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Print'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _printReceipt(context, addLogo);
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _printReceipt(BuildContext context, bool addLogo) async {
    try {
      final printerService = ThermalPrinterService();
      final receipt = ReceiptData.generateSampleReceipt();
      final logoSize = int.tryParse(_logoSizeController.text) ?? 150;
      await printerService.printReceipt(receipt, addLogo, logoSize);
      _showAlert(context, 'Success', 'Receipt printed successfully');
    } catch (e) {
      _showAlert(context, 'Error', 'Failed to print: $e');
      print('Error printing receipt: $e');
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
