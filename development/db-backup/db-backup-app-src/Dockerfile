FROM ubuntu:latest

# Update Base and install required packages
RUN apt-get update && apt-get upgrade -y && apt-get install mysql-client davfs2 fuse ssmtp aha rsync curl -y

# Copy app content
# Use the .dockerignore file to control what ends up inside the image!
WORKDIR /usr/local/bin
COPY backup-db.sh .

# Inject default values if uploads and modules are mounted with empty directories, import default database and insert settings stated in env's and 
# adjust rights and start the server
# CMD ["sh", "/usr/local/bin/backup-db.sh"]

# Only for developing
ENTRYPOINT ["tail", "-f", "/dev/null"]