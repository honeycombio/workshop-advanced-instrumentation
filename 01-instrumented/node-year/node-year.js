'use strict';

const { trace, context } = require("@opentelemetry/api");
const express = require("express");

const PORT = 6001;
const HOST = "0.0.0.0";

const tracer = trace.getTracer("node-year"); // get tracer and name it
const app = express();
const years = [2015, 2016, 2017, 2018, 2019, 2020];

app.get("/", async (req, res) => {
  res.setHeader("content-type", "text/html");
  res.send("service: <a href='/year'>/year</a>");
});

app.get("/year", async (req, res) => {
  let activeSpan = trace.getSpan(context.active()); // get active span
  activeSpan.setAttribute("foo", "bar"); // set attributes on active span

  res.setHeader("content-type", "application/json");
  const year = await getYear(years);
  res.json({
    "language": "node",
    "year": year,
    "generated": new Date().toISOString()
  });
});

async function getYear() {

  const span = tracer.startSpan("getYear"); // start span

  const rnd = Math.floor(Math.random() * years.length);
  const year = years[rnd];

  span.setAttributes({ "year": year, "random-index": rnd }); // add attributes to span

  await sleep(getRandomInt(250));

  span.end(); // end span

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
