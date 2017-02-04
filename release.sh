#!/usr/bin/env bash

case $(uname -s) in
  Darwin)
    DATE='gdate'
    ;;
  *)
    DATE='date'
    ;;
esac

REF=$(git symbolic-ref -q HEAD)
REF=${REF##refs/heads/}
SHORTREV="$(git rev-parse --short HEAD)"
REF=${REF:-$SHORTREV}
SOURCE="$(grep ^SOURCE= seed.sh | cut -f2 -d\')"
HEADRESPONSE="$(curl -sI "$SOURCE" | grep '^Last-Modified\|^ETag\|^Content')"
LAST_MODIFIED_TIMESTAMP="$(echo "$HEADRESPONSE" | grep ^Last-Modified: | cut -f2- -d\ )"
ANNOTATION_FILE="$(mktemp)"
{
  echo 'preseed added to partition.img.gz'
  echo
  echo "$SOURCE"
  echo
  echo "$HEADRESPONSE"
} >> "$ANNOTATION_FILE"
TAG_NAME="$REF/$($DATE -d "$LAST_MODIFIED_TIMESTAMP" +%Y.%m.%d)"
if git tag | grep -q "$TAG_NAME" ; then
  echo "aborting: tag $TAG_NAME already exists"
  exit 1
else
  git tag --file="$ANNOTATION_FILE" "$TAG_NAME" HEAD
  git show "$TAG_NAME"
fi

