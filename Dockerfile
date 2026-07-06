# === שלב 1: בניית ה-Frontend (React) ===
FROM node:18-alpine AS frontend-build
WORKDIR /client
COPY clientapp/package*.json ./
RUN npm install
COPY clientapp/ ./
RUN npm run build

# === שלב 2: בנייה של ה-Backend (.NET Core) ===
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS backend-build
WORKDIR /src
COPY ["WebApiServer/WebApiServer.csproj", "WebApiServer/"]
RUN dotnet restore "WebApiServer/WebApiServer.csproj"
COPY WebApiServer/ ./WebApiServer/
WORKDIR "/src/WebApiServer"
RUN dotnet publish "WebApiServer.csproj" -c Release -o /app/publish

# === שלב 3: אימג' הריצה הסופי באמצעות שרת Nginx ===
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# ניקוי קבצי ברירת המחדל
RUN rm -rf ./*

# יצירת תת-התיקייה app שהדפדפן דורש, והעתקת קבצי ה-React לתוכה ולשורש
RUN mkdir -p app
COPY --from=frontend-build /client/dist ./app/
COPY --from=frontend-build /client/dist .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]