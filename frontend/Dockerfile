# ---------- Build ----------
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .
ARG API_URL
ENV API_URL=$API_URL

RUN npm run build

# ---------- Production ----------
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist/barber_booking_system/browser /usr/share/nginx/html

EXPOSE 80

CMD ["nginx","-g","daemon off;"]
