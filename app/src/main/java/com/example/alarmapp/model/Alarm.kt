package com.example.alarmapp.model

import java.io.Serializable

data class Alarm(
    val id: Int,
    val hour: Int,
    val minute: Int,
    val label: String = "",
    val isEnabled: Boolean = true,
    val repeatDays: List<Int> = emptyList(),  // 0 = Sunday, 1 = Monday, etc.
    val soundUri: String = "",
    val vibrate: Boolean = true
) : Serializable
