import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

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
                    children = Container(
                      height: 400,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(),
                                  ),
                                  const Center(
                                    child: Text(
                                        "Capteur Température indoor – LoRaWan"),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {
                                        controller!.resumeCamera().then(
                                              (value) => Navigator.pop(context),
                                            );
                                      },
                                      icon: const Icon(Icons.arrow_downward),
                                    ),
                                  )
                                ],
                              )),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                const Image(
                                  image: AssetImage('assets/device.jpg'),
                                  width: 75,
                                  height: 75,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.support_agent),
                                  title: InkWell(
                                    child: const Text(
                                      "Access to the support site",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                    onTap: () => {
                                      _launchURL(
                                          "https://support.nke-watteco.com/indoor_th/")
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(
                                      Icons.settings_applications_outlined),
                                  title: InkWell(
                                    child: const Text(
                                      "Access to the configuration site",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                    onTap: () => {
                                      _launchURL(
                                          "http://support.nke.fr/Lora/LoraEncoder/Index.html")
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.qr_code_2),
                                  title: Text(result!.code),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    children = Container(
                      height: 400,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                        ),
                      ),
                      child: const Text("error"),
                    );
                  } else {
                    children = Container(
                        height: 400,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                          ),
                        ),
                        child: const Center(
                          heightFactor: 50,
                          widthFactor: 50,
                          child:
                              CircularProgressIndicator(color: Colors.orange),
                        ));
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
