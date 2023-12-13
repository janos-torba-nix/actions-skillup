docker build -t ubuntugradle --squash --build-arg SSH_KEY="$(cat ~/.ssh/id_rsa)" .
# --no-cache