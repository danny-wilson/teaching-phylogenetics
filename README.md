# Phylogenetics in Practice

## Running on GitHub Codespaces

If you haven't already, sign up to `github.com`. In your web browser, navigate to `github.com/codepaces` and log in.

Click `New codespace`, and under `Select a repository` type `danny-wilson/teaching-phylogenetics`. Use the default options, including branch `main` and Machine Type `2-core`. Then click `Create codespace`.

Codespaces begins by building the Docker container to run the practical.

## Running locally with Visual Studio Code

Install the prerequisite software:
- GitHub
- Docker Desktop
- Visual Studio Code (VS Code)
- Dev Containers (Container Tools) extension in VS Code

Clone the GitHub repository if you haven't already, for example
```
cd ~/Documents/GitHub       # or wherever you store your local repos
git clone https://github.com/danny-wilson/teaching-phylogenetics.git
```

In VS Code, open the GitHub repository folder. At the command line, you can type (for example)
```
code ~/Documents/GitHub/teaching-phylogenetics
```


## Running locally

To run locally, launch Docker Desktop and create a local working directory, for example
```
WDIR=~/Downloads/phylogenetics-in-practice
mkdir -p $WDIR
```

Navigate to the Dockerfile-containing directory and build the container as
```
docker build -t teaching-phylo:xpra .
```

Launch the container as
```
docker run -v $WDIR:/home -it --name practical -p 14500:14500 -p 14501:14501 -p 14502:14502 -p 14503:14503 -p 6080:6080 -p 14600:14600 --rm teaching-phylo:xpra
```

Your local working directory will be mounted inside the container at /home. In your web browser, navigate to
```
http://localhost:14501
```
