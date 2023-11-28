import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';

class PaypalService {
  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;
  // log queue
  static List<String> logQueue = [];

  Function callback = () => {};

  String getTransactions() {
    String transactions = "";
    for (var i = 0; i < logQueue.length; i++) {
      transactions += "${logQueue[i]}\n";
    }
    return transactions;
  }

  void makePayment(double price, callback) async {
    await initPayPal();
    this.callback = callback;

    //add 1 item to cart. Max is 4!
    if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
      _flutterPaypalNativePlugin.removeAllPurchaseItems();
      _flutterPaypalNativePlugin.addPurchaseUnit(
        FPayPalPurchaseUnit(
            amount: price,
            currencyCode: FPayPalCurrencyCode.eur,
            referenceId: '2'),
      );
    }

    _flutterPaypalNativePlugin.makeOrder(
      action: FPayPalUserAction.payNow,
    );
  }

  Future<void> initPayPal() async {
    //set debugMode for error logging
    FlutterPaypalNative.isDebugMode = false;

    //initiate payPal plugin
    await _flutterPaypalNativePlugin.init(
      //your app id !!! No Underscore!!! see readme.md for help
      returnUrl: "com.payment.paysnap://paypalpay",
      //client id from developer dashboard
      clientID:
          "AWU5P1hIhIrLzXwI3hIeT4OO52gCls-GH483l-tnPNPNw1hZR9oA4UhUJNlWZhX-juCrddTi8nlewzaO",
      //clientID:
      //    "AWb9Y3UG5d30Td2TGeUB4nXXOrrLanKANm1ESqf9uzvvXKbfGn6APCLi-mANRDWbD3FQqEpAMDPfR0hI",
      //sandbox, staging, live etc
      payPalEnvironment: FPayPalEnvironment.sandbox,
      //payPalEnvironment: FPayPalEnvironment.live,
      //what currency do you plan to use?
      currencyCode: FPayPalCurrencyCode.eur,
      //action pay now?
      action: FPayPalUserAction.payNow,
    );

    //call backs for payment
    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          logResult("cancel");
        },
        onSuccess: (data) {
          //successfully paid
          //remove all items from queue
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          String visitor = data.cart?.shippingAddress?.firstName ?? 'Visitor';
          String address =
              data.cart?.shippingAddress?.line1 ?? 'Unknown Address';
          logResult(
            "Order successful ${data.payerId ?? ""} - ${data.orderId ?? ""} - $visitor -$address",
          );
        },
        onError: (data) {
          //an error occurred
          logResult("error: ${data.reason}");
        },
        onShippingChange: (data) {
          //the user updated the shipping address
          logResult(
            "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}",
          );
        },
      ),
    );
  }

  // all to log queue
  logResult(String text) {
    logQueue.add(text);
    callback(text);
  }
}
