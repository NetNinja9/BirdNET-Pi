#!/usr/bin/env bash
set -x
source /etc/birdnet/birdnet.conf

STAMP="%H:%M:%S"

[ -z $RECORDING_LENGTH ] && RECORDING_LENGTH=15

if [ ! -z $RTSP_STREAM ];then
  while true;do
    ffmpeg -i  $RTSP_STREAM -t 15 -vn -acodec pcm_s16le -ac 2 -ar 48000 file:${RECS_DIR}/$(date "+%F")-birdnet-$STAMP.wav
  done
else
  if ! pulseaudio --check;then pulseaudio --start;fi
  if pgrep arecord &> /dev/null ;then
    echo "Recording"
  else
    until grep 5050 <(netstat -tulpn 2>&1);do
      sleep 1
    done
    if [ -z ${REC_CARD} ];then
      arecord -f S16_LE -c${CHANNELS} -r48000 -t wav --max-file-time ${RECORDING_LENGTH}\
        --use-strftime ${RECS_DIR}/%B-%Y/%d-%A/%F-birdnet-${STAMP}.wav
    else
      arecord -f S16_LE -c${CHANNELS} -r48000 -t wav --max-file-time ${RECORDING_LENGTH}\
        -D "${REC_CARD}" --use-strftime \
        ${RECS_DIR}/%B-%Y/%d-%A/%F-birdnet-${STAMP}.wav
    fi
fi
