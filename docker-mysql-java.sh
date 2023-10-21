#!/bin/bash

# Nome da imagem Docker
image_name="login-java"

# Caminho para o Dockerfile
dockerfile_path="."

if docker images | grep -q "$image_name"; then
    echo "A imagem Docker $image_name já existe."
else
    docker build -t "$image_name" "$dockerfile_path" || echo "Falha ao construir a imagem Docker."
fi
