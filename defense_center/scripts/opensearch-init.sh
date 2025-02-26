#!/bin/sh

OPENSEARCH_USERNAME=${OPENSEARCH_USERNAME:-admin}
OPENSEARCH_PASSWORD=${OPENSEARCH_PASSWORD:-$OPENSEARCH_INITIAL_ADMIN_PASSWORD}

USE_AUTH="-u ${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}"

# Get OpenSearch URL from environment variable
if [ -z "$OPENSEARCH_URL" ]; then
    echo "OPENSEARCH_URL environment variable is not set."
    exit 1
fi

# Get OpenSearch Dashboards URL from environment variable
if [ -z "$DASHBOARDS_URL" ]; then
    echo "DASHBOARDS_URL environment variable is not set."
    exit 1
fi

# Get OpenSearch username from environment variable
if [ -z "$OPENSEARCH_USERNAME" ] && [ -z "$OPENSEARCH_PASSWORD" ]; then
    echo "OPENSEARCH_USERNAME and OPENSEARCH_PASSWORD environment variables are not set. Authentication is disabled."
    USE_AUTH=""
fi

# Get OpenSearch password from environment variable
if [ -z "$OPENSEARCH_PASSWORD" ]; then
    echo "OPENSEARCH_PASSWORD environment variable is not set. Disabling security."
fi

# Install jq
apk add --no-cache jq

# Wait until OpenSearch is available
until $(curl --output /dev/null --silent --head -k $USE_AUTH --fail $OPENSEARCH_URL); do
    echo "Waiting for OpenSearch to be ready..."
    sleep 5
done

echo "OpenSearch is ready."

# Wait until OpenSearch Dashboards is available
until $(curl --output /dev/null --silent --head -k $USE_AUTH --fail $DASHBOARDS_URL/api/status); do
    echo "Waiting for OpenSearch Dashboards to be ready..."
    sleep 5
done

echo "OpenSearch Dashboards is ready."

# Load component templates
for template in /templates/component-templates/*.json; do
    if [ -f "$template" ]; then
        template_name=$(basename "$template" .json)
        echo "\nLoading component template: $template_name"
        curl -sS -X PUT "$OPENSEARCH_URL/_component_template/$template_name" \
            -H 'Content-Type: application/json' \
            -k $USE_AUTH \
            -d @"$template"
    else
        echo "No component templates found in /templates/component-templates/"
        break
    fi
done

# Load index templates
for template in /templates/index-templates/*.json; do
    if [ -f "$template" ]; then
        template_name=$(basename "$template" .json)
        echo "Loading index template: $template_name"
        curl -sS -X PUT "$OPENSEARCH_URL/_index_template/$template_name" \
            -H 'Content-Type: application/json' \
            -k $USE_AUTH \
            -d @"$template"
    else
        echo "No index templates found in /templates/index-templates/"
        break
    fi
done

# Load data stream templates
for template in /templates/data-streams/*.json; do
    echo "Loading data stream template: $template"
    curl -sS -X PUT "$OPENSEARCH_URL/_data_stream/$(basename $template .json)" \
        -k $USE_AUTH \
        -H 'Content-Type: application/json'
done

# Import OpenSearch Dashboards objects
for object in /templates/saved-objects/*.ndjson; do
    if [ -f "$object" ]; then
        echo "Importing OpenSearch Dashboards object: $object"
        curl -sS -X POST "$DASHBOARDS_URL/api/saved_objects/_import?overwrite=true" \
            -H 'osd-xsrf: true' \
            -k $USE_AUTH \
            --form file=@"$object"
    else
        echo "No OpenSearch Dashboards objects found in /templates/saved-objects/"
        break
    fi
done

echo "Initialization completed successfully."
