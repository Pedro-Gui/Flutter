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
    
    // Criamos a lógica da correção em uma variável
    val applyNamespaceFix = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                // Se o group estiver vazio, geramos um namespace baseado no nome do plugin
                val namespaceName = project.group.toString().ifEmpty { 
                    "com.fix.${project.name.replace("-", "_")}" 
                }
                android.namespace = namespaceName
            }
        }
    }

    // Se o projeto já foi configurado, aplica agora.
    // Se não, agenda para quando terminar.
    if (project.state.executed) {
        applyNamespaceFix()
    } else {
        project.afterEvaluate {
            applyNamespaceFix()
        }
    }
}