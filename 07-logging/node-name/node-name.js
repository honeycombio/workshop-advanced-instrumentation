'use strict';

const express = require("express");
const fetch = require("node-fetch");
const pino = require("pino");
const { trace, context } = require("@opentelemetry/api");

const PORT = 6002;
const HOST = "0.0.0.0";

const app = express();
const namesByYear = {
    2015: ["sophia", "jackson", "emma", "aiden", "olivia", "liam", "ava", "lucas", "mia", "noah"],
    2016: ["sophia", "jackson", "emma", "aiden", "olivia", "lucas", "ava", "liam", "mia", "noah"],
    2017: ["sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "lucas"],
    2018: ["sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "caden"],
    2019: ["sophia", "liam", "olivia", "jackson", "emma", "noah", "ava", "aiden", "aria", "grayson"],
    2020: ["olivia", "noah", "emma", "liam", "ava", "elijah", "isabella", "oliver", "sophia", "lucas"],
}

const logger = pino({
    level: "debug",
    mixin() {
        const activeSpan = trace.getSpan(context.active());
        return activeSpan ? { trace_id: activeSpan.spanContext().traceId } : {};
    }
})

app.get("/", async (req, res) => {
    res.setHeader("content-type", "text/html");
    res.send("service: <a href='/name'>/name</a>");
});

app.get("/name", async (req, res) => {
    res.setHeader("content-type", "application/json");
    logger.info("get_name received");

    const year = await getYear();
    const name = getName(year);

    logger.debug(`get_year generated: Year: ${year}`);
    logger.debug(`name randomly chosen: ${name}`);

    res.json({
        "language": "node",
        "year": year,
        "name": name,
        "generated": new Date().toISOString()
    });
});

async function getYear() {
    try {
        const response = await fetch('http://localhost:6001/year');
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        return data.year;
    } catch (error) {
        logger.error(`Error fetching year: ${error}`);
        return null;
    }
}

function getName(year) {
    const names = namesByYear[year];
    const rnd = Math.floor(Math.random() * names.length);
    return names[rnd];
}

function getRandomInt(max) {
    return Math.floor(Math.random() * max) + 1;
}

app.listen(PORT, HOST);
console.log(`Running node year service on http://${HOST}:${PORT}/year`);
