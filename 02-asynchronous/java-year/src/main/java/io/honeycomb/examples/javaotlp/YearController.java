package io.honeycomb.examples.javaotlp;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Context;
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
            Span.current().setStatus(StatusCode.ERROR);
            ;
        }

        Span.current().setAttribute("foo", "bar");

        Runnable runnable = () -> {
            doSomeWork();
        };
        // create a thread and wrap it in current context
        // each thread in Java gets its own context so we need to specify 
        // current context
        new Thread(Context.current().wrap(runnable)).start();

        return getYear();
    }

    @WithSpan("random-year")
    public String getYear() {
        int rnd = generator.nextInt(YEARS.length);
        Span.current().setAttribute("random-index", rnd);

        try {
            Thread.sleep(generator.nextInt(250));
        } catch (InterruptedException e) {
            Span.current().setStatus(StatusCode.ERROR);
            ;
        }
        return YEARS[rnd];
    }

    public void doSomeWork() {
        Tracer tracer = GlobalOpenTelemetry.getTracer("");

        Span span = tracer.spanBuilder("some-work").startSpan();
        try (Scope scope = span.makeCurrent()) {
            span.setAttribute("otel", "rocks");
            Thread.sleep(500);
        } catch (Throwable t) {
            span.setStatus(StatusCode.ERROR);
        } finally {
            span.end();
        }

    }


}
