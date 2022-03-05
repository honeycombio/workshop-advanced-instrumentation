'use strict';

const { trace, context } = require("@opentelemetry/api");
const express = require("express");

// Constants
const PORT = 6001;
const HOST = "0.0.0.0";
const tracer = trace.getTracer("node-year.js");

// App
const app = express();
app.get("/year", async (req, res) => {

  let activeSpan = trace.getSpan(context.active());
  activeSpan.setAttribute("foo", "bar");
  doSomeWork();
  const year = await getYear(years);

  res.send(`${year}`);
});


function sleep(wait_time) {
  // mock some work by sleeping
  return new Promise((resolve, reject) => {
    setTimeout(resolve, wait_time);
  })
}
function getRandomInt(max) {
  return Math.floor(Math.random() * max) + 1;
}

async function doSomeWork() {

  const span = tracer.startSpan("some-work");

  span.setAttribute("otel", "rocks");
  // mock some work by sleeping
  await sleep(getRandomInt(250));
  span.addEvent("my event", { "more": "details" });
  await sleep(getRandomInt(150) + 100);
  span.addEvent("another event");
  span.end();
}

const years = [2015, 2016, 2017, 2018, 2019, 2020];

async function getYear() {

  const span = tracer.startSpan("getYear");

  const rnd = Math.floor(Math.random() * years.length);
  const year = years[rnd];

  span.setAttributes({ "year": year, "random-index": rnd });

  await sleep(getRandomInt(250));

  span.end();

  return year;
}

app.listen(PORT, HOST);
console.log(`Running node year service on http://${HOST}:${PORT}`);



