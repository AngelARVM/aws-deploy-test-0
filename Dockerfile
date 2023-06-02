###############################
# Build for local development #
###############################

FROM node:18-alpine As development

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY --chown=node:node package*.json ./

RUN npm ci

# Bundle app source
COPY --chown=node:node . .

# Use the node user from the image (instead the root user)
USER node

###############################
# Build for production        #
###############################

FROM node:18-alpine As build

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY --chown=node:node package*.json ./

# Copy node_modules from development in order to have nesjs cli available to run build
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

COPY --chown=node:node . .

# Build the app
RUN npm run build

# Set the NODE_ENV to production
ENV NODE_ENV=production

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Use the node user from the image (instead the root user)
USER node

###############################
# Production                  #
###############################

FROM node:18-alpine As production

# Copy the bundle from build stage to production image
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules

COPY --chown=node:node --from=build /usr/src/app/dist ./dist

EXPOSE 3000

# Start the server
CMD ["node", "dist/main"]