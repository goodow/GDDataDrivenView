#!/usr/bin/env bash
# --js_out=import_style=commonjs,binary:.
protoc --objc_out=GDDataDrivenView/Generated/goodow/data-driven -Iprotos -IExample/Pods/GDChannel/protos \
 protos/goodow_extras_option.proto \
 protos/firebase_log_event.proto

protoc --objc_out=Example/GDDataDrivenView/Router -IExample/GDDataDrivenView/Router \
 Example/GDDataDrivenView/Router/view_model.proto