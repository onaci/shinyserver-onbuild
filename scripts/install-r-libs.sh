#!/bin/sh
#------------------------------------------------------------------------------
# Ensure that all the R-libraries required by an application are installed.
#
# Takes a single argument, which is the absolute location of the directory
# containing R files that should be parsed for 'library' statements.
#
# Uses the following predefined shell (or environment) variables:
# - MRAN = the URL of the repository from which libraries should be fetched.
# - R_LIBS_INSTALLED = space-separated list of libraries which are *known* to 
#                      already have been installed. (This will be appended to)
#
# - R_LIBS_TO_INSTALL = space-seperated list of libraries that should be
#                       installed. Default to an empty string
#
# - R_SRC = absolute path to the directory where your R source files live.
#           This can be overridden by the first argument to this script.
#------------------------------------------------------------------------------
MRAN="${MRAN:-http://cran.rstudio.com/}"
echo "MRAN='${MRAN}'"

R_LIBS_INSTALLED="${R_LIBS_INSTALLED:-}"
echo "R_LIBS_INSTALLED='${R_LIBS_INSTALLED}'"

R_LIBS_TO_INSTALL="${R_LIBS_TO_INSTALL:-}"
R_SRC="${1:-$R_SRC}"
if [ -d "${R_SRC}" ]; then
  # Loop over all available R code files looking for library statements:
  echo "R_SRC='${R_SRC}'"
  R_FILES=$(mktemp)
  find "${R_SRC}" \( -name "*.R" -o -name "*.Rmd" \) -type f -print > "${R_FILES}"
  while read -r R_FILE; do
    echo "Processing R_FILE='${R_FILE}'"
    R_FILE_LIBS=$(cat "${R_FILE}" | grep "^library(" | sed 's/library(\(.*\))/\1/' | tr '\n' ' ')
    R_LIBS_TO_INSTALL="${R_LIBS_TO_INSTALL} ${R_FILE_LIBS}"
  done < "${R_FILES}"
  rm "${R_FILES}"
elif [ -n "${R_SRC}" ]; then
  echo "Invalid R_SRC '${R_SRC}': directory does not exist"
  exit 1
else
  echo "R_SRC not specified"
fi
echo "R_LIBS_TO_INSTALL='${R_LIBS_TO_INSTALL}'"

# Ensure all the requested libraries are installed.
for R_LIB in $R_LIBS_TO_INSTALL; do
  echo "R_LIB='${R_LIB}'";
  if echo "${R_LIBS_INSTALLED}" | grep -Eq "(^|.*\\s)${R_LIB}(\\s.*|$)"; then
    echo "The ${R_LIB} library has already been installed"
  else
    R -q -e "install.packages('${R_LIB}', repos='${MRAN}')"
    R_LIBS_INSTALLED="${R_LIBS_INSTALLED} ${R_LIB}"
  fi
done
echo "R_LIBS_INSTALLED='${R_LIBS_INSTALLED}'"
