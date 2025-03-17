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

@RestController
public class NameController {

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

        int year = getYear();
        String[] names = NAMES_BY_YEAR.get(year);
        int rnd = generator.nextInt(names.length);
        String name = names[rnd];

        Map<String, Object> response = new HashMap<>();
        response.put("language", "Java");
        response.put("year", year);
        response.put("name", name);
        response.put("generated", LocalDateTime.now());

        return response;
    }

    public int getYear() {
        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:6001/year";

        ResponseEntity<YearResponse> response = restTemplate.getForEntity(url, YearResponse.class);
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
