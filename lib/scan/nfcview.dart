import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'modal/info.dart';
import 'modal/loading.dart';
import 'modal/error.dart';

class NFCViewExample extends StatefulWidget {
  final scanArea;

  const NFCViewExample({Key? key, this.scanArea}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NFCViewExampleState();
}

class _NFCViewExampleState extends State<NFCViewExample> {
  String nfcResult = "";
  _NFCViewExampleState();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: NfcManager.instance.isAvailable(),
      builder: (context, ss) => ss.data != true
          ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
          : Flex(
              direction: Axis.vertical,
              children: [
                Expanded(flex: 1, child: Container()),
                const CircleAvatar(
                  child: Icon(Icons.phone_android_sharp),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text("Hold your phone next to the device"),
                Expanded(flex: 3, child: Container())
              ],
            ),
    );
  }

  @override
  void initState() {
    _tagRead();
    super.initState();
  }

  void showModalNFC() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: fetchWeb(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            Widget children;
            if (snapshot.hasData) {
              children = InfoWidget(context);
            } else if (snapshot.hasError) {
              children = const CustomErrorWidget();
            } else {
              children = const LoadingWidget();
            }
            return children;
          },
        );
      },
    ).whenComplete(() {
      nfcResult = "";
    });
  }

  Future<String> fetchWeb() async {
    Response res = await http.get(Uri.parse(
        "https://world.openfoodfacts.org/api/v0/product/737628064502.json"));

    return jsonDecode(res.body)['code'];
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      log(tag.data.toString());
      var buffer = tag.data['ndef']['cachedMessage']['records'][0]['payload'];

      String str = "";
      for (var item in buffer) {
        str += String.fromCharCode(item);
      }

      nfcResult = str;

      showModalNFC();
    });
  }
}
