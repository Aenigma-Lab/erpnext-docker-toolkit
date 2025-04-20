#!/bin/bash

# Step 1: Automatically get Docker container ID for the backend container
CONTAINER_ID=$(docker ps --filter "name=frappe_docker-backend" --format "{{.ID}}")

# Check if container ID is found
if [ -z "$CONTAINER_ID" ]; then
    echo "❌ Error: Unable to find the container ID for the backend container."
    exit 1
fi

# Step 2: Get the site name from user input
echo "👉 Please enter the site name (e.g., 'frontend'):"
read SITE

if [ -z "$SITE" ]; then
    echo "❌ Error: No site name entered. Exiting."
    exit 1
fi

echo "✅ Using site: $SITE"
echo "🐳 Using Docker container ID: $CONTAINER_ID"

# Define apps with their Git URL and branch version
APPS=(
    "india_compliance https://github.com/resilient-tech/india-compliance.git version-15"
    "erpnext_telegram_integration https://github.com/yrestom/erpnext_telegram.git version-14"
    "hrms https://github.com/frappe/hrms.git version-15"
)

# Step 3: Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Please run as root or use sudo."
    exit 1
fi

# Step 4: Download ERPNext Apps
echo "⬇️  Downloading ERPNext Apps..."
for APP in "${APPS[@]}"; do
    APP_NAME=$(echo "$APP" | cut -d ' ' -f 1)
    GIT_URL=$(echo "$APP" | cut -d ' ' -f 2)
    BRANCH=$(echo "$APP" | cut -d ' ' -f 3)

    echo "📦 Getting app: $APP_NAME from $GIT_URL on branch $BRANCH"
    docker exec -u frappe -it "$CONTAINER_ID" bench get-app --branch "$BRANCH" "$GIT_URL"
done

# Step 5: Install the Apps on the Site
echo "⚙️  Installing apps on site $SITE..."
for APP in "${APPS[@]}"; do
    APP_NAME=$(echo "$APP" | cut -d ' ' -f 1)
    docker exec -u frappe -it "$CONTAINER_ID" bench --site "$SITE" install-app "$APP_NAME"
done

# Step 6: Migrate the Database
echo "🔄 Migrating database..."
docker exec -u frappe -it "$CONTAINER_ID" bench --site "$SITE" migrate

# Step 7: Restart Services
echo "🔁 Restarting services..."
docker exec -u frappe -it "$CONTAINER_ID" sudo supervisorctl restart all

# Step 8: Verify Installation
echo "🔍 Verifying installed apps..."
docker exec -u frappe -it "$CONTAINER_ID" bench --site "$SITE" list-apps

echo "✅ All apps installed and configured successfully!"
