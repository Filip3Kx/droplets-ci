build:
        @echo "Building droplets at './bin/droplets' ..."
        @go build -o bin/droplets

clean:
        rm -rf ./bin

all: lint       vet     test    build

test:
        @echo "Running unit tests..."
        @go test -cover ./...

vet:
        @echo "Running vet..."
        @go vet ./...

lint:
        @echo "Running golint..."
        @golint ./...

setup:
        @go get -u golang.org/x/lint/golint
        @go get -u github.com/fzipp/gocyclo
