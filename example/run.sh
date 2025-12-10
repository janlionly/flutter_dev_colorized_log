#!/bin/bash

export PUB_HOSTED_URL=https://pub.dev
export FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

flutter clean
flutter pub get
