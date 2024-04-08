# Use Node.js version 16
FROM node:16

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Bundle app source
COPY . .

# Expose port 3000 to the outside once the container has launched
EXPOSE 3000

# Define the command to run your app
CMD [ "node", "app.js" ]
