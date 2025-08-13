plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace = "com.example.teacher_attendance"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.teacher_attendance"
        minSdk = 21
        targetSdk = 34
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM - keeps all Firebase libraries in sync
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    
    // Firebase Analytics (optional)
    implementation("com.google.firebase:firebase-analytics")
    
    // Firebase Firestore (for storing Teacher name & mobile)
    implementation("com.google.firebase:firebase-firestore")
}

// plugins {
//     // id("com.android.application") version "8.7.0" apply false
//     // id("com.android.library") version "8.7.0" apply false
//     // id("org.jetbrains.kotlin.android") version "1.9.0" apply false
//     // id("com.google.gms.google-services") version "4.3.15" apply false // change here

//     id("com.android.application")
//     id("com.android.library")
//     id("org.jetbrains.kotlin.android")
//     id("com.google.gms.google-services")

// }

// android {
//     namespace = "com.example.teacher_attendance"
//     // compileSdk = flutter.compileSdkVersion
//     // ndkVersion = flutter.ndkVersion
//     compileSdk = 34
//     defaultConfig {
//         // minSdk = 21
//         // targetSdk = 34
//         applicationId = "com.example.teacher_attendance"
//         minSdk = 21
//         targetSdk = 34
//         versionCode = 1
//         versionName = "1.0.0"
//     }

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_11
//         targetCompatibility = JavaVersion.VERSION_11
//     }

//     kotlinOptions {
//         jvmTarget = JavaVersion.VERSION_11.toString()
//     }

//     defaultConfig {
//         // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//         applicationId = "com.example.teacher_attendance"
//         // You can update the following values to match your application needs.
//         // For more information, see: https://flutter.dev/to/review-gradle-config.
//         minSdk = flutter.minSdkVersion
//         targetSdk = flutter.targetSdkVersion
//         versionCode = flutter.versionCode
//         versionName = flutter.versionName
//     }

//     buildTypes {
//         release {
//             // TODO: Add your own signing config for the release build.
//             // Signing with the debug keys for now, so `flutter run --release` works.
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }
// }

// flutter {
//     source = "../.."
// }
// //added
// dependencies {
//     // Firebase BoM - keeps all Firebase libraries in sync
//     implementation(platform("com.google.firebase:firebase-bom:34.1.0"))

//     // Firebase Analytics (optional)
//     implementation("com.google.firebase:firebase-analytics")

//     // Firebase Firestore (for storing Teacher name & mobile)
//     implementation("com.google.firebase:firebase-firestore")
// }
// apply(plugin = "com.google.gms.google-services")

