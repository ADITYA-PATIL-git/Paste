//@author/nadeem_ahmed_khan_getAvbRewards
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
// ignore: library_prefixes
import 'dart:io' as Io;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:penthousemumbai/adminHome.dart';
import 'package:penthousemumbai/sideMenuWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'uploadParse.dart';

bool getamtiscalled = false;
String Uploadinvoiceamt = "";
bool isoutletchangenotclicked = true;
bool isLoaderVisibleamt = true;
bool firstinvoiceScan = true;
var listitemCs = [];
var listitemCs1 = [];
// bool futureisCalled = false;
var listitemCs2 = [];
var listitemCs3 = [];
var cardColour = Color(0xff282828);
var _bgColour = Color(0xff1a1a1a);
String _mySelection = "c9868ddd-c41f-412a-87ad-a529d98nk17x";
String _selected = 'Select Outlet Namee';
String outletIdFromLogin = "c9868ddd-c41f-412a-87ad-a529d98nk17x";
String outletNameFromLogin = 'Select Outlet Namee';
List outletList = [];
List outletList2 = [];
bool isManualcardLoading = false;
bool isDisabledSave = true;
List<String> list = <String>['Cheque', 'Others'];
String _mySelection3 = "A444CB8B-5AAD-4B4D-8198-FA6C7B082981";
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
late String smembershipType;
bool finalSaveVisible = false;
String Etag2 = "";
String Filename2 = "";

class earnPoints extends StatefulWidget {
  const earnPoints({super.key});

  @override
  State<earnPoints> createState() => _earnPointsState();
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
    if (response.statusCode == 200 && resp['data'] != null) {
      setState(() {
        availableReward.value = resp['data']['iAvailableReward'];
        custname = resp['data']['sName'];
        smembershipType = resp['data']['sMembershipType'];
      });

      Navigator.pop(context);
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
      //     title: const Text('')),
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
                          final code = parts.length > 1 ? parts[1].trim() : '';

                          debugPrint('Barcode found! $code');

                          _save(code);
                          await _getAvbRewards(context);

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
                  MaterialPageRoute(builder: (context) => const earnPoints()),
                );
                setvisiEarn();
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

setvisiEarn() {
  _isVisible = false; //it always must be set to  false but while testing
  isVisible2 = false;
  String mySelection3 = "A444CB8B-5AAD-4B4D-8198-FA6C7B082981";
  //  _selected2 =
  //                                                           listitemCs2[0];
  isoutletchangenotclicked = true;
  img64 = "";
  ranonce = false;
  redeemController.text = "0";
  nSavedAmount = "";
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

class _earnPointsState extends State<earnPoints> {
  late Future<Album> futureAlbum = futureAlbum;
  List data1 = [];
  @override
  void initState() {
    Etag2 = "";
    Filename2 = "";
    getoutletfromloginpage();
    outletList = [];
    super.initState();
    getPaymentType();
    getOutletType();
    // _mySelection = "c9868ddd-c41f-412a-87ad-a529d98nk17x";
    isManualcardLoading = false;
    isDisabledSave = true;
    cardno.text = '';
    // getAvbRewards();
    // if (futureisCalled) {
    //   futureAlbum = fetchAlbum(img64);
    // }
    futureAlbum = fetchAlbum(img64);
    myFocusNode = FocusNode();
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
    print("outletType-----$resp");
    if (response.statusCode == 200) {
      var parsedata = convert.jsonEncode(resp['data']);
      print("outlet ran");
      List result = jsonDecode(parsedata);

      result.insert(0, {
        "sOutletId": "c9868ddd-c41f-412a-87ad-a529d98nk17x",
        "sOutLetName": "Select Outlet Name",
      });
      // result.add(
      //     "{ sOutletId: c9868ddd-c41f-412a-87ad-a529d98nk17x, sTransactionId: null, sRedeem: null, sOutLetName: please select outlet name}");
      print("value-------$result");
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
      print(listitemCs);
      print(listitemCs1);
      //  return TransactionDetails.fromJson(jsonDecode(response.body))..toList();
      //return result.map((data) => paymentTypeDetails.fromJson(data)).toList();
    }
  }

  Future askNA(BuildContext context) async {
    if (amountController.text == "0" || amountController.text == "N/A") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            "The amount is not detected, please scan the bill again or enter details manually.",
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

  getPaymentType() async {
    outletList2 = [];
    listitemCs2 = [];
    listitemCs3 = [];
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
        outletList2 = result;
        outletList2.map((item) {
          listitemCs2.add(item['sParametername'].toString());
          listitemCs3.add(item['sId'].toString());

          return DropdownMenuItem(
            value: item['sId'].toString(),
            child: new Text(item['sParametername'].toString()),
          );
        }).toList();
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
    print("dateText------------$dateText");
    // String formattedDate = "";
    String inputDate = dateText;
    int index = inputDate.indexOf("-");
    print(index);
    // if (index == 2) {
    //   print(1);
    DateTime date = DateFormat('dd-MM-yyyy').parse(inputDate);
    //   String formattedDate = DateFormat('MM-dd-yyyy').format(date);
    // } else {
    //DateTime date = DateTime.parse(inputDate);

    String formattedDate = DateFormat('dd-MMM-yyyy').format(date);
    // }

    print(formattedDate);
    double damt = double.parse(amountController.text);
    int ddamt = damt.round();
    Map<String, String> param = {
      "sOperationType": "GetRewardEarnedWithoutSave",
      "sMemberShipType": smembershipType,
      "sInvoiceDate": formattedDate,
      "iInvoiceAmount": ddamt.toString(),
    };

    Map<String, String> headers = {"Content-type": "application/json"};
    var body = convert.jsonEncode(param);
    print("BODy------------$body");

    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    var resp = convert.jsonDecode(response.body);
    print("EarnRewardPreview$resp");
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
        "sInvoiceDate": dateText,
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
                  "Earn points",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                // subtitle: Text("subtitle"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      resp['data']["sResult"].toString(),
                      textAlign: TextAlign.justify,
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
              "Earn points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Unable To Redeem! Insufficient Available Rewards.",
                  textAlign: TextAlign.justify,
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
      "sCardNumber": cardno.text.toString(),
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
                "Earn points",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              // subtitle: Text("subtitle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Please enter a valid Membership number.",
                    textAlign: TextAlign.justify,
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

  redeemRewards() async {
    print("nk17x");
    final prefs = await SharedPreferences.getInstance();
    SID = prefs.getString('sidearn').toString();
    print("$SID this is your user");
    String SIDAdmin = prefs.getString('SID').toString();
    print("$SIDAdmin this is your admin");
    if (getamtiscalled == false) {
      Uploadinvoiceamt = prefs.getString('uploadInvoiceAmt').toString();
    }
    print("pran $Uploadinvoiceamt");
    var filename = prefs.getString('uploadfilename'.toString());
    var Eatg = prefs.getString('uploadetag'.toString());
    print("Eatg$Etag2");
    print("Eatg$Filename2");
    print("Eatg $Eatg");
    var UserID = prefs.getString('GuestID'.toString());

    // String formattedDate = "";
    String inputDate = dateText;
    int index = inputDate.indexOf("-");
    print(index);
    print("nk17x2");
    //  if (index == '2') {
    DateTime date = DateFormat('dd-MM-yyyy').parse(inputDate);
    // String formattedDate = DateFormat('MM-dd-yyyy').format(date);
    // } else {
    //  DateTime date = DateTime.parse(inputDate);

    String formattedDate = DateFormat('dd-MMM-yyyy').format(date);
    //}
    print("outputDate----$formattedDate");
    if (Uploadinvoiceamt == "N/A") {
      Uploadinvoiceamt = "0";
      print("Uploadinvoiceamt$Uploadinvoiceamt");
    }

    if (int.parse(availableReward.value.toString()) >=
        int.parse(redeemController.text)) {
      print("nk17x3");
      String baseUrl =
          "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/InsertGuestReward";
      double damt = double.parse(amountController.text);
      int ddamt = damt.round();
      Map<String, String> param = {
        "sOperationType": "CheckRetroLogic",
        "sId": SID, //from qr need from available rewards
        "sOutLetId": _mySelection, //dont know ,should get from invoice api
        "sMemberShipType":
            smembershipType, //not getting ,need from available rewards
        "iRedeemPoints": "0",

        "iRewardEarn": iEarnReward.toString(),
        "sInvoiceNo": invNoController.text.toString(),
        "sPaymentType": _mySelection3, //dont know from where to get or use
        "sMongoId": Eatg.toString(),
        "sMongoNew": Etag2, //default
        "sInvoiceDate": formattedDate,
        "sUserId": SIDAdmin.toString(), //dont know from where to get or its use
        "iInvoiceAmount": Uploadinvoiceamt.toString(),
        "sFileName": filename.toString(),
        "sFileNameNew": Filename2,
        "iActualAmount": ddamt.toString(),
      };
      print("$param your paa");
      //formattedDate
      print("actual amt + $Uploadinvoiceamt");
      // print("nk17xxx" +
      //     "1sId" +
      //     SID + //from qr need from available rewards
      //     "2sOutLetId" +
      //     "3C9868DDD-C41F-412A-87AD-A529D98D1AA3" + //dont know ,should get from invoice api
      //     "4sMemberShipType" +
      //     smembershipType + //not getting ,need from available rewards
      //     "5iRedeemPoints" +
      //     "0" +
      //     "6iRewardEarn" +
      //     iEarnReward.toString() +
      //     "7sInvoiceNo" +
      //     invNoController.text.toString() +
      //     "8sPaymentType" +
      //     _mySelection3 + //dont know from where to get or use
      //     "9sMongoId" +
      //     Eatg.toString() + //default
      //     "10sInvoiceDate" +
      //     formattedDate +
      //     "11sUserId" +
      //     UserID.toString() + //dont know from where to get or its use
      //     "12iInvoiceAmount" +
      //     Uploadinvoiceamt +
      //     "13sFileName" +
      //     filename.toString() +
      //     "14iActualAmount" +
      //     ddamt.toString());
      print("nk17x4");
      Map<String, String> headers = {"Content-type": "application/json"};
      var body = convert.jsonEncode(param);
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );
      print(
        "PARAMM------"
        "param",
      );

      var resp = convert.jsonDecode(response.body);
      // print(resp["statusMsg"] + "nk17xz");
      // print(resp.toString() + "nnnn");
      print("pran $resp");
      if (response.statusCode == 200) {
        print("200 is");
        statusmsg = resp["statusMsg"];

        if (resp["statusCode"] == "-1" || resp["statusCode"] == -1) {
          print("nk17x9");
          statusmsg = resp["statusMsg"];
          print(statusmsg);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(top: 8),
                title: Text(
                  "Earn points",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                // subtitle: Text("subtitle"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      statusmsg,
                      textAlign: TextAlign.justify,
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
          //     msg: statusmsg,
          //     toastLength: Toast.LENGTH_LONG,
          //     gravity: ToastGravity.BOTTOM_LEFT,
          //     timeInSecForIosWeb: 2,
          //     textColor: Colors.black,
          //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
          //     fontSize: 16.0);
        } else if (resp["statusCode"] == 1 || resp["statusCode"] == "1") {
          print("nk17x6");
          var redeemedPointsval = redeemController.text.toString();
          var earnPointsval2 = iEarnReward.toString();
          // sBase64 = resp['data']['sBase64'];
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  contentPadding: EdgeInsets.only(top: 8),
                  title: Text(
                    "Earn points",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  // subtitle: Text("subtitle"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "You have successfully earned $earnPointsval2 Reward Points for this transaction.",
                          textAlign: TextAlign.justify,
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
                            setvisiEarn();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => adminHome(),
                              ),
                            );
                          },
                          child: Text("Ok"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
          // Fluttertoast.showToast(
          //     msg:
          //         "You have successfully earned $earnPointsval2 Reward Points on this transaction.",
          //     toastLength: Toast.LENGTH_LONG,
          //     gravity: ToastGravity.BOTTOM_LEFT,
          //     timeInSecForIosWeb: 2,
          //     textColor: Colors.black,
          //     backgroundColor: Color.fromARGB(255, 204, 174, 174),
          //     fontSize: 16.0);

          // setState(() {
          //   _mySelection3 = "A444CB8B-5AAD-4B4D-8198-FA6C7B082981";
          //   ervisibility = false;
          //   Future.delayed(Duration(seconds: 5), () {
          //     getAvbRewards();
          //     setvisiEarn();
          //     isVisible2 = true;
          //     finalSaveVisible = true;
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const adminHome()),
          //     );
          //     // (route) => true);
          //   });
          // });
        }
        // print(statusmsg);
      }
    } else {
      print("nk17x9");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 8),
            title: Text(
              "Earn points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Unable To Redeem! Insufficient Available Rewards.",
                  textAlign: TextAlign.justify,
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
      isDisabledSave = true;
    }
  }

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
      img64 = base64Encode(bytes);
      //img64 is the string base64 converted image
      // final decodedBytes = base64Decode(img64);
      // var file = Io.File(imageTemp.path);
      // file.writeAsBytesSync(decodedBytes);
      // GallerySaver.saveImage(file.path, albumName: "Media");
      if (kDebugMode) {
        print(img64);
      }
      // futureisCalled = true;
      futureAlbum = fetchAlbum(img64);
      setState(() => _isVisible = true);
    } on PlatformException catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => earnPoints()),
      );
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => earnPoints()),
      );
      print('Failed to pick image: $e');
    }
  }

  Future pickImage() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 160,
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          color: cardColour,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                        "Camera",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff848484),
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
                          fontSize: 14,
                          color: Color(0xff848484),
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
    // setState(() {
    //   isLoaderVisibleamt = true;
    // });

    // isLoaderVisibleamt
    //     ?
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Detecting Check Amount"),
        content:
            // isLoaderVisibleamt
            //     ?
            SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
        // : Text(
        //     "",
        //     style: TextStyle(color: Colors.red),
        //   )
      ),
    );
    // : null;
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
    dynamic resp = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("exit1");
      setState(() {
        getamtiscalled = true;
        Etag2 = resp['etag'];
        Filename2 = resp['file_name'];
        String amntna = resp['amount_data'];
        Uploadinvoiceamt = amntna.toString().split(".")[0];
        print("pran $Uploadinvoiceamt");
        print(Etag2);
        print(Filename2);
        amountController.text = amntna.toString();
        isLoaderVisibleamt = false;
        _isVisible = true;
        print("exit2");
      });
      print("exit3");
      Navigator.of(context, rootNavigator: true).pop();
      print("exit4");
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
              "Earn points",
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
    print("exit5");
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
      print("exit6");
      // futureAlbum = fetchAlbum(img649);
      // setState(() => _isVisible = true);
    } on PlatformException catch (e) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => earnPoints()),
      // );
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
      print("exit6");
      // futureAlbum = fetchAlbum(img649);
      // setState(() => _isVisible = true);
    } on PlatformException catch (e) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => earnPoints()),
      // );
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

  String _selected2 = '';

  void showModal2(context) {
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
              height: 120,
              alignment: Alignment.center,
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: listitemCs2.length,
                separatorBuilder: (context, int) {
                  return Divider();
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(listitemCs2[index]),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selected2 = listitemCs2[index];
                        _mySelection3 = listitemCs3[index];
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

  // String _selected = 'Select Outlet Name';

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
                    onTap: () async {
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
        builder: (context, child) {
          //ignore system scale factor
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          extendBodyBehindAppBar: true,
          drawer: sideMenuWidget(),
          appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 38,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: _bgColour,
                // image: DecorationImage(
                //     image: AssetImage('images/App_barBG_Image.jpg'),
                //     fit: BoxFit.fill)
              ),
            ),
            backgroundColor: Color(0x00000000),
            elevation: 0,
            title: const Text("Earn Points", style: TextStyle(fontSize: 14)),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
            iconTheme: const IconThemeData(
              color: Colors.white, // ← drawer icon color
            ),
          ),
          body: DecoratedBox(
            decoration: BoxDecoration(
              // image: DecorationImage(
              //     image: AssetImage('images/BG_image.jpg'), fit: BoxFit.fill),
              color: _bgColour,
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
                      padding: EdgeInsets.fromLTRB(18, 78, 18, 0), //top64
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.start,
                                        // mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 100),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: 0,
                                              right: 10,
                                            ), //icon level padding...
                                            child: Visibility(
                                              visible:
                                                  !isVisible2, //notviceversa......
                                              child: IconButton(
                                                iconSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.6,
                                                onPressed: () {
                                                  setState(() {
                                                    getamtiscalled = false;
                                                    // _selected =
                                                    //     'Select Outlet Name';
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
                                                  Icons.qr_code_scanner_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Visibility(
                                            visible:
                                                !isVisible2, //notviceversa......
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Scan QR to proceed !",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                      Row(
                                        children: [
                                          Visibility(
                                            visible: isVisible2,
                                            child: SizedBox(
                                              height: 24,
                                              child: Image.asset(
                                                "images/Login-User-Icon.png",
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: isVisible2,
                                            child: SizedBox(width: 10),
                                          ),
                                          Visibility(
                                            visible: isVisible2,
                                            child: Text(
                                              custname,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Visibility(
                                            visible:
                                                isVisible2, //notviceversa......
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  getamtiscalled = false;
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
                                                Icons.qr_code_scanner_rounded,
                                                color: Colors.white,
                                                size: 30,
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
                                                    getamtiscalled = false;
                                                    isoutletchangenotclicked =
                                                        true;
                                                    // _selected =
                                                    //     'Select Outlet Name';
                                                    _mySelection3 =
                                                        "A444CB8B-5AAD-4B4D-8198-FA6C7B082981";
                                                    _selected2 = listitemCs2[0];
                                                    setState(() {
                                                      setState(() {
                                                        // _mySelection =
                                                        //     "c9868ddd-c41f-412a-87ad-a529d98nk17x";
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
                                                    color: Colors.white,
                                                    size: 32,
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
                          Visibility(
                            visible: isVisible2,
                            child: Container(
                              margin: EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage(
                                    'images/Earn-pts-banner.png',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: availableReward,
                                builder: (context, value, child) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              availableReward.value.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 38,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                SizedBox(height: 9),
                                                Text(
                                                  " Pts",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 70,
                                          child: Image.asset(
                                            "images/Earn-pts-banner-icon.png",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ), /////////
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
                          //                   print(cardno.text.toString() +
                          //                       "this is card");
                          //                   isManualcardLoading = true;
                          //                   //_savecarddno();
                          //                   getAvbRewardscardno();
                          //                   // setState(() {
                          //                   //   //finalSaveVisible = false;
                          //                   //   // _toast();
                          //                   // });
                          //                 },
                          //                 child: const Text(
                          //                   "Proceed",
                          //                   style: TextStyle(
                          //                       color: Color.fromARGB(
                          //                           255, 0, 0, 0)),
                          //                 ),
                          //               ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Visibility(
                            visible: isVisible2, //notviceversa......
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.77,
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
                                                        SizedBox(height: 18),
                                                        Text(
                                                          "QR scanning is successfully done.",
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
                                                        InkWell(
                                                          onTap: () {
                                                            getamtiscalled =
                                                                false;
                                                            // _selected =
                                                            //     'Select Outlet Name';
                                                            isoutletchangenotclicked =
                                                                true;
                                                            _mySelection3 =
                                                                "A444CB8B-5AAD-4B4D-8198-FA6C7B082981";
                                                            _selected2 =
                                                                listitemCs2[0];
                                                            setState(() {
                                                              setState(() {
                                                                // _mySelection =
                                                                //     "c9868ddd-c41f-412a-87ad-a529d98nk17x";
                                                                firstinvoiceScan =
                                                                    true;
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
                                                            width: 200, //80
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
                                                            fontSize: 15,
                                                            color: Color(
                                                              0xff848484,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        // TextButton(
                                                        //     onPressed:
                                                        //         () => {
                                                        //               Navigator.pushReplacement(
                                                        //                 context,
                                                        //                 MaterialPageRoute(
                                                        //                   builder: (context) => earnPoints(),
                                                        //                 ),
                                                        //               ),
                                                        //               setvisiEarn(),
                                                        //             },
                                                        //     child: Text(
                                                        //         "Go back to Home")),
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
                                                            setvisiEarn();
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
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        left: 5,
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
                                                          _mySelection = getdata
                                                              .invoiceOutlet;
                                                          _selected =
                                                              outletNameFromLogin;
                                                          print(
                                                            "$_selected and $_mySelection",
                                                          );

                                                          print(
                                                            "not working buddy",
                                                          );
                                                        } else {
                                                          if (firstinvoiceScan) {
                                                            firstinvoiceScan =
                                                                false;
                                                            // setState(
                                                            //   () {
                                                            _mySelection = getdata
                                                                .invoiceOutletId; //commented pooja 12-10-23
                                                            // _mySelection = getdata
                                                            // .invoiceOutlet;
                                                            print(
                                                              "outelet-----${getdata.invoiceOutlet}",
                                                            );
                                                            print(
                                                              "outelet-----$_mySelection",
                                                            );
                                                            print(
                                                              "selectedOutletName$_selected",
                                                            );
                                                            print(
                                                              "nadeem$_mySelection",
                                                            );
                                                            print(
                                                              "nadeem$listitemCs",
                                                            );
                                                            print(
                                                              "nadeem$listitemCs1",
                                                            );

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
                                                        dateText = getdata
                                                            .invoiceDate
                                                            .toString();
                                                        firstcall = 0;
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
                                                                          color:
                                                                              Colors.white,
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
                                                            // SizedBox(
                                                            //   height: 4,
                                                            // ),
                                                            // Divider(
                                                            //   color: Color
                                                            //       .fromARGB(
                                                            //           122,
                                                            //           122,
                                                            //           118,
                                                            //           118),
                                                            //   thickness: 0.4,
                                                            // ),
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
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () => {
                                                                    showModal(
                                                                      context,
                                                                    ),
                                                                  },
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
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text(
                                                                  "Payment Type",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .white,
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
                                                                      showModal2(
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
                                                                      _selected2,
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .white,
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
                                                                    color: Colors
                                                                        .white,
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
                                                                      color: Colors
                                                                          .white,
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
                                                                          color:
                                                                              Colors.black,
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
                                                                    color: Colors
                                                                        .white,
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
                                                                      color: Colors
                                                                          .white,
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
                                                                          color:
                                                                              Colors.white,
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
                                                            SizedBox(
                                                              height: 15,
                                                            ),

                                                            Container(
                                                              decoration: BoxDecoration(
                                                                border: Border.all(
                                                                  color: Color(
                                                                    0xff616161,
                                                                  ),
                                                                  width: 0.5,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20,
                                                                    ),
                                                                image: DecorationImage(
                                                                  image: AssetImage(
                                                                    "images/Earn-pts-banner.png",
                                                                  ),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              child: ValueListenableBuilder(
                                                                valueListenable:
                                                                    availableReward,
                                                                builder:
                                                                    (
                                                                      context,
                                                                      value,
                                                                      child,
                                                                    ) {
                                                                      return Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              20,
                                                                            ),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Column(
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      "Earned",
                                                                                      style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: Colors.white,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Visibility(
                                                                                      visible: true,
                                                                                      child: Text(
                                                                                        iEarnReward.toString(),
                                                                                        style: TextStyle(
                                                                                          fontSize: 28,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: Color.fromARGB(
                                                                                            255,
                                                                                            0,
                                                                                            255,
                                                                                            115,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 4,
                                                                                    ),
                                                                                    Text(
                                                                                      "Pts",
                                                                                      style: TextStyle(
                                                                                        fontSize: 16,
                                                                                        color: Colors.white,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              height: 65,
                                                                              child: Image.asset(
                                                                                "images/Earn-pts-footer-banner-icon.png",
                                                                                fit: BoxFit.fitHeight,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                              ),
                                                            ),

                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                    top: 20,
                                                                  ),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Expanded(
                                                                        child: MaterialButton(
                                                                          onPressed:
                                                                              isDisabledSave
                                                                              ? () {
                                                                                  print(
                                                                                    'Submit',
                                                                                  );

                                                                                  if (_mySelection ==
                                                                                          "c9868ddd-c41f-412a-87ad-a529d98nk17x" ||
                                                                                      _selected ==
                                                                                          listitemCs[0] ||
                                                                                      _selected ==
                                                                                          "") {
                                                                                    _selected = listitemCs[0];
                                                                                    _mySelection = "c9868ddd-c41f-412a-87ad-a529d98nk17x";
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder:
                                                                                          (
                                                                                            BuildContext context,
                                                                                          ) {
                                                                                            return AlertDialog(
                                                                                              contentPadding: EdgeInsets.only(
                                                                                                top: 8,
                                                                                              ),
                                                                                              title: Text(
                                                                                                "Earn points",
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                              // subtitle: Text("subtitle"),
                                                                                              content: Column(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                // crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsets.symmetric(
                                                                                                      horizontal: 10,
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      "Outlet name is not detected,Please select outlet name manually.",
                                                                                                      textAlign: TextAlign.justify,
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 16,
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
                                                                                  } else if (getdata.invoiceRedeemable !=
                                                                                          "1" &&
                                                                                      getdata.invoiceRedeemable ==
                                                                                          "0") {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder:
                                                                                          (
                                                                                            BuildContext context,
                                                                                          ) {
                                                                                            return AlertDialog(
                                                                                              contentPadding: EdgeInsets.only(
                                                                                                top: 8,
                                                                                              ),
                                                                                              title: Text(
                                                                                                "Earn points",
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                              // subtitle: Text("subtitle"),
                                                                                              content: Column(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                // crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsets.symmetric(
                                                                                                      horizontal: 10,
                                                                                                    ),
                                                                                                    child: Center(
                                                                                                      child: Padding(
                                                                                                        padding: EdgeInsets.symmetric(
                                                                                                          horizontal: 5,
                                                                                                        ),
                                                                                                        child: Text(
                                                                                                          "Cannot Earn points on this Check, as scanned check is not a Tax Invoice.",
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
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                                                                  } else if (getdata.invoiceDate ==
                                                                                      "N/A") {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder:
                                                                                          (
                                                                                            BuildContext context,
                                                                                          ) {
                                                                                            return AlertDialog(
                                                                                              contentPadding: EdgeInsets.only(
                                                                                                top: 8,
                                                                                              ),
                                                                                              title: Text(
                                                                                                "Earn points",
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                              // subtitle: Text("subtitle"),
                                                                                              content: Column(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                // crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsets.symmetric(
                                                                                                      horizontal: 10,
                                                                                                    ),
                                                                                                    child: Padding(
                                                                                                      padding: EdgeInsets.symmetric(
                                                                                                        horizontal: 10,
                                                                                                      ),
                                                                                                      child: Text(
                                                                                                        "Date is not detected, please scan it again.",
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
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                                                                  } else if (getdata.invoiceBillNo ==
                                                                                      "N/A") {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder:
                                                                                          (
                                                                                            BuildContext context,
                                                                                          ) {
                                                                                            return AlertDialog(
                                                                                              contentPadding: EdgeInsets.only(
                                                                                                top: 8,
                                                                                              ),
                                                                                              title: Text(
                                                                                                "Earn points",
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                              // subtitle: Text("subtitle"),
                                                                                              content: Column(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                // crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsets.symmetric(
                                                                                                      horizontal: 10,
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      "Check number is not detected, please scan it again.",
                                                                                                      textAlign: TextAlign.justify,
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 16,
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
                                                                                  } else if (amountController.text !=
                                                                                              "0" &&
                                                                                          iEarnReward.toString() !=
                                                                                              "0" &&
                                                                                          _mySelection !=
                                                                                              "c9868ddd-c41f-412a-87ad-a529d98nk17x" &&
                                                                                          getdata.invoiceBillNo !=
                                                                                              "N/A" &&
                                                                                          getdata.invoiceRedeemable ==
                                                                                              "1" ||
                                                                                      getdata.invoiceRedeemable ==
                                                                                          "") {
                                                                                    redeemRewards();
                                                                                    print(
                                                                                      'Submit is working00',
                                                                                    );
                                                                                  } else {
                                                                                    print(
                                                                                      'amountController.text---${amountController.text}',
                                                                                    );
                                                                                    print(
                                                                                      'iEarnReward---$iEarnReward',
                                                                                    );
                                                                                    print(
                                                                                      '_mySelection---$_mySelection',
                                                                                    );
                                                                                    print(
                                                                                      'getdata.invoiceBillNo---${getdata.invoiceBillNo}',
                                                                                    );
                                                                                    print(
                                                                                      'getdata.invoiceRedeemable---${getdata.invoiceRedeemable}',
                                                                                    );
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder:
                                                                                          (
                                                                                            BuildContext context,
                                                                                          ) {
                                                                                            return AlertDialog(
                                                                                              contentPadding: EdgeInsets.only(
                                                                                                top: 8,
                                                                                              ),
                                                                                              title: Text(
                                                                                                "Earn points",
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                              // subtitle: Text("subtitle"),
                                                                                              content: Column(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                children: [
                                                                                                  Text(
                                                                                                    "Please Enter Valid Check Details!",
                                                                                                    textAlign: TextAlign.justify,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 16,
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
                                                                                    //  isDisabledSave = true;
                                                                                  }
                                                                                }
                                                                              : null,
                                                                          height:
                                                                              42,
                                                                          disabledColor:
                                                                              Colors.grey,
                                                                          color:
                                                                              isDisabledSave
                                                                              ? _bgColour
                                                                              : Colors.grey,
                                                                          elevation:
                                                                              10,
                                                                          textColor:
                                                                              isDisabledSave
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                          splashColor:
                                                                              Colors.redAccent,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10.0,
                                                                            ),
                                                                            side: BorderSide(
                                                                              color: Color(
                                                                                0xff616161,
                                                                              ),
                                                                              width: 0.2,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            "Proceed",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
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
