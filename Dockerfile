# ===========================
#  Etapa 1: Build del proyecto
# ===========================
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app

# Copiamos solo archivos necesarios primero (mejor cache)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Descarga dependencias antes de copiar todo → cache efectivo
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline

# Copiamos el resto del proyecto
COPY . .

# Instalamos Node para compilar el frontend
RUN apt-get update && apt-get install -y nodejs npm

# Compilar frontend React/Vite si existe
WORKDIR /app/src/main/resources/react
RUN npm install
RUN npm run build

# Empaquetar Spring Boot
WORKDIR /app
RUN ./mvnw clean package -DskipTests

# ===========================
#  Etapa 2: Imagen final
# ===========================
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
