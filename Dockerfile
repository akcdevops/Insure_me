From alpine
USER ubuntu
WORKDIR /app
RUN apt update && apt install java  && apt install tomcat && apt install maven
RUN git clone repo.git && cd repo && mvn clean package
COPY  target/*.jar app.jar
CMD ["java", "-jar", app.jar]