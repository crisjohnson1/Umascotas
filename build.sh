#!/usr/bin/env bash
set -e

echo "===== Construyendo FRONTEND ====="
cd src/main/resources/react
npm install
npm run build

echo "===== Construyendo BACKEND (Spring Boot) ====="
cd ../../../../
./mvnw clean package -DskipTests
