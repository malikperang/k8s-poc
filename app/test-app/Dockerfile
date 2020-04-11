FROM node:10.13.0-alpine

# Create app directory
WORKDIR /srv/test-app/

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json /srv/test-app/

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]