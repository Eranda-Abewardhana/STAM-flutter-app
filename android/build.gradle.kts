allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirect build outputs to the root "build" folder (standard Flutter behavior)
rootProject.layout.buildDirectory.set(file("${project.projectDir}/../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get().asFile}/${project.name}"))
}

subprojects {
    // Ensure the :app project is evaluated before plugins
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }

    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            android.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.add("-Xlint:-options")
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
