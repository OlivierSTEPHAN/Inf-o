import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'modal/info.dart';
import 'modal/loading.dart';
import 'modal/error.dart';

class QRViewExample extends StatefulWidget {
  final scanArea;

  const QRViewExample({Key? key, this.scanArea}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState(scanArea);
}

class _QRViewExampleState extends State<QRViewExample>
    with WidgetsBindingObserver {
  double scanArea;
  Barcode? result;
  QRViewController? controller;
  bool isModal = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  _QRViewExampleState(this.scanArea);

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        showModal();
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isModal == true) controller!.resumeCamera();
    }
  }

  void showModal() {
    isModal = true;
    controller!.pauseCamera().then(
          (value) => showModalBottomSheet<void>(
            isScrollControlled: true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return FutureBuilder(
                future: fetchWeb(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
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
            isModal = false;
            controller!.resumeCamera();
          }),
        );
  }

  Future<String> fetchWeb() async {
    Response res = await http.get(Uri.parse(
        "https://world.openfoodfacts.org/api/v0/product/737628064502.json"));

    return jsonDecode(res.body)['code'];
  }
}
