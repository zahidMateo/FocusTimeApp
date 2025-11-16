package com.example.pomodoro_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class TaskWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.task_widget)

            // Formato de fecha
            val dateFormat = SimpleDateFormat("dd MMM", Locale("es", "ES"))
            views.setTextViewText(R.id.widget_date, dateFormat.format(Date()))

            // Leer tareas desde SharedPreferences
            val prefs: SharedPreferences = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )

            val tasksJson = prefs.getString("flutter.tasks", null)

            if (tasksJson != null) {
                try {
                    val tasksArray = JSONArray(tasksJson)
                    val todayTasks = getTodayTasks(tasksArray)

                    if (todayTasks.isEmpty()) {
                        views.setTextViewText(R.id.widget_empty_state, "No hay tareas para hoy")
                        views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
                        views.setViewVisibility(R.id.widget_task_list, View.GONE)
                    } else {
                        views.setViewVisibility(R.id.widget_empty_state, View.GONE)
                        views.setViewVisibility(R.id.widget_task_list, View.VISIBLE)

                        // Mostrar hasta 5 tareas
                        val tasksToShow = todayTasks.take(5)
                        val summary = "${tasksToShow.size} ${if (tasksToShow.size == 1) "tarea" else "tareas"} para hoy"
                        views.setTextViewText(R.id.widget_title, summary)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    views.setTextViewText(R.id.widget_empty_state, "Error al cargar tareas")
                    views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
                }
            } else {
                views.setTextViewText(R.id.widget_empty_state, "No hay tareas")
                views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getTodayTasks(tasksArray: JSONArray): List<JSONObject> {
            val today = Calendar.getInstance()
            val todayDay = today.get(Calendar.DAY_OF_WEEK)
            // Convertir de Calendar (Domingo=1) a nuestro formato (Lunes=1)
            val ourDayFormat = if (todayDay == 1) 7 else todayDay - 1

            val result = mutableListOf<JSONObject>()

            for (i in 0 until tasksArray.length()) {
                val task = tasksArray.getJSONObject(i)
                var addedToResult = false

                // Verificar si fue creada hoy
                if (task.has("createdAt") && !task.isNull("createdAt")) {
                    val createdAt = task.getString("createdAt")
                    val createdDate = Calendar.getInstance()
                    try {
                        createdDate.time = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US).parse(createdAt)!!

                        if (createdDate.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                            createdDate.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)) {
                            result.add(task)
                            addedToResult = true
                        }
                    } catch (e: Exception) {
                        // Intentar con formato ISO 8601 con milisegundos
                        try {
                            createdDate.time = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).parse(createdAt)!!

                            if (createdDate.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                                createdDate.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)) {
                                result.add(task)
                                addedToResult = true
                            }
                        } catch (e2: Exception) {
                            e2.printStackTrace()
                        }
                    }
                }

                // Verificar si es tarea programada para hoy (solo si no se agregó ya)
                if (!addedToResult && task.has("scheduledFor") && !task.isNull("scheduledFor")) {
                    val scheduledFor = task.getString("scheduledFor")
                    val taskDate = Calendar.getInstance()
                    try {
                        taskDate.time = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US).parse(scheduledFor)!!

                        if (taskDate.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                            taskDate.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)) {
                            result.add(task)
                            addedToResult = true
                        }
                    } catch (e: Exception) {
                        try {
                            taskDate.time = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).parse(scheduledFor)!!

                            if (taskDate.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                                taskDate.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)) {
                                result.add(task)
                                addedToResult = true
                            }
                        } catch (e2: Exception) {
                            e2.printStackTrace()
                        }
                    }
                }

                // Verificar si es tarea repetida para hoy (solo si no se agregó ya)
                if (!addedToResult && task.has("repeatDays")) {
                    val repeatDays = task.getJSONArray("repeatDays")
                    for (j in 0 until repeatDays.length()) {
                        if (repeatDays.getInt(j) == ourDayFormat) {
                            result.add(task)
                            break
                        }
                    }
                }
            }

            return result
        }
    }
}
