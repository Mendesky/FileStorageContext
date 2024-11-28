#------- build -------
FROM swift:latest AS builder

# set up the workspace
WORKDIR /workspace

ENV APP_NAME="FileStorageContextServer"
ENV BUILD_FOLDER="/workspace/.build/release"

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
# copy the workspace to the docker image
COPY . /workspace

RUN --mount=type=ssh swift build -c release --static-swift-stdlib

# set up the dist folder
WORKDIR /dist

# copy the app executable file to dist
RUN cp ${BUILD_FOLDER}/${APP_NAME} ./

# copy the resources in all targets what has the postfix with ".resources" to dist.
RUN find -L ${BUILD_FOLDER}/ -regex '.*\.resources$' -exec cp -Ra {} ./ \;

#------- package -------
FROM swift:slim
ENV APP_NAME="FileStorageContextServer"

# set up the app folder
WORKDIR /app

# copy all resources and executables file at /dist folder in builder container
COPY --from=builder /dist ./

WORKDIR /usr/bin
RUN ln -s /app/${APP_NAME} server

# set the entry point (application name)
CMD ["/usr/bin/server"]

