package com.example.example

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "alarm_notifications"
    private val CHANNEL_ID = "alarm_channel"
    private val NOTIFICATION_ID = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Make sure the activity can be shown over the lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
// ...existing code...
        super.configureFlutterEngine(flutterEngine)

        // Create notification channel
// ...existing code...
        createNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
// ...existing code...
            when (call.method) {
                "showAlarmNotification" -> {
                    val title = call.argument<String>("title") ?: "Alarm"
// ...existing code...
                    val body = call.argument<String>("body") ?: "Wake up!"
                    val alarmId = call.argument<String>("alarmId") ?: "alarm"
                    
                    showAlarmNotification(title, body, alarmId)
// ...existing code...
                    result.success(null)
                }
                "cancelNotification" -> {
// ...existing code...
                    val alarmId = call.argument<String>("alarmId") ?: "alarm"
                    cancelNotification(alarmId)
                    result.success(null)
// ...existing code...
                }
                "scheduleNativeAlarm" -> {
                    val alarmId = call.argument<String>("alarmId") ?: "alarm"
                    val label = call.argument<String>("label") ?: "Wake up!"
                    val triggerTime = call.argument<Long>("triggerTime") ?: 0L
                    
                    NativeAlarmReceiver.scheduleAlarm(this, alarmId, label, triggerTime)
                    result.success(null)
                }
                "cancelNativeAlarm" -> {
                    val alarmId = call.argument<String>("alarmId") ?: "alarm"
                    NativeAlarmReceiver.cancelAlarm(this, alarmId)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
// ...existing code...
                }
            }
        }
    }
// ...existing code...

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
// ...existing code...
            val name = "Alarms"
            val descriptionText = "Alarm notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
// ...existing code...
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(true)
// ...existing code...
                setShowBadge(true)
            }
            
            val notificationManager: NotificationManager =
// ...existing code...
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
// ...existing code...
    }

    private fun showAlarmNotification(title: String, body: String, alarmId: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
// ...existing code...
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("alarm_id", alarmId)
        }
// ...existing code...
        
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this, 0, intent,
// ...existing code...
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val dismissIntent = Intent(this, AlarmActionReceiver::class.java).apply {
            action = "DISMISS_ALARM"
            putExtra(AlarmActionReceiver.ALARM_ID, alarmId)
            putExtra(AlarmActionReceiver.NOTIFICATION_ID, alarmId.hashCode())
        }

        val dismissPendingIntent: PendingIntent = PendingIntent.getBroadcast(
            this, alarmId.hashCode(), dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(pendingIntent)
            .setFullScreenIntent(pendingIntent, true)
            .addAction(0, "Dismiss", dismissPendingIntent)
            .setVibrate(longArrayOf(0, 1000, 500, 1000))

// ...existing code...
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(alarmId.hashCode(), builder.build())
    }

    private fun cancelNotification(alarmId: String) {
// ...existing code...
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(alarmId.hashCode())
    }
}
