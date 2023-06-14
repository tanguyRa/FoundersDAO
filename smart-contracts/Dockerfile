FROM node:18

WORKDIR /app/src

COPY package*.json .
RUN npm install

COPY hardhat.config.js hardhat.config.js

COPY contracts/ contracts/
COPY test/ test/
COPY scripts/ scripts/

COPY data/artifacts/ artifacts/
COPY data/cache cache/

COPY .env .env