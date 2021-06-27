image=eigr/massa-proxy:0.1.36
port=8080

.PHONY: all clean

all: build install

build:

	docker build -f Dockerfile-Bakeware -t ${image} .

run: 

	docker run --rm --name=massa-proxy --net=host -e PROXY_POD_IP=10.0.0.149 -e PROXY_HTTP_PORT=9001 -e PROXY_PORT=9002 -e PROXY_UDS_ADDRESS=false -e PROXY_UDS_MODE=/var/run/cloudstate.sock -e USER_FUNCTION_HOST=127.0.0.1 -e USER_FUNCTION_PORT=${port} ${image}

install:

	docker push ${image}