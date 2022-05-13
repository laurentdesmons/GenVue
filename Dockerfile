FROM mcr.microsoft.com/dotnet/core/aspnet:2.1 as base

FROM mcr.microsoft.com/dotnet/core/sdk:2.1 AS build
WORKDIR /src

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

COPY *.sln app/
COPY *.csproj app/
RUN dotnet restore app/GenVue.sln

COPY . .

RUN dotnet build /src/GenVue.sln -c Release -o /app/build 

FROM build as publish
RUN dotnet publish /src/GenVue.sln -c Release -o /app/publish --no-restore

FROM base as final
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:5000
WORKDIR /app
EXPOSE 5000
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "GenVue.dll"]
