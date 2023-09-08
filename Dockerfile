FROM node:20-slim as build

#USER node
# Install Chrome
RUN apt update && apt install -y chromium
ENV CHROME_BIN='/usr/bin/chromium-browser'

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install -g @angular/cli@9.1.13

RUN npm install

COPY . .

RUN node --max_old_space_size=8192 ./node_modules/@angular/cli/bin/ng build --prod --output-path=dist

# use Angular CLI to trigger a test run so we have coverage data
RUN ./node_modules/.bin/ng test --watch=false --code-coverage


FROM nginx:1.17-alpine as web

COPY --from=build /usr/src/app/dist /usr/share/nginx/html

#COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
