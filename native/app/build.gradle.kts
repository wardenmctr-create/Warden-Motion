import java.util.Properties
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.serialization")
}

android {
    namespace = "com.warden.motion.app"
    compileSdk = 34
    defaultConfig {
        // Geliştirme süresince eski uygulamayla yan yana kurulsun diye ayrı kimlik.
        // Bütün özellikler yetişince "com.warden.motion" yapılıp eskisinin üstüne kurulacak.
        applicationId = "com.warden.motion.glow"
        minSdk = 26
        targetSdk = 34
        versionCode = 7
        versionName = "0.20"
    }
    // Yayın imzası: anahtar depoda değil, native/keystore.properties + warden.jks (git'e girmez)
    val kp = rootProject.file("keystore.properties")
    signingConfigs {
        if (kp.exists()) create("release") {
            val pr = Properties().apply { kp.inputStream().use { load(it) } }
            storeFile = rootProject.file(pr.getProperty("storeFile"))
            storePassword = pr.getProperty("storePassword")
            keyAlias = pr.getProperty("keyAlias")
            keyPassword = pr.getProperty("keyPassword")
        }
    }
    buildTypes {
        release {
            // Kod küçültme: kullanılmayan kütüphane kodu atılır (APK küçülür, uygulama hızlanır)
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            if (kp.exists()) signingConfig = signingConfigs.getByName("release")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    testOptions { unitTests { isIncludeAndroidResources = true; all { it.systemProperty("robolectric.graphicsMode", "NATIVE"); it.systemProperty("shots.dir", rootProject.file("shots").absolutePath) } } }
    buildFeatures { compose = true }
    // Hazır pack'ler, bayraklar, WardenCB görselleri: eski uygulamanın public klasöründen (tek kopya)
    sourceSets["main"].assets.srcDirs("../../public")
    composeOptions { kotlinCompilerExtensionVersion = "1.5.10" }
}

dependencies {
    val bom = platform("androidx.compose:compose-bom:2024.02.00")
    implementation(bom)
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-core")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("com.caverock:androidsvg-aar:1.4")
    // Bilgisayarda ekran görüntüsü testleri (telefon olmadan kontrol)
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.robolectric:robolectric:4.11.1")
    testImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
