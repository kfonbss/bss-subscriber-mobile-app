# Razorpay (razorpay_flutter) — keep the SDK and its payment callbacks so R8
# doesn't strip them in release builds.
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }
-optimizations !method/inlining/
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
