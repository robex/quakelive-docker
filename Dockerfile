FROM debian:bookworm-slim AS build

WORKDIR /app
RUN apt-get update && apt-get install -y python3-dev build-essential git sed

RUN git clone https://github.com/tjone270/minqlxtended.git
WORKDIR /app/minqlxtended
RUN sed -i '/"unix_socket_path": address\[0\] if unix_socket else None,/d' ./python/minqlxtended/database.py
RUN make


FROM debian:bookworm-slim AS prod

WORKDIR /app

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get upgrade -y && apt-get install -y libstdc++6:i386 libc6:i386 lib32z1 wget sed git python3 python3-dev python3-pip

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    steam

RUN chown -R steam:steam /app
USER steam

ENV HOME="/app"

RUN wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
RUN tar -xvzf steamcmd_linux.tar.gz
RUN ./steamcmd.sh +force_install_dir /app/Steam/steamapps/common/qlds +login anonymous +@sSteamCmdForcePlatformType linux +app_update 349090 +quit

COPY --chown=steam:steam ./server-config/server.cfg.default /app/Steam/steamapps/common/qlds/baseq3/server.cfg

COPY --chown=steam:steam --from=build /app/minqlxtended/bin/minqlxtended.zip /app/Steam/steamapps/common/qlds/
COPY --chown=steam:steam --from=build /app/minqlxtended/bin/run_server_x64_minqlxtended.sh /app/Steam/steamapps/common/qlds/
COPY --chown=steam:steam --from=build /app/minqlxtended/bin/minqlxtended.x64.so /app/Steam/steamapps/common/qlds/

WORKDIR /app/Steam/steamapps/common/qlds

RUN chmod +x ./run_server_x64_minqlxtended.sh
RUN git clone https://github.com/tjone270/minqlxtended-plugins.git
RUN python3 -m pip install -r minqlxtended-plugins/requirements.txt --break-system-packages

COPY --chown=steam:steam ./entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]

