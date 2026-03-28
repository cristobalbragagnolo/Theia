// CORRECCIÓN: Se añade la importación que faltaba para la clase Properties.
// El error "Unresolved reference: util" ocurre porque Kotlin no sabía dónde encontrar "java.util.Properties".
import java.util.Properties

plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

fun localProperties(): Properties {
    val properties = Properties()
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { properties.load(it) }
    }
    return properties
}

val flutterVersionCode = localProperties().getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties().getProperty("flutter.versionName") ?: "1.0"

val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.example.theia"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.theia"
        minSdk = 21
        targetSdk = 35
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// CORRECCIÓN: Se añade el bloque de dependencias y la librería de TensorFlow Lite.
// Esto es necesario para resolver los errores "Unresolved reference: tensorflow" y "Unresolved reference: Interpreter"
// que ocurren en tu archivo MainActivity.kt.
dependencies {
    implementation(kotlin("stdlib"));
    implementation("org.tensorflow:tensorflow-lite:2.12.0")
    // LÍNEA CORRECTA
    //implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.23")
    // LÍNEA CORRECTA
    //implementation("org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version")

    // Si también usas las librerías de soporte o de delegados de GPU, añádelas aquí.
    // implementation("org.tensorflow:tensorflow-lite-support:0.4.3")
    // implementation("org.tensorflow:tensorflow-lite-gpu:2.12.0")
}
