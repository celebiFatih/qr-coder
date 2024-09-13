package com.qrcoder.app

import android.content.Intent
import android.os.Bundle
import android.content.pm.ActivityInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.qrcoder.app/app"
    private var sharedText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedText" -> {
                    result.success(sharedText ?: "")
                    sharedText = null // Paylaşılan metni bir kez işledikten sonra temizle
                }
                "openWifiSettings" -> {
                    openWifiSettings()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (Intent.ACTION_SEND == intent.action && intent.type != null) {
            if ("text/plain" == intent.type) {
                sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            }
        }
    }

    private fun openWifiSettings() {
        try {
            // Özel Wi-Fi ayarlarını açmayı dene
            val intent = Intent(Intent.ACTION_MAIN)
            intent.setClassName("com.android.settings", "com.android.settings.wifi.WifiSettings")
            startActivity(intent)
        } catch (e: Exception) {
            // Hata durumunda genel Wi-Fi ayarları sayfasını aç
            val intent = Intent(Intent.ACTION_VIEW)
            intent.action = android.provider.Settings.ACTION_WIFI_SETTINGS
            startActivity(intent)
        }
    }
}
