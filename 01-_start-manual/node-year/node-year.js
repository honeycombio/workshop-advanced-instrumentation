'use strict';

const express = require('express');
function sleep(wait_time) {
  // mock some work by sleeping
  return new Promise((resolve, reject) => {
    setTimeout(resolve, wait_time);
  })
}
function getRandomInt(max) {
  return Math.floor(Math.random() * max) + 1;
}

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

async function determineYear() {

  const rnd = Math.floor(Math.random() * years.length);
  const year = years[rnd];

  await sleep(getRandomInt(250));

  return year;
}

app.listen(PORT, HOST);
console.log(`Running node year service on http://${HOST}:${PORT}`);