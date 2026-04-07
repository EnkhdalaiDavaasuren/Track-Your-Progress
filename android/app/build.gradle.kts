import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") 
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // Must match your Firebase console exactly
    namespace = "com.teamninik.trackyourprogress"
    
    // Satisfies requirements for shared_preferences, image_picker, etc.
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        applicationId = "com.teamninik.trackyourprogress"
        // MinSDK 23 is required for many modern PDF and Firebase features
        minSdk = flutter.minSdkVersion 
        targetSdk = 35 
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // RELEASE FIX: Prevents crash if the app has too many methods (Firebase/PDF/Fonts)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // Set to false to prevent R8 from accidentally deleting Firebase code
            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Multidex support for Android
    implementation("androidx.multidex:multidex:2.0.1")

    // Firebase BOM and specific requirements
    implementation(platform("com.google.firebase:firebase-bom:34.11.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Required for older Android versions to handle new Java features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
