cd ..
curl https://raw.githubusercontent.com/appculture/xcode-project-renamer/master/Sources/main.swift -o rename.swift && chmod +x rename.swift
./rename.swift "iOSBaseSource" "$1"
