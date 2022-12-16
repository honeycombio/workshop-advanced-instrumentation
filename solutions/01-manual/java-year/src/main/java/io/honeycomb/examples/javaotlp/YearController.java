package io.honeycomb.examples.javaotlp;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;
import io.opentelemetry.instrumentation.annotations.WithSpan;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Random;

@RestController
public class YearController {

    private static final String[] YEARS = new String[]{"2015", "2016", "2017", "2018", "2019", "2020"};
    private static final Random generator = new Random();

    @RequestMapping("/year")
    public String index() {
        try {
            Thread.sleep(generator.nextInt(250));
        } catch (InterruptedException e) {
            Span.current().setStatus(StatusCode.ERROR); // set span status
            ;
        }

        Span.current().setAttribute("foo", "bar"); // set span attribute

        doSomeWork();

        return getYear();
    }

    @WithSpan("random-year") // create span
    public String getYear() {
        int rnd = generator.nextInt(YEARS.length);
        Span.current().setAttribute("random-index", rnd); // get the span and add an attribute

        try {
            Thread.sleep(generator.nextInt(250));
        } catch (InterruptedException e) {
            Span.current().setStatus(StatusCode.ERROR); // set status
            ;
        }
        return YEARS[rnd];
    }

    public void doSomeWork() {
        //Step 1: Aquiring a tracer
        Tracer tracer = GlobalOpenTelemetry.getTracer("");
        //Step 2: Creating a manual span
        Span span = tracer.spanBuilder("some-work").startSpan(); // manually start a span
        try (Scope scope = span.makeCurrent()) { // make it the current span in function scope
            span.setAttribute("otel", "rocks"); // Step 3: set attribute
            Thread.sleep(generator.nextInt(250));
        } catch (Throwable t) {
            span.setStatus(StatusCode.ERROR); // set status
        } finally {
            span.end();
        }

    }


}
