# Dockerfile for lum8rjack/caddy-mcp
FROM golang:1.24-alpine AS builder

# Install git for cloning the repository
RUN apk add --no-cache git make

# Clone the official caddy-mcp repository
WORKDIR /build
RUN git clone https://github.com/lum8rjack/caddy-mcp.git .

# Build the application
RUN make

# Final stage: minimal runtime image
FROM alpine:latest

# Install CA certificates for HTTPS support
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S caddy-mcp && \
    adduser -u 1001 -S caddy-mcp -G caddy-mcp

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /build/caddy-mcp ./

# Change ownership to non-root user
RUN chown -R caddy-mcp:caddy-mcp /app

# Switch to non-root user
USER caddy-mcp

# Expose default port for HTTP stream transport
EXPOSE 7000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep caddy-mcp > /dev/null || exit 1

# Default command (will be overridden by docker-compose)
CMD ["./caddy-mcp", "-transport", "stdio", "-url", "http://localhost:2019"]