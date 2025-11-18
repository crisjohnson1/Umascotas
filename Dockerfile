# ===========================
#  Etapa 1: Build
# ===========================
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app

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

# Asegurar permisos del mvnw (IMPORTANTE porque COPY sobrescribe archivos)
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

# Copiar el jar generado en la etapa de build
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

