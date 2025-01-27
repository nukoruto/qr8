package com.example.qr8; // パッケージ名をプロジェクトに合わせて変更してください

import android.os.Environment;
import java.io.File;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "file_permissions";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("setFilePermissions")) {
                        String path = call.argument("path");
                        Boolean readable = call.argument("readable");
                        Boolean writable = call.argument("writable");
                        Boolean executable = call.argument("executable");

                        if (path != null) {
                            File file = new File(path);
                            boolean success = file.setReadable(readable != null ? readable : true) &&
                                              file.setWritable(writable != null ? writable : true) &&
                                              file.setExecutable(executable != null ? executable : false);

                            result.success(success);
                        } else {
                            result.error("INVALID_PATH", "File path is null", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }
}
