#!/bin/sh -eux

OPERATION="${1}"
BRANCH="${2}"
shift; shift
FILES="$@"

case "${OPERATION}" in
  "add") COMMIT_MESSAGE_PREFIX="Adding" ;;
  "rm")  COMMIT_MESSAGE_PREFIX="Removing" ;;
  *) echo "Action is neither 'add' nor 'rm'. Cannot proceed."; exit 1 ;;
esac

for file in ${FILES}; do
  (
    printf "commit refs/heads/${BRANCH}\n"
    printf "committer <${USER}@${HOSTNAME}> now\n"
    printf "data <<EOC\n"
    printf "${COMMIT_MESSAGE_PREFIX} $(basename ${file}).\n"
    printf "EOC\n"
    if git branch 2>/dev/null | grep -q "${BRANCH}"; then
      printf "from refs/heads/${BRANCH}^0\n"
    fi
    case "${OPERATION}" in
      "add")
        printf "M 100644 inline ${file}\n"
        printf "data $(stat --format='%s' ${file})\n"
        cat ${file}
      ;;
      "rm")
        printf "D ${file}\n"
      ;;
    esac
  ) \
  | git fast-import --quiet --date-format=now
done
