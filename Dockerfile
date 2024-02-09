FROM openjdk:17.0.2-jdk-slim

ENV APP_HOME "/app"
ENV LOG_HOME "/app/logs"
ENV SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/petclinic

# RUN useradd -u 999 user
USER nobody

WORKDIR ${APP_HOME}

COPY build/libs/petclinic.jar app.jar

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "app.jar" ]