package com.example.example

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmActionReceiver : BroadcastReceiver() {
    companion object {
        const val ALARM_ID = "ALARM_ID"
        const val NOTIFICATION_ID = "NOTIFICATION_ID"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(ALARM_ID)
        val notificationId = intent.getIntExtra(NOTIFICATION_ID, 0)

        if (alarmId != null && notificationId != 0) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(notificationId)
            Log.d("AlarmActionReceiver", "Dismissed notification for alarm ID: $alarmId")
        }
    }
}
