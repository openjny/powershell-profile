function jupyterlab-base-notebook () {
    docker run -it --rm -p 8888:8888 -v ${PWD}:/home/jovyan/work jupyter/base-notebook:latest
}
function jupyterlab-scipy-notebook () {
    docker run -it --rm -p 8888:8888 -v ${PWD}:/home/jovyan/work jupyter/scipy-notebook:latest
}
function docker-go {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    docker run --rm -v ${PWD}:/workspace -w /workspace golang:1.22 go $Args
}
