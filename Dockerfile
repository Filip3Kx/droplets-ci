FROM ubuntu:latest
RUN mkdir /app
WORKDIR /app
COPY ./ .
RUN cp ./bin/droplets .
EXPOSE 8080
CMD ["./droplets"]
