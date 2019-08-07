package com.flutter.flutter_trip;

import android.os.Bundle;

import com.demo.flutter.plugin.asr.AsrPlugin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        registerSelfPlugin();
    }

    private void registerSelfPlugin() {
        AsrPlugin.registerWith(registrarFor("com.demo.flutter.plugin.asr.AsrPlugin"));
    }
}
