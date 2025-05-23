/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 */
package org.example;

import software.amazon.smithy.java.aws.servicebundle.bundler.AwsServiceBundler;
import software.amazon.smithy.java.mcp.server.McpServer;
import software.amazon.smithy.mcp.bundle.api.McpBundles;
import software.amazon.smithy.mcp.bundle.api.model.Bundle;
import software.amazon.smithy.mcp.bundle.api.model.BundleMetadata;
import software.amazon.smithy.mcp.bundle.api.model.SmithyMcpBundle;
import software.amazon.smithy.modelbundle.api.model.SmithyBundle;

/**
 * Demo server implementation for Amazon SES v2 using Smithy MCP (Model Context Protocol).
 * <p>
 * Sets up and runs a basic MCP server for the Amazon SES v2 service, communicating via standard input and output streams.
 *
 * @see <a href="https://modelcontextprotocol.io">Model Context Protocol (MCP)</a>
 * @see <a href="https://docs.aws.amazon.com/ses/latest/APIReference-V2/Welcome.html">Amazon Simple Email Service (SES) v2 API</a>
 */

public class AmazonSesMcpMain {
    public static void main(String[] args) {
        initializeHttpClientEnvironment();

        String serviceName = "sesv2";
        SmithyBundle smithyBundle = new AwsServiceBundler(serviceName).bundle();
        var smithyMcpBundle = SmithyMcpBundle.builder()
            .bundle(smithyBundle)
            .metadata(BundleMetadata.builder().name(serviceName).build())
            .build();
        var bundle = Bundle.builder()
            .smithyBundle(smithyMcpBundle)
            .build();

        var service = McpBundles.getService(bundle);

        var mcpServer = McpServer.builder()
            .stdio()
            .addService(service)
            .name("amazon-sesv2-mcp-server")
            .build();

        mcpServer.start();
        try {
            Thread.currentThread().join();
        } catch (InterruptedException e) {
            mcpServer.shutdown().join();
        }
    }

    /**
     * Initializes the HTTP client environment settings.
     * Required because Smithy Java needs to use the 'Host' header,
     * which is restricted by the JDK HTTP Client implementation by default.
     * <p>
     * This must be executed before the first use of java.net.http.HttpClient
     * to allow setting the 'jdk.httpclient.allowRestrictedHeaders' system property.
     */
    private static void initializeHttpClientEnvironment() {
        try {
            Class.forName("software.amazon.smithy.java.client.http.JavaHttpClientTransport");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Failed to initialize environment", e);
        }
    }
}
