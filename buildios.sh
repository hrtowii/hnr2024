rm -rf Payload
flutter build ios --release --no-codesign
mkdir Payload
cp -r build/ios/Release-iphoneos/Runner.app Payload/Runner.app
zip -vr9 bruh.ipa Payload
