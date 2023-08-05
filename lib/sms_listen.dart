import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class SmsListen extends StatefulWidget {
  SmsListen({Key key}) : super(key: key);

  @override
  State<SmsListen> createState() => _SmsListenState();
}

class _SmsListenState extends State<SmsListen> {
  OtpFieldController otpbox = OtpFieldController();
  Telephony telephony = Telephony.instance;

  @override
  void initState() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address); //+977981******67, sender nubmer
        print(message.body); //Your OTP code is 34567
        print(message.date); //1659690242000, timestamp

        String sms = message.body.toString(); //get the message

        if (message.address == "CloudOTP") {
          //verify SMS is sent for OTP with sender number
          String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
          //prase code from the OTP sms
          otpbox.set(otpcode.split(""));
          //split otp code to list of number
          //and populate to otb boxes

          setState(() {
            //refresh UI
          });
        } else {
          print("Normal message.");
        }
      },
      listenInBackground: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Autofill OTP From SMS"),
            backgroundColor: Colors.redAccent),
        body: Container(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20),
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Enter OTP Code",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Padding(padding: EdgeInsets.all(20)),
                OTPTextField(
                  controller: otpbox,
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 50,
                  style: TextStyle(fontSize: 17),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onCompleted: (pin) {
                    print("Entered OTP Code: $pin");
                  },
                ),
              ],
            )));
  }
}
