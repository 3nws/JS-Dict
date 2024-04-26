package io.github.petlyh.jsdict

import io.flutter.embedding.android.FlutterActivity

import android.app.ActivityManager
import android.content.Context
import android.os.Bundle
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    // https://github.com/flutter/flutter/issues/66212#issuecomment-924980973
    protected override fun onPause() {
        super.onPause()
        try {
            java.lang.Thread.sleep(200);
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }

    private val CHANNEL = "io.github.petlyh.jsdict"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getIntent") {
                val intent = getIntent()
                val action = intent.action
                if (Intent.ACTION_PROCESS_TEXT == action) {
                    val selectedText = intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
                    result.success(mapOf("action" to action, "text" to selectedText))
                } else {
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
