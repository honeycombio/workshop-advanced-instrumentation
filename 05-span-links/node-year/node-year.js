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

  doSomeWork();

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

function sleepSync(wait_time) {
    var waitTill = new Date(new Date().getTime() + wait_time);
    while (waitTill > new Date()) {
    }
}

function getRandomInt(max) {
  return Math.floor(Math.random() * max) + 1;
}

async function doSomeWork() {

  const span = tracer.startSpan("some-work");

    span.setAttribute("otel", "rocks");
    // mock some work by sleeping
    await sleep(getRandomInt(250));
    // add span event and attributes
    span.addEvent("my event", { "more": "details" });
    await sleep(getRandomInt(150) + 100);
    span.addEvent("another event");

    generateLinkedTrace();

    span.end();
}

async function generateLinkedTrace() {

    let sourceSpan = trace.getSpan(context.active());
    // add links with the current span context
    // set root:true to not to use implicit context
    tracer.startActiveSpan("generated-span-root", {
        root: true,
        attributes: {"depth": 1},
        links: [{context: sourceSpan.spanContext()}]
    }, span => {
        sleepSync(getRandomInt(250));
        addRecursiveSpan(2, 5);
        span.end();
    });


}

async function addRecursiveSpan(depth, maxDepth) {

    tracer.startActiveSpan("generated-span", {attributes: {"depth": depth}}, span => {
        sleepSync(getRandomInt(250));
        if (depth < maxDepth) {
            addRecursiveSpan(depth + 1, maxDepth)
        }
        span.end();


    });

}

app.listen(PORT, HOST);
console.log(`Running node year service on http://${HOST}:${PORT}/year`);
