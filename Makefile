
# What to name the Docker container, last part of direcotry.
# That way can use the same makefile in many projects (assuming
# I run 'make' from the  directory where I have the Dockerfile).
#
TARGET_NAME = "$$USER/$(shell basename `pwd`)"

all: container

container: Dockerfile
	docker build -t $(TARGET_NAME) .

clean: 
	docker build --no-cache -t $(TARGET_NAME) .
