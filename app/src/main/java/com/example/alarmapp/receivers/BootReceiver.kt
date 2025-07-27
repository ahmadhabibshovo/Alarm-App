package com.example.alarmapp.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.alarmapp.data.AlarmDatabase
import com.example.alarmapp.utils.AlarmScheduler

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.intent.action.BOOT_COMPLETED") {
            val alarmDatabase = AlarmDatabase(context)
            val alarmScheduler = AlarmScheduler(context)
            
            // Reschedule all enabled alarms
            alarmDatabase.getAllAlarms()
                .filter { it.isEnabled }
                .forEach { alarm ->
                    alarmScheduler.schedule(alarm)
                }
        }
    }
}
