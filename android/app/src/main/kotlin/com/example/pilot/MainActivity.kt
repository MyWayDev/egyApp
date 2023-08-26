package com.myway.mor_release

import io.flutter.embedding.android.FlutterActivity
//import android.content.Intent
//import android.provider.Telephony
//import io.flutter.plugin.common.MethodChannel
//import android.os.Bundle



class MainActivity: FlutterActivity() {
        /*     private val CHANNEL = "com.myway.mor_release/sms_handler"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setDefaultSmsHandler") {
                if (Telephony.Sms.getDefaultSmsPackage(this) != packageName) {
                    val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
                    intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, packageName)
                    startActivity(intent)
                    result.success("Success")
                } else {
                    result.error("Error", "Already the default SMS handler", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }*/
}
