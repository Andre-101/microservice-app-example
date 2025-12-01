FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
RUN mvn -B dependency:go-offline
COPY src ./src
RUN mvn -B package -DskipTests

FROM eclipse-temurin:8-jre
WORKDIR /app
COPY --from=build /build/target/users-api-0.0.1-SNAPSHOT.jar /app/users-api.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "/app/users-api.jar"]
