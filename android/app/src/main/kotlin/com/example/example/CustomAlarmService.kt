package com.example.example

import android.content.Context
import dev.fluttercommunity.plus.androidalarmmanager.AlarmService
import io.flutter.Log

class CustomAlarmService : AlarmService() {
    
    companion object {
        private const val TAG = "CustomAlarmService"
        
        @JvmStatic
        fun alarmCallback(context: Context, id: Int, params: Map<String, Any>) {
            Log.d(TAG, "Alarm fired! ID: $id, Params: $params")
            
            try {
                val alarmId = params["alarmId"] as? String ?: "alarm"
                val title = params["title"] as? String ?: "Alarm"
                val body = params["body"] as? String ?: "Wake up!"
                
                // Show notification directly using Android notification service
                AlarmNotificationService.showAlarmNotification(context, title, body, alarmId)
                
                Log.d(TAG, "Alarm notification shown for alarm ID: $alarmId")
            } catch (e: Exception) {
                Log.e(TAG, "Error processing alarm: ${e.message}")
            }
        }
    }
}
