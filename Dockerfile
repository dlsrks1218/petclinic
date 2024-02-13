FROM openjdk:17.0.2-jdk-slim


ENV APP_HOME "/app"
ENV LOG_HOME "/app/logs"
# ENV SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/petclinic
# ENV SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/petclinic

# RUN groupadd -g 999 appuser && \
#     useradd -r -u 999 -g appuser appuser && \
#     mkdir -p /app/logs && \
#     chown -R appuser:appuser /app/logs && \
#     chmod -R 775 /app/logs

USER appuser

WORKDIR ${APP_HOME}

# VOLUME /tmp
# ARG JAR_FILE
# COPY ${JAR_FILE} app.jar
COPY build/libs/petclinic.jar app.jar

EXPOSE 8080

# ENTRYPOINT [ "java", "-Dspring.profiles.active=test", "-jar", "app.jar" ]
ENTRYPOINT [ "java", "-jar", "app.jar" ]
