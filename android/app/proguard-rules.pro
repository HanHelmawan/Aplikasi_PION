# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Auth
-keepattributes Signature
-keepattributes *Annotation*

# Firestore
-keep class com.google.firestore.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Keep Dart/Flutter entry points
-keep class com.penacode.pion.** { *; }
-keepclassmembers class com.penacode.pion.** { *; }

# Prevent stripping of generic signatures needed by Gson/Firebase
-keepattributes EnclosingMethod

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.**

