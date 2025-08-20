# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep Stripe Financial Connections classes
-keep class com.stripe.android.financialconnections.** { *; }
-dontwarn com.stripe.android.financialconnections.**

# Keep all Stripe classes to prevent R8 issues
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Keep Google Play Core classes
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Flutter and Dart related classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep generic signatures; needed for correct type resolution
-keepattributes Signature

# Keep InnerClasses; needed for accessing outer class from inner class
-keepattributes InnerClasses,EnclosingMethod

# Keep annotations
-keepattributes *Annotation*

# Specific rules from missing_rules.txt
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheet$Companion
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheet$Configuration
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheet
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheetResult$Canceled
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheetResult$Completed
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheetResult$Failed
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheetResult
-dontwarn com.stripe.android.financialconnections.FinancialConnectionsSheetResultCallback
-dontwarn com.stripe.android.financialconnections.R$drawable
-dontwarn com.stripe.android.financialconnections.model.BankAccount
-dontwarn com.stripe.android.financialconnections.model.FinancialConnectionsAccount
-dontwarn com.stripe.android.financialconnections.model.FinancialConnectionsSession
-dontwarn com.stripe.android.financialconnections.model.PaymentAccount

# Play Core rules from missing classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
