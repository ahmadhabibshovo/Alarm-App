package com.example.example

import android.content.Context
import dev.fluttercommunity.plus.androidalarmmanager.AlarmService

class CustomAlarmCallback {
    companion object {
        @JvmStatic
        fun onAlarmFired(context: Context, id: Int, params: Map<String, Any>) {
            val alarmId = params["alarmId"] as? String ?: "alarm"
            val label = params["label"] as? String ?: "Wake up!"
            
            // Show the alarm notification with full-screen intent
            AlarmNotificationService.showAlarmNotification(
                context,
                "Alarm",
                label,
                alarmId
            )
        }
    }
}
