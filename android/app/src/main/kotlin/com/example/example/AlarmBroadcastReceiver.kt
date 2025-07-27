package com.example.example

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmBroadcastReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmBroadcastReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Alarm broadcast received")
        
        val alarmId = intent.getStringExtra("alarmId") ?: "alarm"
        val title = intent.getStringExtra("title") ?: "Alarm"
        val body = intent.getStringExtra("body") ?: "Wake up!"
        
        // Show notification directly using our notification service
        AlarmNotificationService.showAlarmNotification(context, title, body, alarmId)
        
        Log.d(TAG, "Alarm notification shown for ID: $alarmId")
    }
}
