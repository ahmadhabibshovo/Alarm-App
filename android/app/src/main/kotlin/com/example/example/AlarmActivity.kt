package com.example.example

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity

class AlarmActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make this activity show over the lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        
        // Create a simple alarm UI
        setContentView(createAlarmView())
        
        // Get alarm details from intent
        val alarmId = intent.getStringExtra("alarmId") ?: "alarm"
        val alarmLabel = intent.getStringExtra("alarmLabel") ?: "Wake up!"
        
        // Update UI with alarm details
        findViewById<TextView>(android.R.id.text1)?.text = alarmLabel
        
        // Handle dismiss button
        findViewById<Button>(android.R.id.button1)?.setOnClickListener {
            finish()
        }
        
        // Handle snooze button (optional)
        findViewById<Button>(android.R.id.button2)?.setOnClickListener {
            // TODO: Implement snooze functionality
            finish()
        }
    }
    
    private fun createAlarmView(): android.view.View {
        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setPadding(50, 50, 50, 50)
            setBackgroundColor(android.graphics.Color.RED)
        }
        
        val titleText = TextView(this).apply {
            id = android.R.id.text1
            text = "ALARM"
            textSize = 32f
            setTextColor(android.graphics.Color.WHITE)
            gravity = android.view.Gravity.CENTER
            setPadding(0, 50, 0, 50)
        }
        
        val dismissButton = Button(this).apply {
            id = android.R.id.button1
            text = "DISMISS"
            textSize = 20f
            setPadding(0, 20, 0, 20)
        }
        
        val snoozeButton = Button(this).apply {
            id = android.R.id.button2
            text = "SNOOZE"
            textSize = 20f
            setPadding(0, 20, 0, 20)
        }
        
        layout.addView(titleText)
        layout.addView(dismissButton)
        layout.addView(snoozeButton)
        
        return layout
    }
    
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Prevent back button from dismissing alarm
        // User must explicitly dismiss the alarm
    }
}
