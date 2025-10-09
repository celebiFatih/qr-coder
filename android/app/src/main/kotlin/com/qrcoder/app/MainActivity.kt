package com.qrcoder.app

import android.content.Intent
import android.os.Bundle
import android.content.pm.ActivityInfo
import androidx.core.view.WindowCompat 
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowInsetsControllerCompat
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

        // Edge-to-edge (Android 14 ve altına geriye dönük)
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // Sistem çubuk ikon renkleri (açık/koyu)
        val controller = WindowInsetsControllerCompat(window, window.decorView)
        val isLight = (resources.configuration.uiMode and 0x30) == 0x10
        controller.isAppearanceLightStatusBars = isLight
        controller.isAppearanceLightNavigationBars = isLight

        // Telefon <-> Tablet yön kilidi (Manifest'teki PORTRAIT satırını kaldırırsan etkili olur)
        val sw = resources.configuration.smallestScreenWidthDp
        requestedOrientation = if (sw < 600)
            ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        else
            ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED

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
            val intent = Intent(android.provider.Settings.ACTION_WIFI_SETTINGS)
            startActivity(intent)
        }
    }
}
