import 'package:flutter/material.dart';
import 'package:servigo/main.dart';
import 'package:servigo/pages/dashboard.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'fakebanktable.dart';

class PaymentScreen extends StatefulWidget {
  var price;
  PaymentScreen({this.price});
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expirationDateController;
  late TextEditingController _securityCodeController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expirationDateController = TextEditingController();
    _securityCodeController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expirationDateController.dispose();
    _securityCodeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    final cardNumber = _cardNumberController.text;
    final expirationDate = _expirationDateController.text;
    final securityCode = _securityCodeController.text;
    final amount = double.tryParse(widget.price) ?? 0.0;
    final account = fakeBankTable[cardNumber];
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid card number.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (account['balance'] < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    fakeBankTable[cardNumber]['balance'] -= amount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment processed successfully ${widget.price}.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return dashBoard();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(''),
        title: Text('Payment'),
        backgroundColor: maincolor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                cursorColor: maincolor,
                controller: _cardNumberController,
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: maincolor, width: 2)),
                    labelText: 'Card Number',
                    labelStyle: psmallts),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Card number is required.';
                  } else if (value.length != 16) {
                    return 'Card number must be 16 digits.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextFormField(
              //         cursorColor: maincolor,
              //         controller: _expirationDateController,
              //         decoration: InputDecoration(
              //             focusedBorder: UnderlineInputBorder(
              //                 borderSide:
              //                     BorderSide(color: maincolor, width: 2)),
              //             labelText: 'Expiration Date (MM/YY)',
              //             labelStyle: psmallts),
              //         keyboardType: TextInputType.number,
              //         validator: (value) {
              //           if (value!.isEmpty) {
              //             return 'Expiration date is required.';
              //           } else if (value.length != 5) {
              //             return 'Expiration date must be in format MM/YY.';
              //           }
              //           return null;
              //         },
              //       ),
              //     ),
              //     SizedBox(width: 16.0),
              //     Expanded(
              //       child: TextFormField(
              //         cursorColor: maincolor,
              //         controller: _securityCodeController,
              //         decoration: InputDecoration(
              //             focusedBorder: UnderlineInputBorder(
              //                 borderSide:
              //                     BorderSide(color: maincolor, width: 2)),
              //             labelText: 'Security Code',
              //             labelStyle: psmallts),
              //         keyboardType: TextInputType.number,
              //         validator: (value) {
              //           if (value!.isEmpty) {
              //             return 'Security code is required.';
              //           } else if (value.length != 3) {
              //             return 'Security code must be 3 digits.';
              //           }
              //           return null;
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 16.0),
              TextFormField(
                cursorColor: maincolor,
                // controller: _amountController,
                initialValue: widget.price,
                decoration: InputDecoration(
                  
                  enabled: false,
                  
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: maincolor, width: 2)),
                    labelText: 'Amount',
                    labelStyle: psmallts),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Amount is required.';
                  } else if (double.tryParse(value) == null) {
                    return 'Amount must be a valid number.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: _submitPayment,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text('Pay Now'),
                ),
                style: ElevatedButton.styleFrom(
                  primary: maincolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(border_rad_size),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
