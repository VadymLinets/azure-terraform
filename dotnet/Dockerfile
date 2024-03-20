# Use the official .NET SDK image as a base image
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env

# Set the working directory in the container
WORKDIR /app

# Copy the C# project file and restore any dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the remaining source code
COPY . ./

# Build the C# application
RUN dotnet publish -c Release -o out

# Generate runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0

# Set the working directory in the container
WORKDIR /app

# Copy the built application from the previous stage
COPY --from=build-env /app/out .

# Set the entry point for the container
ENTRYPOINT ["dotnet", "hello.dll"]
