# Sample MCP Server for Amazon SES (SESv2)

This sample shows how to build a Model Context Protocol (MCP) server for Amazon Simple Email Service (SES). This server implementation exposes all public SES v2 API actions through the MCP. You can send email, access SES account resources, and more. This sample is not intended to be used in a production environment.

## Prerequisites

* Git
* Java 21 or later
* AWS profile configured in your environment (the MCP server uses the default profile if not specified otherwise)
* An LLM client that supports MCP, such as:
  - [Amazon Q Developer CLI](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line.html)
  - Claude Desktop

## Getting Started
Clone and build the project:

### macOS/Linux
```
git clone https://github.com/aws-samples/sample-for-amazon-ses-mcp.git
cd sample-for-amazon-ses-mcp
./build.sh
```

### Windows
```
git clone https://github.com/aws-samples/sample-for-amazon-ses-mcp.git
cd sample-for-amazon-ses-mcp
.\build.bat
```

## Configuration

### MCP Server Configuration
After building, add the server to your MCP configuration:

```json
{
  "mcpServers": {
    "sesv2-mcp-server": {
      "command": "java",
      "args": [
        "-jar",
        "JAR_PATH_FROM_BUILD_OUTPUT"
      ]
    }
  }
}
```
The `JAR_PATH_FROM_BUILD_OUTPUT` will be printed at the end of the build script.

### Client Setup

#### Amazon Q Developer
See [Amazon Q Developer documentation](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-mcp-configuration.html) for configuration steps.

#### Claude Desktop
See [Claude Desktop MCP configuration guide](https://modelcontextprotocol.io/quickstart/user) for setup instructions.

## Example Use Cases
* Send a simple email to a single recipient
* Send an email to multiple recipients using a template
* Create a new dedicated IP address pool
* Check deliverability metrics (requires Virtual Deliverability Manager)
* Manage contact lists
* View and modify suppression lists

## Troubleshooting
### Common Issues
1. Jar not found: Ensure the path in MCP configuration matches the build output
2. Permission denied: Check AWS credentials and SES permissions
3. Windows build errors with `[ERROR] ... > Illegal char <` may be caused by incorrect line endings (CRLF vs LF). Try setting Git to use CRLF with `git config --global core.autocrlf true` and cloning the repository again.









## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
