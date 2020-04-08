// index.js

/**
 * Required External Modules
 */

const express = require("express");
const path = require("path");
const expressSession = require("express-session");
const passport = require("passport");
const Auth0Strategy = require("passport-auth0");
const { createProxyMiddleware } = require('http-proxy-middleware');
require("dotenv").config();
const authRouter = require("./auth");
var morgan = require('morgan')

morgan(':method :url :status :res[content-length] - :response-time ms')


// App Variables

const app = express();
const PORT = process.env.PORT || 8000; 

/*
const { routes } =  {
  "routes": [
    {
      "route": "/site",
      "address": "http://localhost:8000"
    },
    {
      "route": "/notebooks",
      "address": "http://localhost:8888"
    }
  ]
}
*/

// Session Configuration

const session = {
  secret: "LoxodontaElephasMammuthusPalaeoloxodonPrimelephas",
  cookie: {},
  resave: false,
  saveUninitialized: false
};

if (app.get("env") === "production") {
  // Serve secure cookies, requires HTTPS
  session.cookie.secure = true;
}

// Passport Configuration

const strategy = new Auth0Strategy(
  {
    domain: process.env.AUTH0_DOMAIN,
    clientID: process.env.AUTH0_CLIENT_ID,
    clientSecret: process.env.AUTH0_CLIENT_SECRET,
    callbackURL:
      process.env.AUTH0_CALLBACK_URL || "http://localhost:8000/callback"
  },
  function(accessToken, refreshToken, extraParams, profile, done) {
    /**
     * Access tokens are used to authorize users to an API
     * (resource server)
     * accessToken is the token to call the Auth0 API
     * or a secured third-party API
     * extraParams.id_token has the JSON Web Token
     * profile has all the information from the user
     */
    return done(null, profile);
  }
);

/**
 *  App Configuration
 */

app.set("views", path.join(__dirname, "views"));
app.set("view engine", "pug");
app.use(express.static(path.join(__dirname, "public")));

app.use(expressSession(session));

passport.use(strategy);
app.use(passport.initialize());
app.use(passport.session());

passport.use(strategy);
app.use(passport.initialize());
app.use(passport.session());

passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

// mouting morgan the loger
app.use(morgan('combined'))

// Creating custom middleware with Express
app.use((req, res, next) => {
  res.locals.isAuthenticated = req.isAuthenticated();
  next();
});

// Router mounting
app.use("/", authRouter);

/**
 * Routes Definitions
 */

const secured = (req, res, next) => {
  if (req.user) {
    return next();
  }
  req.session.returnTo = req.originalUrl;
  res.redirect("/login");
};

/*
for (route of routes) {
    app.use(route.route,
        proxy({
            target: route.address,
            pathRewrite: (path, req) => {
                return path.split('/').slice(2).join('/'); // Could use replace, but take care of the leading '/'
            }
        })
    );
}
*/



/* default route removed
app.get("/", (req, res) => {
  res.render("index", { title: "Home" });
});
*/

app.get("/user", secured, (req, res, next) => {
  const { _raw, _json, ...userProfile } = req.user;
  res.render("user", {
    title: "Profile",
    userProfile: userProfile
  });
});

// JuypterProxy middleware options
const options = {
  target: 'http://localhost:'PORT, // target host
  changeOrigin: true, // needed for virtual hosted sites
  ws: true, // proxy websockets
  router: {
    // when request.headers.host == 'dev.localhost:3000',
    // override target 'http://www.example.org' to 'http://localhost:8000'
    'localhost:'PORT: 'http://localhost:8888',
  },
};

// create JuypterProxy
const jupyterPoxy = createProxyMiddleware(options);

app.use('/site', secured,  express.static(path.join(__dirname, 'site')))   //KTB  3/31/20
app.use('/notebook', secured, jupyterPoxy);
app.use('/', secured,  express.static(path.join(__dirname, 'site')))
//app.use('/', secured,  express.static(path.join(__dirname, 'site')))   //KTB  3/31/20

//app.use('/api', createProxyMiddleware({ target: 'http://www.example.org', changeOrigin: true }));


// Server Activation

app.listen(PORT, () => {
  console.log(`Listening to requests on http://localhost:${PORT}`);
});
