import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:penthousemumbai/sideMenuWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'login.dart';

var isVerifyLoading = true;
var _cardColour = const Color(0xff282828);
var _bgColour = const Color(0xff1a1a1a);

class scanVoucher extends StatefulWidget {
  const scanVoucher({super.key});

  @override
  State<scanVoucher> createState() => _scanVoucherState();
}

bool scanAnotherVisible = false;
String code = "";
bool scannerVisible = true;
bool voucherScreen = false;
bool isDisabledSubmit = true;
String voucherId = "";
String membershipId = "";
String voucherName = "";
String voucherIdShow = "";
String memberIdShow = "";
String voucherStatus = "";
String voucherFromDate = "";
String voucherToDate = "";
String _otpValue = '';
String MobileNo = "";
setexitScanVoucher() {
  code = "";
  isVerifyLoading = true;
  scanAnotherVisible = false;
  scannerVisible = true;
  voucherScreen = false;
  isDisabledSubmit = true;
  voucherId = "";
  membershipId = "";
  voucherName = "";
  voucherIdShow = "";
  memberIdShow = "";
  voucherStatus = "";
  voucherFromDate = "";
  voucherToDate = "";
}

class _scanVoucherState extends State<scanVoucher> {
  bool _isProcessing = false;
  @override
  void initState() {
    super.initState();
    setexitScanVoucher();
  }

  otplogin() async {
    // _read();
    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/OtpGenerate";
    Map<String, String?> param = {
      "sOperationType": "GENOTP",
      "sIsGenerated": "1",
      "sMobile": MobileNo,
      "sFromMobile": "1",
      "type": "Voucher Redeem",
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
            contentPadding: const EdgeInsets.only(top: 8),
            title: const Text(
              "Redeem points",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: const Column(
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
                    child: const Text("Ok"),
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

  getVoucherDetails() async {
    final prefs = await SharedPreferences.getInstance();
    var UserID = prefs.getString('GuestID'.toString());

    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/InsertGuestVoucherHistory";
    Map<String, String> param = {
      "sOperationType": "InsertGuestVoucherHistory",
      "sId": membershipId.toString().trim(),
      "sVoucherId": voucherId.toString().trim(),
      "iSubmitFlag": "0",
    };

    // {
    //   "sOperationType": "GetGuestVoucherHistory",
    //   "sVoucherId": voucherId.toString().trim(),
    //   "sMemberId": membershipId.toString().trim(),
    //   "iSubmitFlag": "0",
    //   "sUserId": UserID.toString()
    // };

    Map<String, String> headers = {"Content-type": "application/json"};
    String body = convert.jsonEncode(param).toString();
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    print(param);

    var resp = convert.jsonDecode(response.body);
    print("$resp this is your voucher Details");

    if (response.statusCode == 200) {
      setState(() {
        voucherName = resp['data'][0]['sVoucherName'];
        voucherIdShow = resp['data'][0]['sVoucherId'];
        memberIdShow = resp['data'][0]['sMemberId'];
        voucherStatus = resp['data'][0]['sStatus'];
        voucherFromDate = resp['data'][0]['sEffectiveFrom'];
        voucherToDate = resp['data'][0]['sEffectiveTo'];
      });
      if (voucherStatus == "Redeemed") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.only(top: 8),
              title: const Text(
                "Gift Certificate Redemption",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              // subtitle: Text("subtitle"),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Gift Certificate Already Redeemed!",
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
                        Navigator.pop(context);
                      },
                      child: const Text("Ok"),
                    ),
                  ],
                ),
              ],
            );
          },
        );
        scanAnotherVisible = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        home: Scaffold(
          extendBodyBehindAppBar: true,
          drawer: const sideMenuWidget(),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            toolbarHeight: 38,
            flexibleSpace: Container(
              decoration: BoxDecoration(color: _bgColour),
            ),
            backgroundColor: const Color.fromARGB(000, 000, 000, 000),
            elevation: 0,
            title: const Text(
              "Gift Certificate Redemption",
              style: TextStyle(fontSize: 14),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: _bgColour),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 90),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          //Main column
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: scannerVisible,
                              child: Card(
                                color: _cardColour,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    20,
                                    0,
                                    10,
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.75,
                                  width:
                                      MediaQuery.of(context).size.width * 0.94,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: scannerVisible,
                                        child: SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: Image.asset(
                                            "images/penthouse-Logo.png",
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),
                                      const Text(
                                        "Scan Gift Certificate",
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Scan QR to display Gift Certificate Details",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 300,
                                            width: 300,
                                            // child: MobileScanner(
                                            //   allowDuplicates: false,
                                            //   onDetect: (barcode, args) {
                                            //     if (barcode.rawValue ==
                                            //         null) {
                                            //       debugPrint(
                                            //           'Failed to scan Barcode');
                                            //     } else if (barcode.rawValue !=
                                            //             null &&
                                            //         barcode.rawValue!
                                            //             .contains(
                                            //                 "Voucher Id")) {
                                            //       String voucherData =
                                            //           barcode.rawValue
                                            //               .toString();
                                            //       voucherId = voucherData.substring(
                                            //           voucherData.lastIndexOf(
                                            //                   (RegExp(
                                            //                       r' Id:'))) +
                                            //               4,
                                            //           voucherData.indexOf(
                                            //               (RegExp(
                                            //                   r'MembershipId:'))));
                                            //       membershipId = voucherData.substring(
                                            //           voucherData.lastIndexOf(
                                            //                   (RegExp(
                                            //                       r'Id:'))) +
                                            //               3,
                                            //           voucherData.indexOf(
                                            //               (RegExp(
                                            //                   r'MobileNo:'))));
                                            //       MobileNo = voucherData
                                            //           .substring(voucherData
                                            //                   .lastIndexOf(
                                            //                       (RegExp(
                                            //                           r'MobileNo:'))) +
                                            //               9);
                                            //       getVoucherDetails();
                                            //       print(voucherId);
                                            //       print(membershipId);
                                            //       print(MobileNo);
                                            //       // setState(() {
                                            //       //   isVisible2 = true;
                                            //       // });
                                            //       // var parts = barcode.rawValue!.split(':');
                                            //       // var prefix = parts[1].trim();
                                            //       // String code = prefix.toString();

                                            //       debugPrint(
                                            //           'Barcode found! $voucherId');
                                            //       debugPrint(
                                            //           'Barcode found! $membershipId');

                                            //       setState(() {
                                            //         scannerVisible = false;
                                            //         voucherScreen = true;
                                            //         isDisabledSubmit = true;
                                            //       });
                                            //     }
                                            //   },
                                            // ),
                                            child: MobileScanner(
                                              onDetect: (BarcodeCapture capture) async {
                                                if (_isProcessing) return;

                                                for (final barcode
                                                    in capture.barcodes) {
                                                  final rawValue =
                                                      barcode.rawValue;

                                                  if (rawValue == null) {
                                                    debugPrint(
                                                      'Failed to scan Barcode',
                                                    );
                                                    continue;
                                                  }

                                                  if (!rawValue.contains(
                                                    "Voucher Id",
                                                  )) {
                                                    continue;
                                                  }

                                                  // LOCK only after valid QR found
                                                  _isProcessing = true;

                                                  final String voucherData =
                                                      rawValue;

                                                  voucherId = voucherData
                                                      .substring(
                                                        voucherData.lastIndexOf(
                                                              RegExp(r' Id:'),
                                                            ) +
                                                            4,
                                                        voucherData.indexOf(
                                                          RegExp(
                                                            r'MembershipId:',
                                                          ),
                                                        ),
                                                      );

                                                  membershipId = voucherData
                                                      .substring(
                                                        voucherData.lastIndexOf(
                                                              RegExp(r'Id:'),
                                                            ) +
                                                            3,
                                                        voucherData.indexOf(
                                                          RegExp(r'MobileNo:'),
                                                        ),
                                                      );

                                                  MobileNo = voucherData
                                                      .substring(
                                                        voucherData.lastIndexOf(
                                                              RegExp(
                                                                r'MobileNo:',
                                                              ),
                                                            ) +
                                                            9,
                                                      );

                                                  debugPrint(
                                                    'Barcode found! $voucherId',
                                                  );
                                                  debugPrint(
                                                    'Barcode found! $membershipId',
                                                  );
                                                  debugPrint(
                                                    'Barcode found! $MobileNo',
                                                  );

                                                  await getVoucherDetails();

                                                  if (mounted) {
                                                    setState(() {
                                                      scannerVisible = false;
                                                      voucherScreen = true;
                                                      isDisabledSubmit = true;
                                                    });
                                                  }

                                                  //  Throttle AFTER success
                                                  await Future.delayed(
                                                    const Duration(seconds: 2),
                                                  );
                                                  _isProcessing = false;

                                                  return; // stop scanning
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      // TextButton(
                                      //     onPressed: () {
                                      //       setState(() {
                                      //         scannerVisible = false;
                                      //         voucherScreen = true;
                                      //         isDisabledSubmit = false;
                                      //       });

                                      //       // Navigator.push(
                                      //       //   context,
                                      //       //   MaterialPageRoute(
                                      //       //       builder: (context) =>
                                      //       //           const homepage()),
                                      //       // );
                                      //     },
                                      //     child: Text(
                                      //         "Proceed without Scanning!"))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: voucherScreen,
                              child: Column(
                                children: [
                                  Card(
                                    color: _cardColour,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        10,
                                        10,
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.9,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.94,
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 20),
                                          Visibility(
                                            visible: !scannerVisible,
                                            child: SizedBox(
                                              height: 140,
                                              width: 140,
                                              child: Image.asset(
                                                "images/Voucher-Redem-Page-Icon.png",
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Center(
                                            child: Text(
                                              "Gift Certificate Details",
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Visibility(
                                            visible: isDisabledSubmit,
                                            child: Card(
                                              color: const Color.fromARGB(
                                                255,
                                                59,
                                                59,
                                                59,
                                              ),
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                  color: Color(0xff616161),
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Center(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        20,
                                                        20,
                                                        20,
                                                        20,
                                                      ),
                                                  // height: MediaQuery.of(
                                                  //             context)
                                                  //         .size
                                                  //         .height *
                                                  //     0.48,
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.90,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Name ",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 60,
                                                                  right: 3,
                                                                ),
                                                            child: Text(
                                                              " : ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          //   ],
                                                          // ),
                                                          Flexible(
                                                            child: Text(
                                                              voucherName,
                                                              style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(height: 22),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Row(
                                                          //   children: [
                                                          const Text(
                                                            "ID ",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 87,
                                                                  right: 5,
                                                                ),
                                                            child: Text(
                                                              " : ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          //   ],
                                                          // ),
                                                          Flexible(
                                                            child: Text(
                                                              voucherIdShow,
                                                              style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(height: 22),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Row(
                                                          //   children: [
                                                          const Text(
                                                            "Membership Id ",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 1,
                                                                ),
                                                            child: Text(
                                                              " : ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          //   ],
                                                          // ),
                                                          Text(
                                                            " $memberIdShow",
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(height: 22),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Row(
                                                          //   children: [
                                                          const Text(
                                                            "Valid From ",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 32,
                                                                ),
                                                            child: Text(
                                                              " : ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          //   ],
                                                          // ),
                                                          Text(
                                                            " $voucherFromDate",
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      // SizedBox(
                                                      //   height: 6,
                                                      // ),
                                                      const Divider(height: 22),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Row(
                                                          //   children: [
                                                          const Text(
                                                            "Valid Till ",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 47,
                                                                ),
                                                            child: Text(
                                                              " : ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          //   ],
                                                          // ),
                                                          Text(
                                                            " $voucherToDate",
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      // SizedBox(
                                                      //   height: 6,
                                                      // ),
                                                      const Divider(height: 22),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Row(
                                                          //   children: [
                                                          const Text(
                                                            "Status ",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 65,
                                                                ),
                                                            child: Text(
                                                              ": ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          //   ],
                                                          // ),
                                                          Text(
                                                            " $voucherStatus",
                                                            style: TextStyle(
                                                              color:
                                                                  voucherStatus ==
                                                                      "Active"
                                                                  ? const Color.fromARGB(
                                                                      255,
                                                                      0,
                                                                      255,
                                                                      8,
                                                                    )
                                                                  : Colors.red,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Expanded(
                                                            child: MaterialButton(
                                                              // style: ButtonStyle(

                                                              //   backgroundColor:
                                                              //       MaterialStateProperty
                                                              //           .all(Colors
                                                              //               .black87),
                                                              // ),
                                                              onPressed:
                                                                  voucherStatus ==
                                                                      "Active"
                                                                  ? () {
                                                                      isVerifyLoading =
                                                                          true;
                                                                      print(
                                                                        'Submit success',
                                                                      );

                                                                      otplogin();
                                                                    }
                                                                  : null,
                                                              disabledColor:
                                                                  Colors.grey,
                                                              color:
                                                                  isDisabledSubmit
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                              elevation: 10,
                                                              height: 40,

                                                              textColor:
                                                                  isDisabledSubmit
                                                                  ? Colors.white
                                                                  : Colors
                                                                        .black,
                                                              child: Text(
                                                                "Submit",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              setexitScanVoucher;
                                                              Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) =>
                                                                          const scanVoucher(),
                                                                ),
                                                              );
                                                            },
                                                            child: const Text(
                                                              "Scan Another Gift Certificate",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          // TextButton(
                                                          //   onPressed: () {
                                                          //     setexitScanVoucher;
                                                          //     Navigator
                                                          //         .pushReplacement(
                                                          //       context,
                                                          //       MaterialPageRoute(
                                                          //           builder:
                                                          //               (context) =>
                                                          //                   scanVoucher()),
                                                          //     );
                                                          //   },
                                                          //   child: Text(
                                                          //     "Scan Another Voucher",
                                                          //     style: TextStyle(
                                                          //         color: Colors
                                                          //             .white),
                                                          //   ),
                                                          //   color:
                                                          //       Colors.black,
                                                          // ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              10,
                                              16,
                                              10,
                                              16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //   Text(
                                                //     "  Bill Booking No/Cheque No.",
                                                //     style: TextStyle(
                                                //         color: Colors.black,
                                                //         fontSize: 16),
                                                //   ),
                                                //   SizedBox(
                                                //     height: 5,
                                                //   ),
                                                //   SizedBox(
                                                //     height: 50,
                                                //     child: TextFormField(
                                                //       style: TextStyle(
                                                //           color:
                                                //               Colors.black),
                                                //       keyboardType:
                                                //           TextInputType
                                                //               .number,
                                                //       inputFormatters: [
                                                //         FilteringTextInputFormatter
                                                //             .digitsOnly,
                                                //         // LengthLimitingTextInputFormatter(
                                                //         //     ),
                                                //       ],
                                                //       decoration:
                                                //           const InputDecoration(
                                                //         focusedBorder:
                                                //             OutlineInputBorder(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .all(Radius
                                                //                       .circular(
                                                //                           10)),
                                                //           borderSide:
                                                //               BorderSide(
                                                //                   width: 1,
                                                //                   color: Colors
                                                //                       .black),
                                                //         ),
                                                //         focusColor:
                                                //             Colors.black,
                                                //         enabledBorder:
                                                //             OutlineInputBorder(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .all(Radius
                                                //                       .circular(
                                                //                           10)),
                                                //           borderSide:
                                                //               BorderSide(
                                                //                   width: 1,
                                                //                   color: Colors
                                                //                       .black),
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ),
                                                //   SizedBox(
                                                //     height: 10,
                                                //   ),
                                                //   Text(
                                                //     "  Comments.",
                                                //     style: TextStyle(
                                                //         color: Colors.black,
                                                //         fontSize: 16),
                                                //   ),
                                                //   SizedBox(
                                                //     height: 5,
                                                //   ),
                                                //   SizedBox(
                                                //     height: 50,
                                                //     child: TextFormField(
                                                //       style: TextStyle(
                                                //           color:
                                                //               Colors.black),
                                                //       keyboardType:
                                                //           TextInputType
                                                //               .number,
                                                //       inputFormatters: [
                                                //         FilteringTextInputFormatter
                                                //             .digitsOnly,
                                                //         // LengthLimitingTextInputFormatter(
                                                //         //     ),
                                                //       ],
                                                //       decoration:
                                                //           const InputDecoration(
                                                //         focusedBorder:
                                                //             OutlineInputBorder(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .all(Radius
                                                //                       .circular(
                                                //                           10)),
                                                //           borderSide:
                                                //               BorderSide(
                                                //                   width: 1,
                                                //                   color: Colors
                                                //                       .black),
                                                //         ),
                                                //         focusColor:
                                                //             Colors.black,
                                                //         enabledBorder:
                                                //             OutlineInputBorder(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .all(Radius
                                                //                       .circular(
                                                //                           10)),
                                                //           borderSide:
                                                //               BorderSide(
                                                //                   width: 1,
                                                //                   color: Colors
                                                //                       .black),
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ),
                                                //   SizedBox(
                                                //     height: 10,
                                                //   ),
                                                //   Text(
                                                //     "  Choose File",
                                                //     style: TextStyle(
                                                //         color: Colors.black,
                                                //         fontSize: 16),
                                                //   ),
                                                //   SizedBox(
                                                //     height: 2,
                                                //   ),
                                                //   SizedBox(
                                                //     width: 120,
                                                //     child: ElevatedButton(
                                                //       style: ButtonStyle(
                                                //         backgroundColor:
                                                //             MaterialStateProperty
                                                //                 .all(Colors
                                                //                     .black87),
                                                //       ),
                                                //       onPressed: () {},
                                                //       child:
                                                //           Text("CHOOSE FILE"),
                                                //     ),
                                                //   ),
                                                //   SizedBox(
                                                //     height:
                                                //         MediaQuery.of(context)
                                                //                 .size
                                                //                 .height *
                                                //             0.13,
                                                //   ),

                                                // scanAnotherVisible = false;
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
                          ],
                        ),
                      ),
                    ),
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

setVisiScanVoucher() {
  scannerVisible = true;
  voucherScreen = false;
  isDisabledSubmit = true;
}

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

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
      "sMobile": MobileNo,
      // guestMobileNumber.toString()
      "sFromMobile": "1",
      "type": "Voucher Redeem",
      "sIpAddress": "192.168.67.58",
    };
    // var otp = controller.value?.nsn.toString();
    var otp = MobileNo;
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
    var otpmobileno = MobileNo;
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
    // Widget okButton = TextButton(
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => login()),
    //         );
    //   },
    // );
    // AlertDialog alert = AlertDialog(
    //   title: Text("Login"),
    //   content: Text("Unauthorized User"),
    //   actions: [
    //     okButton,
    //   ],
    // );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      // elevation: 100,
      contentPadding: const EdgeInsets.only(left: 20, right: 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: const Color.fromARGB(132, 158, 158, 158),
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
                backgroundColor: const Color.fromARGB(118, 158, 158, 158),
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
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OTP Verification",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Please enter verification code \nwhich is sent to Member's email & Whatsapp",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xff848484)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 60, right: 60),
            child: TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlignVertical: TextAlignVertical.center,
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xff616161)),
                ),
                focusColor: Colors.black,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xff616161)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xff616161)),
                ),
                //   border: OutlineInputBorder(),
                hintStyle: const TextStyle(color: Colors.black, fontSize: 14),
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
          padding: const EdgeInsets.only(top: 8, left: 22, right: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // width: 170,
                margin: const EdgeInsets.only(left: 0),
                child: InkWell(
                  child: Text(
                    '00:$secondsRemaining',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
              Container(
                // width: 80,
                margin: const EdgeInsets.only(left: 0),
                child: InkWell(
                  onTap: () => enableResend ? _resendCode() : null,
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      fontSize: 13,
                      color: enableResend
                          ? Colors.blue[600]
                          : const Color.fromARGB(113, 158, 158, 158),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
                    child: const Text("         Verify         "),
                  )
                : CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.black,
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  redeemVoucher() async {
    final prefs = await SharedPreferences.getInstance();
    var UserID = prefs.getString('GuestID'.toString());

    String baseUrl =
        "https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/Login/GetVoucherHistory";
    Map<String, String> param = {
      "sOperationType": "InsertGuestVoucherHistory",
      "sId": membershipId.toString().trim(),
      "sVoucherId": voucherId.toString().trim(),
      "iSubmitFlag": "1",
    };

    // {
    //   "sOperationType": "GetGuestVoucherHistory",
    //   "sVoucherId": voucherIdShow.toString().trim(),
    //   "sMemberId": memberIdShow.toString().trim(),
    //   "iSubmitFlag": "1",
    //   "sUserId": UserID.toString()
    // };

    Map<String, String> headers = {"Content-type": "application/json"};
    String body = convert.jsonEncode(param).toString();
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );
    print(param);

    var resp = convert.jsonDecode(response.body);
    print("$resp this is your voucher Details");
    setexitScanVoucher();
    if (response.statusCode == 200) {
      // setState(() {
      // voucherName = resp['data'][0]['sVoucherName'];
      // voucherIdShow = resp['data'][0]['sVoucherId'];
      // memberIdShow = resp['data'][0]['sMemberId'];
      // voucherStatus = resp['data'][0]['sStatus'];
      // voucherFromDate = resp['data'][0]['sEffectiveFrom'];
      // voucherToDate = resp['data'][0]['sEffectiveTo'];
      // });
    }
    setexitScanVoucher();
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
      "sMobile": MobileNo,
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
      redeemVoucher();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.only(top: 8),
            title: const Text(
              "Gift Certificate Redemption",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("subtitle"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Gift Certificate Redeemed Successfully.",
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const scanVoucher(),
                        ),
                      );
                    },
                    child: const Text("Ok"),
                  ),
                ],
              ),
            ],
          );
        },
      );
      // redeemRewards();
    } else {
      print("$statusmsg this one");
      _otpValue = '';
      isVerifyLoading = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.only(top: 8),
            title: const Text(
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
                  style: const TextStyle(fontSize: 16),
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
                        isVerifyLoading = true;
                        Navigator.of(context).pop();
                      });
                    },
                    child: const Text("Ok"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }
}
