allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Move root build directory up one level to keep build outputs out of VCS workspace
rootProject.buildDir = rootProject.file("../build")

// Place each subproject build output inside the root build directory under its project name
subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
