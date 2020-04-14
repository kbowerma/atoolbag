// index.js

// Required External Modules

  const express = require("express");
  const path = require("path");
  const expressSession = require("express-session");
  const passport = require("passport");
  const Auth0Strategy = require("passport-auth0");
  const { createProxyMiddleware } = require('http-proxy-middleware');
  require("dotenv").config();
  const authRouter = require("./auth");
  var morgan = require('morgan')
 

// App Variables

  morgan(':method :url :status :res[content-length] - :response-time ms')
  const app = express();
  //const port =  "8000";
  const port = process.env.PORT || process.env.STATIC_PORT;


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
        process.env.AUTH0_CALLBACK_URL
    },
    function(accessToken, refreshToken, extraParams, profile, done) {
      return done(null, profile);
    }
  );



// App Configuration

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

// mounting morgan the logger
  app.use(morgan('combined'))

// Creating custom middleware with Express
  app.use((req, res, next) => {
    res.locals.isAuthenticated = req.isAuthenticated();
    next();
  });

// Router mounting
 app.use("/", authRouter);

// Routes Definitions
 
  const secured = (req, res, next) => {
    if (req.user) {
      return next();
    }
    req.session.returnTo = req.originalUrl;
    res.redirect("/login");
  };



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
  const tragetValue = `http://${process.env.THIS_HOST}:${port}` // 'http://localhost:8000'  4/14 changed strom STATIC_PORT to port for heroku 
  const customRouter = function (req) {
    const routervalue = `http://${process.env.THIS_HOST}:${process.env.JUPYTER_PORT}` // 'http://localhost:8888'
    return routervalue;
  }
  const options = {
    target: tragetValue, // target host
    changeOrigin: true, // needed for virtual hosted sites
    ws: true, // proxy websockets
    router: customRouter,
    //router: {
      // when request.headers.host == 'dev.localhost:3000',
      // override target 'http://www.example.org' to 'http://localhost:8000'
    //},
  };

  // create JuypterProxy
  const jupyterPoxy = createProxyMiddleware(options);

  app.use('/site', secured,  express.static(path.join(__dirname, '../www/site')))   //KTB  3/31/20
  app.use('/notebook', secured, jupyterPoxy);
  app.use('/', secured,  express.static(path.join(__dirname, '../www/site')))
  //app.use('/', secured,  express.static(path.join(__dirname, 'site')))   //KTB  3/31/20

  //app.use('/api', createProxyMiddleware({ target: 'http://www.example.org', changeOrigin: true }));


// Server Activation
 
  app.listen(port, () => {
    console.log(`Listening to requests on http://localhost:${port}`);
  });
