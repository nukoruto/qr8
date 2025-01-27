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

                            try {
                                // chmodコマンドを実行
                                String permissions = (readable ? "r" : "-") + 
                                                     (writable ? "w" : "-") +
                                                     (executable ? "x" : "-");
                                String command = "chmod 644 " + file.getAbsolutePath();
                                Process process = Runtime.getRuntime().exec(command);
                                process.waitFor();

                                if (process.exitValue() == 0) {
                                    result.success(true); // 成功
                                } else {
                                    result.success(false); // 失敗
                                }
                            } catch (Exception e) {
                                result.error("CHMOD_FAILED", "Failed to execute chmod: " + e.getMessage(), null);
                            }
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
