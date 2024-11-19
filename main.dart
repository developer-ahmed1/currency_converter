import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}


class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? selectedCurrency = 'USD';
  double? convertedAmount;
  Map<String, double> exchangeRates = {};

  // Fetch exchange rates from the API
  Future<void> fetchExchangeRates() async {
    final apiUrl = 'https://v6.exchangerate-api.com/v6/f142bc1e30c238d335bfd577/latest/PKR';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRates = Map<String, double>.from(data['conversion_rates']);
        });
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch exchange rates. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExchangeRates(); // Fetch rates on app startup
  }

  void convertCurrency() {
    final String amountText = _amountController.text;

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Input'),
          content: Text('Please enter a valid numeric amount in PKR.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final double amountInPKR = double.parse(amountText);

    if (exchangeRates.containsKey(selectedCurrency)) {
      setState(() {
        convertedAmount = amountInPKR * exchangeRates[selectedCurrency]!;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Currency rate not available.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void clearFields() {
    setState(() {
      _amountController.clear();
      convertedAmount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter amount in PKR',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedCurrency,
              onChanged: (value) {
                setState(() {
                  selectedCurrency = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Currency',
                border: OutlineInputBorder(),
              ),
              items: exchangeRates.keys.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Row(
                    children: [
                      Text(currency),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: convertCurrency,
                  child: Text('Convert'),
                ),
                ElevatedButton(
                  onPressed: clearFields,
                  child: Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (convertedAmount != null)
              Text(
                'Converted Amount: ${selectedCurrency!} ${convertedAmount!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}