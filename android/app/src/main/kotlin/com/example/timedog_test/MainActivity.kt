package com.example.timedog_test

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.AudioManager
import android.content.Context

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.timedog_test/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAudioFocusMixMode" -> {
                    // Android에서 오디오 믹스 모드 설정
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    // 음악 재생과 함께 비디오 오디오를 믹스할 수 있도록 설정
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
