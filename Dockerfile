# ===========================
#  Etapa 1: Build
# ===========================
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app

# Instalar Node.js 18 (requerido para Vite/React)
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# Copiar archivos necesarios para descargar dependencias
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Dar permisos al wrapper de Maven
RUN chmod +x mvnw

# Descargar dependencias sin compilar
RUN ./mvnw dependency:go-offline

# Copiar el resto del proyecto
COPY . .

# Asegurar permisos del mvnw
RUN chmod +x mvnw

# Compilar frontend React (Vite)
WORKDIR /app/src/main/resources/react
RUN npm install
RUN npm run build

# Volver al backend
WORKDIR /app

# Empaquetar Spring Boot
RUN ./mvnw clean package -DskipTests


# ===========================
#  Etapa 2: Imagen final
# ===========================
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
