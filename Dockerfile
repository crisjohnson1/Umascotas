# ===========================
#  Etapa 1: Build del proyecto
# ===========================
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /app
COPY . .

# Dar permisos al wrapper de Maven
RUN chmod +x mvnw

# Instalamos Node para compilar el frontend
RUN apt-get update && apt-get install -y nodejs npm

# Compilar frontend React (Vite)
WORKDIR /app/src/main/resources/react
RUN npm install
RUN npm run build

# Regresar al backend y empaquetar Spring Boot
WORKDIR /app
RUN ./mvnw clean package -DskipTests

# ===========================
#  Etapa 2: Imagen final
# ===========================
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copiamos solo el JAR final
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

