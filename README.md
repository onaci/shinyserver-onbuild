# shinyserver-onbuild
A dockerised build-environment base image for R-Shiny application deployment,
based on the [rocker/shiny-verse](https://hub.docker.com/r/rocker/shiny/) base image (which includes the ```tidyverse```
packages).

## Enforced Build steps
This image enforces some standard build steps for R-Shiny application dockerfiles
that inherit from it, namely:

* Install R-Shiny application source code at the proper filepath
* Install any libraries required by the R-Shiny application.
* Install any theme content at the proper location
* Make selected environment variables available to the R-Shiny runtime environment
* Run ShinyServer as the non-root 'shiny' user.

## Configurable Build Arguments
Dockerfiles which inherit FROM this docker image should define the following
build arguments _before_ their 'FROM' statement (or in a command line argument):

* ```SHINY_APP_SRC``` => the location of the directory containing the 
  R-Shiny application code relative to the docker context. This should 
  NOT be slash-terminated. Defaults to ```.```
  
* ```SHINY_THEME_SRC``` => the location of the directory containing any 
  custom theme code (CSS and images), relative to the docker context. 
  Should NOT be slash-terminated. Defaults to ```${SHINY_APP_SRC}/www```
  
* ```SHINY_ENV_VARS``` =>  space-separated string of the names of any
  environment variables which need to be made available to the R-Shiny 
  application at _runtime_. Defaults to an empty string.
  
## Sample Child Dockerfile
```
ARG SHINY_APP_SRC=./source/my_app
ARG SHINY_THEME_SRC=./source/my_theme
ARG SHINY_ENV_VARS="MY_THEME_NAME MY_HOME_URL"
FROM onaci/shinyserver-onbuild:3.5.1

ENV MY_THEME="my_theme.css"
ENV MY_HOME_URL="https://www.example.com/"
```  

## DockerHub

You can pull a pre-build docker image based on this repository from https://hub.docker.com/r/onaci/shinyserver-onbuild/
