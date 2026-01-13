#!/bin/sh
set -e

if [ -n "$PLATFORM_PULL_REQUEST" ]; then
  echo "PR environment detected – sanitizing database"

  DB_CREDENTIALS=$(echo "$PLATFORM_RELATIONSHIPS" | base64 --decode | jq -r '.database[0]')
  DB_HOST=$(echo "$DB_CREDENTIALS" | jq -r '.host')
  DB_PORT=$(echo "$DB_CREDENTIALS" | jq -r '.port')
  DB_USER=$(echo "$DB_CREDENTIALS" | jq -r '.username')
  DB_PASS=$(echo "$DB_CREDENTIALS" | jq -r '.password')
  DB_NAME=$(echo "$DB_CREDENTIALS" | jq -r '.path')

  mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
UPDATE users
SET email = CONCAT('user+', id, '@example.com'),
    phone = NULL;
EOF

  echo "Database sanitization completed"
else
  echo "Not a PR environment – skipping sanitization"
fi

