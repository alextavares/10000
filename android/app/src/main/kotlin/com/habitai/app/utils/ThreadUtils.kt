package com.habitai.app.utils

import android.os.Handler
import android.os.Looper
import android.util.Log

/**
 * Utilitário para gerenciar threads e evitar erros de Looper
 */
object ThreadUtils {
    private const val TAG = "HabitAI-ThreadUtils"

    /**
     * Executa código na UI thread de forma segura
     */
    fun runOnUiThread(action: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            // Já estamos na UI thread
            action()
        } else {
            // Postar para a UI thread
            Handler(Looper.getMainLooper()).post(action)
        }
    }

    /**
     * Executa código em background thread de forma segura
     */
    fun runOnBackgroundThread(action: () -> Unit) {
        Thread {
            try {
                // Preparar Looper se necessário
                if (Looper.myLooper() == null) {
                    Looper.prepare()
                }
                action()
            } catch (e: Exception) {
                Log.e(TAG, "Error in background thread", e)
            }
        }.start()
    }

    /**
     * Verifica se estamos na UI thread
     */
    fun isMainThread(): Boolean {
        return Looper.myLooper() == Looper.getMainLooper()
    }

    /**
     * Cria um Handler de forma segura
     */
    fun createSafeHandler(looper: Looper? = null): Handler? {
        return try {
            val targetLooper = looper ?: Looper.myLooper() ?: Looper.getMainLooper()
            Handler(targetLooper)
        } catch (e: Exception) {
            Log.e(TAG, "Error creating handler", e)
            null
        }
    }
}
