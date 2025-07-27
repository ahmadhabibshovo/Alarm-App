package com.example.alarmapp.data

import android.content.Context
import android.content.SharedPreferences
import com.example.alarmapp.model.Alarm
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class AlarmDatabase(context: Context) {
    private val sharedPreferences: SharedPreferences = context.getSharedPreferences("alarms", Context.MODE_PRIVATE)
    private val gson = Gson()

    fun saveAlarm(alarm: Alarm) {
        val alarms = getAllAlarms().toMutableList()
        val existingIndex = alarms.indexOfFirst { it.id == alarm.id }
        
        if (existingIndex != -1) {
            alarms[existingIndex] = alarm
        } else {
            alarms.add(alarm)
        }
        
        saveAllAlarms(alarms)
    }

    fun deleteAlarm(alarmId: Int) {
        val alarms = getAllAlarms().toMutableList()
        alarms.removeIf { it.id == alarmId }
        saveAllAlarms(alarms)
    }

    fun getAlarm(alarmId: Int): Alarm? {
        return getAllAlarms().find { it.id == alarmId }
    }

    fun getAllAlarms(): List<Alarm> {
        val alarmsJson = sharedPreferences.getString("alarms_data", null) ?: return emptyList()
        val type = object : TypeToken<List<Alarm>>() {}.type
        return gson.fromJson(alarmsJson, type)
    }

    private fun saveAllAlarms(alarms: List<Alarm>) {
        val alarmsJson = gson.toJson(alarms)
        sharedPreferences.edit().putString("alarms_data", alarmsJson).apply()
    }
}
