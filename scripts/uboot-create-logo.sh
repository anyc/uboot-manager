#! /bin/bash

# create a uboot logo from a jpg or png image
#
# Written by Mario Kicherer (http://kicherer.org)

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
	echo "usage: ${0##*/} INPUT.png|INPUT.jpg" >&2
	exit 2
fi
IN=$1
OUT=splash.bmp

EXT=${IN##*.}

case "${EXT}" in
	png) CONV=pngtopnm ;;
	jpg|jpeg) CONV=jpegtopnm ;;
	*) echo "unsupported input format: ${EXT}" >&2; exit 2 ;;
esac

if ! command -v "${CONV}" >/dev/null 2>&1; then
	echo "error, ${CONV} not found"
	exit 1
fi


# uncompressed images seem to be more reliable
#"${CONVBIN}" "${IN}" | ppmquant 220 | ppmtobmp -bpp 8 | gzip -9 > "${OUT}"

for tool in ppmquant ppmtobmp; do
	command -v "$tool" >/dev/null 2>&1 || { echo "error, ${tool} not found" >&2; exit 1; }
done
set -o pipefail
"${CONV}" "${IN}" | ppmquant 220 | ppmtobmp -bpp 8 > "${OUT}"
