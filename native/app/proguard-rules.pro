# SVG çizici (bayraklar) yansıma kullanır
-keep class com.caverock.androidsvg.** { *; }
-dontwarn com.caverock.androidsvg.**
# Proje dosyaları (kotlinx.serialization)
-keepattributes *Annotation*, InnerClasses
-keep,includedescriptorclasses class com.warden.motion.app.model.**$$serializer { *; }
-keepclassmembers class com.warden.motion.app.model.** { *** Companion; kotlinx.serialization.KSerializer serializer(...); }
