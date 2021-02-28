image=mungotinae/massa-proxy:0.1.0
port=8080

.PHONY: all clean

all: build install

build:

	docker build -t ${image} .

run: 

	docker run --rm --name=massa-proxy --net=host -e USER_FUNCTION_PORT=${port} ${image}

install:

	docker push ${image}