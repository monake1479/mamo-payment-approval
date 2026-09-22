plugins {
    id("com.android.application")
    // Flutter's plugin requires the Android application plugin to be applied first.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.danieloblak.mamo_payment_approval_challenge"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "mamo.payment.approval"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        resValues = true
    }

    // Per owner decision (2026-09-21) every flavor ships the single "Mamo Approval"
    // installation identity `mamo.payment.approval`; see ADR 0007. Flavors remain
    // for entry-point/scheme selection but no longer differ in id or launcher name,
    // so dev/staging/prod cannot be installed side by side.
    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            resValue("string", "app_name", "Mamo Approval")
        }
        create("staging") {
            dimension = "environment"
            resValue("string", "app_name", "Mamo Approval")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Mamo Approval")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
