'use strict';

const express = require("express");

const PORT = 6001;
const HOST = "0.0.0.0";
const app = express();
const years = [2015, 2016, 2017, 2018, 2019, 2020];

app.get("/", async (req, res) => {
  res.setHeader("content-type", "text/html");
  res.send("service: <a href='/year'>/year</a>");
});

app.get("/year", async (req, res) => {
  res.setHeader("content-type", "application/json");
  const year = await getYear(years);
  res.json({"language": "node", "year": year});
});

async function getYear() {

  const rnd = Math.floor(Math.random() * years.length);
  const year = years[rnd];

  await sleep(getRandomInt(250));

  return year;
}

function sleep(wait_time) {
  // mock some work by sleeping
  return new Promise((resolve) => {
    setTimeout(resolve, wait_time);
  })
}

function getRandomInt(max) {
  return Math.floor(Math.random() * max) + 1;
}

app.listen(PORT, HOST);
console.log(`Running node year service on http://${HOST}:${PORT}/year`);