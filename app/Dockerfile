# --- Stage 1: Build Stage ---
# Use an official Node.js runtime as a parent image. Use a specific version for reproducibility.
FROM node:18-alpine AS builder

# Set the working directory in the container to /app
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# --- Stage 2: Production Stage ---
# Start from a clean, lightweight Node.js image
FROM node:18-alpine

WORKDIR /app

# Copy the installed dependencies from the builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy the application code (excluding development files)
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public

# The application needs permissions to talk to AWS. 
# We will grant these permissions to the EKS Node's IAM Role later.

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Define the command to run your app
CMD [ "node", "src/index.js" ]