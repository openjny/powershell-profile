function docker-juypterlab () {
    docker run -it --rm -p 8888:8888 -v ${PWD}:/home/jovyan/work jupyter/base-notebook:latest
}