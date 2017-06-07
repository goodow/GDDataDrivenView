# --js_out=import_style=commonjs,binary:.
protoc --objc_out=GDDataDrivenView/Generated/goodow/data-driven -Iprotos -IExample/Pods/GDChannel/protos \
 protos/goodow_extras_option.proto \
 protos/firebase_log_event.proto