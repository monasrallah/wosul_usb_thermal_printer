# USB Thermal Printer Demo

This Flutter application demonstrates how to use a USB thermal printer to print receipts. It's designed to work with POSIFLEX or other compatible thermal printers.

## Features

- Simple user interface with a "Print Receipt" button
- Generates a sample receipt with dynamic data
- Prints receipts including:
  - Restaurant logo
  - Restaurant name
  - Date and time
  - Itemized list of purchases
  - Total amount
  - QR code for digital receipt

## Dependencies

This project relies on the following packages:

- `flutter/material.dart`: For building the UI
- `usb_serial`: To communicate with USB devices
- `esc_pos_utils`: For generating ESC/POS commands
- `image`: For image processing

## Setup

1. Ensure you have Flutter installed on your development machine.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Connect a compatible USB thermal printer to your device.
5. Run the app on a device that supports USB OTG (On-The-Go).

## Usage

1. Launch the app on your device.
2. Ensure the thermal printer is connected.
3. Tap the "Print Receipt" button.
4. The app will attempt to print a sample receipt.
5. A success or error message will be displayed based on the printing result.

## Project Structure

- `main.dart`: Entry point of the application
- `home_screen.dart`: Contains the main UI of the app
- `thermal_printer_service.dart`: Handles communication with the printer and generates print commands
- `receipt_data.dart`: Defines the structure for receipt data and generates sample data

## Customization

- To change the receipt layout or content, modify the `printReceipt` method in `thermal_printer_service.dart`.
- To adjust the sample receipt data, update the `generateSampleReceipt` method in `receipt_data.dart`.
- The app logo can be changed by replacing the `logo.png` file in the `assets/images/` directory.

## Notes

- This app is designed for demonstration purposes and may require additional error handling and testing for production use.
- Ensure you have the necessary permissions to access USB devices on your target platform.
- The printer detection is based on manufacturer and product names. You may need to adjust these if using a different printer model.

## Contributing

Contributions to improve the app or extend its functionality are welcome. Please feel free to submit pull requests or open issues for any bugs or feature requests.

## License

[Specify your license here, e.g., MIT License]
