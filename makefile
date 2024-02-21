tart-image:
	packer build -var-file="tart/variables.pkrvars.hcl" tart/xcode-nix.pkr.hcl

pod-install:
	yarn nx pod-install mobile

build-ios:
	yarn nx build-ios mobile

build-android:
	chmod 755 apps/mobile/android/gradlew
	yarn nx build-android mobile
