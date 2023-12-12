FROM ubuntu:22.04

ARG SSH_KEY

SHELL ["/bin/bash", "-c"]

RUN apt update

RUN apt install git openssh-client bash -y
RUN mkdir -p /root/.ssh && chmod 0700 /root/.ssh && ssh-keyscan github.com > /root/.ssh/known_hosts
WORKDIR /

RUN echo "$SSH_KEY" > /root/.ssh/id_rsa && chmod 0600 /root/.ssh/id_rsa
RUN git clone git@github.com:janos-torba-nix/actions-skillup.git
RUN rm -f /root/.ssh/id_rsa

WORKDIR /actions-skillup
RUN useradd -ms /bin/bash newuser
RUN chown -R newuser: /actions-skillup

RUN apt install unzip curl zip -y
USER newuser

RUN curl -s "https://get.sdkman.io" | bash
RUN ln -s "/home/newuser/.sdkman/bin/sdkman-init.sh" "init.sh"
RUN source "init.sh" && sdk install java 11.0.16-zulu
RUN source "init.sh" && sdk install gradle 7.4
RUN source "init.sh" && ./gradlew :spotlessApply
RUN source "init.sh" && ./gradlew build
