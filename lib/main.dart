import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
  'pk_test_51PaMBcIjLHsJjWOvtX31evcr32zf0SXoWHjdtD7gPfY3wb2oM6czboRDxRqQBkQfPDpLoJxiSOzjlrjlVKMaJbdA00Xjbi1j0A';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Payment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Stripe payment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController amountController =  TextEditingController();
  Map<String, dynamic>? stripeIntentResponse;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
            padding:  const EdgeInsets.only(left: 20, right: 20),
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                labelText: 'Amount',
              )),
          ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  makePayment ( amount: amountController.text);
                },
                child: const Text('Pay'))
          ],
        ),
      ),
    );
  }

   createPaymentIntent({amount, currency} )async{
    try{
      Map<String, dynamic> body = {
        "amount": amount,
        "currency": currency
      };
      http.Response? response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization": "Bearer sk_test_51PaMBcIjLHsJjWOvOi1u4tEDJx1IRqf7N7fVLn6nrhtzfbYIHdeOK5BtdUrwR22uf37z7qeo4wBpnkZVr3e1ASd600RrPFRJlm",
          "Content-Type": "application/x-www-form-urlencoded"
        }
      );
      return json.decode(response.body);


    }catch(e){
      throw Exception(e.toString());
    }

  }

  Future<void> makePayment ({amount}) async{
    int amountInPenny = (int.parse(amount) * 100).toInt();
    try{
      final paymentIntent = await createPaymentIntent(amount: amountInPenny.toString(), currency: "gbp");

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent["client_secret"],
            style: ThemeMode.light,
            merchantDisplayName: "Stripe Payment",
              billingDetails: const BillingDetails(),
          )
      );
      await Stripe.instance.presentPaymentSheet();
      stripeIntentResponse = paymentIntent;
    }catch(e){
      rethrow;
    }





  }












}
