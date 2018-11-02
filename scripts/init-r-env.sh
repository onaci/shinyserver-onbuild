#!/bin/sh
#------------------------------------------------------------------------------
# Ensure the application environment is in place before running the application
#------------------------------------------------------------------------------

# Pre-create the bookmarks folder and allow the shiny user to write to it.
mkdir -p "${SHINY_BOOKMARKS_DIR}"
chown -R ${SHINY_USER}:${SHINY_USER} "${SHINY_BOOKMARKS_DIR}"    

# Pre-create the logs folder and allow the shiny user to write to it.
mkdir -p "${SHINY_LOGS_DIR}" 
chown -R ${SHINY_USER}:${SHINY_USER} "${SHINY_LOGS_DIR}"    

# Ensure all the application files are accessible to the shiny user.
chown -R root:${SHINY_USER} "${SHINY_APPS_DIR}"
chmod -R g+r "${SHINY_APPS_DIR}"

# Dump docker app-enviroment settings to a file where the
# R Shiny server will actually read them.
if [ -n "${SHINY_ENV_VARS}" ]; then
  ENV_FILE=/home/shiny/.Renviron
  for APP_VAR in $SHINY_ENV_VARS; do
    echo "${APP_VAR}='$(eval echo \"\$${APP_VAR}\")'" >> "${ENV_FILE}"
  done
  cat "${ENV_FILE}"
  chown shiny:shiny "${ENV_FILE}"
fi

# Run whichever command has been configured
CMD="${@}"
echo "CMD='${CMD}'"
if [ -n "${CMD}" ]; then
  eval "${CMD}"
fi
