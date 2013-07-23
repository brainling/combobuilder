bundle @args
gem uninstall sqlite3 -a
$optDir = @{$true = $env:SQLITE3_DIR; $false = 'd:/code/sqlite3'}[(Test-Path Env:\SQLITE3_DIR)]
gem install sqlite3 --platform=ruby -- --with-opt-dir=$optDir
