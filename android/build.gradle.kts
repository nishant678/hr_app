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
}

subprojects {
    afterEvaluate {
        if (project.name == "isar_flutter_libs") {
            project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                namespace = "com.example.hr_app.isar_flutter_libs"
            }
            tasks.matching { it.name.startsWith("preBuild") }.configureEach {
                doFirst {
                    val manifest = file("src/main/AndroidManifest.xml")
                    if (manifest.exists()) {
                        val text = manifest.readText()
                        val cleaned = text.replace("""package="dev.isar.isar_flutter_libs"""", "")
                        if (text != cleaned) {
                            manifest.writeText(cleaned)
                            logger.warn("Patched AndroidManifest.xml for ${project.name}")
                        }
                    }
                }
            }
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
