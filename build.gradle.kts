import com.github.jengelman.gradle.plugins.shadow.transformers.AppendingTransformer

plugins {
    id("java")
    id("com.gradleup.shadow") version "8.3.5"
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenLocal()
    mavenCentral()
}

dependencies {
    val smithyJavaVersion = "0.0.2"

    implementation("software.amazon.smithy.java:aws-service-bundler:$smithyJavaVersion")
    implementation("software.amazon.smithy.java:mcp-bundle-api:$smithyJavaVersion")
    implementation("software.amazon.smithy.java:mcp-server:$smithyJavaVersion")

    implementation("software.amazon.smithy.java:aws-client-restjson:$smithyJavaVersion")
    implementation("software.amazon.smithy.java:aws-service-bundle:$smithyJavaVersion")
}

tasks.shadowJar {
    mergeServiceFiles()
    transform(AppendingTransformer::class.java) {
        resource = "META-INF/smithy/manifest"
    }

    destinationDirectory.set(file("artifacts"))
    archiveFileName.set("sample-for-amazon-ses-mcp-all.jar")

    manifest {
        attributes(mapOf(
            "Main-Class" to "org.example.AmazonSesMcpMain"
        ))
    }
}
