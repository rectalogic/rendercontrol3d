# syntax = docker/dockerfile:1.2
# linux arm64 not supported by Qt https://doc.qt.io/qt-6/supported-platforms.html
FROM --platform=linux/amd64 ubuntu:jammy
LABEL maintainer=rectalogic

ENV container docker
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=C.UTF-8
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get -y update \
    && apt-get -y install build-essential cmake \
       libglx-mesa0 libglvnd-dev libxkbcommon-x11-0 libxkbcommon-dev libxcb-shape0 libpulse-dev libxcb1 libx11-xcb1 libxcb-glx0 \
       libxcb-icccm4 libxcb-image0 libxcb-render-util0 libxcb-keysyms1 \
       python3 python3-pip python3-venv \
       xvfb pkg-config \
       fontconfig fonts-liberation

ARG QT_VER=6.4.0

RUN mkdir -p /rendercontrol3d/build
COPY run.sh main.cpp CMakeLists.txt *.qml /rendercontrol3d/
WORKDIR /rendercontrol3d

RUN python3 -m venv venv && \
    venv/bin/pip install aqtinstall && \
    venv/bin/python -m aqt install-qt linux desktop ${QT_VER} -m qtquick3d qtshadertools qtquicktimeline -O qt
RUN cd build && cmake -DCMAKE_PREFIX_PATH=$PWD/../qt/${QT_VER}/gcc_64 .. && cmake --build .

RUN ldconfig

ENTRYPOINT ["/usr/bin/xvfb-run"]
CMD ["/rendercontrol3d/run.sh"]
