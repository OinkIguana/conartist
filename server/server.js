'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const express = require("express");
const bodyParser = require("body-parser");
const api_1 = require("./api");
const app = express();
app.listen(process.env.PORT || 8080, () => {
    console.log('Server is listening on port 8080');
});
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/api', api_1.default);
app.use('/', express.static('public_html'));