plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.go"
    compileSdk = 36   // ← changé de 34 à 36

    defaultConfig {
        applicationId = "com.example.go"
        minSdk = flutter.minSdkVersion     // tu peux garder ton minSdk ou changer si nécessaire
        targetSdk = 36  // ← aligné avec compileSdk
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        getByName("release") {
            signingConfig = getByName("debug").signingConfig
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib", "1.8.0"))
}
