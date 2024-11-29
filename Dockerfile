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

# Install gcloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update \
    && apt-get install -y google-cloud-sdk \
    && gcloud --version

# Copy Service Account Key (replace the path with your key file path if needed)
# Note: Ensure the key.json file is added during build time or passed securely.
COPY /Users/donggicai1991/Documents/einvoice/key/limit-storage/ai-jiabao-com-jw_storage.json /app/key.json

# Set GOOGLE_APPLICATION_CREDENTIALS environment variable
ENV GOOGLE_APPLICATION_CREDENTIALS="/app/key.json"
RUN gcloud auth activate-service-account --key-file=/app/key.json

# set up the app folder
WORKDIR /app

# copy all resources and executables file at /dist folder in builder container
COPY --from=builder /dist ./

WORKDIR /usr/bin
RUN ln -s /app/${APP_NAME} server

# set the entry point (application name)
CMD ["/usr/bin/server"]
