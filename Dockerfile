FROM ubuntu:latest
RUN mkdir /app
WORKDIR /app
COPY ./ .
EXPOSE 8080
CMD ["./droplets"]
