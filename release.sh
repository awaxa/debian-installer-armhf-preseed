#!/usr/bin/env bash

case $(uname -s) in
  Darwin)
    DATE='gdate'
    ;;
  *)
    DATE='date'
    ;;
esac

SOURCE="$(grep ^SOURCE= seed.sh | cut -f2 -d\')"
ANNOTATION_FILE="$(mktemp)"
echo "$SOURCE" > "$ANNOTATION_FILE"
echo >> "$ANNOTATION_FILE"
curl -sI "$SOURCE" | grep '^Last-Modified\|^ETag\|^Content' >> "$ANNOTATION_FILE"
LAST_MODIFIED_TIMESTAMP="$(grep ^Last-Modified: "$ANNOTATION_FILE" | cut -f2 -d:)"
TAG_NAME="$($DATE -d "$LAST_MODIFIED_TIMESTAMP" '+%Y.%m.%d')"
if git tag | grep -q "$TAG_NAME" ; then
  echo "aborting: tag $TAG_NAME already exists"
  exit 1
else
  set -vx
  git tag --file="$ANNOTATION_FILE" "$TAG_NAME" master
  git show "$TAG_NAME"
fi

