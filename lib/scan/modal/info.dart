import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:url_launcher/url_launcher.dart';

Container InfoWidget(BuildContext context) {
  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  return Container(
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
                child: Text("Capteur Température indoor – LoRaWan"),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () => {Navigator.pop(context)},
                  icon: const Icon(Icons.arrow_downward),
                ),
              )
            ],
          ),
        ),
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
                    _launchURL("https://support.nke-watteco.com/indoor_th/")
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_applications_outlined),
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
                title: Text("data"),
              )
            ],
          ),
        )
      ],
    ),
  );
}
