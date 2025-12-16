# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver

# Google ML Kit
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.** { *; }

# Realm (ensure it's not stripped if internal rules fail)
-dontwarn io.realm.**
-keep class io.realm.** { *; }

