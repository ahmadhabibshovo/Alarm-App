package com.example.alarmapp.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import com.example.alarmapp.data.AlarmDatabase
import com.example.alarmapp.services.AlarmService

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "com.example.alarmapp.ALARM_TRIGGERED") {
            val alarmId = intent.getIntExtra("ALARM_ID", -1)
            if (alarmId != -1) {
                val alarmDatabase = AlarmDatabase(context)
                val alarm = alarmDatabase.getAlarm(alarmId)
                
                alarm?.let {
                    // Start the service to play the alarm
                    val serviceIntent = Intent(context, AlarmService::class.java).apply {
                        putExtra("ALARM_ID", alarmId)
                    }
                    
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                }
            }
        }
    }
}
