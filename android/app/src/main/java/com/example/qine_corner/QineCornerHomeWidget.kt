package com.example.qine_corner

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class QineCornerHomeWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.qine_corner_widget).apply {
                // Get the data
                val widgetData = HomeWidgetPlugin.getData(context)
                val bookTitle = widgetData.getString("app_widget_current_book", "") ?: ""
                val bookCover = widgetData.getString("app_widget_book_cover", "") ?: ""
                val goalProgress = widgetData.getString("app_widget_goal_progress", "") ?: ""

                // Set the data
                setTextViewText(R.id.widget_book_title, bookTitle)
                setTextViewText(R.id.widget_goal_progress, goalProgress)

                // Set cover image if available
                if (bookCover.isNotEmpty()) {
                    setImageViewResource(R.id.widget_book_cover, context.resources.getIdentifier(
                        bookCover,
                        "drawable",
                        context.packageName
                    ))
                }

                // Set up click intent
                val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_open_app, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
