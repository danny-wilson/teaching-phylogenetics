# Phylogenetics in Practice
## Running instructions

To run locally, launch Docker Desktop and create a local working directory, for example
``
WDIR=~/Downloads/phylogenetics-in-practice
mkdir $WDIR
``

Navigate to the Dockerfile-containing directory, and launch the container as
``
docker run -v $WDIR:/home -it --name practical -p 14500:14500 -p 14501:14501 -p 14502:14502 -p 14503:14503 -p 6080:6080 -p 14600:14600 --rm teaching-phylo:xpra
``
