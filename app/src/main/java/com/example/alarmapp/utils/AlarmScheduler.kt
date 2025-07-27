package com.example.alarmapp.utils

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.example.alarmapp.model.Alarm
import com.example.alarmapp.receivers.AlarmReceiver
import java.util.Calendar

class AlarmScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    fun schedule(alarm: Alarm) {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, alarm.hour)
            set(Calendar.MINUTE, alarm.minute)
            set(Calendar.SECOND, 0)
            
            // If the time is in the past, schedule for the next day
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.example.alarmapp.ALARM_TRIGGERED"
            putExtra("ALARM_ID", alarm.id)
        }

        val pendingIntentFlags = PendingIntent.FLAG_UPDATE_CURRENT or 
                                  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) 
                                      PendingIntent.FLAG_IMMUTABLE 
                                  else 0

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarm.id,
            intent,
            pendingIntentFlags
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pendingIntent
            )
        }
    }

    fun cancel(alarmId: Int) {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.example.alarmapp.ALARM_TRIGGERED"
        }

        val pendingIntentFlags = PendingIntent.FLAG_NO_CREATE or 
                                 if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) 
                                     PendingIntent.FLAG_IMMUTABLE 
                                 else 0

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            pendingIntentFlags
        )

        pendingIntent?.let {
            alarmManager.cancel(it)
            it.cancel()
        }
    }
}
