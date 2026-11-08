# R image for the Titanic logistic regression
FROM rocker/r-ver:4.4.1

# All work happens in /app inside the container
WORKDIR /app

# Install pinned packages first (cached unless install_packages.R changes)
COPY install_packages.R .
RUN Rscript install_packages.R

# Copy the script
COPY titanic.R .

# Data is NOT copied in; it is mounted at /app/data at run time:
#   docker run --rm -v "$(pwd)/src/data:/app/data" titanic-r
CMD ["Rscript", "titanic.R"]
