package io.honeycomb.examples.javaotlp;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Context;
import io.opentelemetry.context.Scope;
import io.opentelemetry.instrumentation.annotations.WithSpan;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.logging.Handler;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.SimpleFormatter;

@RestController
public class NameController {

    // add a logger
    private static final Logger logger = Logger.getLogger(NameController.class.getName());

    static {
        logger.setLevel(Level.FINE);
        // create and configure handler
        Handler handler = new ConsoleHandler();
        handler.setLevel(Level.FINE);
        // create and set formatter
        Formatter formatter = new SimpleFormatter();
        handler.setFormatter(formatter);
        // add handler to logger
        logger.addHandler(handler);
    }

    private static final int[] YEARS = new int[]{2015, 2016, 2017, 2018, 2019, 2020};
    private static final Map<Integer, String[]> NAMES_BY_YEAR = Map.ofEntries(
            Map.entry(2015, new String[]{"sophia", "jackson", "emma", "aiden", "olivia", "liam", "ava", "lucas", "mia", "noah"}),
            Map.entry(2016, new String[]{"sophia", "jackson", "emma", "aiden", "olivia", "lucas", "ava", "liam", "mia", "noah"}),
            Map.entry(2017, new String[]{"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "lucas"}),
            Map.entry(2018, new String[]{"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "caden"}),
            Map.entry(2019, new String[]{"sophia", "liam", "olivia", "jackson", "emma", "noah", "ava", "aiden", "aria", "grayson"}),
            Map.entry(2020, new String[]{"olivia", "noah", "emma", "liam", "ava", "elijah", "isabella", "oliver", "sophia", "lucas"})
    );
    private static final Random generator = new Random();

    @RequestMapping(value="/", produces="text/html")
	public String index() {
		return "service: <a href='/year'>/year</a>";
	}

    @RequestMapping("/name")
    public Map<String, Object> name() {

        logger.info("/name");
        int year = getYear();
        String[] names = NAMES_BY_YEAR.get(year);
        int rnd = generator.nextInt(names.length);
        logger.fine("getting year: " + year);
        String name = names[rnd];
        logger.fine("gettingname: " + name);

        Map<String, Object> response = new HashMap<>();
        response.put("language", "Java");
        response.put("year", year);
        response.put("name", name);
        response.put("generated", LocalDateTime.now());

        return response;
    }

    public int getYear() {
        RestTemplate restTemplate = new RestTemplate();
        logger.fine("getting year from year service.");
        String url = "http://localhost:6001/year";

        ResponseEntity<YearResponse> response = restTemplate.getForEntity(url, YearResponse.class);
        logger.fine("year response: " + response.getBody().getYear());
        return response.getBody().getYear();
    }

    // DTO Class for JSON mapping
    private static class YearResponse {
        private int year;

        public int getYear() {
            return year;
        }

        public void setYear(int year) {
            this.year = year;
        }
    }
}
