
BASE_IMAGE = amd64/golang:1.15-alpine3.12
GO_LINT_IMAGE = golangci/golangci-lint:v1.33.0

.PHONY: $(shell ls)

help:
	@echo "usage: make [action]"
	@echo ""
	@echo "available actions:"
	@echo ""
	@echo "  mod-tidy      run go mod tidy"
	@echo "  format        format source files"
	@echo "  test          run tests"
	@echo "  lint          run linter"
	@echo "  msgs          generate standard messages"
	@echo ""

blank :=
define NL

$(blank)
endef

mod-tidy:
	docker run --rm -it -v $(PWD):/s $(BASE_IMAGE) \
	sh -c "apk add git && cd /s && go get && go mod tidy"

format:
	docker run --rm -it -v $(PWD):/s $(BASE_IMAGE) \
	sh -c "cd /s && find . -type f -name '*.go' | xargs gofmt -l -w -s"

define DOCKERFILE_TEST
FROM $(BASE_IMAGE)
RUN apk add --no-cache make docker-cli git gcc musl-dev
WORKDIR /s
COPY go.mod go.sum ./
RUN go mod download
COPY . ./
endef
export DOCKERFILE_TEST

test:
	echo "$$DOCKERFILE_TEST" | docker build -q . -f - -t temp
	docker run --rm -it \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	temp \
	make test-nodocker

test-examples:
	$(foreach f,$(shell ls examples/*),go build -o /dev/null $(f)$(NL))

test-pkg:
	go test -race -v ./pkg/...

test-root:
	$(foreach IMG,$(shell echo testimages/*/ | xargs -n1 basename), \
	docker build -q testimages/$(IMG) -t goroslib-test-$(IMG)$(NL))
	go test -race -v .

test-nodocker: test-examples test-pkg test-root

lint:
	docker run --rm -v $(PWD):/app -w /app \
	$(GO_LINT_IMAGE) \
	golangci-lint run -v

define DOCKERFILE_MSGS
FROM $(BASE_IMAGE)
RUN apk add --no-cache make docker-cli git
WORKDIR /s
COPY go.mod go.sum ./
RUN go mod download
endef
export DOCKERFILE_MSGS

msgs:
	echo "$$DOCKERFILE_TEST" | docker build -q . -f - -t temp
	docker run --rm -it \
	-v $(PWD):/s \
	temp \
	sh -c "cd /s && make msgs-nodocker"

msgs-nodocker:
	go run ./cmd/msgs-gen
	find ./pkg/msgs -type f -name '*.go' | xargs gofmt -l -w -s
