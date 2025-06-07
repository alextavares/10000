package com.habitai.app

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.StrictMode
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.habitai.app.utils.ThreadUtils
import com.habitai.app.BuildConfig

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.habitai.app/native"
    private val TAG = "HabitAI-MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Configurar StrictMode apenas em debug para detectar problemas
        if (BuildConfig.DEBUG) {
            StrictMode.setThreadPolicy(
                StrictMode.ThreadPolicy.Builder()
                    .detectAll()
                    .penaltyLog()
                    .build()
            )
        }
        
        // Garantir que estamos na UI thread
        ThreadUtils.runOnUiThread {
            // Configurar channel para comunicação com Flutter
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkExactAlarmPermission" -> {
                        ThreadUtils.runOnUiThread {
                            result.success(checkExactAlarmPermission())
                        }
                    }
                    "requestExactAlarmPermission" -> {
                        ThreadUtils.runOnUiThread {
                            requestExactAlarmPermission()
                            result.success(true)
                        }
                    }
                    "checkNativeLibrary" -> {
                        val libraryName = call.argument<String>("libraryName") ?: "unknown"
                        ThreadUtils.runOnBackgroundThread {
                            val isLoaded = checkNativeLibrary(libraryName)
                            ThreadUtils.runOnUiThread {
                                result.success(isLoaded)
                            }
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
            
            // Verificar permissões e bibliotecas ao inicializar
            ThreadUtils.runOnBackgroundThread {
                checkAndRequestPermissions()
                checkNativeLibraries()
            }
        }
    }

    private fun checkExactAlarmPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true // Permissão não necessária em versões anteriores
        }
    }

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w(TAG, "Requesting exact alarm permission")
                try {
                    startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM))
                } catch (e: Exception) {
                    Log.e(TAG, "Error requesting exact alarm permission", e)
                }
            }
        }
    }

    private fun checkNativeLibrary(libraryName: String): Boolean {
        return try {
            System.loadLibrary(libraryName)
            Log.i(TAG, "Successfully loaded native library: $libraryName")
            true
        } catch (e: UnsatisfiedLinkError) {
            Log.w(TAG, "Native library not found or failed to load: $libraryName", e)
            false
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error loading native library: $libraryName", e)
            false
        }
    }

    private fun checkAndRequestPermissions() {
        // Verificar permissão de alarme exato
        if (!checkExactAlarmPermission()) {
            Log.w(TAG, "Exact alarm permission not granted")
            // Nota: Não solicitar automaticamente para não interromper a experiência do usuário
            // A solicitação deve ser feita quando necessário
        } else {
            Log.i(TAG, "Exact alarm permission is granted")
        }
    }

    private fun checkNativeLibraries() {
        // Lista de bibliotecas que podem estar sendo procuradas
        val librariesToCheck = listOf("penguin", "c++_shared")
        
        for (library in librariesToCheck) {
            val isLoaded = checkNativeLibrary(library)
            if (!isLoaded) {
                Log.w(TAG, "Native library '$library' is not available - this may cause issues")
            }
        }
    }
}
