function jupyterlab-base-notebook () {
    docker run -it --rm -p 8888:8888 -v ${PWD}:/home/jovyan/work jupyter/base-notebook:latest
}
function jupyterlab-scipy-notebook () {
    docker run -it --rm -p 8888:8888 -v ${PWD}:/home/jovyan/work jupyter/scipy-notebook:latest
}