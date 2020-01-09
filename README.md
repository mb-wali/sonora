# sonora

The new UI for the Discovery Environment

## Configuration

Configuration files are located in the `config/` directory. You can override the default configuration values (located in `config/default.yml`) by creating a local configuration file as described at https://github.com/lorenwest/node-config/wiki/Configuration-Files. The `.gitignore` file has entries to ignore local and production configs that are named with the conventions described at that link.

Additionally, the `NODE_ENV` environment variable can be set to `production` if you need to run a production-ready build.

## Commands

**Start development server** - ```npm run dev```

**Production build** -  ```npm run build```

**Production start** - ```npm run start```

Check the scripts in `packages.json` for more options.
