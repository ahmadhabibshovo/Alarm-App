package com.example.example

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object AlarmNotificationService {
    private const val CHANNEL_ID = "alarm_channel"
    
    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Alarms"
            val descriptionText = "Alarm notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(true)
                setShowBadge(true)
            }
            
            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    fun showAlarmNotification(context: Context, title: String, body: String, alarmId: String) {
        createNotificationChannel(context)
        
        // Create intent to launch the full-screen alarm activity
        val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                   Intent.FLAG_ACTIVITY_CLEAR_TASK or
                   Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
            putExtra("alarmId", alarmId)
            putExtra("alarmLabel", body)
        }
        
        val alarmPendingIntent: PendingIntent = PendingIntent.getActivity(
            context, alarmId.hashCode(), alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Also create intent for the main app
        val mainIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("alarm_id", alarmId)
        }
        
        val mainPendingIntent: PendingIntent = PendingIntent.getActivity(
            context, 0, mainIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val dismissIntent = Intent(context, AlarmActionReceiver::class.java).apply {
            action = "DISMISS_ALARM"
            putExtra(AlarmActionReceiver.ALARM_ID, alarmId)
            putExtra(AlarmActionReceiver.NOTIFICATION_ID, alarmId.hashCode())
        }

        val dismissPendingIntent: PendingIntent = PendingIntent.getBroadcast(
            context, alarmId.hashCode(), dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(mainPendingIntent)
            .setFullScreenIntent(alarmPendingIntent, true) // This launches the full-screen alarm
            .addAction(0, "Dismiss", dismissPendingIntent)
            .setVibrate(longArrayOf(0, 1000, 500, 1000))

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(alarmId.hashCode(), builder.build())
        
        // Also try to launch the alarm activity directly for better reliability
        try {
            context.startActivity(alarmIntent)
        } catch (e: Exception) {
            // If we can't start the activity, the notification should still work
        }
    }
    
    fun cancelNotification(context: Context, alarmId: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(alarmId.hashCode())
    }
}
