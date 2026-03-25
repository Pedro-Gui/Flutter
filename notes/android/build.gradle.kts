allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    val project = this
    
    // Função que aplica a correção do namespace
    val applyNamespaceFix = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                // Se o group estiver vazio, usamos o nome do projeto para evitar novo erro
                android.namespace = if (project.group.toString().isNotEmpty()) {
                    project.group.toString()
                } else {
                    "com.fix.namespace.${project.name.replace("-", "_")}"
                }
            }
        }
    }

    // Se o projeto já passou da fase de avaliação, aplica agora. 
    // Se não, agenda para o afterEvaluate.
    if (project.state.executed) {
        applyNamespaceFix()
    } else {
        project.afterEvaluate {
            applyNamespaceFix()
        }
    }
}