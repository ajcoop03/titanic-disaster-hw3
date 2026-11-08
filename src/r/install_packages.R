# R package requirements (like requirements.txt)
packages <- c(
  "dplyr" = "1.1.4",
  "readr" = "2.1.5"
)

install.packages("remotes", repos = "https://cloud.r-project.org")
for (pkg in names(packages)) {
  remotes::install_version(pkg, version = packages[[pkg]], repos = "https://cloud.r-project.org")
}
