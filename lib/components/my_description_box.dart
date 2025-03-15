import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDescriptionBox extends StatelessWidget {
  const MyDescriptionBox({super.key});
  Future<String> getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber') ?? "";
  }

  void support() async {
    String message = "Hello, ";
    String phoneNumber =
        await getPhoneNumber(); // Replace with the restaurant's WhatsApp number
    String whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message.toString())}";

    Uri uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not open WhatsApp.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var myPrimaryTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
    );
    var mySecondTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.only(left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text('For Support', style: myPrimaryTextStyle),
              GestureDetector(
                child: Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: support,
              ),
            ],
          ),

          Column(
            children: [
              Text('15-30 min', style: myPrimaryTextStyle),
              Text('Preparation time', style: mySecondTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}
