run:
	go run cmd/ocp-prize-api/main.go

lint:
	golangci-lint run

test:
	go test -v ./...

.PHONY: build
build: vendor-proto generate

.PHONY: generate
generate: .generate

.PHONY: .generate
.generate:
	mkdir -p swagger
	mkdir -p pkg/short-link-api
	protoc -I vendor.protogen \
				--go_out=pkg/short-link-api --go_opt=paths=import \
    			--go-grpc_out=pkg/short-link-api --go-grpc_opt=paths=import \
    			--grpc-gateway_out=/pkg/short-link-api \
    			--grpc-gateway_opt=logtostderr=true \
    			--grpc-gateway_opt=paths=import \
    			--validate_out lang=go:pkg/short-link-api \
    			--swagger_out=allow_merge=true,merge_file_name=api:swagger \
    			api/short-link-api/short-link-api.proto
	mv pkg/short-link-api/github.com/blue-gopher/link-shortener-service/pkg/short-link-api/* pkg/short-link-api/
	rm -rf pkg/short-link-api/gihtub.com
	mkdir -p cmd/short-link-api

PHONY: vendor-proto
vendor-proto: .vendor-proto

PHONY: .vendor-proto
.vendor-proto:
		mkdir -p vendor.protogen
		mkdir -p vendor.protogen/api/short-link-api
		cp api/short-link-api/short-link-api.proto vendor.protogen/api/short-link-api
		@if [ ! -d vendor.protogen/google ]; then \
			git clone https://github.com/googleapis/googleapis vendor.protogen/googleapis &&\
			mkdir -p  vendor.protogen/google/ &&\
			mv vendor.protogen/googleapis/google/api vendor.protogen/google &&\
			rm -rf vendor.protogen/googleapis ;\
		fi
		@if [ ! -d vendor.protogen/github.com/envoyproxy ]; then \
			mkdir -p vendor.protogen/github.com/envoyproxy &&\
			git clone https://github.com/envoyproxy/protoc-gen-validate vendor.protogen/github.com/envoyproxy/protoc-gen-validate ;\
		fi
