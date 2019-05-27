ARG R_VERSION=3.5.1
ARG BASE_IMAGE=rocker/shiny-verse:${R_VERSION}
FROM ${BASE_IMAGE}

# Define variables that identify the state of the R runtime environment
# (The BASE_IMAGE arg here will automagically have the
# same value as the one above the FROM statement)
ARG BASE_IMAGE
ARG BASE_R_LIBS
ENV BASE_R_LIBS="${BASE_R_LIBS:-caTools datasets dplyr devtools formatR remotes rmarkdown selectr shiny tidyverse}"
RUN echo "Using BASE_IMAGE='${BASE_IMAGE}' with pre-installed R-libs: ${BASE_R_LIBS}"

# Install some helper scripts.
ENV SCRIPT_DIR="/srv/scripts"
RUN mkdir -p "${SCRIPT_DIR}"
COPY ./scripts/*.sh "${SCRIPT_DIR}/"
RUN chmod 755 "${SCRIPT_DIR}"/*.sh

# Define variables for important build locations.
ENV SHINY_APPS_DIR="/srv/shiny-server"
ENV SHINY_THEME_DIR="${SHINY_APPS_DIR}/www"
ENV SHINY_BOOKMARKS_DIR="/var/lib/shiny-server/bookmarks"
ENV SHINY_LOGS_DIR="/var/log/shiny-server"
ENV SHINY_USER="shiny"

# Ensure child-dockerfiles define the SHINY_APP_SRC argument
# They should set this to the location of the directory containing the
# R-Shiny application code relative to the child build's docker context.
# This should NOT be slash-terminated.
ONBUILD ARG SHINY_APP_SRC
ONBUILD ENV SHINY_APP_SRC="${SHINY_APP_SRC:-.}"

# Ensure child-dockerfiles define the SHINY_THEME_SRC argument
# They should set this to the location of the directory containing any
# custom theme code (CSS and images), relative to the child build's
# docker context. Should NOT be slash-terminated.
ONBUILD ARG SHINY_THEME_SRC
ONBUILD ENV SHINY_THEME_SRC="${SHINY_THEME_SRC:-$SHINY_APP_SRC/www}"

# Ensure child-dockerfiles define the SHINY_ENV_VARS argument
# This should be set to a space-separated string of all names of any
# environment variables which need to be made available to the
# R-Shiny application at runtime. Defaults to an empty string.
ONBUILD ARG SHINY_ENV_VARS
ONBUILD ENV SHINY_ENV_VARS="${SHINY_ENV_VARS:-}"

# Allow child dockerfiles to define a list of libraries that
# should be installed from github rather than CRAN.
ONBUILD ARG GITHUB_R_LIBS
ONBUILD ENV GITHUB_R_LIBS="${GITHUB_R_LIBS:-}"

# Ensure child dockerfiles install their application source code
# to the proper location, then install any R libraries required
# by that source code.
ONBUILD RUN echo "SHINY_APP_SRC='${SHINY_APP_SRC}'"
ONBUILD COPY "${SHINY_APP_SRC}/" "${SHINY_APPS_DIR}/"
ONBUILD RUN R_LIBS_INSTALLED="${BASE_R_LIBS}" \
            R_LIBS_GITHUB="${GITHUB_R_LIBS}" \
            "${SCRIPT_DIR}/install-r-libs.sh" "${SHINY_APPS_DIR}"

# Ensure child dockerfiles install  any custom theme content to the
# proper location *after* the source code has been installed.
ONBUILD RUN echo "SHINY_THEME_SRC='${SHINY_THEME_SRC}'"
ONBUILD COPY "${SHINY_THEME_SRC}/" "${SHINY_THEME_DIR}/"

# By default, run shinyserver as the non-root shiny user, with
# all the variables listed in SHINY_ENV_VARS available to the apps
ENTRYPOINT [ "/srv/scripts/init-r-env.sh" ]
CMD [ "su", "-", "shiny", "-c", "/usr/bin/shiny-server.sh" ]
