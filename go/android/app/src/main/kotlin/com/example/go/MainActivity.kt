package com.example.go

import android.content.Intent
import android.provider.Settings
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val WIFI_CHANNEL = "com.example.localshare/wifi"
    private val DEVICE_CHANNEL = "com.example.localshare/device"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Channel pour les paramètres WiFi
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIFI_CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "openWifiSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Impossible d'ouvrir les paramètres WiFi", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Channel pour le nom de l'appareil
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "getDeviceName" -> {
                    try {
                        result.success(getDeviceName())
                    } catch (e: Exception) {
                        result.error("ERROR", "Impossible d'obtenir le nom de l'appareil", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getDeviceName(): String {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                Settings.Global.getString(contentResolver, "device_name") ?:
                Build.MANUFACTURER + " " + Build.MODEL
            } else {
                Build.MANUFACTURER + " " + Build.MODEL
            }
        } catch (e: Exception) {
            "Device-${Build.MODEL}"
        }
    }
}