# =========================
# Stage 1: Build React App
# =========================
FROM node:20-alpine AS build

WORKDIR /app

# Copy dependency files first (cache optimization)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code
COPY . .

# Build Vite app
RUN npm run build


# =========================
# Stage 2: Serve with Nginx
# =========================
FROM nginx:1.27-alpine

# Copy custom nginx config (SPA routing fix)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy build output
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
