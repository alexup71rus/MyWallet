package com.example.mywallet

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mywallet/intent"
    private var initialIntentData: String? = null
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialIntent" -> {
                        result.success(initialIntentData)
                        initialIntentData = null // Clear after reading
                    }
                    else -> result.notImplemented()
                }
            }
        }

        // Handle initial intent
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent ?: return

        val filePath = when (intent.action) {
            Intent.ACTION_VIEW -> {
                // Opened via file manager or deep link
                intent.data?.let { copyUriToTempFile(it) }
            }
            Intent.ACTION_SEND -> {
                // Shared to the app
                (intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))?.let { copyUriToTempFile(it) }
            }
            else -> null
        }

        filePath?.let {
            if (methodChannel != null) {
                // App is running, send via method channel
                methodChannel?.invokeMethod("onNewIntent", it)
            } else {
                // App is starting, store for later
                initialIntentData = it
            }
        }
    }

    private fun copyUriToTempFile(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val tempFile = File(cacheDir, "temp.pkpass")
            
            FileOutputStream(tempFile).use { output ->
                inputStream.copyTo(output)
            }
            inputStream.close()
            
            tempFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
