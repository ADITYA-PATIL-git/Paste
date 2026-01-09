import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:penthousemumbai/sideMenuWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adminHome.dart';
import 'login.dart';
import 'uploadParse.dart';

String Uploadinvoiceamt = "";
bool getamtiscalled = false;
bool isoutletchangenotclicked = true;
var invoiceRedeemableForRedeem = "1";
bool isLoaderVisibleamt = true;
bool firstinvoiceScan = true;
var listitemCs = [];
var listitemCs1 = [];
bool isbottomcardVisible = false;
var cardColour = Color(0xff282828);
var _bgColour = Color(0xff1a1a1a);
String _mySelection = "c9868ddd-c41f-412a-87ad-a529d98nk17x";
String _selected = 'Select Outlet Namee';
String outletIdFromLogin = "c9868ddd-c41f-412a-87ad-a529d98nk17x";
String outletNameFromLogin = 'Select Outlet Namee';
String invoicebillnotext = "";
List outletList = [];
bool isManualcardLoading = false;
var isVerifyLoading = true;
//temp variables for earnpage
String txnDate = "05-05-2023 03:47:03";
String txnInvoiceNo = "";
String txnId = "";
String txnRedeemedPoints = "";
String txnAvailableReward = "";
String txnInvoiceAmount = "";
String txnSavedAmount = "";
// int txnAmountToBePaid = 0;
String guestMobileNumber = "";
bool isDisabledSave = true;
String _otpValue = '';
String Etagredeem = "";
String filename2redeem = "";
const String otpmobileno = '';
List<String> list = <String>['Cheque', 'Others'];

ValueNotifier<int> availableReward = ValueNotifier(0);
// ValueNotifier<String> iEarnReward = ValueNotifier("0");
FocusNode myFocusNode = FocusNode();
FocusNode myFocusNode2 = FocusNode();
final TextEditingController invNoController = TextEditingController();
final TextEditingController amountController = TextEditingController();
final TextEditingController redeemController = TextEditingController();
final TextEditingController cardno = TextEditingController();
String dateText = "";
String custnamenew = "N";
var firstcall = 1;
String img64 = "";
late String SID;
// late int availableReward = 0;
String custname = "";
bool ervisibility = true;
bool ervisibility2 = true;
int iEarnReward = 0;
String statusmsg = "";
bool _isVisible = false; //it always must be set to  false but while testing
bool isVisible2 = false; //it always must be set to  false but while testing
bool ranonce = false;
String nSavedAmount = "";
String smembershipType = "";
bool finalSaveVisible = false;
// String LoginMobileNumber = "";

class earnRedeemPoints extends StatefulWidget {
  const earnRedeemPoints({super.key});

  @override
  State<earnRedeemPoints> createState() => _earnRedeemPointsState();
}

getoutletfromloginpage() async {
  final prefs = await SharedPreferences.getInstance();
  print("lognadeem${prefs.getString('OutletSelectedOnLogin')}");
  print("lognadeem${prefs.getString('OutletSelectedIDOnLogin')}");
  outletIdFromLogin = prefs.getString('OutletSelectedIDOnLogin').toString();
  outletNameFromLogin = prefs.getString('OutletSelectedOnLogin').toString();
  _mySelection = prefs.getString('OutletSelectedIDOnLogin').toString();
  _selected = prefs.getString('OutletSelectedOnLogin').toString();
}

_save(String code) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'sidearn';
  final String value1 = code;
  SID = value1;
  prefs.setString(key, value1);
}

class qrCodeRedeem extends StatefulWidget {
  const qrCodeRedeem({super.key});

  @override
  State<qrCodeRedeem> createState() => _qrCodeRedeemState();
}

class _qrCodeRedeemState extends State<qrCodeRedeem> {
  bool _isProcessing = false;
  String code = "";
  _getAvbRewards(context) async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'sidearn';
    final value1 = prefs.getString(key) ?? "";
    // LoginMobileNumber = prefs.getString("LoginMobileNumber")!;
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/AvailableRewards";
    Map<String, String> param = {
      "sOperationType": "AvailableRewards",
      "sId": SID,
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );

    var resp = convert.jsonDecode(response.body);
    if (response.statusCode == 200) {
      availableReward.value = resp['data']['iAvailableReward'];
      custname = resp['data']['sName'];
      smembershipType = resp['data']['sMembershipType'];
      guestMobileNumber = resp['data']['sMobile'];

      // Navigator.pop(context);
    } else {
      print("caution dologin2notworkinh");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: sideMenuWidget(),
      // appBar: AppBar(
      //     backgroundColor: Color(0000000000),
      //     elevation: 0,
      //     title: const Text('QR Code Scan')),
      body: Container(
        decoration: BoxDecoration(color: _bgColour),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.fromLTRB(0, 100, 0, 10),
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Scan Card",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Scan QR to Add Details",
              style: TextStyle(fontSize: 16, color: Color(0xff848484)),
            ),
            SizedBox(height: 84),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: MobileScanner(
                    onDetect: (BarcodeCapture capture) async {
                      if (_isProcessing) return;
                      _isProcessing = true;

                      for (final barcode in capture.barcodes) {
                        final String? rawValue = barcode.rawValue;

                        if (rawValue == null) {
                          debugPrint('Failed to scan Barcode');
                          continue;
                        }

                        if (rawValue.contains("Membership@PPqRSiiD")) {
                          final parts = rawValue.split(':');
                          final String code = parts.length > 1
                              ? parts[1].trim()
                              : '';

                          debugPrint('Barcode found! $code');

                          _save(code);
                          await _getAvbRewards(context);

                          if (mounted) {
                            Navigator.pop(context);
                          }

                          debugPrint('Barcode found2! $code');
                          break; // stop after first valid scan
                        }
                      }

                      // Throttle next scan
                      await Future.delayed(const Duration(seconds: 2));
                      _isProcessing = false;
                    },
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // setState(() {
                //   // isVisible = false;
                //   isVisible2 = false;
                // });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const earnRedeemPoints(),
                  ),
                );
                setvisiEarnRedeem();
              },
              child: Text(
                "Go Back",
                style: TextStyle(color: Color(0xff848484)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

setvisiEarnRedeem() {
  _isVisible = false; //it always must be set to  false but while testing
  isVisible2 = false;
  isbottomcardVisible = false;
  isoutletchangenotclicked = true;
  img64 = "";
  ranonce = false;
  redeemController.text = "0";
  nSavedAmount = "";
  amountController.text = "0";
  dateText = "";
  isDisabledSave = true;
  finalSaveVisible = false;
}

class paymentTypeDetails {
  // String? avatar;
  String? parametername;
  String? paymentsid;

  paymentTypeDetails({
    //  this.avatar,
    this.parametername,
    this.paymentsid,
  });

  paymentTypeDetails.fromJson(Map<String, dynamic> json) {
    // avatar = json['avatar'];
    parametername = json['sParametername'];
    paymentsid = json['sId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['sParametername'] = parametername;
    data['sId'] = paymentsid;

    return data;
  }
}

class _earnRedeemPointsState extends State<earnRedeemPoints> {
  late Future<Album> futureAlbum = futureAlbum;
  List data1 = [];
  @override
  void initState() {
    super.initState();
    Etagredeem = "";
    filename2redeem = "";
    getoutletfromloginpage();
    getPaymentType();
    getOutletType();
    isbottomcardVisible = false;
    invoicebillnotext = "";
    // _mySelection = "c9868ddd-c41f-412a-87ad-a529d98nk17x";
    isManualcardLoading = false;
    isDisabledSave = true;
    cardno.text = '';
    // getAvbRewards();
    futureAlbum = fetchAlbum(img64);
    myFocusNode = FocusNode();
  }

  Future askNA(BuildContext context) async {
    if (amountController.text == "0" || amountController.text == "N/A") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            "The amount was not detected, please capture/rescan the bill again or enter details manually.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      "Capture Image",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => {
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.pop(context);
                        pickImage2();
                      }),
                    },
                  ),
                  TextButton(
                    child: Text(
                      "Enter Manually",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => {
                      Navigator.pop(context),
                      myFocusNode.requestFocus(),
                      amountController.text = "0",
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  otplogin() async {
    // _read();
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/OtpGenerate";
    Map<String, String?> param = {
      "sOperationType": "GENOTP",
      "sIsGenerated": "1",
      "sMobile": guestMobileNumber.toString(),
      "sFromMobile": "1",
      "type": "redeem",
      "sIpAddress": "192.168.67.58",
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    print(param);
    var otpmobileno = PhoneNumber;
    print("$otpmobileno this is one");
    var resp = convert.jsonDecode(response.body);
    print(resp);

    if (resp['statusCode'] == 200 || resp['statusCode'] == "200") {
      //  print("generate otp");
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("otpmobileno", otpmobileno.toString());
      print(prefs.getString("otpmobileno"));
      // otpmobileno = controller.value?.nsn.toString();
      //OTP popup
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return OtpPopup();
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 8),
            title: Text(
              "Redeem points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "OTP not generated",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"),
                  ),
                ],
              ),
            ],
          );
        },
      );

      // Fluttertoast.showToast(
      //     msg: "Otp not send",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.BOTTOM_LEFT,
      //     timeInSecForIosWeb: 2,
      //     textColor: Colors.black,
      //     backgroundColor: Color.fromARGB(255, 231, 224, 224),
      //     fontSize: 16.0);
    }
  }

  getOutletType() async {
    outletList = [];
    listitemCs = [];
    listitemCs1 = [];
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/GetOutletType";
    Map<String, String> param = {"sOperationType": "GetOutletType"};

    Map<String, String> headers = {"Content-type": "application/json"};
    String body = convert.jsonEncode(param).toString();
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    dynamic resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      var parsedata = convert.jsonEncode(resp['data']);

      final List result = jsonDecode(parsedata);
      result.insert(0, {
        "sOutletId": "c9868ddd-c41f-412a-87ad-a529d98nk17x",
        "sOutLetName": "Select Outlet Name",
      });
      // result.add(
      //     "{ sOutletId: c9868ddd-c41f-412a-87ad-a529d98nk17x, sTransactionId: null, sRedeem: null, sOutLetName: please select outlet name}");
      print(result);
      setState(() {
        outletList = result;
        outletList.map((item) {
          listitemCs.add(item['sOutLetName'].toString());
          listitemCs1.add(item['sOutletId'].toString());

          return DropdownMenuItem(
            value: item['sOutletId'].toString(),
            child: new Text(item['sOutLetName'].toString()),
          );
        }).toList();
      });
      //  return TransactionDetails.fromJson(jsonDecode(response.body))..toList();
      //return result.map((data) => paymentTypeDetails.fromJson(data)).toList();
    }
  }

  getPaymentType() async {
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/GetPaymentType";
    Map<String, String> param = {"sOperationType": "GetPaymentType"};

    Map<String, String> headers = {"Content-type": "application/json"};
    String body = convert.jsonEncode(param).toString();
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    dynamic resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      var parsedata = convert.jsonEncode(resp['data']);

      final List result = jsonDecode(parsedata);

      setState(() {
        data1 = result;
      });
      //  return TransactionDetails.fromJson(jsonDecode(response.body))..toList();
      //return result.map((data) => paymentTypeDetails.fromJson(data)).toList();
    }
  }

  getEarnedpreviewRewards() async {
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/EarnRewardPreview";
    if (amountController.text == "N/A") {
      amountController.text = "0";
    }
    String inputDate = dateText;
    DateTime date = DateFormat('dd-MM-yyyy').parse(inputDate);
    String outputDate = DateFormat('MM-dd-yyyy').format(date);

    // else
    //   (ranonce = false);
    double damt = double.parse(amountController.text);
    int ddamt = damt.round();
    Map<String, String> param = {
      "sOperationType": "GetRewardEarnedWithoutSave",
      "sMemberShipType": smembershipType,
      "sInvoiceDate": outputDate,
      "iInvoiceAmount": ddamt.toString(),
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = convert.jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    var resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      iEarnReward = int.parse(resp['data']["iEarnReward"]);

      if (ddamt >= 2000 && iEarnReward == 0) {}

      setState(() {
        ervisibility = false;
      });
    }
  }

  getSavedpreviewRewards() async {
    final prefs = await SharedPreferences.getInstance();
    SID = prefs.getString('sidearn').toString();

    if (int.parse(availableReward.value.toString()) >=
        int.parse(redeemController.text)) {
      String baseUrl =
          "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/SavedPoints";
      double damt = double.parse(amountController.text);
      int ddamt = damt.round();
      String inputDate = dateText;
      DateTime date = DateFormat('dd-MM-yyyy').parse(inputDate);
      String outputDate = DateFormat('MM-dd-yyyy').format(date);

      Map<String, String> param = {
        "sOperationType": "GetSavedAmount",
        "sId": SID,
        "sMemberShipType": smembershipType,
        "iRedeemPoints": redeemController.text.toString(),
        "sInvoiceDate": outputDate,
      };

      Map<String, String> headers = {"Content-type": "application/json"};
      var body = convert.jsonEncode(param);
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );
      String redeemvaluetxt = redeemController.text.toString();
      var resp = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (resp['data']["sSavedAmount"] == "0") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(top: 8),
                title: Text(
                  "Redeem points",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                // subtitle: Text("subtitle"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      resp['data']["sResult"].toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Ok"),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
          // Fluttertoast.showToast(
          //     msg: resp['data']["sResult"].toString(),
          //     toastLength: Toast.LENGTH_LONG,
          //     gravity: ToastGravity.BOTTOM_LEFT,
          //     timeInSecForIosWeb: 2,
          //     textColor: Colors.black,
          //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
          //     fontSize: 16.0);
          redeemController.text = "0";
          nSavedAmount = "0";
        } else {
          String tempsa = resp['data']["sSavedAmount"];
          if (tempsa.contains('.')) {
            nSavedAmount = tempsa.substring(0, tempsa.indexOf('.'));
          } else {
            nSavedAmount = tempsa;
          }

          setState(() {
            ervisibility2 = false;
          });
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 8),
            title: Text(
              "Redeem points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Unable to Redeem! Insufficiant available Rewards.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"),
                  ),
                ],
              ),
            ],
          );
        },
      );
      // Fluttertoast.showToast(
      //     msg: "Unable To Redeem ! Insufficient Available Rewards.",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.BOTTOM_LEFT,
      //     timeInSecForIosWeb: 2,
      //     textColor: Colors.black,
      //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
      //     fontSize: 16.0);
      redeemController.text = "0";
      nSavedAmount = "0";
    }
  }

  getAvbRewards() async {
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/AvailableRewards";
    Map<String, String> param = {
      "sOperationType": "AvailableRewards",
      "sId": SID,
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );

    var resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      availableReward.value = resp['data']['iAvailableReward'];
      custname = resp['data']['sName'];
    } else {
      print("caution dologin2notworkinh");
    }
  }

  // api on enter card no mannually
  getAvbRewardscardno() async {
    final prefs = await SharedPreferences.getInstance();

    // LoginMobileNumber = prefs.getString("LoginMobileNumber")!;
    String cardNo = cardno.text.toString();
    String formattedCardNo = cardNo.replaceAllMapped(
      RegExp(
        r"(\d{3})(?=\d)",
      ), // matches every 4 digits that are followed by another digit
      (match) =>
          "${match.group(1)} ", // adds a space after the matched 4 digits
    );
    print(formattedCardNo);
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/AvailableRewards";
    Map<String, String> param = {
      "sOperationType": "AvailableRewards",
      //"sId": SID,
      "sCardNumber": cardNo,
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );

    var resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (resp['data'] != null) {
        isManualcardLoading = false;
        print("card number is valid");
        // availableReward.value = resp['data']['iAvailableReward'];
        // custname = resp['data']['sName'];
        availableReward.value = resp['data']['iAvailableReward'];
        custname = resp['data']['sName'];
        smembershipType = resp['data']['sMembershipType'];
        var sid = resp['data']['sId'];
        guestMobileNumber = resp['data']['sMobile'];
        //  _savecarddno(sid);
        final prefs = await SharedPreferences.getInstance();
        const key = 'sidearn';
        final String value1 = sid;
        SID = value1;
        prefs.setString(key, value1);
        custnamenew = "Y";

        showdata();
      } else {
        isManualcardLoading = false;
        print('invalid card');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.only(top: 8),
              title: Text(
                "Redeem points",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              // subtitle: Text("subtitle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Please enter a valid Membership number.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),

              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isManualcardLoading = false;
                        });

                        Navigator.of(context).pop();
                      },
                      child: Text("Ok"),
                    ),
                  ],
                ),
              ],
            );
          },
        );
        // Fluttertoast.showToast(
        //     msg: "Please enter a valid card number",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.BOTTOM_LEFT,
        //     timeInSecForIosWeb: 2,
        //     textColor: Colors.black,
        //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
        //     fontSize: 16.0);
      }
    } else {
      print("caution dologin2notworkinh");
    }
  }

  showdata() async {
    final prefs = await SharedPreferences.getInstance();
    SID = prefs.getString('sidearn').toString();
    print(SID);
    if (custnamenew == 'Y') {
      setState(() {
        isManualcardLoading = false;
        print("nkjdhkfjkf");
        finalSaveVisible = false;
        _isVisible = false;
        isVisible2 = true;
      });
      //
      // below should be uncommented to build qr scan module
    }
  }

  //   redeemRewards1() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     SID = prefs.getString('sidearn').toString();
  //     String SIDAdmin = prefs.getString('SID').toString();
  //     Uploadinvoiceamt = prefs.getString('uploadInvoiceAmt').toString();
  //     var filename = prefs.getString('uploadfilename'.toString());
  //     var Eatg = prefs.getString('uploadetag'.toString());
  //     var UserID = prefs.getString('GuestID'.toString());
  //     String inputDate = dateText;
  //     DateTime date = DateFormat('dd-MM-yyyy').parse(inputDate);
  //     String outputDate = DateFormat('dd-MMM-yyyy').format(date);
  //     print(outputDate);
  //     if (int.parse(availableReward.value.toString()) >=
  //         int.parse(redeemController.text)) {
  //       String BASE_URL =
  //           "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/InsertGuestRedeemHistory";
  //       double damt = double.parse(amountController.text);
  //       int ddamt = damt.round();
  //       Map<String, String> param = {
  //         "sOperationType": "InsertGuestRedeemHistory",
  //         "sId": SID, //from qr need from available rewards
  //         "sOutLetId": _mySelection, //dont know ,should get from invoice api
  //         "sMemberShipType":
  //             smembershipType, //not getting ,need from available rewards
  //         "iRedeemPoints": redeemController.text.toString(),
  //         "iRewardEarn": "0",
  //         "sInvoiceNo": invNoController.text.toString(),
  //         "sPaymentType":
  //             "00000000-0000-0000-0000-000000000000", //currently passing blank  //dont know from where to get or use
  //         "sMongoId": Eatg.toString(), //default
  //         "sInvoiceDate": outputDate.toString()
  //         "sUserId": UserID.toString(), //dont know from where to get or its use
  //         "iInvoiceAmount": Uploadinvoiceamt, //ddamt.toString(),
  //         "sFileName": filename.toString(),
  //         "iActualAmount": ddamt.toString(),
  //       };
  //       print(param);
  //       Map<String, String> headers = {"Content-type": "application/json"};
  //       var body = convert.jsonEncode(param);
  //       var response = await http.post(
  //         Uri.parse(BASE_URL),
  //         headers: headers,
  //         body: body,
  //       );
  //       var resp = convert.jsonDecode(response.body);
  //       print(resp);
  //       if (response.statusCode == 200) {
  //         if (resp["statusCode"] == 1 || resp["statusCode"] == "1") {
  //           isVerifyLoading = true;
  //           statusmsg = resp["statusMsg"];
  //           var redeemedPointsval = redeemController.text.toString();
  //           var earnPointsval2 = iEarnReward.toString();
  //           // sBase64 = resp['data']['sBase64'];
  //           // Fluttertoast.showToast(
  //           //     msg:
  //           //         "You have successfully redeemed $redeemedPointsval points on this transaction.",
  //           //     toastLength: Toast.LENGTH_LONG,
  //           //     gravity: ToastGravity.BOTTOM_LEFT,
  //           //     timeInSecForIosWeb: 2,
  //           //     textColor: Colors.black,
  //           //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
  //           //     fontSize: 16.0);
  //           // setState(() {
  //           //   ervisibility = false;
  //           //   Future.delayed(Duration(seconds: 3), () {
  //           //     getAvbRewards();
  //           //     setvisiEarnRedeem();
  //           //     isVisible2 = true;
  //           //     finalSaveVisible = true;
  //           //     Navigator.push(
  //           //       context,
  //           //       MaterialPageRoute(
  //           //           builder: (context) => const earnRedeemPoints()),
  //           //     );
  //           //     // (route) => true);
  //           //   });
  //           // });
  // //
  //           setState(
  //             () {
  //               ervisibility = false;
  //               String inputDateStr = "05-05-2023 04:15:30";
  //               DateTime inputDate =
  //                   DateFormat("MM/dd/yyyy hh:mm:ss a").parse(inputDateStr);
  //               String outputDateStr = DateFormat("dd/MM/yyyy").format(inputDate);
  //               String outputDateStr2 =
  //                   DateFormat("dd MMM yyyy").format(inputDate);
  //               print(outputDateStr2);
  //               Future.delayed(Duration(seconds: 4), () {
  //                 txnSavedAmount = nSavedAmount.toString();
  //                 print(txnSavedAmount + "this is your txnSavedAmount");
  //                 int txnAmountToBePaid =
  //                     int.parse(amountController.text.toString()) -
  //                         int.parse(nSavedAmount.toString());
  //                 showDialog(
  //                   barrierColor: Colors.black,
  //                   context: context,
  //                   builder: (context) {
  //                     return Dialog(
  //                       backgroundColor: Color.fromARGB(0, 0, 0, 0),
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(40)),
  //                       elevation: 16,
  //                       child: Container(
  //                         decoration: const BoxDecoration(
  //                           image: DecorationImage(
  //                               image: AssetImage(
  //                                 'images/invoice-bg-01.png',
  //                               ),
  //                               fit: BoxFit.fill),
  //                         ),
  //                         height: MediaQuery.of(context).size.height * 0.70,
  //                         width: MediaQuery.of(context).size.width * 0.90,
  //                         child: Column(
  //                           children: [
  //                             SizedBox(height: 60),
  //                             Center(
  //                                 child: Text(
  //                               'Transaction Details',
  //                               style: TextStyle(
  //                                   color: Color.fromARGB(255, 128, 98, 42),
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold),
  //                             )),
  //                             SizedBox(height: 20),
  //                             Container(
  //                                 height:
  //                                     MediaQuery.of(context).size.height * 0.47,
  //                                 padding:
  //                                     const EdgeInsets.only(left: 16, right: 16),
  //                                 child: Padding(
  //                                   padding: EdgeInsets.fromLTRB(16, 0, 10, 0),
  //                                   child: Column(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                     children: [
  //                                       Text("Transaction ID"),
  //                                       Text(
  //                                         txnId,
  //                                         style: TextStyle(
  //                                             color: Color.fromARGB(
  //                                                 255, 128, 98, 42),
  //                                             fontSize: 14,
  //                                             fontWeight: FontWeight.bold),
  //                                       ),
  //                                       Divider(color: Colors.black),
  //                                       Text("Transaction Date"),
  //                                       Text(
  //                                         outputDateStr2,
  //                                         style: TextStyle(
  //                                             fontSize: 14,
  //                                             color: Color.fromARGB(
  //                                                 255, 128, 98, 42),
  //                                             fontWeight: FontWeight.bold),
  //                                       ),
  //                                       Divider(color: Colors.black),
  //                                       Text("Check No"),
  //                                       Text(
  //                                         txnInvoiceNo,
  //                                         style: TextStyle(
  //                                             color: Color.fromARGB(
  //                                                 255, 128, 98, 42),
  //                                             fontSize: 14,
  //                                             fontWeight: FontWeight.bold),
  //                                       ),
  //                                       Divider(color: Colors.black),
  //                                       Text("Check Amount"),
  //                                       Text(
  //                                         txnInvoiceAmount,
  //                                         style: TextStyle(
  //                                             color: Color.fromARGB(
  //                                                 255, 128, 98, 42),
  //                                             fontSize: 14,
  //                                             fontWeight: FontWeight.bold),
  //                                       ),
  //                                       Divider(color: Colors.black),
  //                                       Text("Saved Amount"),
  //                                       Text(
  //                                         txnSavedAmount,
  //                                         style: TextStyle(
  //                                             color: Color.fromARGB(
  //                                                 255, 128, 98, 42),
  //                                             fontSize: 14,
  //                                             fontWeight: FontWeight.bold),
  //                                       ),
  //                                       Divider(color: Colors.black),
  //                                       Text("Amount to be paid"),
  //                                       Text(
  //                                         txnAmountToBePaid.toString(),
  //                                         style: TextStyle(
  //                                             color: Color.fromARGB(
  //                                                 255, 128, 98, 42),
  //                                             fontSize: 14,
  //                                             fontWeight: FontWeight.bold),
  //                                       ),
  //                                       // Divider(color: Colors.black),
  //                                       // Text("Redeemed Points"),
  //                                       // Text(
  //                                       //   txnRedeemedPoints,
  //                                       //   style: TextStyle(
  //                                       //       color: Color.fromARGB(
  //                                       //           255, 128, 98, 42),
  //                                       //       fontSize: 14,
  //                                       //       fontWeight: FontWeight.bold),
  //                                       // ),
  //                                       // Divider(color: Colors.black),
  //                                       // Text("Available Rewards"),
  //                                       // Text(
  //                                       //   txnAvailableReward,
  //                                       //   style: TextStyle(
  //                                       //       color: Color.fromARGB(
  //                                       //           255, 128, 98, 42),
  //                                       //       fontSize: 14,
  //                                       //       fontWeight: FontWeight.bold),
  //                                       // ),
  //                                     ],
  //                                   ),
  //                                 )),
  //                             SizedBox(height: 10),
  //                             ElevatedButton(
  //                                 style: ButtonStyle(
  //                                   backgroundColor: MaterialStateProperty.all(
  //                                     Color.fromARGB(255, 128, 98, 42),
  //                                   ),
  //                                 ),
  //                                 onPressed: () {
  //                                   txnDate = "";
  //                                   txnInvoiceNo = "";
  //                                   txnId = "";
  //                                   txnRedeemedPoints = "";
  //                                   txnAvailableReward = "";
  //                                   txnInvoiceAmount = "";
  //                                   txnSavedAmount = "";
  //                                   txnAmountToBePaid = 0;
  //                                   getAvbRewards();
  //                                   setvisiEarnRedeem();
  //                                   isVisible2 = true;
  //                                   finalSaveVisible = true;
  //                                   inputDate = DateTime.now();
  //                                   Navigator.push(
  //                                     context,
  //                                     MaterialPageRoute(
  //                                         builder: (context) =>
  //                                             const earnRedeemPoints()),
  //                                   );
  //                                 },
  //                                 child: Text("Okay")),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 );
  //               });
  //             },
  //           );
  //         }
  //       }
  //     } else {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             contentPadding: EdgeInsets.only(top: 8),
  //             title: Text("Redeem points",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  //             // subtitle: Text("subtitle"),
  //             content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Text("Unable To Redeem ! Insufficient Available Rewards.",
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                       )),
  //                 ]),
  //             actions: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text("Ok"),
  //                   )
  //                 ],
  //               )
  //             ],
  //           );
  //         },
  //       );
  //       // Fluttertoast.showToast(
  //       //     msg: "Unable To Redeem ! Insufficient Available Rewards.",
  //       //     toastLength: Toast.LENGTH_LONG,
  //       //     gravity: ToastGravity.BOTTOM_LEFT,
  //       //     timeInSecForIosWeb: 2,
  //       //     textColor: Colors.black,
  //       //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
  //       //     fontSize: 16.0);
  //       redeemController.text = "0";
  //       nSavedAmount = "0";
  //       isDisabledSave = true;
  //     }
  //   }

  _savecarddno(code) async {
    // var code = cardno.text.toString();
    final prefs = await SharedPreferences.getInstance();
    const key = 'sidearn';
    final String value1 = code;
    SID = value1;
    prefs.setString(key, value1);
  }

  Future sourcepickCamera() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (image == null) return;
      final imageTemp = File(image.path);
      final bytes = Io.File(imageTemp.path).readAsBytesSync();
      img64 = base64Encode(bytes); //img64 is the string base64 converted image
      // final decodedBytes = base64Decode(img64);
      // var file = Io.File(imageTemp.path);
      // file.writeAsBytesSync(decodedBytes);
      // GallerySaver.saveImage(file.path, albumName: "Media");
      if (kDebugMode) {
        print(img64);
      }

      futureAlbum = fetchAlbum(img64);
      setState(() => _isVisible = true);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  sourcepickGallery() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) return;
      final imageTemp = File(image.path);
      final bytes = Io.File(imageTemp.path).readAsBytesSync();
      img64 = base64Encode(bytes); //img64 is the string base64 converted image
      // final decodedBytes = base64Decode(img64);
      // var file = Io.File(imageTemp.path);
      // file.writeAsBytesSync(decodedBytes);
      // GallerySaver.saveImage(file.path, albumName: "Media");
      if (kDebugMode) {
        print(img64);
      }

      futureAlbum = fetchAlbum(img64);
      setState(() => _isVisible = true);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImage() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          color: cardColour,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Check Photo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     setState(
                  //       () {
                  //         // Future.delayed(const Duration(seconds: 4), () {
                  //         //   Navigator.push(context, MaterialPageRoute(
                  //         //       builder: (BuildContext context) {
                  //         //     return profile();
                  //         //   }));
                  //         // });
                  //         // setProfile();
                  //       },
                  //     );

                  //     Navigator.pop(context);
                  //   },
                  //   icon: Icon(
                  //     Icons.delete,
                  //     color: Color.fromARGB(199, 88, 66, 35),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // SizedBox(
                  //   width: 10,
                  // ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          sourcepickCamera();
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "    Camera",
                        style: TextStyle(
                          color: Color(0xff848484),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Container(
                        // padding: EdgeInsets.all(5),
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.black, width: 1),
                        //     borderRadius: BorderRadius.circular(80.0)),
                        child: IconButton(
                          onPressed: () {
                            sourcepickGallery();
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "    Gallery",
                        style: TextStyle(
                          color: Color(0xff848484),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
    // showDialog<ImageSource>(
    //   context: context,
    //   builder: (context) =>
    //       AlertDialog(content: Text("Choose image source"), actions: [
    //     ElevatedButton(
    //         child: Text("Camera"),
    //         onPressed: () => {sourcepickCamera(), Navigator.pop(context)}),
    //     ElevatedButton(
    //         child: Text("Gallery"),
    //         onPressed: () => {sourcepickGallery(), Navigator.pop(context)}),
    //   ]),
    // );
  }

  //
  //if amt not detected code below
  //
  getamt() async {
    setState(() {
      isLoaderVisibleamt = true;
    });

    isLoaderVisibleamt
        ? showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Detecting Check Amount"),
              content: isLoaderVisibleamt
                  ? SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      ),
                    )
                  : Text("", style: TextStyle(color: Colors.red)),
            ),
          )
        : null;
    String baseUrl =
        "https://api.osourceglobal.com/Hotel_Invoice_Parser/upload_file_and_parse ";

    Map<String, String> param = {"base64_of_image": img649};

    Map<String, String> headers = {"Content-type": "application/json"};
    String body = convert.jsonEncode(param).toString();
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    print(body);
    dynamic resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("exit1");
      setState(() {
        getamtiscalled = true;

        Etagredeem = resp['etag'];
        filename2redeem = resp['file_name'];
        print("exit2");
        String amntna = resp['amount_data'];
        Uploadinvoiceamt = amntna.toString().split(".")[0];
        print(amntna);
        amountController.text = amntna.toString();
        print(amountController.text);
        isLoaderVisibleamt = false;
        _isVisible = true;
        print("exit3");
      });
      print("exit4");
      Navigator.of(context, rootNavigator: true).pop();
      // Navigator.pop(context);
      print("exit5");
    } else {
      setState(() {
        isLoaderVisibleamt = false;
        Navigator.of(context, rootNavigator: true).pop();
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 8),
            title: Text(
              "Redeem points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        "something went wrong!",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
    print("exit6");
  }

  late String img649 = "";
  Future sourcepickCamera2() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (image == null) return;
      final imageTemp = File(image.path);
      final bytes = Io.File(imageTemp.path).readAsBytesSync();
      img649 = base64Encode(bytes); //img64 is the string base64 converted image
      // final decodedBytes = base64Decode(img649);
      // var file = Io.File(imageTemp.path);
      // file.writeAsBytesSync(decodedBytes);
      // GallerySaver.saveImage(file.path, albumName: "Media");
      if (kDebugMode) {
        print(img649);
      }

      getamt();
      // futureAlbum = fetchAlbum(img649);
      // setState(() => _isVisible = true);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  sourcepickGallery2() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) return;
      final imageTemp = File(image.path);
      final bytes = Io.File(imageTemp.path).readAsBytesSync();
      img649 = base64Encode(bytes); //img64 is the string base64 converted image
      // final decodedBytes = base64Decode(img649);
      // var file = Io.File(imageTemp.path);
      // file.writeAsBytesSync(decodedBytes);
      // GallerySaver.saveImage(file.path, albumName: "Media");
      if (kDebugMode) {
        print(img649);
      }

      getamt();

      // futureAlbum = fetchAlbum(img649);
      // setState(() => _isVisible = true);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImage2() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 160,
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Check Photo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {});

                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // SizedBox(
                  //   width: 10,
                  // ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          sourcepickCamera2();

                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.camera_alt, size: 50),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "    Camera",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Container(
                        child: IconButton(
                          onPressed: () {
                            sourcepickGallery2();
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.image, size: 50),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "    Gallery",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showModal(context) {
    showModalBottomSheet(
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width -
            20, // here increase or decrease in width
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      // useSafeArea: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              // color: Colors.red,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Done", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Container(
              padding: EdgeInsets.only(top: 6),
              height: 330,
              alignment: Alignment.center,
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: listitemCs.length,
                separatorBuilder: (context, int) {
                  return Divider();
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(listitemCs[index]),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        isoutletchangenotclicked = false;
                        Future.delayed(Duration(seconds: 1), () {
                          _selected = listitemCs[index];
                          _mySelection = listitemCs1[index];
                        });
                        print("$_selected $_mySelection this is all you need ");
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    String dropdownValue = list.first;

    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        home: Scaffold(
          extendBodyBehindAppBar: true,
          drawer: sideMenuWidget(),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            toolbarHeight: 38,
            flexibleSpace: Container(
              decoration: BoxDecoration(color: _bgColour),
            ),
            backgroundColor: Color(0x00000000),
            elevation: 0,
            title: const Text("Redeem Points", style: TextStyle(fontSize: 14)),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          body: DecoratedBox(
            decoration: BoxDecoration(
              color: _bgColour,

              // image: DecorationImage(
              // image: AssetImage('images/BG_image.jpg'), fit: BoxFit.fill),
            ),
            child: Column(
              //main column
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      height: deviceHeight + 100,
                      width: deviceWidth,
                      padding: EdgeInsets.fromLTRB(18, 88, 18, 0), //top64
                      child: Column(
                        //main column@2
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: null),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Visibility(
                                    visible: !isVisible2,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.88,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(height: 100),
                                              Visibility(
                                                visible: !isVisible2,
                                                child: Container(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 0,
                                                      right: 10,
                                                    ), //icon level padding...
                                                    child: IconButton(
                                                      iconSize:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.6,
                                                      onPressed: () {
                                                        getamtiscalled = false;
                                                        setState(() {
                                                          isoutletchangenotclicked =
                                                              true;
                                                          _isVisible = false;
                                                          isVisible2 = true;
                                                          //
                                                          // below should be uncommented to build qr scan module
                                                          //
                                                          finalSaveVisible =
                                                              false;
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const qrCodeRedeem(),
                                                            ),
                                                          );
                                                          isDisabledSave = true;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .qr_code_scanner_rounded,
                                                        color: Colors.white,
                                                        // size: 28,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    !isVisible2, //notviceversa......
                                                child: Text(
                                                  "Scan QR to proceed !",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // ignore: avoid_unnecessary_containers
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Visibility(
                                          visible:
                                              isVisible2, //notviceversa......
                                          child: ValueListenableBuilder(
                                            valueListenable: availableReward,
                                            builder: (context, value, child) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                  left: 20,
                                                  bottom: 0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Column(
                                                          // crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  availableReward
                                                                      .value
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        32,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Column(
                                                                  // mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    SizedBox(
                                                                      height: 9,
                                                                    ),
                                                                    Text(
                                                                      " Pts",
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.only(
                                                                        right:
                                                                            8,
                                                                      ),
                                                                  child: Text(
                                                                    custname,
                                                                    style: TextStyle(
                                                                      color: Color(
                                                                        0xff848484,
                                                                      ),
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Visibility(
                                            visible: isVisible2,
                                            child: Container(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 0,
                                                  right: 0,
                                                ), //icon level padding...
                                                child: IconButton(
                                                  onPressed: () {
                                                    getamtiscalled = false;
                                                    setState(() {
                                                      isoutletchangenotclicked =
                                                          true;
                                                      _isVisible = false;
                                                      isVisible2 = true;
                                                      firstinvoiceScan = true;
                                                      //
                                                      // below should be uncommented to build qr scan module
                                                      //
                                                      finalSaveVisible = false;
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const qrCodeRedeem(),
                                                        ),
                                                      );
                                                      isDisabledSave = true;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons
                                                        .qr_code_scanner_rounded,
                                                    color: Colors.grey,
                                                    size: 28,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                isVisible2, //notviceversa......
                                            child: Container(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 0,
                                                ),
                                                child: IconButton(
                                                  onPressed: () {
                                                    isoutletchangenotclicked =
                                                        true;
                                                    setState(() {
                                                      setState(() {
                                                        getamtiscalled = false;
                                                        // _mySelection =
                                                        //     "c9868ddd-c41f-412a-87ad-a529d98nk17x";
                                                        // _selected =
                                                        //     listitemCs[0]; nadeemkhan
                                                        firstinvoiceScan = true;
                                                        finalSaveVisible =
                                                            false;
                                                        if (_isVisible ==
                                                            true) {
                                                          _isVisible = false;
                                                          firstcall = 1;
                                                          ervisibility = true;
                                                          ranonce = false;
                                                          redeemController
                                                                  .text =
                                                              "0";
                                                          nSavedAmount = "0";
                                                        } else {
                                                          redeemController
                                                                  .text =
                                                              "0";
                                                          pickImage();
                                                          firstcall = 1;
                                                          ervisibility = true;
                                                          ranonce = false;
                                                          nSavedAmount = "0";
                                                        }
                                                        isDisabledSave = true;
                                                      });
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.camera_alt_outlined,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ), //first container
                          ),
                          // Visibility(
                          //   visible: !isVisible2, //notviceversa......
                          //   child: Column(
                          //     children: [
                          //       Padding(
                          //         padding: const EdgeInsets.only(
                          //             top: 20, right: 0, bottom: 20),
                          //         child: SizedBox(
                          //           height: 50,
                          //           child: TextFormField(
                          //             style: TextStyle(color: Colors.white),
                          //             keyboardType: TextInputType.text,
                          //             controller: cardno,
                          //             inputFormatters: [
                          //               // FilteringTextInputFormatter
                          //               //     .digitsOnly,
                          //               LengthLimitingTextInputFormatter(12),
                          //             ],
                          //             decoration: const InputDecoration(
                          //               hintText:
                          //                   'Please enter Membership number',
                          //               hintStyle:
                          //                   TextStyle(color: Colors.grey),
                          //               helperStyle:
                          //                   TextStyle(color: Colors.white),
                          //               focusedBorder: OutlineInputBorder(
                          //                 borderSide:
                          //                     BorderSide(color: Colors.white),
                          //               ),
                          //               focusColor: Colors.white,
                          //               enabledBorder: OutlineInputBorder(
                          //                 borderSide:
                          //                     BorderSide(color: Colors.white),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //       SizedBox(
                          //         width: 100,
                          //         child: isManualcardLoading
                          //             ? Container(
                          //                 height: 40,
                          //                 width: 40,
                          //                 child: CircularProgressIndicator(
                          //                   valueColor:
                          //                       new AlwaysStoppedAnimation<
                          //                           Color>(Colors.white),
                          //                 ))
                          //             : ElevatedButton(
                          //                 style: ElevatedButton.styleFrom(
                          //                     primary: Color.fromARGB(
                          //                         255,
                          //                         255,
                          //                         255,
                          //                         255), // Set the button's background color
                          //                     padding: EdgeInsets.symmetric(
                          //                         horizontal: 16,
                          //                         vertical:
                          //                             8), // Set the button's padding
                          //                     textStyle:
                          //                         TextStyle(fontSize: 16)),
                          //                 // Set the text style),
                          //                 onPressed: () {
                          //                   print(cardno.text.toString());
                          //                   //_savecarddno();
                          //                   getAvbRewardscardno();
                          //                   isManualcardLoading = true;
                          //                   setState(() {
                          //                     //finalSaveVisible = false;
                          //                     // _toast();
                          //                   });
                          //                 },
                          //                 child: const Text(
                          //                   "Proceed",
                          //                   style: TextStyle(
                          //                       color: Colors.black),
                          //                 ),
                          //               ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Visibility(
                            visible: isVisible2, //notviceversa......
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.50,
                                    // fixed height
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.90,
                                    child: Card(
                                      color: cardColour,
                                      elevation: 50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.0,
                                        ),
                                      ),
                                      margin: EdgeInsets.only(
                                        top: 10,
                                        left: 0,
                                        right: 0,
                                      ),
                                      child: Column(
                                        // padding: EdgeInsets.only(bottom: 20),
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Visibility(
                                                visible:
                                                    !_isVisible &&
                                                    !finalSaveVisible,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                    top: 60,
                                                  ),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "QR scanning successfully done.",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          "Please proceed with Check scanning",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(height: 24),
                                                        SizedBox(
                                                          height: 120,
                                                          child: Image.asset(
                                                            'images/Earn-pts-tick-icon.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        // Visibility(
                                                        //   visible:
                                                        //       !_isVisible &&
                                                        //           !finalSaveVisible, //notviceversa......
                                                        //   child:
                                                        //       ValueListenableBuilder(
                                                        //           valueListenable:
                                                        //               availableReward,
                                                        //           builder: (context,
                                                        //               value,
                                                        //               child) {
                                                        //             return Center(
                                                        //               child:
                                                        //                   Padding(
                                                        //                 padding: const EdgeInsets.only(top: 10, right: 0, bottom: 0),
                                                        //                 child: Row(
                                                        //                   mainAxisAlignment: MainAxisAlignment.center,
                                                        //                   children: [
                                                        //                     Column(
                                                        //                       // mainAxisSize: MainAxisSize.min,
                                                        //                       children: [
                                                        //                         Column(
                                                        //                           // crossAxisAlignment: CrossAxisAlignment.end,
                                                        //                           children: [
                                                        //                             Row(
                                                        //                               children: [
                                                        //                                 Text(availableReward.value.toString(), style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
                                                        //                                 Column(
                                                        //                                   // mainAxisAlignment: MainAxisAlignment.end,
                                                        //                                   children: [
                                                        //                                     SizedBox(
                                                        //                                       height: 9,
                                                        //                                     ),
                                                        //                                     Text(" Pts", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                                                        //                                   ],
                                                        //                                 ),
                                                        //                               ],
                                                        //                             ),
                                                        //                             Row(
                                                        //                               mainAxisAlignment: MainAxisAlignment.start,
                                                        //                               children: [
                                                        //                                 Padding(
                                                        //                                   padding: EdgeInsets.only(right: 8),
                                                        //                                   child: Text(
                                                        //                                     custname,
                                                        //                                     style: TextStyle(
                                                        //                                       color: Colors.white,
                                                        //                                       fontSize: 16,
                                                        //                                     ),
                                                        //                                   ),
                                                        //                                 ),
                                                        //                               ],
                                                        //                             ),
                                                        //                           ],
                                                        //                         ),
                                                        //                       ],
                                                        //                     )
                                                        //                   ],
                                                        //                 ),
                                                        //               ),
                                                        //             );
                                                        //           }),
                                                        // ),
                                                        InkWell(
                                                          onTap: () {
                                                            isoutletchangenotclicked =
                                                                true;
                                                            setState(() {
                                                              setState(() {
                                                                getamtiscalled =
                                                                    false;
                                                                // _mySelection =
                                                                //     "c9868ddd-c41f-412a-87ad-a529d98nk17x";
                                                                // _selected =
                                                                //     'Select Outlet Name'; nadeemkhan

                                                                finalSaveVisible =
                                                                    false;
                                                                if (_isVisible ==
                                                                    true) {
                                                                  _isVisible =
                                                                      false;
                                                                  firstcall = 1;
                                                                  ervisibility =
                                                                      true;
                                                                  ranonce =
                                                                      false;
                                                                  redeemController
                                                                          .text =
                                                                      "0";
                                                                  nSavedAmount =
                                                                      "0";
                                                                } else {
                                                                  redeemController
                                                                          .text =
                                                                      "0";
                                                                  pickImage();
                                                                  firstcall = 1;
                                                                  ervisibility =
                                                                      true;
                                                                  ranonce =
                                                                      false;
                                                                  nSavedAmount =
                                                                      "0";
                                                                }
                                                                isDisabledSave =
                                                                    true;
                                                              });
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  top: 20,
                                                                ),

                                                            height: 50,
                                                            width: 180, //80
                                                            decoration: BoxDecoration(
                                                              color: _bgColour,
                                                              // border: Border.all(
                                                              //     color: _bgColour),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                const Text(
                                                                  "Capture Check",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 18,
                                                                ),
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        right:
                                                                            5,
                                                                      ),
                                                                  height: 36,
                                                                  width: 36,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons
                                                                        .arrow_right_alt_outlined,
                                                                    size: 25,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: finalSaveVisible,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                    top: 100,
                                                  ),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 120,
                                                          child: Image.asset(
                                                            'images/Earn-pts-tick-icon.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Transaction successfully done.",
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xff848484,
                                                            ),
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        adminHome(),
                                                              ),
                                                            );
                                                            setvisiEarnRedeem();
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  top: 20,
                                                                ),

                                                            height: 50,
                                                            width: 195, //80
                                                            decoration: BoxDecoration(
                                                              color: _bgColour,
                                                              border: Border.all(
                                                                width: 0.3,
                                                                color: Color(
                                                                  0xff616161,
                                                                ),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        left: 6,
                                                                        right:
                                                                            5,
                                                                      ),
                                                                  height: 36,
                                                                  width: 36,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons
                                                                        .arrow_right_alt_outlined,
                                                                    size: 25,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 18,
                                                                ),
                                                                const Text(
                                                                  "Go back to Home",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: _isVisible,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 18,
                                                    top: 16,
                                                  ),
                                                  child: FutureBuilder<Album>(
                                                    future: futureAlbum,
                                                    builder: (context, snapshot) {
                                                      String outnameid =
                                                          "a54720aa-2ee8-4e2f-a7ce-8c7b61f96912";
                                                      String dropdownvalue =
                                                          "a54720aa-2ee8-4e2f-a7ce-8c7b61f96912";
                                                      if (snapshot.hasData &&
                                                          snapshot
                                                                  .data!
                                                                  .invoiceAmount ==
                                                              "N/A" &&
                                                          ranonce == false) {
                                                        ranonce = true;
                                                        Future.delayed(
                                                          Duration(seconds: 3),
                                                          () async {
                                                            askNA(context);
                                                          },
                                                        );
                                                      }
                                                      if (snapshot.hasData) {
                                                        var getdata =
                                                            snapshot.data!;
                                                        if (getdata.invoiceOutlet ==
                                                                "N/A" &&
                                                            isoutletchangenotclicked) {
                                                          _mySelection =
                                                              outletIdFromLogin;
                                                          _selected =
                                                              outletNameFromLogin;
                                                          print(
                                                            "$_selected and $_mySelection",
                                                          );
                                                          print(
                                                            "not working buddy",
                                                          );
                                                        } else {
                                                          // _mySelection = getdata
                                                          //     .invoiceOutletId;
                                                          // _selected = listitemCs1
                                                          //             .indexOf(
                                                          //                 _mySelection) !=
                                                          //         -1
                                                          //     ? listitemCs[
                                                          //         listitemCs1
                                                          //             .indexOf(
                                                          //                 _mySelection)]
                                                          //     : listitemCs[0];
                                                          if (firstinvoiceScan) {
                                                            firstinvoiceScan =
                                                                false;
                                                            // setState(
                                                            //   () {
                                                            _mySelection = getdata
                                                                .invoiceOutletId;
                                                            _selected =
                                                                listitemCs1
                                                                    .contains(
                                                                      _mySelection,
                                                                    )
                                                                ? listitemCs[listitemCs1
                                                                      .indexOf(
                                                                        _mySelection,
                                                                      )]
                                                                : listitemCs[0];
                                                            print(
                                                              "$_mySelection $_selected hii pooja",
                                                            );
                                                            //   },
                                                            // );
                                                          }
                                                        }

                                                        if (firstcall == 1) {
                                                          invNoController
                                                              .text = getdata
                                                              .invoiceBillNo;
                                                          amountController
                                                              .text = getdata
                                                              .invoiceAmount;
                                                        }
                                                        invoiceRedeemableForRedeem =
                                                            getdata
                                                                .invoiceRedeemable;
                                                        getdata.invoiceRedeemable ==
                                                            "";
                                                        invoicebillnotext =
                                                            getdata
                                                                .invoiceBillNo;
                                                        dateText = getdata
                                                            .invoiceDate
                                                            .toString();

                                                        isbottomcardVisible =
                                                            true;
                                                        firstcall = 0;
                                                        print(
                                                          "invoiceRedeemable------${getdata.invoiceRedeemable}",
                                                        );
                                                        getEarnedpreviewRewards();
                                                        return Column(
                                                          children: [
                                                            SizedBox(height: 0),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                    top: 0,
                                                                  ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children:
                                                                        [],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .calendar_month_outlined,
                                                                        color: Color.fromARGB(
                                                                          232,
                                                                          122,
                                                                          118,
                                                                          118,
                                                                        ),
                                                                        size:
                                                                            16,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        getdata
                                                                            .invoiceDate,
                                                                        style: TextStyle(
                                                                          color: Color(
                                                                            0xff848484,
                                                                          ),
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "Outlet Name",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Color(
                                                                      0xff848484,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      showModal(
                                                                        context,
                                                                      ),
                                                                  child: Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          10,
                                                                        ),
                                                                    width: MediaQuery.of(
                                                                      context,
                                                                    ).size.width,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12.0,
                                                                          ),
                                                                      border: Border.all(
                                                                        color: Color(
                                                                          0xff616161,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      _selected,
                                                                      style: TextStyle(
                                                                        color: Color(
                                                                          0xff848484,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text(
                                                                  "Check No",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Color(
                                                                      0xff848484,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  height: 38,
                                                                  width: MediaQuery.of(
                                                                    context,
                                                                  ).size.width,
                                                                  child: TextFormField(
                                                                    style: TextStyle(
                                                                      color: Color(
                                                                        0xff848484,
                                                                      ),
                                                                    ),
                                                                    enabled:
                                                                        false, //nadeem
                                                                    controller:
                                                                        invNoController,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    decoration: InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                            10,
                                                                          ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12.0,
                                                                            ),
                                                                        borderSide: BorderSide(
                                                                          color: Color(
                                                                            0xff616161,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      focusColor:
                                                                          Colors
                                                                              .black,
                                                                      disabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12.0,
                                                                            ),
                                                                        borderSide: BorderSide(
                                                                          color: Color(
                                                                            0xff616161,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12.0,
                                                                            ),
                                                                        borderSide: BorderSide(
                                                                          color: Color(
                                                                            0xff616161,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text(
                                                                  "Check Amount",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Color(
                                                                      0xff848484,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  height: 38,
                                                                  width: MediaQuery.of(
                                                                    context,
                                                                  ).size.width,
                                                                  child: TextFormField(
                                                                    style: TextStyle(
                                                                      color: Color(
                                                                        0xff848484,
                                                                      ),
                                                                    ),
                                                                    onChanged: (newText) {
                                                                      if (newText ==
                                                                          "N/A") {
                                                                        amountController.text =
                                                                            "";
                                                                      }
                                                                    },
                                                                    focusNode:
                                                                        myFocusNode,
                                                                    onFieldSubmitted: (value) {
                                                                      if (value ==
                                                                              "" &&
                                                                          value ==
                                                                              "N/A") {
                                                                        setState(
                                                                          () =>
                                                                              myFocusNode.requestFocus(),
                                                                        );
                                                                      }
                                                                      if (value !=
                                                                              "" &&
                                                                          value !=
                                                                              "N/A") {
                                                                        setState(
                                                                          () =>
                                                                              {},
                                                                        );
                                                                      }

                                                                      if (ervisibility ==
                                                                          true) {
                                                                        setState(() {
                                                                          getEarnedpreviewRewards();
                                                                          ervisibility =
                                                                              false;
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                          () {
                                                                            getEarnedpreviewRewards();
                                                                          },
                                                                        );
                                                                      }
                                                                      // getEarnedRewards();
                                                                    },
                                                                    inputFormatters: [
                                                                      LengthLimitingTextInputFormatter(
                                                                        7,
                                                                      ),
                                                                    ],
                                                                    controller:
                                                                        amountController,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    decoration: InputDecoration(
                                                                      suffix: Text(
                                                                        "₹",
                                                                        style: TextStyle(
                                                                          color: Color(
                                                                            0xff848484,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                            10,
                                                                          ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12.0,
                                                                            ),
                                                                        borderSide: BorderSide(
                                                                          color: Color(
                                                                            0xff616161,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      focusColor:
                                                                          Colors
                                                                              .black,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12.0,
                                                                            ),
                                                                        borderSide: BorderSide(
                                                                          color: Color(
                                                                            0xff616161,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text(
                                                                  "Redeem",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Color(
                                                                      0xff848484,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  height: 38,
                                                                  width: MediaQuery.of(
                                                                    context,
                                                                  ).size.width,
                                                                  child: TextFormField(
                                                                    style: TextStyle(
                                                                      color: Color(
                                                                        0xff848484,
                                                                      ),
                                                                    ),
                                                                    controller:
                                                                        redeemController,
                                                                    focusNode:
                                                                        myFocusNode2,
                                                                    onFieldSubmitted: (value) {
                                                                      if (value ==
                                                                              "" ||
                                                                          value ==
                                                                              "N/A") {
                                                                        setState(
                                                                          () =>
                                                                              myFocusNode2.requestFocus(),
                                                                        );
                                                                        redeemController.text =
                                                                            "0";
                                                                      }
                                                                      if (value !=
                                                                              "" &&
                                                                          value !=
                                                                              "N/A") {
                                                                        setState(
                                                                          () =>
                                                                              {},
                                                                        );
                                                                      }

                                                                      if (ervisibility ==
                                                                          true) {
                                                                        setState(() {
                                                                          getSavedpreviewRewards();
                                                                          ervisibility =
                                                                              false;
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                          () {
                                                                            getSavedpreviewRewards();
                                                                          },
                                                                        );
                                                                      }
                                                                      // getEarnedRewards();
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    inputFormatters: [
                                                                      LengthLimitingTextInputFormatter(
                                                                        6,
                                                                      ),
                                                                    ],
                                                                    onTap: () {
                                                                      redeemController
                                                                              .text =
                                                                          "";
                                                                    },
                                                                    decoration: InputDecoration(
                                                                      suffix: Text(
                                                                        "Pts",
                                                                        style: TextStyle(
                                                                          color: Color(
                                                                            0xff848484,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                            10,
                                                                          ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12.0,
                                                                            ),
                                                                        borderSide: BorderSide(
                                                                          color: Color(
                                                                            0xff616161,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      focusColor:
                                                                          Colors
                                                                              .black,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12.0,
                                                                            ),
                                                                        borderSide: BorderSide(
                                                                          color: Color(
                                                                            0xff616161,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                          '${snapshot.error}',
                                                        );
                                                      }
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _isVisible && isbottomcardVisible,
                            child: Container(
                              margin: EdgeInsets.only(top: 8),
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(
                                color: cardColour,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Column(
                                      //   children: [
                                      //     Text(
                                      //       "Earned",
                                      //       style: TextStyle(
                                      //           fontSize:
                                      //               14,
                                      //           color: Colors
                                      //               .black),
                                      //     ),
                                      //     Row(
                                      //       children: [
                                      //         // Visibility(
                                      //         //   visible:
                                      //         //       ervisibility,
                                      //         //   child:
                                      //         //       Text(
                                      //         //     iEarnReward
                                      //         //         .toString(),
                                      //         //     style: TextStyle(
                                      //         //         fontSize: 28,
                                      //         //         color: Colors.black),
                                      //         //   ),
                                      //         // ),
                                      //         Visibility(
                                      //           visible:
                                      //               true,
                                      //           child:
                                      //               Text(
                                      //             iEarnReward
                                      //                 .toString(),
                                      //             style: TextStyle(
                                      //                 fontSize: 28,
                                      //                 fontWeight: FontWeight.bold,
                                      //                 color: Color.fromARGB(255, 230, 125, 34)),
                                      //           ),
                                      //         ),
                                      //         SizedBox(
                                      //           width:
                                      //               4,
                                      //         ),
                                      //         Text(
                                      //           "Pts",
                                      //           style:
                                      //               TextStyle(
                                      //             fontSize:
                                      //                 16,
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ],
                                      // ),
                                      // SizedBox(
                                      //   height: 20,
                                      // ),
                                      Column(
                                        children: [
                                          SizedBox(height: 14),
                                          Text(
                                            "Saved Amount",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xff848484),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "₹",
                                                style: TextStyle(
                                                  fontSize: 32,
                                                  // fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                    255,
                                                    39,
                                                    174,
                                                    96,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                nSavedAmount.toString(),
                                                style: TextStyle(
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                    255,
                                                    39,
                                                    174,
                                                    96,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: MaterialButton(
                                                onPressed: isDisabledSave
                                                    ? () {
                                                        isVerifyLoading = true;
                                                        print('Submit');
                                                        // showDialog(
                                                        //   context: context,
                                                        //   builder: (context) {
                                                        //     return OtpPopup();
                                                        //   },
                                                        // );

                                                        // isDisabledSave = false; //-- rm disable functionality by priya
                                                        if (invoiceRedeemableForRedeem ==
                                                            "1") {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                        ),
                                                                    title: Text(
                                                                      "Redeem points",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    // subtitle: Text("subtitle"),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child: Center(
                                                                            child: Padding(
                                                                              padding: EdgeInsets.symmetric(
                                                                                horizontal: 5,
                                                                              ),
                                                                              child: Text(
                                                                                "Cannot Redeem points on this Check, as scanned check is a Tax Invoice.",
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            child: Text(
                                                                              "Ok",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                          );
                                                        } else if (redeemController
                                                                    .text ==
                                                                "0" &&
                                                            redeemController
                                                                    .text ==
                                                                nSavedAmount &&
                                                            nSavedAmount ==
                                                                "0" &&
                                                            amountController
                                                                    .text !=
                                                                "0") {
                                                          // redeemRewards();
                                                          // otplogin();
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                        ),
                                                                    title: Text(
                                                                      "Redeem points",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    // subtitle: Text("subtitle"),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "Please enter points to Redeem",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            child: Text(
                                                                              "Ok",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                          );
                                                        } else if (_mySelection ==
                                                                "c9868ddd-c41f-412a-87ad-a529d98nk17x" ||
                                                            _selected ==
                                                                listitemCs[0] ||
                                                            _selected == "") {
                                                          _selected =
                                                              listitemCs[0];
                                                          _mySelection =
                                                              "c9868ddd-c41f-412a-87ad-a529d98nk17x";
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                        ),
                                                                    title: Text(
                                                                      "Redeem points",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    // subtitle: Text("subtitle"),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child: Text(
                                                                            "Outlet name is not detected,Please select outlet  name manually",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            child: Text(
                                                                              "Ok",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                          );
                                                        } else if (dateText ==
                                                            "N/A") {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                        ),
                                                                    title: Text(
                                                                      "Redeem points",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    // subtitle: Text("subtitle"),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child: Padding(
                                                                            padding: EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                            ),
                                                                            child: Text(
                                                                              "Check Date is not detected, Please rescan Check.",
                                                                              textAlign: TextAlign.justify,
                                                                              style: TextStyle(
                                                                                fontSize: 16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            child: Text(
                                                                              "Ok",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                          );
                                                        } else if (invoicebillnotext ==
                                                            "N/A") {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                        ),
                                                                    title: Text(
                                                                      "Redeem points",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    // subtitle: Text("subtitle"),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child: Text(
                                                                            "Check number is not detected, Please rescan Check.",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            child: Text(
                                                                              "Ok",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                          );
                                                        } else if (redeemController
                                                                        .text !=
                                                                    "0" &&
                                                                nSavedAmount !=
                                                                    "0" &&
                                                                amountController
                                                                        .text !=
                                                                    "0" &&
                                                                amountController
                                                                    .text
                                                                    .contains(
                                                                      ".",
                                                                    )
                                                            ? int.parse(
                                                                    amountController.text.substring(
                                                                      0,
                                                                      amountController
                                                                          .text
                                                                          .indexOf(
                                                                            ".",
                                                                          ),
                                                                    ),
                                                                  ) >
                                                                  int.parse(
                                                                    nSavedAmount,
                                                                  )
                                                            : int.parse(
                                                                    amountController
                                                                        .text,
                                                                  ) >
                                                                  int.parse(
                                                                    nSavedAmount,
                                                                  )) {
                                                          // redeemRewards();
                                                          otplogin();
                                                        } else if (amountController
                                                                .text
                                                                .contains(".")
                                                            ? int.parse(
                                                                    amountController.text.substring(
                                                                      0,
                                                                      amountController
                                                                          .text
                                                                          .indexOf(
                                                                            ".",
                                                                          ),
                                                                    ),
                                                                  ) <
                                                                  int.parse(
                                                                    nSavedAmount,
                                                                  )
                                                            : int.parse(
                                                                    amountController
                                                                        .text,
                                                                  ) <
                                                                  int.parse(
                                                                    nSavedAmount,
                                                                  )) {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                        ),
                                                                    title: Text(
                                                                      "Redeem points",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    // subtitle: Text("subtitle"),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "Redeem points should be less than Check amount.",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            child: Text(
                                                                              "Ok",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                          );
                                                          // Fluttertoast.showToast(msg: "Redeem points should be less than invoice ammount", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 2, textColor: Colors.black, backgroundColor: Color.fromARGB(255, 204, 174, 174), fontSize: 16.0);
                                                        } else {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                        ),
                                                                    title: Text(
                                                                      "Redeem points",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    // subtitle: Text("subtitle"),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child: Text(
                                                                            "Cannot Redeem on invalid Inputs,please check and enter again.",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            child: Text(
                                                                              "Ok",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                          );
                                                          // Fluttertoast.showToast(msg: "Cannot Earn or Redeem on invalid Inputs,please check and enter again!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 2, textColor: Colors.black, backgroundColor: Color.fromARGB(255, 204, 174, 174), fontSize: 16.0);
                                                          // isDisabledSave = false;
                                                        }
                                                      }
                                                    : null,
                                                disabledColor: Colors.grey,
                                                color: isDisabledSave
                                                    ? _bgColour
                                                    : Colors.grey,
                                                elevation: 10,
                                                textColor: isDisabledSave
                                                    ? Colors.grey
                                                    : Colors.black,
                                                splashColor: Colors.redAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.0,
                                                      ),
                                                ),
                                                child: Text("Process"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///  OTP popup code -//
class OtpPopup extends StatefulWidget {
  const OtpPopup({super.key});

  @override
  _OtpPopupState createState() => _OtpPopupState();
}

class _OtpPopupState extends State<OtpPopup> {
  final TextEditingController _otpController = TextEditingController();
  final otpController = TextEditingController();
  int secondsRemaining = 30;
  bool enableResend = false;
  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  resendotplogin() async {
    // _read();
    String baseUrl =
        // "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/OtpGenerate";
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/OtpGenerate";
    Map<String, String?> param = {
      "sOperationType": "GENOTP",
      "sIsGenerated": "1",
      "sMobile": guestMobileNumber.toString(),
      "sFromMobile": "1",
      "type": "login",
      "sIpAddress": "192.168.67.58",
    };
    var otp = PhoneNumber;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("automobile", otp.toString());
    print(prefs.getString("otpmobileno"));
    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    print(param);
    var otpmobileno = PhoneNumber;
    print(otpmobileno);
    var resp = convert.jsonDecode(response.body);
    print(resp);
    // print(resp['data']["sOutcome"]);
    if (resp['statusCode'] == 200) {
      if (resp['data']["sOutcome"] == "OTP Generated Successfully.") {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("otpmobileno", otpmobileno.toString());
        print(prefs.getString("otpmobileno"));
        // otpmobileno = controller.value?.nsn.toString();
        //OTP popup
      }
    }
  }

  void _resendCode() {
    resendotplogin();
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => login()),
        );
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Login"),
      content: Text("Unauthorized User"),
      actions: [okButton],
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      // elevation: 100,
      contentPadding: EdgeInsets.only(left: 20, right: 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(2),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: Color.fromARGB(132, 158, 158, 158),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset("images/cross.png"),
            ),
          ),
        ],
      ),
      // subtitle: Text("subtitle"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Color.fromARGB(118, 158, 158, 158),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 42,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Image.asset("images/logout.png"),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OTP Verification",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Please enter verification code \nwhich is sent to Member's email & Whatsapp",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xff848484)),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 60, right: 60),
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlignVertical: TextAlignVertical.center,
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color(0xff616161)),
                ),
                focusColor: Colors.black,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color(0xff616161)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color(0xff616161)),
                ),
                //   border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                // hintText: "Enter OTP here",
              ),
            ),
          ),
          // TextField(
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontSize: 14,
          //     fontWeight: FontWeight.bold,
          //   ),
          //   textAlignVertical: TextAlignVertical.center,
          //   controller: otpController,
          //   keyboardType: TextInputType.number,
          //   maxLength: 6,
          //   decoration: InputDecoration(
          //       //   border: OutlineInputBorder(),
          //       hintStyle: TextStyle(
          //     color: Colors.black,
          //     fontSize: 14,
          //   )
          //       // hintText: "Enter OTP here",
          //       ),
          // ),
        ],
      ),

      actions: [
        Container(
          padding: EdgeInsets.only(top: 8, left: 22, right: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // width: 170,
                margin: EdgeInsets.only(left: 0),
                child: InkWell(
                  child: Text(
                    '00:$secondsRemaining',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
              Container(
                // width: 80,
                margin: EdgeInsets.only(left: 0),
                child: InkWell(
                  onTap: () => enableResend ? _resendCode() : null,
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      fontSize: 13,
                      color: enableResend
                          ? Colors.blue[600]
                          : Color.fromARGB(113, 158, 158, 158),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isVerifyLoading
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Colors.grey, //change background color of button
                      backgroundColor: _bgColour, //change text color of button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 15.0,
                    ),
                    onPressed: () {
                      print("OTP entered: ${otpController.text}");
                      _otpValue = otpController.text;

                      verifyotplogin();

                      // Navigator.of(context).pop();
                    },
                    child: Text("         Verify         "),
                  )
                : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
          ],
        ),
      ],
    );
  }

  getAvbRewards() async {
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/AvailableRewards";
    Map<String, String> param = {
      "sOperationType": "AvailableRewards",
      "sId": SID,
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );

    var resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      availableReward.value = resp['data']['iAvailableReward'];
      custname = resp['data']['sName'];
    } else {
      print("caution dologin2notworkinh");
    }
  }

  String outputDateStr2 = "";
  _getTransactionSuccessDetails() async {
    final prefs = await SharedPreferences.getInstance();
    SID = prefs.getString('sidearn').toString();
    print("${SID}this your sidll");
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/GetGuestReedeemHistory";
    Map<String, String> param = {
      "sOperationType": "GetGuestRedeemHistory",
      "sId": SID,
      "sInvoiceNo": invNoController.text.toString(),
    };
    // invNoController.text.toString()
    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );

    var resp = convert.jsonDecode(response.body);
    print(resp['data']);
    if (response.statusCode == 200) {
      txnDate = resp['data'][0]['sTransactionDate'] as String;
      txnInvoiceNo = resp['data'][0]['sInvoiceNo'] as String;
      txnId = resp['data'][0]['sTransactionId'] as String;
      txnRedeemedPoints = resp['data'][0]['sRedeem'] as String;
      txnAvailableReward = resp['data'][0]['iAvailableReward'].toString();
      txnInvoiceAmount = resp['data'][0]['iInvoiceAmount'].toString();
      print(txnRedeemedPoints);
      print("${txnDate}999hii there");
      if (resp['data'][0]['sTransactionDate'] == "") {
        print("date not coming");
        outputDateStr2 = DateTime.now().toString();
      } else {
        String inputDateStr = resp['data'][0]['sTransactionDate'].toString();
        print("${inputDateStr}this is your date");
        DateTime inputDate = DateFormat(
          "dd-MM-yyyy hh:mm:ss",
        ).parse(inputDateStr);

        String outputDateStr = DateFormat("dd/MM/yyyy").format(inputDate);
        outputDateStr2 = DateFormat("dd MMM yyyy").format(inputDate);

        print("${outputDateStr2}this is your date");
      }
    } else {
      print("not working transaction success details");
    }
  }

  redeemRewards() async {
    final prefs = await SharedPreferences.getInstance();
    SID = prefs.getString('sidearn').toString();
    String SIDAdmin = prefs.getString('SID').toString();
    if (getamtiscalled == false) {
      Uploadinvoiceamt = prefs.getString('uploadInvoiceAmt').toString();
    }
    // if (Uploadinvoiceamt == "" || Uploadinvoiceamt == null) {
    //   Uploadinvoiceamt = "0";
    // }
    var filename = prefs.getString('uploadfilename'.toString());
    var Eatg = prefs.getString('uploadetag'.toString());
    print("Eatg$Etagredeem");
    print("Eatg $Eatg");
    var UserID = prefs.getString('GuestID'.toString());
    String inputDate = dateText;

    DateTime date = DateFormat('dd-MM-yyyy').parse(inputDate);
    String outputDate = DateFormat('dd-MMM-yyyy').format(date);
    print(outputDate);
    if (int.parse(availableReward.value.toString()) >=
        int.parse(redeemController.text)) {
      String baseUrl =
          "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/InsertGuestRedeemHistory";
      double damt = double.parse(amountController.text);
      int ddamt = damt.round();
      Map<String, String> param = {
        "sOperationType": "InsertGuestRedeemHistory",
        "sId": SID, //from qr need from available rewards
        "sOutLetId": _mySelection,
        "sMemberShipType":
            smembershipType, //not getting ,need from available rewards
        "iRedeemPoints": redeemController.text.toString(),

        "iRewardEarn": "0",
        "sInvoiceNo": invNoController.text.toString(),
        "sPaymentType":
            "00000000-0000-0000-0000-000000000000", //dont know from where to get or use
        "sMongoId": Eatg.toString(), //default
        "sMongoNew": Etagredeem,
        "sInvoiceDate": outputDate.toString(),
        "sUserId": SIDAdmin.toString(), //dont know from where to get or its use
        "iInvoiceAmount": Uploadinvoiceamt.toString(),
        "sFileNameNew": filename2redeem, //ddamt.toString(),
        "sFileName": filename.toString(),
        "iActualAmount": ddamt.toString(),
      };
      print("${UserID}nk17xx1");

      print("$param this is your param");
      Map<String, String> headers = {"Content-type": "application/json"};
      var body = convert.jsonEncode(param);
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );
      var resp = convert.jsonDecode(response.body);
      print(resp);
      if (response.statusCode == 200) {
        if (resp["statusCode"] == -1 || resp["statusCode"] == "-1") {
          String respmsd = resp["statusMsg"];
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(top: 8),
                title: Text(
                  "Redeem points",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                // subtitle: Text("subtitle"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "$respmsd.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),

                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text("Ok"),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
          // Fluttertoast.showToast(
          //     msg: "$respmsd",
          //     toastLength: Toast.LENGTH_LONG,
          //     gravity: ToastGravity.BOTTOM_LEFT,
          //     timeInSecForIosWeb: 2,
          //     textColor: Colors.black,
          //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
          //     fontSize: 16.0);
        } else if (resp["statusCode"] == 1 || resp["statusCode"] == "1") {
          _getTransactionSuccessDetails();
          statusmsg = resp["statusMsg"];
          var redeemedPointsval = redeemController.text.toString();
          var earnPointsval2 = iEarnReward.toString();
          // sBase64 = resp['data']['sBase64'];
          // Fluttertoast.showToast(
          //     msg:
          //         "You have successfully redeemed $redeemedPointsval points on this transaction.",
          //     toastLength: Toast.LENGTH_LONG,
          //     gravity: ToastGravity.BOTTOM_LEFT,
          //     timeInSecForIosWeb: 2,
          //     textColor: Colors.black,
          //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
          //     fontSize: 16.0);

          // setState(() {

          //   ervisibility = false;
          //   Future.delayed(Duration(seconds: 3), () {
          //     getAvbRewards();
          //     setvisiEarnRedeem();
          //     isVisible2 = true;
          //     finalSaveVisible = true;
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const earnRedeemPoints()),
          //     );
          //     // (route) => true);
          //   });
          // });
          setState(() {
            ervisibility = false;

            Future.delayed(Duration(seconds: 4), () {
              txnSavedAmount = nSavedAmount.toString();
              print("${txnSavedAmount}this is your txnSavedAmount");
              print("${txnInvoiceAmount}this is your txnInvoiceAmount");
              int txnAmountToBePaid = 11;
              if (amountController.text.contains(".")) {
                txnAmountToBePaid =
                    int.parse(
                      amountController.text.substring(
                        0,
                        amountController.text.indexOf("."),
                      ),
                    ) -
                    int.parse(nSavedAmount.toString());
              } else {
                txnAmountToBePaid =
                    int.parse(amountController.text) -
                    int.parse(nSavedAmount.toString());
              }

              showDialog(
                barrierDismissible: false,
                barrierColor: Colors.black,
                context: context,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: Dialog(
                      backgroundColor: Color.fromARGB(0, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 16,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/invoice-bg-01.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        height: MediaQuery.of(context).size.height * 0.66,
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: Column(
                          children: [
                            SizedBox(height: 60),
                            Center(
                              child: Text(
                                'Transaction Details',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 128, 98, 42),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.42,
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Transaction ID"),
                                    Text(
                                      txnId,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 128, 98, 42),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    Text("Transaction Date"),
                                    Text(
                                      outputDateStr2,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 128, 98, 42),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    Text("Check No"),
                                    Text(
                                      txnInvoiceNo,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 128, 98, 42),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    Text("Check Amount"),
                                    Text(
                                      amountController.text,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 128, 98, 42),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    Text("Saved Amount"),
                                    Text(
                                      txnSavedAmount,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 128, 98, 42),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    Text("Amount to be paid"),
                                    Text(
                                      txnAmountToBePaid.toString(),
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 128, 98, 42),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Divider(color: Colors.black),
                                    // Text("Redeemed Point"),
                                    // Text(
                                    //   txnRedeemedPoints,
                                    //   style: TextStyle(
                                    //       color: Color.fromARGB(
                                    //           255, 128, 98, 42),
                                    //       fontSize: 14,
                                    //       fontWeight: FontWeight.bold),
                                    // ),
                                    // Divider(color: Colors.black),
                                    // Text("Available Rewards"),
                                    // Text(
                                    //   txnAvailableReward,
                                    //   style: TextStyle(
                                    //       color: Color.fromARGB(
                                    //           255, 128, 98, 42),
                                    //       fontSize: 14,
                                    //       fontWeight: FontWeight.bold),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Color.fromARGB(255, 128, 98, 42),
                                ),
                              ),
                              onPressed: () {
                                txnDate = "";
                                txnInvoiceNo = "";
                                txnId = "";
                                txnRedeemedPoints = "";
                                txnAvailableReward = "";
                                txnInvoiceAmount = "";
                                txnSavedAmount = "";
                                txnAmountToBePaid = 0;
                                getAvbRewards();
                                setvisiEarnRedeem();
                                isVisible2 = true;
                                finalSaveVisible = true;
                                setvisiEarnRedeem();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => adminHome(),
                                  ),
                                );
                              },
                              child: Text("Okay"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            });
          });
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 8),
            title: Text(
              "Redeem points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Unable To Redeem ! Insufficient Available Rewards.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"),
                  ),
                ],
              ),
            ],
          );
        },
      );
      // Fluttertoast.showToast(
      //     msg: "Unable To Redeem ! Insufficient Available Rewards.",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.BOTTOM_LEFT,
      //     timeInSecForIosWeb: 2,
      //     textColor: Colors.black,
      //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
      //     fontSize: 16.0);
      redeemController.text = "0";
      nSavedAmount = "0";
      isDisabledSave = true;
    }
  }

  verifyotplogin() async {
    isVerifyLoading = false;
    print("OTP$_otpValue");

    // _read();
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/ValidateOtp";
    Map<String, String?> param = {
      "sOperationType": "VerifyOtp",
      "sOtp": _otpValue,
      "sMobile": guestMobileNumber.toString(),
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = jsonEncode(param);
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );

    print(param);
    var resp = convert.jsonDecode(response.body);

    print(resp);
    print("nk17xxx2");
    print(resp['data']["sOutcome"]);
    var statusmsg = resp['data']["sOutcome"];
    if (resp['data']["sOutcome"] == "OTP matched.") {
      print("nk17xxx2");
      redeemRewards();
    } else {
      print("$statusmsg this one");
      _otpValue = '';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 8),
            title: Text(
              "Redeem points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$statusmsg",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"),
                  ),
                ],
              ),
            ],
          );
        },
      );
      // Fluttertoast.showToast(
      //     msg: statusmsg,
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.BOTTOM_LEFT,
      //     timeInSecForIosWeb: 2,
      //     textColor: Colors.black,
      //     backgroundColor: Color.fromARGB(255, 231, 224, 224),
      //     fontSize: 16.0);
    }
    //Navigator.of(context).pop(login);
    // if (resp['data']["sOutcome"] == "OTP Generated Successfully.") {
    //   print("generate otp");

    // } else {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return alert;
    //     },
    //   );
    // }
  }
}
