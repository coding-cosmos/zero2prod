#!/usr/bin/env bash

set -euo pipefail

# Non-sensitive configuration
INSTANCE_NAME="zero2prod-db"
DB_NAME="newsletter"
DB_USER="newsletter"

echo "Fetching your public IP..."
CURRENT_IP=$(curl -4 -s --fail https://ifconfig.me)

if [[ -z "$CURRENT_IP" ]]; then
    echo "Error: Could not determine your public IP."
    exit 1
fi

echo "Your public IP: $CURRENT_IP"

echo "Fetching existing authorized networks..."

EXISTING_NETWORKS=$(
    gcloud sql instances describe "$INSTANCE_NAME" \
        --format="value(settings.ipConfiguration.authorizedNetworks[].value)" |
    tr '\n' ',' |
    sed 's/,$//'
)

NEW_NETWORK="$CURRENT_IP/32"

if [[ ",$EXISTING_NETWORKS," == *",$NEW_NETWORK,"* ]]; then
    echo "Your IP is already authorized."
else
    echo "Adding $NEW_NETWORK to authorized networks..."

    if [[ -n "$EXISTING_NETWORKS" ]]; then
        AUTHORIZED_NETWORKS="$EXISTING_NETWORKS,$NEW_NETWORK"
    else
        AUTHORIZED_NETWORKS="$NEW_NETWORK"
    fi

    gcloud sql instances patch "$INSTANCE_NAME" \
        --quiet \
        --authorized-networks="$AUTHORIZED_NETWORKS"
fi

echo "Fetching Cloud SQL public IP..."

DB_HOST=$(gcloud sql instances describe "$INSTANCE_NAME" \
    --format="value(ipAddresses[0].ipAddress)")

if [[ -z "$DB_HOST" ]]; then
    echo "Error: Could not determine Cloud SQL IP."
    exit 1
fi

echo "Cloud SQL host: $DB_HOST"

read -rsp "Enter Cloud SQL password: " DB_PASSWORD
echo

export DATABASE_URL="postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:5432/${DB_NAME}?sslmode=require&connect_timeout=10"

echo
echo "Testing PostgreSQL connection..."

if ! pg_isready -h "$DB_HOST" -p 5432 -d "$DB_NAME" -t 10; then
    echo "Error: Could not connect to Cloud SQL."
    exit 1
fi

echo "Database connection successful."

echo
echo "Current migration status:"
sqlx migrate info

echo
read -rp "Apply pending migrations to the CLOUD database? [y/N] " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo
echo "Running migrations..."
sqlx migrate run

echo
echo "Final migration status:"
sqlx migrate info

echo
echo "Cloud migrations completed successfully."