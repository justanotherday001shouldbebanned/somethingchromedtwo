FROM jupyter/base-notebook:latest

USER root

# Install system dependencies including those needed for Forgejo
RUN apt-get update && \
    apt-get install -y wget gnupg2 git sqlite3 && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable

# Install Forgejo
RUN adduser --disabled-password --gecos '' forgejo --home /opt/forgejo && \
    mkdir -p /opt/forgejo && \
    chown forgejo:forgejo /opt/forgejo

USER forgejo
WORKDIR /opt/forgejo

# Download and install Forgejo binary
RUN wget -O forgejo https://code.forgejo.org/forgejo/forgejo/releases/download/v7.0.0/forgejo-7.0.0-linux-amd64 && \
    chmod +x forgejo

# Initialize Forgejo database and configuration
RUN mkdir -p /opt/forgejo/data /opt/forgejo/conf && \
    ./forgejo web --install-port=3000 --work-path /opt/forgejo &

USER root

# Create a startup script that runs both Jupyter and Forgejo
RUN echo '#!/bin/bash\n\
/opt/forgejo/forgejo web --work-path /opt/forgejo &\n\
start-notebook.sh' > /usr/local/bin/start-services.sh && \
    chmod +x /usr/local/bin/start-services.sh

USER ${NB_UID}

# Override the default command to start both services
CMD ["/usr/local/bin/start-services.sh"]
