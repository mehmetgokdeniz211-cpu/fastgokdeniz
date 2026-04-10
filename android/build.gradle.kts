allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Fix for Isar and other plugins requiring namespace
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            project.extensions.getByType<com.android.build.gradle.LibraryExtension>().apply {
                if (namespace == null) {
                    namespace = "com.isar.flutter"
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
