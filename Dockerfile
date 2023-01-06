
# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.187.0/containers/javascript-node/.devcontainer/base.Dockerfile

# [Choice] Node.js version: 16, 14, 12
ARG VARIANT="16-buster"
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:0-${VARIANT}

# The javascript-node image includes a non-root node user with sudo access. Use
# the "remoteUser" property in devcontainer.json to use it. On Linux, the container
# user's GID/UIDs will be updated to match your local UID/GID when using the image
# or dockerFile property. Update USER_UID/USER_GID below if you are using the
# dockerComposeFile property or want the image itself to start with different ID
# values. See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Alter node user as needed, install tslint, typescript. eslint is installed by javascript image
RUN if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \ groupmod --gid $USER_GID $USERNAME \
&& usermod --uid $USER_UID --gid $USER_GID $USERNAME \
&& chown -R $USER_UID:$USER_GID /home/$USERNAME; \ 
fi \
#

# Install global node modules for SAP CAP and frontend development.
# Install tslint, typescript. eslint is installed by javascript image
&& sudo -u ${USERNAME} npm install -g typescript \
&& sudo -u ${USERNAME} npm install -g node-ts \
&& sudo -u ${USERNAME} npm install -g tslint \
&& sudo -u ${USERNAME} npm install -g @sap/cds-dk \
&& sudo -u ${USERNAME} npm install -g @ui5/cli \
&& sudo -u ${USERNAME} npm install -g yo \
&& sudo -u ${USERNAME} npm install -g @sapui5/generator-sapui5-templates \
&& sudo -u ${USERNAME} npm install -g @sap/generator-base-mta-module \
&& sudo -u ${USERNAME} npm install -g @sap/generator-cap-project \
&& sudo -u ${USERNAME} npm install -g @sap/generator-fiori \
&& sudo -u ${USERNAME} npm install -g @sap/generator-hdb-project \
&& sudo -u ${USERNAME} npm install -g mbt \
&& sudo -u ${USERNAME} npm install -g hana-cli


# *********************************************************************
# * Uncomment this section to use RUN to install other dependencies. *
# * See https://aka.ms/vscode-remote/containers/dockerfile-run *
# *********************************************************************

# Prepare for apt-based install of Cloud Foundry CLI by adding Cloud Foundry Foundation public key & package repository
# (see https://docs.cloudfoundry.org/cf-cli/install-go-cli.html#pkg-linux).
RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add - ; \ 
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \ 
&& apt-get -y install sqlite3 cf-cli \ 
# Install extra tools for CAP development & deployment.
# && apt-get -y install --no-install-recommends sqlite cf-cli
# Clean up 
&& apt-get autoremove -y \ 
&& apt-get clean -y \ 
&& rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Uncomment to default to non-root user
USER $USER_UID
