# syntax=docker/dockerfile:1

# ---- Build: compile penny-server as a release binary ----
FROM swift:6.4-noble AS build
WORKDIR /build

# Resolve dependencies first so they cache between source changes.
COPY Package.swift Package.resolved ./
RUN swift package resolve

COPY Sources ./Sources
COPY Tests ./Tests
RUN swift build -c release --product penny-server \
    && mkdir -p /staging \
    && cp "$(swift build -c release --show-bin-path)/penny-server" /staging/

# ---- Run: the slim Swift image (runtime libraries only) with the binary and static files ----
FROM swift:6.4-noble-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --create-home --home-dir /app penny

WORKDIR /app
COPY --from=build /staging/penny-server /app/penny-server
COPY static /app/static

ENV HOST=0.0.0.0 \
    PORT=8080 \
    STATIC_DIR=/app/static

USER penny
EXPOSE 8080

# Railway and most hosts inject PORT; the server reads it at startup.
ENTRYPOINT ["/app/penny-server"]
CMD ["serve"]
