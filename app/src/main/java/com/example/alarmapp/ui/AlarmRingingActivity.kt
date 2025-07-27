package com.example.alarmapp.ui

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.alarmapp.R
import com.example.alarmapp.data.AlarmDatabase
import com.example.alarmapp.services.AlarmService
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmRingingActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make sure the activity is shown on the lock screen
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        
        setContentView(R.layout.activity_alarm_ringing)
        
        val alarmId = intent.getIntExtra("ALARM_ID", -1)
        if (alarmId != -1) {
            val alarmDatabase = AlarmDatabase(this)
            val alarm = alarmDatabase.getAlarm(alarmId)
            
            alarm?.let {
                // Display alarm information
                findViewById<TextView>(R.id.timeTextView).text = 
                    String.format("%02d:%02d", it.hour, it.minute)
                findViewById<TextView>(R.id.labelTextView).text = 
                    it.label.ifEmpty { "Alarm" }
            }
            
            // Display current date
            val dateFormat = SimpleDateFormat("EEEE, MMMM d", Locale.getDefault())
            findViewById<TextView>(R.id.dateTextView).text = dateFormat.format(Date())
            
            // Set up dismiss button
            findViewById<Button>(R.id.dismissButton).setOnClickListener {
                stopAlarmService()
                finish()
            }
            
            // Set up snooze button
            findViewById<Button>(R.id.snoozeButton).setOnClickListener {
                // Implement snooze functionality
                stopAlarmService()
                // TODO: Schedule a new alarm for 5-10 minutes later
                finish()
            }
        } else {
            // No valid alarm ID, close the activity
            finish()
        }
    }
    
    private fun stopAlarmService() {
        val serviceIntent = Intent(this, AlarmService::class.java)
        stopService(serviceIntent)
    }
    
    override fun onBackPressed() {
        // Prevent back button from dismissing the alarm without interaction
        // Do nothing
    }
}
