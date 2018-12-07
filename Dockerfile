FROM node:8.12-stretch as build-stage
LABEL maintainer="Mohammed Essehemy <mohammedessehemy@gmail.com>"

ENV METEOR_ALLOW_SUPERUSER=true

WORKDIR /source

ADD ./ /source/

RUN curl https://install.meteor.com/ | sh && \
    meteor npm install --production && \
    meteor build --server-only --architecture os.linux.x86_64 --directory /build


FROM node:8.12-alpine
LABEL maintainer="Mohammed Essehemy <mohammedessehemy@gmail.com>"

ENV METEOR_NPM_REBUILD_FLAGS="--update-binary --build-from-source=bcrypt"

COPY --from=build-stage /build /home/node

WORKDIR /home/node/bundle


RUN apk --update --no-cache add --virtual builds-deps libgcc libstdc++ linux-headers make python gcc g++ git libuv bash curl tar bzip2 build-base && \
    npm install node-gyp -g && \
    cd ./programs/server/ && \
    npm install --unsafe-perm && \
    npm audit fix && \
    npm cache clean --force && \
    apk del builds-deps


USER node

EXPOSE 3000

CMD node /home/node/bundle/main.js
