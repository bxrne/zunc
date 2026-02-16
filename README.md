# zunc

High-performance Azure Functions developed in Zig. This project utilizes the Azure Functions Custom Handler interface to provide a low-latency, memory-efficient alternative to managed runtimes.

---

## Prerequisites

* **Zig Compiler**: Ensure `zig` is available in your PATH.
* **Azure Functions Core Tools**: Version 4.x or higher is required for local development and deployment.
* **Azure CLI**: Required for authentication and cloud resource management.

---

## Build Instructions

The Azure Functions host requires a standalone executable. The default configuration expects a binary named **handler**.

### Local Development

Compile for your current operating system and architecture:

```bash
zig build-exe src/main.zig --name handler -O ReleaseSmall

```

### Production Deployment

Azure Functions Linux consumption plans typically run on x86_64 Linux. Cross-compile using Zig's native toolchain:

```bash
zig build-exe src/main.zig --name handler -target x86_64-linux -O ReleaseSmall

```

---

## Local Execution

1. Ensure your binary has execution permissions:
```bash
chmod +x handler

```


2. Start the Azure Functions host:
```bash
func start

```



The host will read `host.json`, spawn the `handler` process, and proxy incoming HTTP requests to the port specified in the `FUNCTIONS_CUSTOMHANDLER_PORT` environment variable.

---

## Deployment

To deploy to an existing Function App in Azure:

1. Compile the binary for the target environment (**x86_64-linux**).
2. Authenticate with Azure:
```bash
az login

```


3. Publish the project:
```bash
func azure functionapp publish <FUNCTION_APP_NAME>

```



---

## Architecture Notes

**zunc** operates as a web server listening on a local loopback address. It does not communicate with Azure via a traditional SDK; instead, it receives invoked triggers as standard HTTP requests.

> **Performance Tip**: Using `ReleaseSmall` or `ReleaseFast` optimization levels significantly reduces cold start times and memory overhead compared to standard debug builds.

