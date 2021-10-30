'use strict';

const express = require('express');

// Constants
const PORT = 6001;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/year', async (req, res) => {
  const year = await determineYear(years);
  res.send(`${year}`);
});

const years = [2015, 2016, 2017, 2018, 2019, 2020];

function determineYear() {
  return years[Math.floor(Math.random() * years.length)];
}

app.listen(PORT, HOST);
console.log(`Running node year service on http://${HOST}:${PORT}`);