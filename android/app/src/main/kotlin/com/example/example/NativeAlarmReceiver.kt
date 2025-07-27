package com.example.example

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class NativeAlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "NativeAlarmReceiver"
        const val EXTRA_ALARM_ID = "alarm_id"
        const val EXTRA_ALARM_LABEL = "alarm_label"
        
        fun scheduleAlarm(context: Context, alarmId: String, label: String, triggerTime: Long) {
            val intent = Intent(context, NativeAlarmReceiver::class.java).apply {
                putExtra(EXTRA_ALARM_ID, alarmId)
                putExtra(EXTRA_ALARM_LABEL, label)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmId.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
            
            Log.d(TAG, "Native alarm scheduled for $alarmId at $triggerTime")
        }
        
        fun cancelAlarm(context: Context, alarmId: String) {
            val intent = Intent(context, NativeAlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmId.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.cancel(pendingIntent)
            
            Log.d(TAG, "Native alarm cancelled for $alarmId")
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Native alarm received!")
        
        val alarmId = intent.getStringExtra(EXTRA_ALARM_ID) ?: "alarm"
        val alarmLabel = intent.getStringExtra(EXTRA_ALARM_LABEL) ?: "Wake up!"
        
        Log.d(TAG, "Alarm fired: $alarmId - $alarmLabel")
        
        // Show the alarm notification with full-screen intent
        AlarmNotificationService.showAlarmNotification(
            context,
            "Alarm",
            alarmLabel,
            alarmId
        )
    }
}
