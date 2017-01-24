FROM chemsorly/msbuilder:latest
MAINTAINER chemso@gmx.de 
# Original author alexellis2@gmail.com, see http://blog.alexellis.io/3-steps-to-msbuild-with-docker/

# docker push chemsorly/msbuild-builder:4.5
SHELL ["powershell"]

# Note: Install full VSC installation
RUN Invoke-WebRequest "https://download.microsoft.com/download/0/B/C/0BC321A4-013F-479C-84E6-4A2F90B11269/vs_community.exe" -OutFile "$env:TEMP\vsc.exe" -UseBasicParsing
RUN Start-Process "$env:TEMP\vsc.exe" '/full /q' -wait