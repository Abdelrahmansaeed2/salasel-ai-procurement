#!/bin/bash
while true; do
  curl -s -I https://salasel.otlob-egy.online/api/health | head -n 1
  sleep 10
done
